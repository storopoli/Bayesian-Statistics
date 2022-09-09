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
    τₐ ~ truncated(Cauchy(0, 2); lower=0)                                            # group-level SDs intercepts
    τᵦ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr)                            # group-level SDs slopes
    αⱼ ~ filldist(Normal(0, τₐ), n_gr)                                               # group-level intercepts
    βⱼ ~ arraydist([MvNormal(Diagonal(fill(τᵦ[j], predictors) .^ 2)) for j in 1:n_gr]) # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + αⱼ[idx[i]] + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
    return (; y, α, β, σ, αⱼ, βⱼ, τₐ, τᵦ)
end

# instantiate the model
model = varying_intercept_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.0875    1.3335     0.0211    0.0489    834.7319    1.0082        0.6666
#         β[1]    0.2909    1.1051     0.0175    0.0342    963.2325    1.0027        0.7692
#         β[2]   -1.2458    1.1020     0.0174    0.0332    976.2196    1.0022        0.7796
#         β[3]    0.7139    1.1056     0.0175    0.0341    942.2414    1.0025        0.7524
#         β[4]    0.0868    1.1011     0.0174    0.0338    973.5747    1.0027        0.7775
#            σ    0.6062    0.0356     0.0006    0.0007   2344.5009    0.9994        1.8723
#           τₐ    1.2158    1.3031     0.0206    0.0387   1197.0380    1.0007        0.9559
#        τᵦ[1]    0.2944    0.3594     0.0057    0.0156    420.7072    1.0038        0.3360
#        τᵦ[2]    0.2903    0.3543     0.0056    0.0144    476.7120    1.0048        0.3807
#        αⱼ[1]    0.2279    0.9283     0.0147    0.0361    888.0507    1.0082        0.7092
#        αⱼ[2]   -0.3256    0.9334     0.0148    0.0375    744.1440    1.0113        0.5943
#      βⱼ[1,1]    0.0714    0.2914     0.0046    0.0086   1068.5540    1.0032        0.8533
#      βⱼ[2,1]   -0.0151    0.2755     0.0044    0.0064   1753.3251    1.0026        1.4002
#      βⱼ[3,1]    0.0724    0.2931     0.0046    0.0079   1369.8074    1.0007        1.0939
#      βⱼ[4,1]    0.0113    0.2747     0.0043    0.0071   1816.2856    1.0022        1.4504
#      βⱼ[1,2]   -0.0564    0.3000     0.0047    0.0091   1093.9136    1.0012        0.8736
#      βⱼ[2,2]   -0.0040    0.2822     0.0045    0.0084   1045.0611    1.0013        0.8346
#      βⱼ[3,2]   -0.0731    0.2942     0.0047    0.0088    984.8319    1.0020        0.7865
#      βⱼ[4,2]   -0.0094    0.2900     0.0046    0.0078   1330.4155    1.0002        1.0624
