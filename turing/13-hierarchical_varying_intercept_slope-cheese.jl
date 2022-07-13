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
                                                   n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τₐ ~ truncated(Cauchy(0, 2), 0, Inf)                 # group-level SDs intercepts
    τᵦ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr) # group-level SDs slopes
    αⱼ ~ filldist(Normal(0, τₐ), n_gr)                   # group-level intercepts
    βⱼ ~ filldist(Normal(0, 1), predictors, n_gr)        # group-level standard normal slopes

    # likelihood
    y ~ MvNormal(α .+ αⱼ[idx] .+ X * β .+ X * βⱼ * τᵦ , σ^2 * I)
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
#           α   -0.0579    1.4455     0.0162    0.0447   1353.9517    1.0064        6.5925
#        β[1]    0.3397    1.6821     0.0188    0.0585    410.6980    1.0141        1.9997
#        β[2]   -0.9567    1.6425     0.0184    0.0374   2130.3510    1.0015       10.3728
#        β[3]    0.5043    1.6677     0.0186    0.0441   1807.4279    1.0062        8.8005
#        β[4]    0.1114    1.6457     0.0184    0.0334   2394.0956    1.0013       11.6570
#           σ    0.6068    0.0338     0.0004    0.0006   4355.7824    1.0012       21.2085
#          τₐ    1.3402    1.5256     0.0171    0.0449   1317.4419    1.0065        6.4147
#       τᵦ[1]    1.1531    0.9571     0.0107    0.0425    201.4844    1.0213        0.9810
#       τᵦ[2]    1.1511    0.9656     0.0108    0.0425    244.5323    1.0145        1.1906
#       αⱼ[1]    0.3584    0.9408     0.0105    0.0401    427.7176    1.0154        2.0826
#       αⱼ[2]   -0.2642    0.9393     0.0105    0.0397    448.4302    1.0152        2.1834
#     βⱼ[1,1]   -0.0129    0.9162     0.0102    0.0257    734.2627    1.0068        3.5752
#     βⱼ[2,1]   -0.1292    0.8918     0.0100    0.0163   4032.2789    1.0019       19.6334
#     βⱼ[3,1]    0.0937    0.9199     0.0103    0.0242    829.6182    1.0069        4.0394
#     βⱼ[4,1]    0.0619    0.9520     0.0106    0.0340    351.5875    1.0106        1.7119
#     βⱼ[1,2]    0.0537    0.9059     0.0101    0.0163   3360.8206    1.0008       16.3640
#     βⱼ[2,2]   -0.0645    0.9441     0.0106    0.0244   1071.9084    1.0038        5.2192
#     βⱼ[3,2]    0.0519    0.9138     0.0102    0.0210   2171.3556    1.0029       10.5724
#     βⱼ[4,2]   -0.0675    1.0080     0.0113    0.0473    137.0841    1.0352        0.6675
