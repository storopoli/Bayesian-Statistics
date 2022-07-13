using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
cheese = CSV.read("datasets/cheese.csv", DataFrame)

# create dummy vars
for c in unique(cheese[:, :cheese])
    cheese[:, "cheese_$c"] = ifelse.(cheese[:, :cheese] .== c, 1, 0)
end

# create int idx
cheese[:, :background_int] = map(cheese[:, :background]) do b
    b == "urban" ? 1 :
    b == "rural" ? 2 : missing
end

# define data matrix X
X = select(cheese, Between(:cheese_A, :cheese_D)) |> Matrix

# define dependent variable y and standardize
y = cheese[:, :y] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define vector of group memberships idx
idx = cheese[:, :background_int]

# define the model
@model function varying_slope_regression(X, idx, y;
                                         predictors=size(X, 2),
                                         n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr) # group-level SDs slopes
    βⱼ ~ filldist(Normal(0, 1), predictors, n_gr)       # group-level standard normal slopes

    # likelihood
    y ~ MvNormal(α .+ X * β .+ X * βⱼ * τ , σ^2 * I)
    return(; y, α, β, σ, βⱼ, τ)
end

# instantiate the model
model = varying_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α   -0.2197    1.4849     0.0166    0.0900     60.6161    1.1353        0.3981
#        β[1]    0.4320    1.7433     0.0195    0.0889    110.2260    1.0672        0.7240
#        β[2]   -0.6424    1.7545     0.0196    0.0945     77.7058    1.1058        0.5104
#        β[3]    0.2307    1.7425     0.0195    0.0969    111.4303    1.0652        0.7319
#        β[4]   -0.0134    1.6014     0.0179    0.0609    625.0772    1.0038        4.1055
#           σ    0.6866    0.0387     0.0004    0.0012    411.0795    1.0185        2.6999
#        τ[1]    1.1356    0.8965     0.0100    0.0496     98.3928    1.0678        0.6462
#        τ[2]    1.4084    1.4182     0.0159    0.1233     27.5102    1.3836        0.1807
#     βⱼ[1,1]   -0.0831    0.9234     0.0103    0.0331    199.4840    1.0390        1.3102
#     βⱼ[2,1]   -0.1481    0.8893     0.0099    0.0259    560.8603    1.0138        3.6837
#     βⱼ[3,1]    0.0939    0.9301     0.0104    0.0396    437.6971    1.0127        2.8748
#     βⱼ[4,1]    0.0918    0.9865     0.0110    0.0448    171.1355    1.0413        1.1240
#     βⱼ[1,2]    0.0830    0.9167     0.0102    0.0281    749.4418    1.0118        4.9223
#     βⱼ[2,2]   -0.0895    0.8700     0.0097    0.0175   2795.3036    1.0051       18.3594
#     βⱼ[3,2]    0.1948    0.9267     0.0104    0.0373    160.6508    1.0466        1.0551
#     βⱼ[4,2]    0.0123    0.9050     0.0101    0.0287    921.0001    1.0030        6.0491
