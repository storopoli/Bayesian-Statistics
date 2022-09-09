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
@model function varying_slope_ncp_regression(X, idx, y;
    predictors=size(X, 2),
    n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr) # group-level SDs slopes
    Zⱼ ~ filldist(Normal(0, 1), predictors, n_gr)        # group-level non-centered slopes
    βⱼ = Zⱼ * τ                                          # group-level slopes

    # likelihood
    y ~ MvNormal(α .+ X * β .+ X * βⱼ, σ^2 * I)
    return (; y, α, β, σ, βⱼ, τ)
end

# instantiate the model
model = varying_slope_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α   -0.0602    1.3619     0.0215    0.0436    810.7149    1.0101        5.5228
#         β[1]    0.3094    1.7628     0.0279    0.0620    581.4114    1.0076        3.9607
#         β[2]   -0.9224    1.9455     0.0308    0.0924    276.7468    1.0129        1.8853
#         β[3]    0.6479    1.9482     0.0308    0.0921    223.5765    1.0133        1.5231
#         β[4]    0.0287    1.7989     0.0284    0.0758    328.7172    1.0068        2.2393
#            σ    0.6830    0.0396     0.0006    0.0014    375.1380    1.0167        2.5555
#         τ[1]    1.2139    1.0288     0.0163    0.0570    190.7566    1.0200        1.2995
#         τ[2]    1.2289    1.0320     0.0163    0.0475    202.2815    1.0164        1.3780
#      Zⱼ[1,1]    0.0016    0.8961     0.0142    0.0180   3185.7126    1.0008       21.7019
#      Zⱼ[2,1]   -0.0693    0.9454     0.0149    0.0320    553.8784    1.0069        3.7732
#      Zⱼ[3,1]    0.1326    0.9157     0.0145    0.0211   1597.2254    1.0050       10.8807
#      Zⱼ[4,1]    0.0331    0.9140     0.0145    0.0256   1034.7876    1.0024        7.0492
#      Zⱼ[1,2]    0.0471    0.9199     0.0145    0.0307    680.6900    1.0083        4.6370
#      Zⱼ[2,2]   -0.1583    0.9520     0.0151    0.0297    839.4767    1.0070        5.7187
#      Zⱼ[3,2]    0.0243    0.9588     0.0152    0.0285    769.7549    1.0052        5.2438
#      Zⱼ[4,2]    0.0124    0.9194     0.0145    0.0235   1103.7476    1.0049        7.5190
