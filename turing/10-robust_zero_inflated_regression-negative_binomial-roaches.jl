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

    # numerical stability
    if p <= 0
        p = 1e-4
    elseif p > 1
        p = 1.0
    end

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
                                logpdf(NegativeBinomial2(α + X[n, :] ⋅ β, ϕ), y[n])
        else
            Turing.@addlogprob! logpdf(Bernoulli(γ), 0) +
                                logpdf(NegativeBinomial2(α + X[n, :] ⋅ β, ϕ), y[n])
        end
    end
    return(; y, α, β, γ, ϕ)
end

# instantiate the model
model = zero_inflated_negative_binomial_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
# TODO: this model is not working
#  parameters       mean       std   naive_se      mcse       ess      rhat   ess_per_sec
#      Symbol    Float64   Float64    Float64   Float64   Float64   Float64       Float64
#
#           α   -15.0511   30.0401     0.3359    3.1506   16.8077    3.0841        0.0955
#        β[1]     6.3093   14.8544     0.1661    1.5595   16.6091    3.7006        0.0943
#        β[2]    24.5615   47.5034     0.5311    4.9914   16.6773    3.3367        0.0947
#        β[3]     3.9758    6.8270     0.0763    0.7236   16.2720    7.4169        0.0924
#        β[4]     1.4100    2.0867     0.0233    0.2193   17.1930    3.1680        0.0977
#           γ     0.2414    0.0677     0.0008    0.0070   16.8259    4.3579        0.0956
#          ϕ⁻     3.2534    0.6385     0.0071    0.0674   16.2059    9.0365        0.0921
