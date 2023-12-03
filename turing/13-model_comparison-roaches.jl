# FIXME: ParetoSmooth is not compatible with Turing 0.29
using Pkg
Pkg.compat("Turing", "0.22")
Pkg.compat("Bijectors", "0.10")
Pkg.compat("StatsBase", "0.33")
Pkg.add("ParetoSmooth")

using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra
using LazyArrays
using ParetoSmooth

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

# define models
# for ParetoSmooth loo we need to remove
# any arraydist or filldist in the likelihood
@model function poisson_regression(X, y; predictors=size(X, 2))
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    for i in eachindex(y)
        y[i] ~ LogPoisson(α + X[i, :] ⋅ β)
    end
    return (; y, α, β)
end
@model function negative_binomial_regression(X, y; predictors=size(X, 2))
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    ϕ⁻ ~ Gamma(0.01, 0.01)
    ϕ = 1 / ϕ⁻
    for i in eachindex(y)
        y[i] ~ NegativeBinomial2(exp(α + X[i, :] ⋅ β), ϕ)
    end
    return (; y, α, β, ϕ)
end

# instantiate models
model_poisson = poisson_regression(X, y)
model_negative_binomial = negative_binomial_regression(X, y)

# sample models with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn_poisson = sample(model_poisson, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
chn_negative_binomial = sample(model_negative_binomial, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# get the LOOs
loo_poisson = loo(model_poisson, chn_poisson)
loo_negative_binomial = loo(model_negative_binomial, chn_negative_binomial)

# LOO compare
comparison = loo_compare((;
    Poisson=loo_poisson,
    NegativeBinomial=loo_negative_binomial
)
)

# Results
#┌──────────────────┬──────────┬────────┬────────┐
#│                  │  cv_elpd │ cv_avg │ weight │
#├──────────────────┼──────────┼────────┼────────┤
#│ NegativeBinomial │     0.00 │   0.00 │   1.00 │
#│          Poisson │ -5295.06 │ -20.21 │   0.00 │
#└──────────────────┴──────────┴────────┴────────┘
