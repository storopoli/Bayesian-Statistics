using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra
using LazyArrays


# reproducibility
using Random: seed!

seed!(123)

# load data
wells = CSV.read("datasets/wells.csv", DataFrame)

# define data matrix X and standardize
X = Matrix(select(wells, Not(:switch)))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = wells[:, :switch]

# Probit regression model (Normal CDF link)
@model function probit_regression(X, y; predictors=size(X, 2), N=size(X, 1))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)

    # linear predictor
    η = α .+ X * β

    # probabilities via probit link
    p = cdf.(Normal(), η)

    # vectorized Bernoulli observations using LazyArrays (kept per user request)
    y ~ arraydist(LazyArray(@~ Bernoulli.(p)))
    return (; y, α, β)
end

# instantiate the model
model = probit_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#  parameters  mean        std        mcse         ess_bulk  ess_tail  rhat     ess_per_sec
# ─┼────────────────────────────────────────────────────
#  α            0.204825   0.0236999  0.000343224   4768.41   3333.97  1.00033      465.12
#  β[1]         0.307314   0.0266702  0.000377028   4919.22   3423.64  1.00016      479.83
#  β[2]        -0.210547   0.0240448  0.000352046   4659.73   3339.36  1.00136      454.519
#  β[3]        -0.0392696  0.023191   0.000335398   4785.94   3065.21  1.00085      466.83
#  β[4]         0.106622   0.0236934  0.000358059   4378.17   3155.03  1.0011       427.055
