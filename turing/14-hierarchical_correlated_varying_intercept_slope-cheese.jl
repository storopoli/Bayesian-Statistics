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
#     τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), predictors) # group-level SDs
#     γ ~ filldist(Normal(0, 5), predictors, n_gr)              # matrix of group coefficients
#     Z ~ filldist(Normal(0, 1), predictors, n_gr)              # matrix of non-centered group coefficients

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
    τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), predictors) # group-level SDs
    γ ~ filldist(Normal(0, 5), predictors, n_gr)              # matrix of group coefficients
    Z ~ filldist(Normal(0, 1), predictors, n_gr)              # matrix of non-centered group coefficients

    # reconstruct β from Ω and τ
    Ω_L = LowerTriangular(collect(τ .* L_U'))                 # collect is necessary for ReverseDiff for some reason
    Ω = PDMat(Cholesky(Ω_L))
    β = γ + Ω * Z

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
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#   L_tilde[1]   -0.0218    0.8050     0.0090    0.0134   4567.1703    1.0001        2.3794
#   L_tilde[2]   -0.0349    0.8040     0.0090    0.0112   5367.7736    0.9998        2.7965
#   L_tilde[3]    0.0091    0.8696     0.0097    0.0130   5385.3632    1.0014        2.8056
#   L_tilde[4]   -0.0103    0.8108     0.0091    0.0126   4581.6880    1.0003        2.3869
#   L_tilde[5]    0.0122    0.8851     0.0099    0.0114   5169.8163    1.0004        2.6933
#   L_tilde[6]    0.0247    0.9936     0.0111    0.0142   4788.4916    1.0003        2.4947
#   L_tilde[7]   -0.0326    0.7985     0.0089    0.0099   5710.1852    1.0007        2.9748
#   L_tilde[8]    0.0047    0.8550     0.0096    0.0109   5098.8417    1.0002        2.6563
#   L_tilde[9]    0.0063    0.9693     0.0108    0.0125   5136.8519    0.9999        2.6761
#  L_tilde[10]   -0.0024    1.1341     0.0127    0.0153   5546.9260    1.0006        2.8898
#            σ    0.6096    0.0357     0.0004    0.0005   5556.9275    1.0006        2.8950
#         τ[1]    0.9249    0.6654     0.0074    0.0120   3114.4500    1.0045        1.6225
#         τ[2]    1.0953    0.8474     0.0095    0.0149   2931.2574    1.0007        1.5271
#         τ[3]    1.0800    0.8539     0.0095    0.0176   2504.7511    1.0036        1.3049
#         τ[4]    1.0776    0.8448     0.0094    0.0175   2366.2606    1.0044        1.2328
#         τ[5]    1.0636    0.8259     0.0092    0.0156   2829.6042    1.0019        1.4741
#       γ[1,1]    0.2620    2.6312     0.0294    0.0658   1456.3870    1.0018        0.7587
#       γ[2,1]    0.3859    2.8122     0.0314    0.0702   1498.7812    1.0020        0.7808
#       γ[3,1]   -1.0197    2.8566     0.0319    0.0697   1570.0691    1.0003        0.8180
#       γ[4,1]    0.7506    2.8163     0.0315    0.0707   1729.4316    1.0005        0.9010
#       γ[5,1]    0.1443    2.7736     0.0310    0.0596   1983.3875    1.0004        1.0333
#       γ[1,2]   -0.2533    2.5958     0.0290    0.0575   2007.9912    1.0002        1.0461
#       γ[2,2]    0.2035    2.8311     0.0317    0.0648   2095.6743    1.0003        1.0918
#       γ[3,2]   -1.0274    2.7888     0.0312    0.0666   2018.3245    1.0011        1.0515
#       γ[4,2]    0.4581    2.7273     0.0305    0.0622   2094.0194    1.0017        1.0909
#       γ[5,2]    0.1674    2.7718     0.0310    0.0663   2050.7521    1.0001        1.0684
#       Z[1,1]    0.0155    0.9532     0.0107    0.0161   4244.0224    0.9997        2.2110
#       Z[2,1]    0.0050    0.9376     0.0105    0.0169   4141.6995    1.0004        2.1577
#       Z[3,1]   -0.0574    0.9346     0.0104    0.0123   4320.1567    1.0011        2.2507
#       Z[4,1]    0.0344    0.9459     0.0106    0.0132   5129.8637    1.0001        2.6725
#       Z[5,1]    0.0158    0.9134     0.0102    0.0141   4085.6477    1.0001        2.1285
#       Z[1,2]   -0.0090    0.9415     0.0105    0.0149   3986.8479    0.9998        2.0770
#       Z[2,2]    0.0057    0.9267     0.0104    0.0154   3806.5231    1.0007        1.9831
#       Z[3,2]   -0.0565    0.9229     0.0103    0.0148   4179.3437    1.0007        2.1773
#       Z[4,2]    0.0275    0.9066     0.0101    0.0111   5086.0682    1.0006        2.6497
#       Z[5,2]    0.0026    0.9437     0.0106    0.0144   4766.3703    1.0002        2.4831
