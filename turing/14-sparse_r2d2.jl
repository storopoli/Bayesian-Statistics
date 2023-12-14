using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
df = CSV.read("datasets/sparse_regression.csv", DataFrame)

# define data matrix X and standardize
X = select(df, Not(:y)) |> Matrix |> float
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y and standardize
y = df[:, :y] |> float
y = standardize(ZScoreTransform, y; dims=1)

# define the model
@model function sparse_r2d2_regression(
    X,
    y;
    predictors=size(X, 2),
    mean_R²=0.5,
    prec_R²=2,
    cons_D2=1,
)
    # priors
    α ~ TDist(3) * 2.5
    z ~ filldist(Normal(), predictors)
    σ ~ Exponential(1)

    R² ~ Beta(mean_R² * prec_R², (1 - mean_R²) * prec_R²)
    ϕ ~ Dirichlet(predictors, cons_D2)
    τ² = σ^2 * R² / (1 - R²)

    β = z .* sqrt.(ϕ * τ²)

    # likelihood
    y ~ MvNormal(α .+ X * β, σ^2 * I)
    return (; y, α, τ², R², ϕ, σ, β)
end

# instantiate the model
model = sparse_r2d2_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)

# results:
#  parameters      mean       std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec
#      Symbol   Float64   Float64   Float64     Float64     Float64   Float64       Float64
#
#           α   -0.0000    0.0331    0.0005   4810.7736   2897.9874    1.0011       77.5906
#        z[1]    1.9471    0.5164    0.0108   2324.2468   2497.6268    1.0017       37.4866
#        z[2]    0.1245    0.4540    0.0092   2791.2661   2248.3270    1.0010       45.0190
#        z[3]    1.3798    0.4926    0.0111   2172.1046   2140.8804    1.0008       35.0328
#        z[4]    0.1563    0.4762    0.0103   2747.7218   1445.6867    1.0023       44.3167
#        z[5]   -1.4380    0.4741    0.0101   2372.1073   2371.4801    1.0027       38.2586
#        z[6]    1.2682    0.4887    0.0115   1992.7956   2278.4217    1.0002       32.1408
#        z[7]    0.3316    0.4499    0.0105   2336.5928   1745.2343    1.0005       37.6858
#        z[8]    0.9663    0.4515    0.0103   2090.2258   2188.1982    1.0004       33.7122
#        z[9]   -0.0916    0.4659    0.0103   2388.7155   1758.8378    1.0026       38.5264
#       z[10]    0.3364    0.4306    0.0090   2567.0167   2250.0817    1.0022       41.4022
#       z[11]    0.6615    0.4337    0.0096   2477.2456   1968.5712    1.0011       39.9543
#       z[12]   -0.1690    0.4355    0.0089   2617.9076   1908.0778    1.0015       42.2230
#       z[13]   -0.1468    0.4400    0.0096   2287.1862   1564.5962    1.0011       36.8889
#       z[14]   -1.7863    0.5031    0.0105   2296.8729   2411.8110    1.0003       37.0451
#       z[15]   -0.3287    0.4700    0.0118   1861.3255   1528.6080    1.0009       30.0204
#       z[16]   -0.1205    0.4489    0.0102   2273.5535   1642.6176    1.0044       36.6690
#       z[17]   -0.1267    0.4418    0.0090   2739.7594   1874.8147    1.0009       44.1882
#       z[18]    0.1688    0.4567    0.0097   2550.0217   1904.7321    1.0022       41.1281
#       z[19]   -0.0199    0.4536    0.0101   2480.7957   1820.9155    1.0015       40.0115
#       z[20]   -1.6009    0.4987    0.0103   2563.1642   2283.9908    1.0015       41.3400
#           σ    0.3346    0.0267    0.0005   2948.2022   2761.5225    1.0004       47.5501
#          R²    0.8390    0.0540    0.0015   1231.3745   1913.9550    1.0010       19.8602
#        ϕ[1]    0.1204    0.0555    0.0010   2333.1188   2513.7715    1.0018       37.6297
#        ϕ[2]    0.0300    0.0367    0.0006   2518.7483   2135.0483    1.0016       40.6237
#        ϕ[3]    0.0743    0.0474    0.0009   2504.7310   2406.8258    1.0015       40.3976
#        ϕ[4]    0.0300    0.0351    0.0006   1981.0706   1398.5553    1.0015       31.9517
#        ϕ[5]    0.0807    0.0473    0.0008   2783.2044   2307.1676    1.0013       44.8889
#        ϕ[6]    0.0669    0.0445    0.0008   2398.9212   2374.6042    1.0008       38.6910
#        ϕ[7]    0.0313    0.0353    0.0006   2118.6381   1571.9491    1.0015       34.1705
#        ϕ[8]    0.0496    0.0407    0.0008   2275.6622   2287.6915    1.0021       36.7030
#        ϕ[9]    0.0305    0.0374    0.0006   2285.8077   1949.9086    1.0016       36.8667
#       ϕ[10]    0.0314    0.0348    0.0005   2562.6691   1670.6879    1.0008       41.3320
#       ϕ[11]    0.0403    0.0389    0.0006   2432.1167   2037.7906    0.9997       39.2264
#       ϕ[12]    0.0310    0.0349    0.0005   2817.5779   2002.4166    1.0006       45.4433
#       ϕ[13]    0.0302    0.0359    0.0006   2301.1932   1914.0317    1.0008       37.1148
#       ϕ[14]    0.1125    0.0550    0.0010   3046.9685   2865.5752    1.0004       49.1431
#       ϕ[15]    0.0313    0.0344    0.0006   2488.5343   2209.6063    0.9997       40.1364
#       ϕ[16]    0.0297    0.0349    0.0006   2590.9197   2303.3675    1.0015       41.7877
#       ϕ[17]    0.0302    0.0336    0.0006   2726.4569   2548.4165    0.9996       43.9737
#       ϕ[18]    0.0305    0.0365    0.0006   2251.9325   1758.6762    1.0029       36.3203
#       ϕ[19]    0.0288    0.0336    0.0006   2342.6613   2457.5977    1.0016       37.7836
#       ϕ[20]    0.0903    0.0493    0.0008   3297.5508   2547.3947    1.0002       53.1846
