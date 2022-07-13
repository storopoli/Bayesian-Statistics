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
                                         N=size(X,1),
                                         n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr)                             # group-level SDs slopes
    βⱼ ~ arraydist([MvNormal(Diagonal(fill(τ[j], predictors).^2)) for j in 1:n_gr]) # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
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
#           α    0.0120    1.0714     0.0120    0.0209   2402.9015    1.0008        3.5961
#        β[1]    0.3221    1.1209     0.0125    0.0222   2502.0644    1.0013        3.7445
#        β[2]   -1.1962    1.1273     0.0126    0.0200   2614.6932    1.0004        3.9131
#        β[3]    0.7043    1.1153     0.0125    0.0210   2474.0642    1.0013        3.7026
#        β[4]    0.1114    1.1078     0.0124    0.0194   2558.5036    1.0004        3.8290
#           σ    0.6083    0.0349     0.0004    0.0005   5209.6270    0.9997        7.7966
#        τ[1]    0.6807    0.5446     0.0061    0.0142   1461.2217    1.0017        2.1868
#        τ[2]    0.6698    0.5554     0.0062    0.0131   1738.2249    1.0007        2.6014
#     βⱼ[1,1]    0.3426    0.4845     0.0054    0.0104   2646.5691    1.0005        3.9608
#     βⱼ[2,1]    0.2127    0.4752     0.0053    0.0094   2775.7427    1.0017        4.1541
#     βⱼ[3,1]    0.3898    0.4834     0.0054    0.0112   2238.3910    1.0016        3.3499
#     βⱼ[4,1]    0.2616    0.4790     0.0054    0.0097   2674.8577    1.0003        4.0031
#     βⱼ[1,2]   -0.3318    0.4855     0.0054    0.0106   2556.1696    1.0005        3.8255
#     βⱼ[2,2]   -0.2693    0.4796     0.0054    0.0095   2622.0417    1.0016        3.9241
#     βⱼ[3,2]   -0.3185    0.4821     0.0054    0.0109   2345.4008    1.0014        3.5101
#     βⱼ[4,2]   -0.2559    0.4780     0.0053    0.0093   2671.3866    1.0006        3.9979
