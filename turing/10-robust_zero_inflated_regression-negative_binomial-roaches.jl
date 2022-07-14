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
@model function zero_inflated_negative_binomial_regression(X,  y; predictors=size(X, 2), N=size(X, 1))
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
    return(; y, α, β, γ, ϕ)
end

# instantiate the model
model = zero_inflated_negative_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    2.8276    0.0762     0.0009    0.0008    9670.1381    0.9996      213.9837
#        β[1]    0.9534    0.1160     0.0013    0.0012    8532.2489    0.9998      188.8042
#        β[2]   -0.3696    0.0779     0.0009    0.0008   10404.6173    1.0001      230.2365
#        β[3]   -0.1548    0.0781     0.0009    0.0007   10702.4068    0.9996      236.8261
#        β[4]    0.1453    0.1197     0.0013    0.0013    9770.7302    0.9998      216.2096
#           γ    0.2656    0.0235     0.0003    0.0002   10083.4400    0.9997      223.1294
#          ϕ⁻    1.4085    0.0808     0.0009    0.0008   11352.8432    1.0003      251.2191
