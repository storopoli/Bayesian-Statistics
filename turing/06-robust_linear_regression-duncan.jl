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
X = float(Matrix(select(duncan, [:income, :education])))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y and standardize
y = float(duncan[:, :prestige])
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
    return (; y, α, β, σ, ν)
end

# instantiate the model
model = student_t_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec 
#       Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#            α    0.0016    0.0630     0.0010    0.0013   2557.3011    1.0009      141.8831
#         β[1]    0.5338    0.1049     0.0017    0.0024   1966.9407    1.0025      109.1290
#         β[2]    0.4667    0.1017     0.0016    0.0023   2145.9728    1.0015      119.0620
#            σ    0.3596    0.0677     0.0011    0.0015   1819.3829    1.0021      100.9422
#            ν   10.6302   12.1233     0.1917    0.3741   1495.5097    1.0056       82.9732
