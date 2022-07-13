// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// cheese$y <- as.numeric(scale(cheese$y))
// cheese$cheese_A <- ifelse(cheese$cheese == "A", 1, 0)
// cheese$cheese_B <- ifelse(cheese$cheese == "B", 1, 0)
// cheese$cheese_C <- ifelse(cheese$cheese == "C", 1, 0)
// cheese$cheese_D <- ifelse(cheese$cheese == "D", 1, 0)
// cheese$background_int <- ifelse(cheese$background == "urban", 1, 2)
// X <- as.matrix(cbind(1, cheese[5:8]))
// cheese data
// beta[K, J] rows are:
// 1. intercept
// 2. cheese_A
// 3. cheese_B
// 4. cheese_C
// 5. cheese_D
// beta [K, J] columns are:
// 1. urban
// 2. rural
data {
  int<lower=1> N;                        // number of observations
  int<lower=1> K;                        // number of independent variables + column of 1s as intercept
  matrix[N, K] X;                        // data matrix
  vector[N] y;                           // dependent variable vector
  int<lower=2> J;                        // number of groups
  array[N] int<lower=1, upper=J> idx;    // group membership
}
parameters {
  real<lower=0> sigma;                   // model error
  vector<lower=0>[K] tau;                // group SDs
  matrix[K, J] Z;                        // group coeffs non-centered
  cholesky_factor_corr[K] L_Omega;       // Cholesky decomposition
  matrix[K, J] gamma;                    // group coeffs
}
transformed parameters {
  matrix[K, J] beta = gamma + diag_pre_multiply(tau, L_Omega) * Z; // coefficients for independent variables
}
model {
  // priors
  sigma ~ exponential(1);
  tau ~ cauchy(0, 2);
  to_vector(Z) ~ normal(0, 1);
  L_Omega ~ lkj_corr_cholesky(2);
  to_vector(gamma) ~ normal(0, 5);

  // likelihood
  vector[N] mu;
  for(n in 1:N) {
    mu[n] = X[n, ] * beta[, idx[n]];
  }
  y ~ normal(mu, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 4.7 seconds.
//Total execution time: 5.5 seconds.
//
//Warning: 156 of 4000 (4.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//     variable   mean median   sd  mad     q5   q95 rhat ess_bulk ess_tail
// lp__         -10.54 -10.24 3.75 3.80 -17.01 -4.95 1.00     1406     2096
// sigma          0.61   0.61 0.04 0.04   0.55  0.67 1.00     3220     2279
// tau[1]         1.90   1.35 1.98 1.29   0.12  5.74 1.00     1470     1957
// tau[2]         1.98   1.34 2.18 1.32   0.12  6.03 1.01      908      973
// tau[3]         1.81   1.31 1.78 1.21   0.11  5.27 1.00     1324     1505
// tau[4]         1.94   1.29 2.11 1.23   0.14  6.23 1.01      755      339
// Z[1,1]         0.04   0.04 0.90 0.87  -1.51  1.52 1.00     1865     1696
// Z[2,1]        -0.02  -0.03 0.92 0.91  -1.50  1.55 1.00     1681      352
// Z[3,1]         0.05   0.07 0.93 0.93  -1.46  1.56 1.00     2173     2805
// Z[4,1]         0.01   0.02 0.94 0.94  -1.51  1.58 1.00     2935     2729
// Z[1,2]        -0.02  -0.04 0.89 0.85  -1.49  1.46 1.00     1822     2404
// Z[2,2]        -0.07  -0.10 0.92 0.87  -1.61  1.42 1.00     1876     2366
// Z[3,2]         0.04   0.08 0.93 0.94  -1.51  1.57 1.00     2329     2623
// Z[4,2]         0.02   0.01 0.96 0.96  -1.54  1.56 1.00     3297     3051
// L_Omega[1,1]   1.00   1.00 0.00 0.00   1.00  1.00   NA       NA       NA
// L_Omega[2,1]   0.01   0.01 0.37 0.41  -0.61  0.61 1.00     3091     2603
// L_Omega[3,1]   0.01   0.02 0.36 0.40  -0.61  0.59 1.00     3205     2358
// L_Omega[4,1]   0.01   0.01 0.38 0.42  -0.63  0.62 1.00     3138     2647
// L_Omega[1,2]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,2]   0.92   0.96 0.10 0.05   0.72  1.00 1.00     2012     2072
// L_Omega[3,2]   0.00  -0.01 0.38 0.43  -0.63  0.62 1.00     2555     2651
// L_Omega[4,2]   0.00  -0.01 0.38 0.41  -0.63  0.64 1.00     3491     2432
// L_Omega[1,3]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,3]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[3,3]   0.84   0.87 0.14 0.12   0.57  0.99 1.00     1725     2133
// L_Omega[4,3]  -0.01  -0.02 0.38 0.42  -0.62  0.61 1.00     3676     1633
// L_Omega[1,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[3,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[4,4]   0.73   0.76 0.17 0.17   0.42  0.96 1.00     1924     2587
// gamma[1,1]     0.57   0.67 1.82 0.99  -2.48  3.45 1.00     1116     1449
// gamma[2,1]    -0.88  -0.96 1.88 1.01  -3.77  2.37 1.00     1167      936
// gamma[3,1]     0.94   1.07 1.82 1.01  -2.46  3.75 1.00      797      448
// gamma[4,1]     0.33   0.39 1.70 0.95  -2.49  3.03 1.00     1366     1179
// gamma[1,2]     0.04   0.02 1.78 0.96  -2.73  2.99 1.00     1429     1354
// gamma[2,2]    -1.34  -1.42 2.03 1.00  -4.40  2.17 1.01     1141      886
// gamma[3,2]     0.33   0.35 1.71 0.98  -2.50  3.22 1.00     1306     1144
// gamma[4,2]    -0.10  -0.14 1.85 1.01  -2.97  2.93 1.01      736      289
// beta[1,1]      0.70   0.70 0.14 0.13   0.47  0.92 1.00     3117     2517
// beta[2,1]     -0.96  -0.96 0.13 0.13  -1.17 -0.74 1.00     3147     3173
// beta[3,1]      1.12   1.12 0.14 0.14   0.90  1.34 1.00     2651     2391
// beta[4,1]      0.40   0.40 0.14 0.14   0.18  0.63 1.00     3789     1893
// beta[1,2]     -0.02  -0.02 0.14 0.14  -0.24  0.20 1.00     3452     3328
// beta[2,2]     -1.47  -1.47 0.14 0.13  -1.69 -1.24 1.00     3079     2486
// beta[3,2]      0.38   0.38 0.14 0.14   0.15  0.59 1.00     3016     1723
// beta[4,2]     -0.15  -0.15 0.14 0.13  -0.37  0.08 1.00     3911     3123
