using Turing
using Bijectors
using CSV
using DataFrames
using LinearAlgebra
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
    cutpoints ~ Bijectors.ordered(filldist(TDist(3) * 5, ncateg - 1))
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    y ~ arraydist([OrderedLogistic(X[i, :] ⋅ β, cutpoints) for i in 1:length(y)])
    return (; y, cutpoints, β)
end

# instantiate the model
model = ordered_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#Summary Statistics
#    parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#        Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#  cutpoints[1]   -1.4140    0.6359     0.0071    0.0092   4165.4455    1.0002      440.5548
#  cutpoints[2]   -0.2446    0.6182     0.0069    0.0089   4330.7124    1.0001      458.0341
#  cutpoints[3]    0.8074    0.6286     0.0070    0.0087   4580.5094    1.0002      484.4537
#          β[1]   -0.0740    0.1184     0.0013    0.0017   5576.9867    1.0000      589.8452
#          β[2]   -0.0727    0.1704     0.0019    0.0022   5732.0269    1.0005      606.2429
