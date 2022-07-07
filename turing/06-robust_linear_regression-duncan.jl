using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
duncan = CSV.read("datasets/duncan.csv", DataFrame)

# define data matrix X and standardize
X = select(duncan, [:income, :education]) |> Matrix |> float
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y and standardize
y = duncan[:, :prestige] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define the model
@model function student_t_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)
    ν ~ LogNormal(2, 1)

    # likelihood
    y ~ arraydist(TDist.(ν) .* σ .+ α .+ (X * β))
    return(; y, α, β, σ, ν)
end

# instantiate the model
model = student_t_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.0028    0.0607     0.0007    0.0007   6302.5129    0.9999      106.9764
#        β[1]    0.5397    0.1033     0.0012    0.0016   4150.2182    1.0008       70.4442
#        β[2]    0.4606    0.0997     0.0011    0.0015   4274.3720    1.0012       72.5515
#           σ    0.3554    0.0684     0.0008    0.0011   3640.0110    1.0001       61.7841
#           ν   10.4426   13.3598     0.1494    0.1887   3917.3390    1.0001       66.4914
