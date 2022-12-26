# TODO: This model currently does not sample.
# It needs either https://github.com/TuringLang/Turing.jl/issues/1629
# or https://github.com/TuringLang/Bijectors.jl/issues/134
# or https://github.com/JuliaStats/PDMats.jl/issues/132
# Currently it uses a workaround with TransformVariables.jl and PDMats.jl thanks to @sethaxen
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
# now we are binding a column of 1s as the first column of X
# for the correlated intercepts
insertcols!(cheese, :intercept => fill(1, nrow(cheese)))
X = select(cheese, Cols(:intercept, Between(:cheese_A, :cheese_D))) |> Matrix

# define dependent variable y and standardize
y = cheese[:, :y] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define vector of group memberships idx
idx = cheese[:, :background_int]

# define the model
# @model function correlated_varying_intercept_slope_regression(X, idx, y;
#                                                               predictors=size(X, 2),
#                                                               N=size(X, 1),
#                                                               n_gr=length(unique(idx)))
#     # priors
#     Ω ~ LKJCholesky(predictors, 2.0)
#     σ ~ Exponential(1)

#     # prior for variance of random intercepts and slopes
#     # usually requires thoughtful specification
#     τ ~ filldist(truncated(Cauchy(0, 2); lower=0), predictors) # group-level SDs
#     γ ~ filldist(Normal(0, 5), predictors, n_gr)               # matrix of group coefficients
#     Z ~ filldist(Normal(0, 1), predictors, n_gr)               # matrix of non-centered group coefficients

#     # reconstruct β from Ω and τ
#     β = γ + τ .* Ω.L * Z

#     # likelihood
#     for i in 1:N
#         y[i] ~ Normal(X[i, :] ⋅ β[:, idx[i]], σ)
#     end
#     return(; y, β, σ, Ω, τ, γ, Z)
# end

# workaround with TransformVariables.jl and PDMats.jl
using TransformVariables
using PDMats

@model function correlated_varying_intercept_slope_regression(X, idx, y;
    predictors=size(X, 2),
    N=size(X, 1),
    n_gr=length(unique(idx)))
    # workaround
    trans = CorrCholeskyFactor(predictors)
    L_tilde ~ filldist(Flat(), dimension(trans))
    L_U, logdetJ = transform_and_logjac(trans, L_tilde)
    Turing.@addlogprob! logpdf(LKJCholesky(predictors, 2.0), Cholesky(L_U)) + logdetJ

    # priors
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), predictors) # group-level SDs
    γ ~ filldist(Normal(0, 5), predictors, n_gr)               # matrix of group coefficients
    Z ~ filldist(Normal(0, 1), predictors, n_gr)               # matrix of non-centered group coefficients

    # reconstruct β from Ω and τ
    Ω_L = LowerTriangular(collect(τ .* L_U'))                  # collect is necessary for ReverseDiff for some reason
    Ω = PDMat(Cholesky(Ω_L))
    β = γ + Ω * Z

    # likelihood
    for i in 1:N
        y[i] ~ Normal(X[i, :] ⋅ β[:, idx[i]], σ)
    end
    return (; y, β, σ, Ω, τ, γ, Z)
end

# instantiate the model
model = correlated_varying_intercept_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64 
#   L_tilde[1]    0.0134    0.8729     0.0138    0.0219   1978.9056    1.0014        1.8512
#   L_tilde[2]   -0.0077    0.8509     0.0135    0.0178   2059.1537    1.0008        1.9263
#   L_tilde[3]    0.0763    1.0059     0.0159    0.0255   1659.5684    1.0005        1.5525
#   L_tilde[4]    0.0210    0.9055     0.0143    0.0275   1040.8284    1.0023        0.9737
#   L_tilde[5]   -0.0190    0.9752     0.0154    0.0228   1674.3909    1.0004        1.5664
#   L_tilde[6]    0.0632    1.1176     0.0177    0.0291   1439.6238    1.0039        1.3468
#            σ    0.6084    0.0350     0.0006    0.0009   1801.6933    1.0029        1.6855
#         τ[1]    0.9784    0.7305     0.0116    0.0272    579.6022    1.0057        0.5422
#         τ[2]    0.8940    0.6539     0.0103    0.0184   1150.8453    1.0074        1.0766
#         τ[3]    0.9722    0.7015     0.0111    0.0284    590.7927    1.0149        0.5527
#         τ[4]    0.9602    0.7077     0.0112    0.0260    736.0099    1.0144        0.6885
#       γ[1,1]    0.6740    1.4735     0.0233    0.0536    706.3475    1.0062        0.6608
#       γ[2,1]   -0.9898    1.2884     0.0204    0.0452    723.9490    1.0027        0.6772
#       γ[3,1]    1.0575    1.5200     0.0240    0.0749    381.3226    1.0023        0.3567
#       γ[4,1]    0.2115    1.5138     0.0239    0.0522    654.1878    1.0014        0.6120
#       γ[1,2]   -0.0924    1.4938     0.0236    0.0603    586.5729    1.0047        0.5487
#       γ[2,2]   -1.3776    1.2600     0.0199    0.0451    694.1231    1.0086        0.6493
#       γ[3,2]    0.4357    1.4541     0.0230    0.0639    425.2658    1.0057        0.3978
#       γ[4,2]   -0.1971    1.3396     0.0212    0.0362    656.2398    1.0019        0.6139
#       Z[1,1]    0.0057    0.9390     0.0148    0.0251   1210.1329    1.0013        1.1321
#       Z[2,1]    0.0383    0.9775     0.0155    0.0328    916.9673    1.0009        0.8578
#       Z[3,1]    0.0385    0.9365     0.0148    0.0264   1536.4146    0.9996        1.4373
#       Z[4,1]    0.0779    0.9458     0.0150    0.0232   1283.2695    1.0020        1.2005
#       Z[1,2]    0.0255    0.9185     0.0145    0.0264   1241.2293    1.0004        1.1612
#       Z[2,2]   -0.0534    0.9356     0.0148    0.0289   1346.0092    1.0020        1.2592
#       Z[3,2]   -0.0185    0.9483     0.0150    0.0266   1271.8442    1.0008        1.1898
#       Z[4,2]    0.0281    0.9088     0.0144    0.0182   1510.2904    1.0004        1.4129