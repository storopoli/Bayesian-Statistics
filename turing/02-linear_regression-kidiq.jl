using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
kidiq = CSV.read("datasets/kidiq.csv", DataFrame)

# define data matrix X and standardize
X = select(kidiq, Not(:kid_score)) |> Matrix
X = standardize(ZScoreTransform, X; dims=1)

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
    y ~ MvNormal(α .+ X * β, σ^2 * I)
    return (; y, α, β, σ)
end

# instantiate the model
model = linear_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.0012    0.0426     0.0007    0.0006   4569.6175    0.9996      134.4955
#         β[1]    0.1154    0.0446     0.0007    0.0005   4613.5210    0.9993      135.7876
#         β[2]    0.4129    0.0452     0.0007    0.0005   4378.9035    0.9995      128.8823
#         β[3]    0.0302    0.0447     0.0007    0.0006   5270.6517    0.9995      155.1287
#            σ    0.8914    0.0316     0.0005    0.0004   4606.7431    1.0005      135.5882

# QR Decomposition
Q, R = qr(X)
# thin and scale the QR decomposition:
Q_ast = Matrix(Q) * sqrt(size(X, 1) - 1)
R_ast = R / sqrt(size(X, 1) - 1)

# instantiate the model
model_qr = linear_regression(Q_ast, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn_qr = sample(model_qr, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# reconstruct β back from the Q_ast scale into X scale
betas = mapslices(x -> R_ast^-1 * x, chn_qr[:, namesingroup(chn_qr, :β), :].value.data, dims=[2])
chain_beta = setrange(Chains(betas, ["real_β[$i]" for i in 1:size(Q_ast, 2)]), 1_001:1:2_000)
chn_qr_reconstructed = hcat(chain_beta, chn_qr)

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64 
#    real_β[1]    0.1134    0.0448     0.0007    0.0006   4200.1480    0.9995
#    real_β[2]    0.4145    0.0443     0.0007    0.0006   4418.2596    0.9995
#    real_β[3]    0.0304    0.0445     0.0007    0.0006   4541.7050    0.9996
#            α    0.0000    0.0434     0.0007    0.0006   4875.4944    1.0004
#         β[1]   -0.2371    0.0423     0.0007    0.0006   4203.4585    0.9994
#         β[2]    0.3985    0.0424     0.0007    0.0006   4408.2610    0.9995
#         β[3]   -0.0297    0.0434     0.0007    0.0006   4541.7050    0.9996
#            σ    0.8915    0.0309     0.0005    0.0005   4251.5506    0.9993
