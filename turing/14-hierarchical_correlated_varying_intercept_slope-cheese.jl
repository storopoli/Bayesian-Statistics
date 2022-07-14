# TODO: This model currently does not sample.
# It needs either https://github.com/TuringLang/Turing.jl/issues/1629
# or https://github.com/TuringLang/Bijectors.jl/issues/134
# or https://github.com/JuliaStats/PDMats.jl/issues/132
using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra
using Bijectors

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
# now we are binding a column of 1s as the first column of X
# for the correlated intercepts
insertcols!(cheese, :intercept => fill(1, nrow(cheese)))
X = select(cheese, Cols(:intercept, Between(:cheese_A, :cheese_D))) |> Matrix

# define dependent variable y and standardize
y = cheese[:, :y] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define vector of group memberships idx
idx = cheese[:, :background_int]

# Bijector
b = bijector(LKJ(1, 1.0)) # just a simple LKJ to get the right bijector

# define the model
@model function correlated_varying_intercept_slope_regression(X, idx, y;
                                                              predictors=size(X, 2),
                                                              N=size(X, 1),
                                                              n_gr=length(unique(idx)))
    # priors
    # Turing does not have LKJCholesky yet
    # see: https://github.com/TuringLang/Turing.jl/issues/1629
    #Ω ~ LKJCholesky(predictors, 2.0)
    Ω ~ LKJ(predictors, 2.0)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), predictors) # group-level SDs
    γ ~ filldist(Normal(0, 5), predictors, n_gr)              # matrix of group coefficients
    Z ~ filldist(Normal(0, 1), predictors, n_gr)              # matrix of non-centered group coefficients

    # reconstruct β from Ω and τ
    #β = γ + τ .* Ω.L * Z                                     # Turing does not have LKJCholesky yet
    #Ω_L = b(Ω)'
    #Ω_L = cholesky(Symmetric(Ω)).L
    #β = γ + (τ .* Ω_L) * Z
    β = γ + (τ .* τ') * Ω * Z

    # likelihood
    for i in 1:N
        y[i] ~ Normal(X[i, :] ⋅ β[:, idx[i]], σ)
    end
    return(; y, β, σ, Ω, τ, γ, Z)
end

# instantiate the model
model = correlated_varying_intercept_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
# TODO!
