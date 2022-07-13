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
  real<lower=0> tau_alpha;               // group-level SD intercepts
  vector[J] alpha_j;                     // group-level intercepts
  vector<lower=0>[J] tau_beta;           // group-level SD slopes
  matrix[K, J] beta_j;                   // group-level slopes
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau_alpha ~ cauchy(0, 2);
  tau_beta ~ cauchy(0, 2);
  alpha_j ~ normal(0, tau_alpha);
  for (j in 1:J) to_vector(beta_j[, j]) ~ normal(0, tau_beta[j]);

  // likelihood
  y ~ normal(alpha + alpha_j[idx] + X * beta + X * beta_j * tau_beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 4.1 seconds.
//Total execution time: 4.6 seconds.
//
//Warning: 60 of 4000 (2.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable  mean median   sd  mad     q5  q95 rhat ess_bulk ess_tail
// lp__        -2.61  -2.84 5.19 5.03 -10.77 6.27 1.01      366      405
// alpha       -0.01   0.01 1.49 1.34  -2.43 2.28 1.00     1242     1512
// beta[1]      0.24   0.27 1.54 1.40  -2.17 2.70 1.00     1587     1441
// beta[2]     -0.95  -0.96 1.60 1.41  -3.40 1.62 1.00     1629     1562
// beta[3]      0.61   0.64 1.61 1.47  -1.97 3.17 1.00     1538     1625
// beta[4]      0.11   0.14 1.50 1.33  -2.31 2.53 1.00     1696     1901
// sigma        0.60   0.60 0.03 0.03   0.55 0.66 1.00     3243     2518
// tau_alpha    1.31   0.89 1.51 0.67   0.27 3.71 1.00     1335     1256
// alpha_j[1]   0.30   0.29 1.00 0.57  -1.18 1.74 1.00     1164     1101
// alpha_j[2]  -0.33  -0.32 1.00 0.57  -1.79 1.06 1.00     1167     1068
// tau_beta[1]  0.74   0.66 0.52 0.54   0.07 1.74 1.01      308      328
// tau_beta[2]  0.75   0.67 0.50 0.52   0.10 1.67 1.00      361      480
// beta_j[1,1]  0.04   0.01 0.80 0.53  -1.28 1.42 1.01     2153     1167
// beta_j[2,1] -0.10  -0.03 0.74 0.48  -1.48 1.08 1.01     2267     1665
// beta_j[3,1]  0.08   0.03 0.77 0.50  -1.12 1.37 1.00     2324     1378
// beta_j[4,1]  0.02   0.00 0.72 0.50  -1.16 1.24 1.00     2590     1302
// beta_j[1,2]  0.04   0.01 0.72 0.51  -1.12 1.30 1.00     2197     1461
// beta_j[2,2] -0.09  -0.02 0.77 0.53  -1.48 1.12 1.00     2393     1914
// beta_j[3,2]  0.05   0.02 0.77 0.53  -1.20 1.41 1.00     2346     1521
// beta_j[4,2]  0.01   0.00 0.76 0.51  -1.26 1.28 1.00     2274     1528
