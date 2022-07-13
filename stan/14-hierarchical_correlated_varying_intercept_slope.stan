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
//Mean chain execution time: 8.3 seconds.
//Total execution time: 8.8 seconds.
//
//Warning: 119 of 4000 (3.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//     variable   mean median   sd  mad     q5   q95 rhat ess_bulk ess_tail
// lp__         -15.47 -15.13 4.49 4.60 -23.47 -8.57 1.00     1500     2374
// sigma          0.61   0.61 0.04 0.03   0.55  0.67 1.00     6148     2869
// tau[1]         1.96   1.37 1.95 1.33   0.13  5.86 1.00     2927     1846
// tau[2]         2.06   1.36 2.32 1.33   0.12  6.47 1.00     3038     2078
// tau[3]         2.13   1.40 2.42 1.41   0.10  6.85 1.00     2962     2173
// tau[4]         2.07   1.33 2.39 1.35   0.10  6.37 1.00     3235     1898
// tau[5]         2.09   1.38 2.26 1.35   0.12  6.66 1.00     3346     2732
// Z[1,1]         0.02   0.01 0.92 0.93  -1.46  1.53 1.00     4303     2983
// Z[2,1]         0.01   0.03 0.94 0.92  -1.55  1.52 1.00     4115     2846
// Z[3,1]        -0.06  -0.07 0.95 0.92  -1.65  1.55 1.00     4290     2269
// Z[4,1]         0.04   0.07 0.96 0.96  -1.58  1.62 1.00     4821     2664
// Z[5,1]         0.00   0.01 0.98 0.97  -1.62  1.59 1.00     4859     2768
// Z[1,2]        -0.03  -0.03 0.92 0.94  -1.52  1.48 1.00     4354     3026
// Z[2,2]         0.02   0.04 0.92 0.91  -1.47  1.52 1.00     4457     2900
// Z[3,2]        -0.05  -0.05 0.94 0.90  -1.53  1.52 1.00     4701     2976
// Z[4,2]         0.03   0.02 0.94 0.93  -1.53  1.59 1.00     5563     2925
// Z[5,2]         0.01   0.01 0.92 0.89  -1.53  1.52 1.00     5602     2735
// L_Omega[1,1]   1.00   1.00 0.00 0.00   1.00  1.00   NA       NA       NA
// L_Omega[2,1]  -0.01  -0.01 0.34 0.38  -0.55  0.55 1.00     6669     2505
// L_Omega[3,1]  -0.01  -0.01 0.36 0.39  -0.61  0.59 1.00     6523     2571
// L_Omega[4,1]   0.00   0.00 0.35 0.38  -0.60  0.59 1.00     6067     2592
// L_Omega[5,1]   0.00   0.00 0.36 0.38  -0.59  0.58 1.00     5889     2827
// L_Omega[1,2]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,2]   0.94   0.97 0.08 0.05   0.76  1.00 1.00     1663     1653
// L_Omega[3,2]   0.01   0.01 0.35 0.38  -0.59  0.58 1.00     6140     2776
// L_Omega[4,2]   0.01   0.01 0.36 0.38  -0.57  0.59 1.00     6373     2793
// L_Omega[5,2]   0.00   0.00 0.35 0.38  -0.57  0.58 1.00     5869     2308
// L_Omega[1,3]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,3]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[3,3]   0.85   0.89 0.13 0.11   0.60  0.99 1.00     1617     1814
// L_Omega[4,3]   0.01   0.01 0.35 0.37  -0.58  0.60 1.00     5806     2592
// L_Omega[5,3]   0.01   0.01 0.35 0.38  -0.57  0.59 1.00     6119     2728
// L_Omega[1,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[3,4]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[4,4]   0.77   0.81 0.16 0.16   0.47  0.97 1.00     1466     1678
// L_Omega[5,4]   0.01   0.01 0.35 0.38  -0.59  0.58 1.01     6310     2672
// L_Omega[1,5]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[2,5]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[3,5]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[4,5]   0.00   0.00 0.00 0.00   0.00  0.00   NA       NA       NA
// L_Omega[5,5]   0.68   0.71 0.18 0.18   0.35  0.93 1.00     1521     1885
// gamma[1,1]     0.15   0.16 2.86 2.73  -4.57  4.82 1.00     2232     2372
// gamma[2,1]     0.41   0.44 2.92 2.74  -4.32  5.08 1.00     2175     2500
// gamma[3,1]    -0.89  -0.91 3.01 2.82  -5.73  4.00 1.00     2013     2184
// gamma[4,1]     0.81   0.88 2.86 2.81  -3.96  5.46 1.00     2210     2735
// gamma[5,1]     0.19   0.20 2.93 2.75  -4.51  4.98 1.00     1808     1795
// gamma[1,2]    -0.31  -0.32 2.79 2.75  -4.86  4.26 1.00     2435     2545
// gamma[2,2]     0.23   0.23 2.88 2.72  -4.49  4.91 1.00     2378     2577
// gamma[3,2]    -0.94  -0.95 2.88 2.78  -5.49  3.86 1.00     2382     2466
// gamma[4,2]     0.64   0.62 2.86 2.71  -3.99  5.22 1.00     2280     2514
// gamma[5,2]     0.15   0.17 2.85 2.80  -4.48  4.79 1.00     2458     2630
// beta[1,1]      0.18   0.19 2.51 2.49  -3.90  4.33 1.00     1930     2326
// beta[2,1]      0.51   0.49 2.51 2.51  -3.67  4.60 1.00     1944     2362
// beta[3,1]     -1.15  -1.15 2.51 2.49  -5.29  2.95 1.00     1921     2386
// beta[4,1]      0.94   0.94 2.52 2.50  -3.21  5.02 1.00     1934     2305
// beta[5,1]      0.22   0.21 2.52 2.51  -3.97  4.29 1.00     1922     2291
// beta[1,2]     -0.35  -0.27 2.43 2.42  -4.36  3.64 1.00     1998     2650
// beta[2,2]      0.33   0.27 2.43 2.44  -3.62  4.37 1.00     2009     2651
// beta[3,2]     -1.12  -1.18 2.43 2.42  -5.10  2.93 1.00     2025     2652
// beta[4,2]      0.73   0.64 2.43 2.42  -3.21  4.75 1.00     2019     2631
// beta[5,2]      0.21   0.13 2.43 2.41  -3.80  4.22 1.00     2032     2614
