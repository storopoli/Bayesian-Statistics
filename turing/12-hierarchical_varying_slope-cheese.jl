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
    N=size(X, 1),
    n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr)                             # group-level SDs slopes
    βⱼ ~ arraydist([MvNormal(Diagonal(fill(τ[j], predictors) .^ 2)) for j in 1:n_gr])  # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
    return (; y, α, β, σ, βⱼ, τ)
end

# instantiate the model
model = varying_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.0437    1.0995     0.0174    0.0334   1087.7242    1.0058        1.2794
#         β[1]    0.2502    1.1344     0.0179    0.0335   1185.0469    1.0038        1.3938
#         β[2]   -1.2413    1.1361     0.0180    0.0335   1152.7612    1.0049        1.3559
#         β[3]    0.6729    1.1137     0.0176    0.0346   1055.1768    1.0032        1.2411
#         β[4]    0.0597    1.1145     0.0176    0.0329   1228.1565    1.0046        1.4445
#            σ    0.6073    0.0345     0.0005    0.0008   2371.1387    1.0010        2.7889
#         τ[1]    0.6481    0.4984     0.0079    0.0174    728.6358    1.0012        0.8570
#         τ[2]    0.6231    0.5212     0.0082    0.0226    601.6737    1.0016        0.7077
#      βⱼ[1,1]    0.3795    0.4764     0.0075    0.0131   1108.7295    1.0006        1.3041
#      βⱼ[2,1]    0.2257    0.4087     0.0065    0.0101   1532.1411    1.0005        1.8021
#      βⱼ[3,1]    0.3822    0.4379     0.0069    0.0144    968.8675    1.0026        1.1396
#      βⱼ[4,1]    0.2823    0.4291     0.0068    0.0111   1409.2813    1.0011        1.6576
#      βⱼ[1,2]   -0.2962    0.4737     0.0075    0.0139   1033.3318    1.0008        1.2154
#      βⱼ[2,2]   -0.2548    0.4108     0.0065    0.0113   1356.0370    1.0000        1.5949
#      βⱼ[3,2]   -0.3212    0.4324     0.0068    0.0142    953.0274    1.0027        1.1209
#      βⱼ[4,2]   -0.2353    0.4288     0.0068    0.0121   1375.0647    1.0007        1.6173
