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
@model function poisson_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    y ~ arraydist(LazyArray(@~ LogPoisson.(α .+ X * β)))
    return (; y, α, β)
end

# instantiate the model
model = poisson_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    2.9810    0.0146     0.0002    0.0002   3951.1294    1.0016      585.2658
#         β[1]    0.4910    0.0066     0.0001    0.0001   4108.0121    1.0006      608.5042
#         β[2]   -0.2521    0.0123     0.0002    0.0002   5078.9666    0.9996      752.3280
#         β[3]   -0.1748    0.0156     0.0002    0.0002   4236.2675    0.9994      627.5022
#         β[4]    0.0516    0.0116     0.0002    0.0002   4171.0393    0.9994      617.8402
