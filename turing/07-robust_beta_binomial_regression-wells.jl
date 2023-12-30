using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra
using LazyArrays

# logistic function
using StatsFuns: logistic

# reproducibility
using Random: seed!

seed!(123)

# load data
wells = CSV.read("datasets/wells.csv", DataFrame)

# define data matrix X and standardize
X = Matrix(select(wells, Not(:switch)))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = wells[:, :switch]

# define alternate parameterizations
function BetaBinomial2(n, μ, ϕ)
    α = μ * ϕ
    β = (1 - μ) * ϕ
    α = α > 0 ? α : 1e-4 # numerical stability
    β = β > 0 ? β : 1e-4 # numerical stability

    return BetaBinomial(n, α, β)
end

# define the model
@model function beta_binomial_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    ϕ ~ Exponential(1)

    # likelihood
    p̂ = logistic.(α .+ X * β)
    y ~ arraydist(LazyArray(@~ BetaBinomial2.(1, p̂, ϕ)))
    # you could also do BetaBinomial2.(n, p̂, ϕ) if you can group the successes
    return (; y, α, β, p̂, ϕ)
end

# instantiate the model
model = beta_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.3373    0.0394     0.0006    0.0006   5610.8988    0.9992       75.4224
#         β[1]    0.5203    0.0458     0.0007    0.0006   5412.8138    0.9994       72.7597
#         β[2]   -0.3456    0.0398     0.0006    0.0005   5275.5706    0.9997       70.9149
#         β[3]   -0.0614    0.0388     0.0006    0.0005   4602.2511    0.9993       61.8640
#         β[4]    0.1709    0.0386     0.0006    0.0006   5515.4004    1.0010       74.1387
#            ϕ    0.9983    1.0268     0.0162    0.0143   4096.5605    0.9998       55.0665
