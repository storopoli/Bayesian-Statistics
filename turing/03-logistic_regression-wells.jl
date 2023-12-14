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
X = select(wells, Not(:switch)) |> Matrix
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y
y = wells[:, :switch]

# define the model
@model function logistic_regression(X, y; predictors=size(X, 2))
    # priors
    α ~ TDist(3) * 2.5
    β ~ filldist(TDist(3) * 2.5, predictors)

    # likelihood
    y ~ arraydist(LazyArray(@~ BernoulliLogit.(α .+ X * β)))
    # you could also do BinomialLogit(n, logitp) if you can group the successes
    return (; y, α, β)
end

# instantiate the model
model = logistic_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#   parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.3363    0.0382     0.0006    0.0006   4832.5931    1.0005      225.3903
#         β[1]    0.5178    0.0460     0.0007    0.0007   3946.2992    0.9999      184.0539
#         β[2]   -0.3458    0.0406     0.0006    0.0006   4342.0380    0.9993      202.5110
#         β[3]   -0.0607    0.0381     0.0006    0.0005   5132.8763    0.9993      239.3954
#         β[4]    0.1693    0.0384     0.0006    0.0005   4088.2092    0.9992      190.6725
