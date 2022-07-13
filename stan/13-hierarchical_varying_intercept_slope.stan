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
  int<lower=0> J;                        // number of groups
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

  // beta_j
  for (k in 1:K) {
    for (j in 1:J) {
      beta_j[k, j] ~ normal(0, 1);
    }
  }

  // likelihood
  y ~ normal(alpha + alpha_j[idx] + X * beta + X * beta_j * tau_beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 4.7 seconds.
//Total execution time: 5.0 seconds.
//
//Warning: 136 of 4000 (3.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable  mean median   sd  mad     q5   q95 rhat ess_bulk ess_tail
// lp__        -7.43  -7.11 3.24 3.14 -13.31 -2.80 1.00     1298     2083
// alpha       -0.01   0.01 1.52 1.36  -2.53  2.42 1.00     1360     1620
// beta[1]      0.17   0.23 1.77 1.60  -2.75  3.03 1.00     1247     1930
// beta[2]     -0.87  -0.91 1.73 1.57  -3.66  1.93 1.00     1813     2158
// beta[3]      0.49   0.51 1.70 1.55  -2.28  3.27 1.00     1959     1999
// beta[4]      0.13   0.10 1.69 1.53  -2.67  3.01 1.00     2402     2106
// sigma        0.60   0.60 0.04 0.04   0.55  0.67 1.00     3981     2753
// tau_alpha    1.36   0.92 1.48 0.70   0.28  3.78 1.00     1307     1496
// alpha_j[1]   0.34   0.32 1.02 0.58  -1.17  1.95 1.01      972      873
// alpha_j[2]  -0.29  -0.29 1.02 0.57  -1.82  1.32 1.01      976      848
// tau_beta[1]  1.16   0.89 1.00 0.82   0.09  3.11 1.00     1466     1425
// tau_beta[2]  1.18   0.89 1.05 0.84   0.09  3.25 1.00     1336      558
// beta_j[1,1]  0.04   0.02 0.92 0.94  -1.49  1.51 1.00     3412     2708
// beta_j[2,1] -0.13  -0.16 0.94 0.94  -1.61  1.47 1.00     3510     2588
// beta_j[3,1]  0.06   0.10 0.92 0.89  -1.45  1.53 1.00     3618     2510
// beta_j[4,1] -0.02  -0.03 0.97 0.95  -1.55  1.62 1.00     1934      792
// beta_j[1,2]  0.05   0.06 0.93 0.93  -1.49  1.58 1.00     3839     2676
// beta_j[2,2] -0.12  -0.12 0.94 0.93  -1.68  1.45 1.00     4189     2818
// beta_j[3,2]  0.06   0.09 0.94 0.94  -1.48  1.59 1.00     3886     2522
// beta_j[4,2]  0.02   0.02 0.91 0.92  -1.46  1.46 1.00     2971     2461
