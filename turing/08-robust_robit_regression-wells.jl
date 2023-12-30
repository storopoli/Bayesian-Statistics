using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra
using LazyArrays

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

# define the model
# setting ν to 4 since we have a lot of parameters
# and Turing v0.29 samples slower than Stan
@model function robit_regression(X, y; predictors=size(X, 2), N=size(X, 1), ν=4)
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    ϵ ~ filldist(TDist(ν), N)
    y ~ arraydist(LazyArray(@~ BernoulliLogit.(α .+ X * β .+ ϵ)))
    return (; y, α, β)
end

# instantiate the model
model = robit_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))
