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
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.0287    1.4682     0.0164    0.0342   2335.9927    1.0044        6.2867
#        β[1]    0.2073    1.6886     0.0189    0.0481    851.8920    1.0083        2.2927
#        β[2]   -0.9169    1.7691     0.0198    0.0545   1564.2228    1.0018        4.2097
#        β[3]    0.5521    1.6923     0.0189    0.0406   2033.6159    1.0041        5.4730
#        β[4]    0.0520    1.6578     0.0185    0.0317   2656.6088    1.0012        7.1496
#           σ    0.6050    0.0335     0.0004    0.0005   6690.8790    1.0007       18.0068
#          τₐ    1.1694    0.9932     0.0111    0.0239   2001.6113    1.0006        5.3868
#       τᵦ[1]    1.1845    1.0763     0.0120    0.0524    185.3298    1.0169        0.4988
#       τᵦ[2]    1.1789    1.0348     0.0116    0.0501    230.7690    1.0117        0.6211
#       zⱼ[1]    0.4331    0.7337     0.0082    0.0206   1365.9734    1.0003        3.6762
#       zⱼ[2]   -0.4990    0.7288     0.0081    0.0155   2467.1344    1.0042        6.6397
#     Zⱼ[1,1]    0.0260    0.9220     0.0103    0.0187   3700.1040    1.0007        9.9579
#     Zⱼ[2,1]   -0.1196    0.9274     0.0104    0.0166   4509.6575    1.0021       12.1366
#     Zⱼ[3,1]    0.0892    0.9348     0.0105    0.0183   3817.6974    1.0016       10.2744
#     Zⱼ[4,1]    0.0117    0.8982     0.0100    0.0177   3596.6601    1.0001        9.6795
#     Zⱼ[1,2]    0.0521    0.8920     0.0100    0.0166   4591.6775    1.0014       12.3573
#     Zⱼ[2,2]   -0.0678    0.9468     0.0106    0.0229   1268.3512    1.0044        3.4134
#     Zⱼ[3,2]    0.0474    0.9212     0.0103    0.0161   3517.5508    1.0019        9.4666
#     Zⱼ[4,2]    0.0265    0.9311     0.0104    0.0200   1942.1012    1.0023        5.2267
