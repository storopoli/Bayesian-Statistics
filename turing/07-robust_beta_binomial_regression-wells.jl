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
X = select(wells, Not(:switch)) |> Matrix
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = wells[:, :switch]

# define alternate parameterizations
BetaBinomial2(n, μ, ϕ) = BetaBinomial(n, μ*ϕ, (1-μ)*ϕ)

# define the model
@model function beta_binomial_regression(X,  y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    ϕ ~ Exponential(1)

    # likelihood
    p̂ = logistic.(α .+ X * β)
    y ~ arraydist(LazyArray(@~ BetaBinomial2.(1, p̂, ϕ)))
    # you could also do BetaBinomial2.(n, p̂, θ) if you can group the successes
    return(; y, α, β, ϕ)
end

# instantiate the model
model = beta_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.3366    0.0383     0.0004    0.0004   8272.7360    1.0005       73.3035
#        β[1]    0.5187    0.0461     0.0005    0.0006   7365.2488    1.0003       65.2624
#        β[2]   -0.3456    0.0400     0.0004    0.0004   7604.7011    1.0002       67.3841
#        β[3]   -0.0615    0.0376     0.0004    0.0004   8252.4562    1.0001       73.1238
#        β[4]    0.1705    0.0377     0.0004    0.0005   7669.6174    1.0002       67.9593
#           ϕ    0.9964    1.0148     0.0113    0.0105   6972.6583    1.0001       61.7837
#
