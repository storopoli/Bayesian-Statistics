using Turing
using Bijectors
using CSV
using DataFrames
using LinearAlgebra
using LazyArrays
using CategoricalArrays

# reproducibility
using Random: seed!

seed!(123)

# load data
esoph = CSV.read("datasets/esoph.csv", DataFrame)

# define data matrix X and make numerical
transform!(
    esoph,
    :agegp =>
        x -> categorical(
            x; levels=["25-34", "35-44", "45-54", "55-64", "65-74", "75+"], ordered=true
        ),
    :alcgp =>
        x -> categorical(x; levels=["0-39g/day", "40-79", "80-119", "120+"], ordered=true),
    :tobgp =>
        x -> categorical(x; levels=["0-9g/day", "10-19", "20-29", "30+"], ordered=true);
    renamecols=false,
)
transform!(esoph, [:agegp, :alcgp, :tobgp] .=> ByRow(levelcode); renamecols=false)

X = Matrix(select(esoph, [:agegp, :alcgp]))

# define dependent variable y
y = esoph[:, :tobgp]

# define the model
@model function ordered_regression(X, y; predictors=size(X, 2), ncateg=maximum(y))
    # priors
    cutpoints ~ Bijectors.ordered(filldist(TDist(3) * 5, ncateg-1))
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    linear_pred = X * β
    #y ~ arraydist(LazyArray(@~ OrderedLogistic.(X * β, cutpoints)))
    y ~ arraydist(LazyArray(@~ OrderedLogistic.(linear_pred, cutpoints)))
    return (; y, cutpoints, β)
end

# define the model
@model function ordered_regression(X, y; predictors=size(X, 2), ncateg=maximum(y))
    # priors
    cutpoints ~ Bijectors.ordered(filldist(TDist(3) * 5, ncateg-1))
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    linear_pred = X * β
    for i in eachindex(y)
        y[i] ~ OrderedLogistic(linear_pred[i], cutpoints)
    end
    return (; y, cutpoints, β)
end

# instantiate the model
model = ordered_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    0.3370    0.0386     0.0004    0.0003   14018.6701    0.9999      218.7341
#        β[1]    0.5176    0.0468     0.0005    0.0004   12269.1734    0.9998      191.4366
#        β[2]   -0.3453    0.0407     0.0005    0.0003   13928.3031    0.9997      217.3241
#        β[3]   -0.0615    0.0377     0.0004    0.0003   14014.8302    0.9999      218.6742
#        β[4]    0.1703    0.0383     0.0004    0.0003   13054.2746    0.9999      203.6866
