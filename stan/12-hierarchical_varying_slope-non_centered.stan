// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// cheese$y <- as.numeric(scale(cheese$y))
// cheese$cheese_A <- ifelse(cheese$cheese == "A", 1, 0)
// cheese$cheese_B <- ifelse(cheese$cheese == "B", 1, 0)
// cheese$cheese_C <- ifelse(cheese$cheese == "C", 1, 0)
// cheese$cheese_D <- ifelse(cheese$cheese == "D", 1, 0)
// cheese$background_int <- ifelse(cheese$background == "urban", 1, 2)
// cheese data
// beta[K, J] rows are:
// 1. cheese_A
// 2. cheese_B
// 3. cheese_C
// 4. cheese_D
// beta [K, J] columns are:
// 1. urban
// 2. rural
data {
  int<lower=1> N;                        // number of observations
  int<lower=1> K;                        // number of independent variables
  matrix[N, K] X;                        // data matrix
  vector[N] y;                           // dependent variable vector
  int<lower=2> J;                        // number of groups
  array[N] int<lower=1, upper=J> idx;    // group membership
}
parameters {
  real alpha;                            // intercept
  vector[K] beta;                        // coefficients for independent variables
  real<lower=0> sigma;                   // model error
  vector<lower=0>[J] tau;                // group-level SD slopes
  matrix[K, J] Z;                        // group-level non-centered slopes
}
transformed parameters {
  matrix[K, J] beta_j;                   // group-level slopes
  for (j in 1:J) beta_j[, j] = Z[, j] * tau[j];
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau ~ cauchy(0, 2);
  to_vector(Z) ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha + X * beta + X * beta_j * tau, sigma);
}
// results
//All 4 chains finished successfully.
//Mean chain execution time: 3.6 seconds.
//Total execution time: 4.5 seconds.
//
//Warning: 248 of 4000 (6.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__        -26.08 -25.72 2.94 2.80 -31.46 -21.84 1.00     1284     2181
// alpha         0.05   0.02 1.22 1.16  -1.97   2.07 1.01      565      811
// beta[1]       0.17   0.24 1.45 1.33  -2.35   2.43 1.01      349       74
// beta[2]      -1.03  -1.01 1.49 1.32  -3.35   1.36 1.01      972      806
// beta[3]       0.64   0.62 1.42 1.30  -1.60   2.99 1.00      926      755
// beta[4]       0.12   0.10 1.43 1.35  -2.19   2.48 1.00      713      846
// sigma         0.68   0.68 0.04 0.04   0.62   0.75 1.00     2264     1776
// tau[1]        0.67   0.61 0.45 0.47   0.06   1.52 1.01     1142     1166
// tau[2]        0.69   0.59 0.50 0.51   0.06   1.67 1.01      436       59
// Z[1,1]        0.04   0.03 0.96 0.96  -1.57   1.68 1.01      628       91
// Z[2,1]       -0.07  -0.05 0.97 0.97  -1.69   1.50 1.01     1824     2132
// Z[3,1]        0.03   0.02 0.95 0.95  -1.55   1.54 1.00     1910     1423
// Z[4,1]        0.00  -0.01 0.93 0.89  -1.53   1.60 1.00     2177     1862
// Z[1,2]        0.04   0.06 0.90 0.86  -1.48   1.52 1.01     2371     2206
// Z[2,2]       -0.09  -0.11 0.96 0.94  -1.64   1.52 1.00     2053     2196
// Z[3,2]        0.04   0.01 0.93 0.90  -1.44   1.55 1.00     2159     2389
// Z[4,2]       -0.01  -0.02 0.99 0.99  -1.62   1.67 1.00     1683     2191
// beta_j[1,1]   0.05   0.01 0.67 0.48  -1.07   1.25 1.00      694      658
// beta_j[2,1]  -0.08  -0.02 0.70 0.48  -1.36   1.01 1.01     1108     1101
// beta_j[3,1]   0.04   0.00 0.67 0.50  -1.04   1.22 1.00     1557     1351
// beta_j[4,1]   0.01   0.00 0.65 0.46  -1.07   1.11 1.00     1560     1485
// beta_j[1,2]   0.05   0.01 0.63 0.44  -0.97   1.15 1.00     1725     1506
// beta_j[2,2]  -0.09  -0.03 0.69 0.45  -1.39   1.07 1.01      544      158
// beta_j[3,2]   0.03   0.00 0.66 0.44  -1.05   1.20 1.01     1013      928
// beta_j[4,2]  -0.02  -0.01 0.72 0.50  -1.37   1.18 1.01      384       65
