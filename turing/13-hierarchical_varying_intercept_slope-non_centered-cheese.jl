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
    n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τₐ ~ truncated(Cauchy(0, 2); lower=0)                 # group-level SDs intercepts
    τᵦ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr) # group-level SDs slopes
    zⱼ ~ filldist(Normal(0, 1), n_gr)                     # group-level non-centered intercepts
    Zⱼ ~ filldist(Normal(0, 1), predictors, n_gr)         # group-level non-centered slopes
    αⱼ = zⱼ .* τₐ                                         # group-level intercepts
    βⱼ = Zⱼ * τᵦ                                          # group-level slopes

    # likelihood
    y ~ MvNormal(α .+ αⱼ[idx] .+ X * β .+ X * βⱼ, σ^2 * I)
    return (; y, α, β, σ, αⱼ, βⱼ, τₐ, τᵦ)
end

# instantiate the model
model = varying_intercept_slope_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.0376    1.4924     0.0236    0.0356   1828.8766    1.0001        7.1727
#         β[1]    0.2126    1.7060     0.0270    0.0327   2452.9311    1.0010        9.6202
#         β[2]   -0.8785    1.7721     0.0280    0.0420   2008.1664    1.0022        7.8759
#         β[3]    0.4784    1.7245     0.0273    0.0371   2375.0523    0.9999        9.3148
#         β[4]    0.0305    1.7271     0.0273    0.0428   2562.7974    1.0009       10.0511
#            σ    0.6044    0.0354     0.0006    0.0005   5767.3723    0.9998       22.6193
#           τₐ    1.2636    1.0990     0.0174    0.0260   1985.5495    1.0007        7.7872
#        τᵦ[1]    1.1623    1.0491     0.0166    0.0229   2107.2728    1.0019        8.2646
#        τᵦ[2]    1.1962    1.1404     0.0180    0.0254   2579.2408    1.0012       10.1156
#        zⱼ[1]    0.4170    0.7249     0.0115    0.0125   2561.4446    1.0002       10.0458
#        zⱼ[2]   -0.4527    0.7205     0.0114    0.0136   2394.4228    0.9998        9.3908
#      Zⱼ[1,1]    0.0472    0.9288     0.0147    0.0126   4259.1193    0.9995       16.7040
#      Zⱼ[2,1]   -0.1106    0.9487     0.0150    0.0177   3787.4435    0.9998       14.8541
#      Zⱼ[3,1]    0.0697    0.9308     0.0147    0.0147   4140.7522    0.9999       16.2398
#      Zⱼ[4,1]    0.0162    0.9265     0.0146    0.0156   4548.3760    1.0007       17.8384
#      Zⱼ[1,2]    0.0267    0.9285     0.0147    0.0121   4141.3169    0.9994       16.2420
#      Zⱼ[2,2]   -0.1216    0.9275     0.0147    0.0144   4136.9234    1.0011       16.2248
#      Zⱼ[3,2]    0.0944    0.9449     0.0149    0.0155   3807.8555    1.0003       14.9342
#      Zⱼ[4,2]    0.0224    0.9345     0.0148    0.0107   4272.2774    0.9999       16.7556
