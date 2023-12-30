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
X = float(Matrix(select(df, Not(:y))))
X = standardize(ZScoreTransform, X; dims=1)

# define dependent variable y and standardize
y = float(df[:, :y])
y = standardize(ZScoreTransform, y; dims=1)

# define the model
@model function sparse_finnish_horseshoe_regression(
    X, y; predictors=size(X, 2), τ₀=3, ν_local=1, ν_global=1, slab_df=4, slab_scale=2
)
    # priors
    α ~ TDist(3) * 2.5
    z ~ MvNormal(I(predictors)) # standard normal for coefs
    σ ~ Exponential(1)
    λ ~ filldist(truncated(TDist(ν_local) * 2.5; lower=0), predictors) # local shrinkage
    τ ~ (τ₀ * σ) * truncated(TDist(ν_global); lower=0)                 # global shrinkage
    c_aux ~ InverseGamma(0.5 * slab_df, 0.5 * slab_df)

    c = slab_scale * sqrt(c_aux)
    λtilde = λ ./ hypot.(1, (τ / c) .* λ)
    β = τ .* z .* λtilde # coefficients

    # likelihood
    y ~ MvNormal(α .+ X * β, σ^2 * I)
    return (; y, α, λ, τ, λtilde, z, c, c_aux, σ, β)
end

# instantiate the model
model = sparse_finnish_horseshoe_regression(X, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters with 1k warmup
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
#  parameters      mean        std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec
#      Symbol   Float64    Float64   Float64     Float64     Float64   Float64       Float64
#
#           α   -0.0000     0.0336    0.0004   8823.6551   2625.2448    1.0010       63.6954
#        z[1]    1.1743     0.6211    0.0109   3213.3734   1982.3955    1.0007       23.1964
#        z[2]    0.1741     0.7198    0.0123   3571.7797   2485.5006    1.0011       25.7836
#        z[3]    1.1017     0.5952    0.0096   3728.6517   2509.9228    1.0004       26.9160
#        z[4]    0.2029     0.6915    0.0125   3294.1032   2269.1136    1.0006       23.7792
#        z[5]   -1.1319     0.6242    0.0106   3273.5540   2001.8126    1.0007       23.6308
#        z[6]    1.0820     0.5930    0.0099   3335.8259   1514.1053    1.0003       24.0803
#        z[7]    0.3718     0.6854    0.0115   3709.5649   2602.5957    1.0030       26.7783
#        z[8]    1.0127     0.5866    0.0104   3281.1430   2528.0699    1.0009       23.6856
#        z[9]   -0.0764     0.7137    0.0114   3946.6966   2386.0961    1.0003       28.4900
#       z[10]    0.3815     0.6643    0.0118   3427.8556   1967.6517    1.0012       24.7447
#       z[11]    0.7501     0.5884    0.0108   3237.0560   2114.0547    1.0011       23.3674
#       z[12]   -0.1908     0.7082    0.0112   4037.0612   2465.3878    1.0016       29.1424
#       z[13]   -0.1799     0.6934    0.0117   3659.5375   2327.1124    1.0008       26.4171
#       z[14]   -1.1706     0.6260    0.0106   2951.8902   2005.4013    1.0019       21.3088
#       z[15]   -0.3192     0.6938    0.0117   3701.8526   2415.6241    1.0017       26.7226
#       z[16]   -0.1536     0.6923    0.0129   3049.0712   2067.3564    1.0034       22.0103
#       z[17]   -0.0948     0.6687    0.0124   2989.3825   2500.1203    1.0015       21.5795
#       z[18]    0.1474     0.6987    0.0113   3903.8315   2364.3293    1.0014       28.1806
#       z[19]   -0.0195     0.6944    0.0115   3577.8364   2623.2387    1.0006       25.8273
#       z[20]   -1.1287     0.5960    0.0100   3204.0600   2055.6806    1.0022       23.1292
#           σ    0.3270     0.0254    0.0004   4952.0710   2899.5720    0.9998       35.7475
#        λ[1]   63.9949   832.4170   24.9693   2269.0570   1452.5641    0.9999       16.3797
#        λ[2]    2.0061     5.1148    0.0903   2689.4842   2228.4052    1.0002       19.4146
#        λ[3]   18.9900   381.5160    6.1106   2473.8537   2344.7816    1.0013       17.8580
#        λ[4]    1.9434     3.6647    0.0671   2629.0522   2303.8663    1.0003       18.9784
#        λ[5]   18.5162   141.6885    3.1343   2258.5089   1992.2430    1.0011       16.3035
#        λ[6]   15.3717   202.8024    3.9001   2514.2793   1621.6142    1.0004       18.1498
#        λ[7]    2.2426     4.9889    0.1117   2206.7881   2225.5464    1.0025       15.9302
#        λ[8]    6.2598    15.3460    0.3315   2004.0581   2379.0276    1.0012       14.4667
#        λ[9]    1.9147     4.4790    0.0726   2720.5423   1990.4467    0.9998       19.6388
#       λ[10]    2.2991     5.4705    0.0881   2931.8924   2340.0812    1.0000       21.1645
#       λ[11]    4.0614    15.8590    0.2706   2451.3843   1738.1194    1.0008       17.6958
#       λ[12]    2.6250    19.0674    0.5702   2802.5203   2222.0887    1.0020       20.2306
#       λ[13]    7.9188   319.1848    5.7201   2453.5111   1751.0486    0.9999       17.7112
#       λ[14]   33.3954   280.7108    7.2404   1981.8888   1342.0934    1.0028       14.3067
#       λ[15]    2.3651     7.2423    0.1300   2877.8021   2190.4599    1.0000       20.7740
#       λ[16]    1.9382     3.8046    0.0748   2461.9774   2181.2419    1.0019       17.7723
#       λ[17]    2.1877     8.0997    0.1390   2862.7741   2464.6434    1.0004       20.6655
#       λ[18]    1.9594     4.6106    0.0787   2840.8212   1831.3241    1.0010       20.5071
#       λ[19]    2.0235     9.6304    0.1527   2409.5807   1930.8216    1.0004       17.3941
#       λ[20]   18.1218    56.2430    1.6780   2247.6124   1714.5189    1.0025       16.2249
#           τ    0.0428     0.0207    0.0005   1851.0045   2496.6184    1.0011       13.3619
#       c_aux    1.8812     4.9001    0.1314   3930.7145   2055.0016    1.0030       28.3747
