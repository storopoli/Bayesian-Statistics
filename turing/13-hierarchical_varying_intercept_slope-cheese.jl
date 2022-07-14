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
@model function varying_intercept_slope_regression(X, idx, y;
                                                   predictors=size(X, 2),
                                                   N=size(X, 1),
                                                   n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τₐ ~ truncated(Cauchy(0, 2), 0, Inf)                                             # group-level SDs intercepts
    τᵦ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr)                             # group-level SDs slopes
    αⱼ ~ filldist(Normal(0, τₐ), n_gr)                                               # group-level intercepts
    βⱼ ~ arraydist([MvNormal(Diagonal(fill(τᵦ[j], predictors).^2)) for j in 1:n_gr]) # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + αⱼ[idx[i]] + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
    return(; y, α, β, σ, αⱼ, βⱼ, τₐ, τᵦ)
end

# instantiate the model
model = varying_intercept_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.0458    1.3261     0.0148    0.0271   1872.8948    1.0001        1.4972
#        β[1]    0.3076    1.1395     0.0127    0.0250   2135.7621    1.0003        1.7073
#        β[2]   -1.2319    1.1482     0.0128    0.0259   2122.4199    1.0003        1.6966
#        β[3]    0.7170    1.1337     0.0127    0.0253   2174.9444    1.0001        1.7386
#        β[4]    0.0983    1.1368     0.0127    0.0258   2145.9709    1.0003        1.7155
#           σ    0.6064    0.0354     0.0004    0.0004   5142.3324    1.0004        4.1107
#          τₐ    1.2358    1.5086     0.0169    0.0306   2340.3749    1.0001        1.8709
#       τᵦ[1]    0.3348    0.4089     0.0046    0.0131    828.5636    1.0025        0.6623
#       τᵦ[2]    0.3307    0.4063     0.0045    0.0139    784.8512    1.0038        0.6274
#       αⱼ[1]    0.2491    0.9202     0.0103    0.0192   1548.0095    1.0008        1.2375
#       αⱼ[2]   -0.2972    0.9315     0.0104    0.0207   1474.6784    1.0008        1.1788
#     βⱼ[1,1]    0.0765    0.3349     0.0037    0.0066   2127.0421    1.0026        1.7003
#     βⱼ[2,1]   -0.0108    0.3410     0.0038    0.0065   2857.2372    1.0017        2.2840
#     βⱼ[3,1]    0.0898    0.3559     0.0040    0.0068   2114.6274    1.0017        1.6904
#     βⱼ[4,1]    0.0161    0.3259     0.0036    0.0058   2645.5181    1.0012        2.1148
#     βⱼ[1,2]   -0.0600    0.3322     0.0037    0.0059   3336.4956    1.0008        2.6671
#     βⱼ[2,2]   -0.0020    0.3411     0.0038    0.0056   3321.6585    1.0008        2.6553
#     βⱼ[3,2]   -0.0693    0.3443     0.0038    0.0059   3241.3245    1.0005        2.5911
#     βⱼ[4,2]   -0.0039    0.3210     0.0036    0.0055   3284.8138    1.0003        2.6258
