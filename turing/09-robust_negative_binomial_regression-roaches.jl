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

# alternative parameterization
function NegativeBinomial2(μ, ϕ)
    p = 1 / (1 + μ / ϕ)
    p = p > 0 ? p : 1e-4 # numerical stability
    r = ϕ
    return NegativeBinomial(r, p)
end

# define the model
@model function negative_binomial_regression(X,  y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    ϕ⁻ ~ Gamma(0.01, 0.01)
    ϕ = 1 / ϕ⁻

    # likelihood
    y ~ arraydist(LazyArray(@~ NegativeBinomial2.(exp.(α .+ X * β), ϕ)))
    return(; y, α, β, ϕ)
end

# instantiate the model
model = negative_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    2.8260    0.0759     0.0008    0.0008    9864.8871    1.0000      261.3561
#        β[1]    0.9536    0.1148     0.0013    0.0012    8856.1048    1.0006      234.6299
#        β[2]   -0.3712    0.0773     0.0009    0.0007    9403.3178    0.9999      249.1275
#        β[3]   -0.1538    0.0760     0.0008    0.0007   11360.4621    0.9999      300.9793
#        β[4]    0.1459    0.1168     0.0013    0.0011    9233.2377    1.0000      244.6215
#          ϕ⁻    1.4091    0.0787     0.0009    0.0009    9940.3546    1.0001      263.3555
