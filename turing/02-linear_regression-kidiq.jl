using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
kidiq = CSV.read("../datasets/kidiq.csv", DataFrame)

# define data matrix X and standardize
X = select(kidiq, Not(:kid_score)) |> Matrix
X = standardize(ZScoreTransform, X; dims=2)

# define dependent variable y and standardize
y = kidiq[:, :kid_score] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define the model
@model function linear_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)
    σ ~ Exponential(1)

    # likelihood
    y ~ MvNormal(α .+ X * β, σ)
    return(; y, α, β, σ)
end

# instantiate the model
model = linear_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#Summary Statistics
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α   -0.0961    2.5327     0.0283    0.0433   3724.6454    1.0001       28.8766
#        β[1]    2.6815    2.4488     0.0274    0.0490   2827.0992    1.0025       21.9180
#        β[2]    0.7224    2.3884     0.0267    0.0423   3388.2018    1.0010       26.2682
#        β[3]   -3.9614    2.2743     0.0254    0.0448   2772.6104    1.0032       21.4956
#           σ    0.9493    0.0327     0.0004    0.0005   5032.3461    1.0015       39.0150

# QR Decomposition
Q, R = qr(X)
# thin and scale the QR decomposition:
Q_ast = Matrix(Q) * sqrt(size(X, 1) - 1)
R_ast = R / sqrt(size(X, 1) - 1)

# instantiate the model
model_qr = linear_regression(Q_ast, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn_qr = sample(model_qr, NUTS(), MCMCThreads(), 2_000, 4)

# reconstruct β back from the Q_ast scale into X scale
betas = mapslices(x -> R_ast^-1 * x, chn_qr[:, namesingroup(chn_qr, :β),:].value.data, dims=[2])
chain_beta = setrange(Chains(betas, ["real_β[$i]" for i in 1:size(Q_ast, 2)]), 1_001:1:3_000)
chn_qr_reconstructed = hcat(chain_beta, chn_qr)
