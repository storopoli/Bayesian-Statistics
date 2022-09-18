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
@model function varying_intercept_slope_ncp_regression(X, idx, y;
    predictors=size(X, 2),
    N=size(X, 1),
    n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τₐ ~ truncated(Cauchy(0, 2); lower=0)                                     # group-level SDs intercepts
    τᵦ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr)                     # group-level SDs slopes
    zⱼ ~ filldist(Normal(0, 1), n_gr)                                         # group-level non-centered intercepts
    Zⱼ ~ arraydist([MvNormal(Diagonal(fill(1, predictors))) for j in 1:n_gr]) # group-level non-centered slopes
    αⱼ = zⱼ .* τₐ                                                             # group-level intercepts
    βⱼ = Zⱼ .* τᵦ'                                                            # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + αⱼ[idx[i]] + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
    return (; y, α, β, σ, αⱼ, βⱼ, τₐ, τᵦ)
end

# instantiate the model
model = varying_intercept_slope_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64 
#            α   -0.0583    1.2332     0.0195    0.0288   1065.3416    1.0029        1.4347
#         β[1]    0.3624    1.0996     0.0174    0.0283   1018.6661    1.0027        1.3718
#         β[2]   -1.1883    1.1055     0.0175    0.0325    902.9370    1.0033        1.2160
#         β[3]    0.7561    1.1120     0.0176    0.0327    883.3827    1.0038        1.1896
#         β[4]    0.1449    1.1133     0.0176    0.0326    901.9416    1.0034        1.2146
#            σ    0.6074    0.0347     0.0005    0.0006   3363.1348    0.9999        4.5291
#           τₐ    1.1173    0.9748     0.0154    0.0325    978.8376    1.0069        1.3182
#        τᵦ[1]    0.2957    0.3402     0.0054    0.0072   1671.8171    1.0015        2.2514
#        τᵦ[2]    0.3096    0.3777     0.0060    0.0092   1610.3047    1.0015        2.1686
#        zⱼ[1]    0.4421    0.7592     0.0120    0.0144   2004.5090    1.0005        2.6994
#        zⱼ[2]   -0.3747    0.7509     0.0119    0.0184   1875.8266    1.0007        2.5261
#      Zⱼ[1,1]    0.1278    0.8577     0.0136    0.0198   2214.3619    1.0019        2.9820
#      Zⱼ[2,1]   -0.1015    0.8608     0.0136    0.0168   3406.5432    1.0016        4.5875
#      Zⱼ[3,1]    0.2079    0.8545     0.0135    0.0172   2618.9795    1.0003        3.5269
#      Zⱼ[4,1]   -0.0293    0.8523     0.0135    0.0175   2931.1685    1.0009        3.9474
#      Zⱼ[1,2]   -0.1776    0.8880     0.0140    0.0207   1897.0453    1.0031        2.5547
#      Zⱼ[2,2]    0.0897    0.8659     0.0137    0.0161   3318.3082    1.0001        4.4687
#      Zⱼ[3,2]   -0.1881    0.8786     0.0139    0.0133   3239.1210    0.9995        4.3621
#      Zⱼ[4,2]    0.0179    0.8584     0.0136    0.0131   3335.7124    0.9991        4.4921