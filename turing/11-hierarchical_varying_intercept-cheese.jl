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
@model function varying_intercept_regression(X, idx, y;
                                             predictors=size(X, 2),
                                             n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts
    # usually requires thoughtful specification
    τ ~ truncated(Cauchy(0, 2), 0, Inf) # group-level SDs intercepts
    αⱼ ~ filldist(Normal(0, τ), n_gr)   # group-level intercepts

    # likelihood
    y ~ MvNormal(α .+ αⱼ[idx] .+ X * β, σ^2 * I)
    return(; y, α, β, σ, αⱼ, τ)
end

# instantiate the model
model = varying_intercept_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α   -0.0430    1.3279     0.0148    0.0314   1834.7966    1.0006       70.7842
#        β[1]    0.3444    1.0838     0.0121    0.0233   1982.9801    1.0008       76.5009
#        β[2]   -1.2097    1.0836     0.0121    0.0234   1990.0338    1.0008       76.7730
#        β[3]    0.7555    1.0832     0.0121    0.0236   1967.2693    1.0009       75.8948
#        β[4]    0.1327    1.0841     0.0121    0.0235   1988.1098    1.0008       76.6988
#           σ    0.6051    0.0351     0.0004    0.0004   4025.2054    0.9998      155.2874
#           τ    1.3159    1.8645     0.0208    0.0411   1694.1575    1.0024       65.3585
#       αⱼ[1]   -0.2735    0.9540     0.0107    0.0254   1501.9573    1.0019       57.9436
#       αⱼ[2]    0.3490    0.9539     0.0107    0.0253   1510.9866    1.0017       58.2920
