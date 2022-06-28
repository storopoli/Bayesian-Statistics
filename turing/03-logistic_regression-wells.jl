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
X = select(wells, Not(:switch)) |> Matrix
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = wells[:, :switch]

# define the model
@model function logistic_regression(X,  y; predictors=size(X, 2))
    # priors
    α ~ Normal(0, 2.5)
    β ~ filldist(TDist(3), predictors)

    # likelihood
    y ~ arraydist(LazyArray(@~ BernoulliLogit.(α .+ X * β)))
    # you could also do BinomialLogit(n, logitp) if you can group the successes
    return(; y, α, β)
end

# instantiate the model
model = logistic_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    0.3370    0.0386     0.0004    0.0003   14018.6701    0.9999      218.7341
#        β[1]    0.5176    0.0468     0.0005    0.0004   12269.1734    0.9998      191.4366
#        β[2]   -0.3453    0.0407     0.0005    0.0003   13928.3031    0.9997      217.3241
#        β[3]   -0.0615    0.0377     0.0004    0.0003   14014.8302    0.9999      218.6742
#        β[4]    0.1703    0.0383     0.0004    0.0003   13054.2746    0.9999      203.6866
