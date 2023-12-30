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
X = Matrix(select(roaches, Not(:y)))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = roaches[:, :y]

# define the model
@model function zero_inflated_poisson_regression(X, y; predictors=size(X, 2), N=size(X, 1))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    γ ~ Beta(1, 1)

    # likelihood
    for n in 1:N
        if y[n] == 0
            Turing.@addlogprob! logpdf(Bernoulli(γ), 0) +
                logpdf(Bernoulli(γ), 1) +
                logpdf(LogPoisson(α + X[n, :] ⋅ β), y[n])
        else
            Turing.@addlogprob! logpdf(Bernoulli(γ), 0) +
                logpdf(LogPoisson(α + X[n, :] ⋅ β), y[n])
        end
    end
    return (; y, α, β, γ)
end

# instantiate the model
model = zero_inflated_poisson_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    2.9809    0.0146     0.0002    0.0002   4564.2668    1.0000      256.9970
#         β[1]    0.4909    0.0068     0.0001    0.0001   4931.4311    0.9996      277.6707
#         β[2]   -0.2524    0.0120     0.0002    0.0002   5241.4828    0.9996      295.1285
#         β[3]   -0.1752    0.0154     0.0002    0.0002   4927.0399    0.9998      277.4234
#         β[4]    0.0513    0.0119     0.0002    0.0002   5229.6487    0.9995      294.4622
#            γ    0.2651    0.0229     0.0004    0.0003   5033.2948    0.9993      283.4062
