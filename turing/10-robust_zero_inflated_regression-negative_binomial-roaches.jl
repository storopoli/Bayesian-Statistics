using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

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
@model function zero_inflated_negative_binomial_regression(X, y; predictors=size(X, 2), N=size(X, 1))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    γ ~ Beta(1, 1)
    ϕ⁻ ~ Gamma(0.01, 0.01)
    ϕ = 1 / ϕ⁻

    # likelihood
    for n in 1:N
        if y[n] == 0
            Turing.@addlogprob! logpdf(Bernoulli(γ), 0) +
                                logpdf(Bernoulli(γ), 1) +
                                logpdf(NegativeBinomial2(exp(α + X[n, :] ⋅ β), ϕ), y[n])
        else
            Turing.@addlogprob! logpdf(Bernoulli(γ), 0) +
                                logpdf(NegativeBinomial2(exp(α + X[n, :] ⋅ β), ϕ), y[n])
        end
    end
    return (; y, α, β, γ, ϕ)
end

# instantiate the model
model = zero_inflated_negative_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    2.8264    0.0742     0.0012    0.0009   6418.9653    0.9996      221.7259
#         β[1]    0.9520    0.1147     0.0018    0.0017   6167.7273    1.0000      213.0476
#         β[2]   -0.3713    0.0766     0.0012    0.0010   6608.4273    0.9998      228.2704
#         β[3]   -0.1569    0.0760     0.0012    0.0009   6441.4946    0.9995      222.5041
#         β[4]    0.1470    0.1203     0.0019    0.0017   5455.6802    1.0002      188.4518
#            γ    0.2654    0.0232     0.0004    0.0003   6129.0029    1.0001      211.7099
#           ϕ⁻    1.4112    0.0804     0.0013    0.0010   6426.0097    0.9994      221.9692
