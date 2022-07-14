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
    return(; y, α, β, σ)
end

# instantiate the model
model = linear_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α    0.0003    0.0431     0.0005    0.0004   13310.0844    0.9997      392.4195
#        β[1]    0.1138    0.0463     0.0005    0.0005    9252.6086    0.9997      272.7935
#        β[2]    0.4138    0.0447     0.0005    0.0005    9399.6572    0.9999      277.1289
#        β[3]    0.0298    0.0430     0.0005    0.0004   11093.6757    1.0001      327.0734
#           σ    0.8913    0.0304     0.0003    0.0003   12746.3192    0.9997      375.7981

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

# results:
#  parameters      mean       std   naive_se      mcse          ess      rhat
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64
#
#   real_β[1]    0.1136    0.0455     0.0005    0.0004   13883.9215    0.9999
#   real_β[2]    0.4134    0.0446     0.0005    0.0004   12017.9704    1.0000
#   real_β[3]    0.0304    0.0439     0.0005    0.0003   14301.8467    0.9996
#           α    0.0001    0.0432     0.0005    0.0004   12634.6117    0.9997
#        β[1]   -0.2369    0.0425     0.0005    0.0004   13464.0249    0.9999
#        β[2]    0.3975    0.0428     0.0005    0.0004   12020.5203    1.0000
#        β[3]   -0.0297    0.0428     0.0005    0.0003   14301.8467    0.9996
#           σ    0.8905    0.0304     0.0003    0.0002   14061.4641    0.9998
