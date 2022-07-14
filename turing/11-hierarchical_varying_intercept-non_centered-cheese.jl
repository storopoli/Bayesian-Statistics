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
@model function varying_intercept_ncp_regression(X, idx, y;
                                                predictors=size(X, 2),
                                                n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random intercepts
    # usually requires thoughtful specification
    τ ~ truncated(Cauchy(0, 2); lower=0) # group-level SDs intercepts
    zⱼ ~ filldist(Normal(0, 1), n_gr)    # group-level non-centered intercepts
    αⱼ = zⱼ .* τ                         # group-level intercepts

    # likelihood
    y ~ MvNormal(α .+ αⱼ[idx] .+ X * β, σ^2 * I)
    return(; y, α, β, σ, zⱼ, αⱼ, τ)
end

# instantiate the model
model = varying_intercept_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.0226    1.2264     0.0137    0.0368   1257.4709    1.0034       19.4902
#        β[1]    0.3089    1.0787     0.0121    0.0251   1890.3819    1.0020       29.3001
#        β[2]   -1.2455    1.0778     0.0121    0.0245   1904.7803    1.0020       29.5232
#        β[3]    0.7189    1.0779     0.0121    0.0249   1889.2430    1.0020       29.2824
#        β[4]    0.0952    1.0800     0.0121    0.0249   1895.8296    1.0019       29.3845
#           σ    0.6053    0.0340     0.0004    0.0006   3309.7791    1.0036       51.3001
#           τ    1.1426    0.8996     0.0101    0.0557    127.3596    1.0366        1.9740
#       zⱼ[1]    0.4668    0.7363     0.0082    0.0194   1672.4779    1.0033       25.9227
#       zⱼ[2]   -0.4371    0.7357     0.0082    0.0163   2102.1842    1.0008       32.5829
