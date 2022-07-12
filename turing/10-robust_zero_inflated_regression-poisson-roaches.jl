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
@model function zero_inflated_poisson_regression(X,  y; predictors=size(X, 2), N=size(X, 1))
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
    return(; y, α, β, γ)
end

# instantiate the model
model = zero_inflated_poisson_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    2.9806    0.0144     0.0002    0.0001    8990.7467    0.9999      516.5611
#        β[1]    0.4910    0.0068     0.0001    0.0001    9390.3923    0.9997      539.5227
#        β[2]   -0.2526    0.0120     0.0001    0.0001   10290.6609    1.0000      591.2474
#        β[3]   -0.1750    0.0155     0.0002    0.0002    9885.4333    0.9996      567.9651
#        β[4]    0.0514    0.0115     0.0001    0.0001    9468.0040    1.0000      543.9818
#           γ    0.2657    0.0235     0.0003    0.0003   10073.2219    1.0004      578.7545
