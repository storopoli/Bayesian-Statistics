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
    N=size(X, 1),
    n_gr=length(unique(idx)))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # prior for variance of random slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr)                      # group-level SDs slopes
    Zⱼ ~ arraydist([MvNormal(Diagonal(fill(1, predictors))) for j in 1:n_gr]) # group-level non-centered slopes
    βⱼ = Zⱼ .* τ'                                                             # group-level slopes

    # likelihood
    for i in 1:N
        y[i] ~ Normal(α + X[i, :] ⋅ β + X[i, :] ⋅ βⱼ[:, idx[i]], σ)
    end
    return (; y, α, β, σ, βⱼ, τ)
end

# instantiate the model
model = varying_slope_ncp_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64 
#            α    0.0025    1.0668     0.0169    0.0328   1261.3058    1.0004        3.0436
#         β[1]    0.3157    1.0948     0.0173    0.0311   1344.0403    1.0000        3.2432
#         β[2]   -1.2084    1.1130     0.0176    0.0297   1345.6314    1.0003        3.2471
#         β[3]    0.7301    1.1233     0.0178    0.0332   1262.9040    0.9999        3.0474
#         β[4]    0.1126    1.0900     0.0172    0.0323   1276.6416    1.0003        3.0806
#            σ    0.6079    0.0336     0.0005    0.0006   4400.6334    0.9999       10.6189
#         τ[1]    0.6602    0.5276     0.0083    0.0116   1746.1706    1.0005        4.2136
#         τ[2]    0.6478    0.5099     0.0081    0.0108   2261.6085    1.0003        5.4574
#      Zⱼ[1,1]    0.5340    0.7657     0.0121    0.0147   2749.1075    1.0008        6.6337
#      Zⱼ[2,1]    0.3385    0.7560     0.0120    0.0131   2973.5554    1.0002        7.1753
#      Zⱼ[3,1]    0.5464    0.8243     0.0130    0.0168   2717.5710    1.0007        6.5576
#      Zⱼ[4,1]    0.4085    0.7700     0.0122    0.0155   2764.1682    1.0001        6.6700
#      Zⱼ[1,2]   -0.4966    0.7992     0.0126    0.0164   2695.0365    1.0009        6.5032
#      Zⱼ[2,2]   -0.3761    0.7534     0.0119    0.0157   2411.6818    1.0006        5.8195
#      Zⱼ[3,2]   -0.5127    0.8244     0.0130    0.0160   2645.8006    1.0006        6.3844
#      Zⱼ[4,2]   -0.3698    0.7699     0.0122    0.0148   2937.4458    1.0001        7.0882
