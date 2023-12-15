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
    τ ~ truncated(Cauchy(0, 2); lower=0) # group-level SDs intercepts
    αⱼ ~ filldist(Normal(α, τ), n_gr)    # group-level intercepts

    # likelihood
    y ~ MvNormal(αⱼ[idx] .+ X * β, σ^2 * I)
    return (; y, α, β, σ, αⱼ, τ)
end

# instantiate the model
model = varying_intercept_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64 
#            α   -0.0343    1.2325     0.0195    0.0400    840.3578    1.0035       12.5883
#         β[1]    0.3180    1.1007     0.0174    0.0402    768.4519    1.0079       11.5112
#         β[2]   -1.2338    1.1024     0.0174    0.0400    772.9007    1.0079       11.5778
#         β[3]    0.7282    1.1012     0.0174    0.0403    763.4832    1.0080       11.4368
#         β[4]    0.1093    1.0999     0.0174    0.0403    767.0231    1.0082       11.4898
#            σ    0.6057    0.0344     0.0005    0.0007   2104.5974    1.0007       31.5262
#            τ    1.2525    1.3452     0.0213    0.0416   1032.7507    1.0041       15.4703
#        αⱼ[1]    0.3647    0.8280     0.0131    0.0274    945.8124    1.0024       14.1680
#        αⱼ[2]   -0.2588    0.8269     0.0131    0.0274    946.0136    1.0023       14.1710
