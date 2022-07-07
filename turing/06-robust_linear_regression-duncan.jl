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
    y ~ arraydist(TDist.(ν) .+ α .+ (X * β) .* σ)
    return(; y, α, β, σ)
end

# instantiate the model
model = student_t_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(), MCMCThreads(), 2_000, 4)

# results:
#  parameters      mean       std   naive_se      mcse         ess      rhat   ess_per_sec
#      Symbol   Float64   Float64    Float64   Float64     Float64   Float64       Float64
#
#           α    0.0032    0.1448     0.0016    0.0037   1307.6503    1.0060       38.2130
#        β[1]    1.9482    2.0948     0.0234    0.0808    433.8524    1.0140       12.6783
#        β[2]    2.0210    1.6720     0.0187    0.0600    612.7589    1.0068       17.9065
#           σ    0.3803    0.2996     0.0033    0.0221     76.0252    1.0542        2.2217
#           ν   27.5254   26.4839     0.2961    1.1397    185.8207    1.0230        5.4302
