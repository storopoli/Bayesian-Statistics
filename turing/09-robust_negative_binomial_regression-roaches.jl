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
X = Matrix(select(roaches, Not(:y)))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = roaches[:, :y]

# alternative parameterization
function NegativeBinomial2(μ, ϕ)
    p = 1 / (1 + μ / ϕ)
    p = p > 0 ? p : 1e-4 # numerical stability
    r = ϕ
    return NegativeBinomial(r, p)
end

# define the model
@model function negative_binomial_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    ϕ⁻ ~ Gamma(0.01, 0.01)
    ϕ = 1 / ϕ⁻

    # likelihood
    y ~ arraydist(LazyArray(@~ NegativeBinomial2.(exp.(α .+ X * β), ϕ)))
    return (; y, α, β, ϕ)
end

# instantiate the model
model = negative_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    2.8263    0.0776     0.0012    0.0011   5151.7518    1.0000      263.2205
#         β[1]    0.9501    0.1142     0.0018    0.0015   5775.2010    0.9994      295.0746
#         β[2]   -0.3690    0.0754     0.0012    0.0011   5572.7346    1.0007      284.7300
#         β[3]   -0.1568    0.0764     0.0012    0.0009   5676.4081    0.9994      290.0270
#         β[4]    0.1454    0.1212     0.0019    0.0020   4262.6961    0.9996      217.7956
#           ϕ⁻    1.4097    0.0791     0.0013    0.0011   5411.2014    0.9999      276.4767
