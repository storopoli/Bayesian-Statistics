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
  int<lower=1> N;                          // number of observations
  int<lower=1> K;                          // number of independent variables
  matrix[N, K] X;                          // data matrix
  vector[N] y;                             // dependent variable vector
  int<lower=2> J;                          // number of groups
  array[N] int<lower=1, upper=J> idx;      // group membership
}
parameters {
  real alpha;                              // intercept
  vector[K] beta;                          // coefficients for independent variables
  real<lower=0> sigma;                     // model error
  real<lower=0> tau_alpha;                 // group-level SD intercepts
  vector[J] z_alpha;                       // group-level non-centered intercepts
  vector<lower=0>[J] tau_beta;             // group-level SD slopes
  matrix[K, J] Z_beta;                     // group-level non-centered slopes
}
transformed parameters {
  vector[J] alpha_j = z_alpha * tau_alpha; // group-level intercepts
  matrix[K, J] beta_j;                     // group-level slopes
  for (j in 1:J) beta_j[, j] = Z_beta[, j] * tau_beta[j];
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau_alpha ~ cauchy(0, 2);
  tau_beta ~ cauchy(0, 2);
  z_alpha ~ normal(0, tau_alpha);
  to_vector(Z_beta) ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha + alpha_j[idx] + X * beta + X * beta_j * tau_beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 5.0 seconds.
//Total execution time: 5.6 seconds.
//
//Warning: 165 of 4000 (4.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable  mean median   sd  mad     q5   q95 rhat ess_bulk ess_tail
// lp__        -7.78  -7.42 3.28 3.19 -13.80 -2.98 1.00     1145     1777
// alpha       -0.01  -0.01 1.44 1.31  -2.26  2.23 1.01     1239     1428
// beta[1]      0.23   0.26 1.43 1.31  -2.11  2.64 1.00     1212     1322
// beta[2]     -0.96  -1.01 1.46 1.37  -3.26  1.43 1.01     1311     1286
// beta[3]      0.64   0.66 1.46 1.29  -1.81  3.01 1.00     1117     1038
// beta[4]      0.13   0.09 1.40 1.28  -2.14  2.43 1.00     1317     1213
// sigma        0.60   0.60 0.03 0.04   0.55  0.66 1.00     3036     2218
// tau_alpha    1.01   0.87 0.52 0.36   0.49  1.99 1.00     1882     2195
// z_alpha[1]   0.37   0.41 0.68 0.63  -0.82  1.43 1.00     1151     1196
// z_alpha[2]  -0.36  -0.40 0.69 0.62  -1.44  0.82 1.01     1230     1168
// tau_beta[1]  0.67   0.61 0.46 0.50   0.06  1.49 1.00     1178     1380
// tau_beta[2]  0.69   0.61 0.47 0.49   0.07  1.54 1.01     1574     1127
// Z_beta[1,1]  0.04   0.04 0.98 0.95  -1.57  1.66 1.00     3486     2273
// Z_beta[2,1] -0.09  -0.09 0.95 0.97  -1.67  1.49 1.00     2766     2162
// Z_beta[3,1]  0.03   0.05 0.95 0.95  -1.57  1.56 1.00     2462      885
// Z_beta[4,1]  0.00  -0.01 0.96 0.96  -1.56  1.60 1.00     3100     2411
// Z_beta[1,2]  0.03   0.06 0.99 0.96  -1.63  1.62 1.00     3277     2490
// Z_beta[2,2] -0.10  -0.11 0.95 0.93  -1.64  1.47 1.00     2883     2226
// Z_beta[3,2]  0.03   0.02 0.92 0.94  -1.43  1.55 1.00     3011     2707
// Z_beta[4,2]  0.02   0.00 0.95 0.94  -1.57  1.59 1.00     2699     2487
// alpha_j[1]   0.32   0.30 0.94 0.51  -1.09  1.69 1.00     1086     1190
// alpha_j[2]  -0.29  -0.29 0.93 0.51  -1.72  1.07 1.00     1118     1210
// beta_j[1,1]  0.04   0.01 0.71 0.46  -1.20  1.31 1.00     2091     1425
// beta_j[2,1] -0.09  -0.02 0.69 0.46  -1.32  1.06 1.00     2058     1036
// beta_j[3,1]  0.03   0.01 0.70 0.45  -1.15  1.19 1.00     1620      934
// beta_j[4,1]  0.00   0.00 0.66 0.48  -1.12  1.15 1.00     2254     1325
// beta_j[1,2]  0.05   0.01 0.72 0.50  -1.14  1.31 1.00     1803     1015
// beta_j[2,2] -0.12  -0.03 0.73 0.48  -1.46  0.96 1.00     1761     1051
// beta_j[3,2]  0.05   0.00 0.68 0.47  -1.07  1.29 1.00     1730     1201
// beta_j[4,2]  0.01   0.00 0.69 0.48  -1.20  1.26 1.00     1747      973
