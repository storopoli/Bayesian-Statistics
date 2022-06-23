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
    y ~ MvNormal(α .+ X * β, σ)
    return(; y, α, β, σ)
end

# instantiate the model
model = linear_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
# parameters      mean       std   naive_se      mcse          ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64       Float64
#
#           α   -0.0005    0.0422     0.0005    0.0003   13197.2563    0.9996     3566.8260
#        β[1]    0.1137    0.0453     0.0005    0.0005    8497.2771    0.9997     2296.5614
#        β[2]    0.4130    0.0445     0.0005    0.0005   10759.8419    0.9997     2908.0654
#        β[3]    0.0292    0.0435     0.0005    0.0005    9389.3471    1.0001     2537.6614
#           σ    0.8909    0.0302     0.0003    0.0003   11543.4624    1.0003     3119.8547

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
#Summary Statistics
#  parameters      mean       std   naive_se      mcse          ess      rhat
#      Symbol   Float64   Float64    Float64   Float64      Float64   Float64
#
#   real_β[1]    0.1134    0.0454     0.0005    0.0004   12505.8900    0.9997
#   real_β[2]    0.4133    0.0452     0.0005    0.0004   14460.7545    0.9997
#   real_β[3]    0.0294    0.0441     0.0005    0.0004   14193.3541    0.9997
#           α   -0.0007    0.0433     0.0005    0.0004   13789.3541    0.9998
#        β[1]   -0.2365    0.0430     0.0005    0.0004   12087.5090    0.9997
#        β[2]    0.3974    0.0433     0.0005    0.0004   14416.3665    0.9997
#        β[3]   -0.0287    0.0431     0.0005    0.0004   14193.3541    0.9997
#           σ    0.8909    0.0305     0.0003    0.0003   12349.2157    1.0005
