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
roaches = CSV.read("datasets/roaches.csv", DataFrame)

# define data matrix X and standardize
X = select(roaches, Not(:y)) |> Matrix
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = roaches[:, :y]

# define the model
@model function poisson_regression(X,  y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    y ~ arraydist(LazyArray(@~ LogPoisson.(α .+ X * β)))
    return(; y, α, β)
end

# instantiate the model
model = poisson_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    2.9808    0.0145     0.0002    0.0002   7320.0230    1.0003      108.0095
#        β[1]    0.4910    0.0067     0.0001    0.0001   7695.6080    1.0002      113.5514
#        β[2]   -0.2523    0.0126     0.0001    0.0001   8870.7340    1.0002      130.8908
#        β[3]   -0.1752    0.0156     0.0002    0.0002   7876.9316    0.9998      116.2269
#        β[4]    0.0517    0.0116     0.0001    0.0001   7634.0212    1.0002      112.6427
