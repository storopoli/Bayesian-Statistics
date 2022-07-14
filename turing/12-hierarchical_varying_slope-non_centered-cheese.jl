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
@model function varying_slope_ncp_regression(X, idx, y;
                                             predictors=size(X, 2),
                                             n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr) # group-level SDs slopes
    Zⱼ ~ filldist(Normal(0, 1), predictors, n_gr)        # group-level non-centered slopes
    βⱼ = Zⱼ * τ                                          # group-level slopes

    # likelihood
    y ~ MvNormal(α .+ X * β .+ X * βⱼ, σ^2 * I)
    return(; y, α, β, σ, βⱼ, τ)
end

# instantiate the model
model = varying_slope_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α   -0.1739    1.4041     0.0157    0.0675    149.4242    1.0257        2.3567
#        β[1]    0.4139    1.6715     0.0187    0.0664    211.8764    1.0216        3.3417
#        β[2]   -0.8526    1.5918     0.0178    0.0416   1898.7924    1.0035       29.9480
#        β[3]    0.6923    1.6229     0.0181    0.0569    336.3913    1.0135        5.3056
#        β[4]   -0.0315    1.6359     0.0183    0.0558    378.8859    1.0196        5.9758
#           σ    0.6845    0.0394     0.0004    0.0011    772.6297    1.0074       12.1860
#        τ[1]    1.1218    0.9312     0.0104    0.0492    104.3116    1.0408        1.6452
#        τ[2]    1.0728    0.8824     0.0099    0.0306    484.7341    1.0123        7.6453
#     Zⱼ[1,1]    0.0519    0.9142     0.0102    0.0176   2815.5456    1.0029       44.4071
#     Zⱼ[2,1]   -0.0977    0.9162     0.0102    0.0242    737.9716    1.0120       11.6394
#     Zⱼ[3,1]    0.0291    0.9209     0.0103    0.0275    656.0340    1.0089       10.3470
#     Zⱼ[4,1]    0.0914    0.9878     0.0110    0.0373    230.1237    1.0282        3.6295
#     Zⱼ[1,2]   -0.0377    0.9619     0.0108    0.0395    160.5521    1.0313        2.5322
#     Zⱼ[2,2]   -0.0893    0.9151     0.0102    0.0176   3452.3528    1.0005       54.4509
#     Zⱼ[3,2]    0.1679    1.0133     0.0113    0.0455    171.8802    1.0219        2.7109
#     Zⱼ[4,2]    0.0314    0.9086     0.0102    0.0167   3525.6862    1.0019       55.6076
