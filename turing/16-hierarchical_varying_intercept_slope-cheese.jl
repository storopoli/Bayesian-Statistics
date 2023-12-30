using Turing
using CSV
using DataFrames
using StatsBase
using LinearAlgebra

# reproducibility
using Random: seed!

seed!(123)

# load data
cheese = CSV.read("datasets/cheese.csv", DataFrame)

# create dummy vars
for c in unique(cheese[:, :cheese])
    cheese[:, "cheese_$c"] = ifelse.(cheese[:, :cheese] .== c, 1, 0)
end

# create int idx
cheese[:, :background_int] = map(cheese[:, :background]) do b
    if b == "urban"
        1
    elseif b == "rural"
        2
    else
        missing
    end
end

# define data matrix X
# now we are binding a column of 1s as the first column of X
# for the correlated intercepts
insertcols!(cheese, :intercept => fill(1, nrow(cheese)))
X = Matrix(select(cheese, Cols(:intercept, Between(:cheese_A, :cheese_D))))

# define dependent variable y and standardize
y = float(cheese[:, :y])
y = standardize(ZScoreTransform, y; dims=1)

# define vector of group memberships idx
idx = cheese[:, :background_int]

# define the model
@model function correlated_varying_intercept_slope_regression(
    X, idx, y; predictors=size(X, 2), N=size(X, 1), n_gr=length(unique(idx))
)
    # priors
    Ω ~ LKJCholesky(predictors, 2.0)
    σ ~ Exponential(1)

    # prior for variance of random intercepts and slopes
    # usually requires thoughtful specification
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), predictors) # group-level SDs
    γ ~ filldist(Normal(0, 5), predictors, n_gr)               # matrix of group coefficients
    Z ~ filldist(Normal(0, 1), predictors, n_gr)               # matrix of non-centered group coefficients

    # reconstruct β from Ω and τ
    β = γ + τ .* Ω.L * Z

    # likelihood
    for i in 1:N
        y[i] ~ Normal(X[i, :] ⋅ β[:, idx[i]], σ)
    end
    return (; y, β, σ, Ω, τ, γ, Z)
end

# instantiate the model
model = correlated_varying_intercept_slope_regression(X, idx, y)

# sample with NUTS, 4 multi-threaded parallel chains, and 2k iters
chn = sample(model, NUTS(1_000, 0.8), MCMCThreads(), 1_000, 4)
println(DataFrame(summarystats(chn)))

# results:
# Summary Statistics
#   parameters      mean       std      mcse    ess_bulk    ess_tail      rhat   ess_per_sec 
#       Symbol   Float64   Float64   Float64     Float64     Float64   Float64       Float64 
#     Ω.L[1,1]    1.0000    0.0000       NaN         NaN         NaN       NaN           NaN
#     Ω.L[2,1]    0.0077    0.3529    0.0055   3960.8548   2002.1197    1.0017        5.1527
#     Ω.L[3,1]   -0.0030    0.3525    0.0073   2318.7503   2318.8227    1.0047        3.0165
#     Ω.L[4,1]    0.0057    0.3630    0.0062   3418.7403   2347.2750    1.0004        4.4474
#     Ω.L[5,1]    0.0033    0.3536    0.0056   4052.7561   2195.1157    1.0021        5.2722
#     Ω.L[2,2]    0.9318    0.0848    0.0022   1140.1517    503.9699    1.0019        1.4832
#     Ω.L[3,2]   -0.0051    0.3544    0.0061   3350.9388   2521.8811    1.0010        4.3592
#     Ω.L[4,2]    0.0069    0.3598    0.0064   3169.0739   2424.1733    1.0013        4.1226
#     Ω.L[5,2]   -0.0015    0.3436    0.0058   3500.7859   2434.4279    1.0007        4.5542
#     Ω.L[3,3]    0.8577    0.1206    0.0031   1675.2394   2014.9484    1.0014        2.1793
#     Ω.L[4,3]   -0.0044    0.3626    0.0092   1342.8179    324.2139    1.0049        1.7469
#     Ω.L[5,3]    0.0153    0.3593    0.0093   1308.5168    377.1732    1.0046        1.7022
#     Ω.L[4,4]    0.7640    0.1534    0.0042   1427.1434   1922.1280    1.0024        1.8566
#     Ω.L[5,4]    0.0076    0.3580    0.0058   3683.6774   2416.5623    1.0029        4.7921
#     Ω.L[5,5]    0.6856    0.1714    0.0044   1611.1157   2222.5532    1.0035        2.0959
#            σ    0.6100    0.0353    0.0006   3299.5373   2580.0330    1.0005        4.2924
#         τ[1]    1.6321    1.5013    0.0324   1325.2906    921.5658    1.0030        1.7241
#         τ[2]    2.0360    2.1504    0.0499   2028.7166   1857.7307    1.0008        2.6392
#         τ[3]    2.0166    2.0165    0.0490   1813.5635   1616.3720    1.0006        2.3593
#         τ[4]    2.1234    2.5838    0.2042    761.5893    328.3545    1.0060        0.9908
#         τ[5]    1.9468    1.9703    0.0457   1507.1912   1439.6925    1.0021        1.9607
#       γ[1,1]    0.3104    2.5783    0.0773   1114.6309   1516.6261    1.0006        1.4500
#       γ[2,1]    0.3607    2.7544    0.0747   1360.3213   1571.1077    1.0013        1.7696
#       γ[3,1]   -1.0665    2.8623    0.0814   1239.2979   1593.4171    1.0019        1.6122
#       γ[4,1]    0.8003    2.7856    0.1029    791.0495    344.1204    1.0032        1.0291
#       γ[5,1]    0.1438    2.8079    0.0955    909.5711   1596.1574    1.0048        1.1833
#       γ[1,2]   -0.4093    2.7175    0.0822   1103.6350    557.1815    1.0028        1.4357
#       γ[2,2]    0.3843    2.8844    0.0805   1280.2732   1453.5727    1.0035        1.6655
#       γ[3,2]   -0.9120    2.7927    0.0766   1336.0124   1892.9783    1.0058        1.7380
#       γ[4,2]    0.6153    2.7966    0.0780   1287.4641   1591.0980    1.0036        1.6749
#       γ[5,2]    0.3028    2.8947    0.0821   1238.1865   1650.1950    1.0028        1.6108
#       Z[1,1]   -0.0134    0.8883    0.0179   2460.2676   2453.7872    1.0020        3.2006
#       Z[2,1]    0.0463    0.9159    0.0181   2563.1459   2738.2363    1.0059        3.3344
#       Z[3,1]   -0.0250    0.9320    0.0188   2455.9229   2419.3012    1.0008        3.1949
#       Z[4,1]    0.0409    0.9215    0.0186   2465.3055   2295.0078    1.0009        3.2071
#       Z[5,1]   -0.0045    0.9716    0.0174   3107.9059   2600.5361    1.0013        4.0431
#       Z[1,2]    0.0096    0.9085    0.0203   2002.6466   2463.5179    1.0022        2.6052
#       Z[2,2]    0.0172    0.9168    0.0179   2621.0574   2284.6429    1.0022        3.4097
#       Z[3,2]   -0.0564    0.9068    0.0171   2829.5749   2393.1926    1.0006        3.6810
#       Z[4,2]    0.0241    0.9430    0.0185   2591.3177   2463.7692    1.0009        3.3710
#       Z[5,2]    0.0144    0.9475    0.0169   3169.3612   2689.0769    1.0012        4.1230
