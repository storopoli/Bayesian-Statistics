using Turing
using CSV
using DataFrames
using LinearAlgebra
using CategoricalArrays
using Bijectors: transformed, OrderedBijector
using DataFrames: transform!

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
    cutpoints ~ transformed(filldist(TDist(3) * 5, ncateg - 1), OrderedBijector())
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    y ~ arraydist([OrderedLogistic(X[i, :] ⋅ β, cutpoints) for i in 1:length(y)])
    return (; y, cutpoints, β)
end

# instantiate the model
model = ordered_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#     parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#         Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#   cutpoints[1]   -1.4154    0.6353     0.0100    0.0135   1799.8496    1.0021       78.8820
#   cutpoints[2]   -0.2437    0.6054     0.0096    0.0127   1949.7758    1.0025       85.4528
#   cutpoints[3]    0.8066    0.6168     0.0098    0.0122   2152.8488    1.0018       94.3528
#           β[1]   -0.0733    0.1151     0.0018    0.0022   2636.8129    1.0012      115.5635
#           β[2]   -0.0735    0.1719     0.0027    0.0029   2440.2544    1.0007      106.9490
