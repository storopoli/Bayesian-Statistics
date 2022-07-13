// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// cheese$y <- as.numeric(scale(cheese$y))
// cheese$cheese_A <- ifelse(cheese$cheese == "A", 1, 0)
// cheese$cheese_B <- ifelse(cheese$cheese == "B", 1, 0)
// cheese$cheese_C <- ifelse(cheese$cheese == "C", 1, 0)
// cheese$cheese_D <- ifelse(cheese$cheese == "D", 1, 0)
// cheese$background_int <- ifelse(cheese$background == "urban", 1, 2)
// cheese data
// beta[K] is:
// 1. cheese_A
// 2. cheese_B
// 3. cheese_C
// 4. cheese_D
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
  real<lower=0> tau;                     // group-level SD intercepts
  vector[J] z_j;                         // group-level non-centered intercepts
}
transformed parameters {
  vector[J] alpha_j = z_j * tau;         // group-level intercepts
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau ~ cauchy(0, 2);
  z_j ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha + alpha_j[idx] + X * beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 1.1 seconds.
//Total execution time: 1.3 seconds.
//
//Warning: 40 of 4000 (1.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//   variable  mean median   sd  mad    q5  q95 rhat ess_bulk ess_tail
// lp__       -2.16  -1.78 2.24 2.04 -6.43 0.87 1.00     1071     1648
// alpha       0.05   0.05 1.30 1.24 -2.03 2.21 1.00      939      984
// beta[1]     0.31   0.31 1.16 1.10 -1.52 2.13 1.00      836      870
// beta[2]    -1.24  -1.24 1.16 1.10 -3.05 0.58 1.00      838      914
// beta[3]     0.73   0.72 1.16 1.09 -1.11 2.54 1.00      846      914
// beta[4]     0.10   0.09 1.16 1.11 -1.72 1.92 1.00      845      900
// sigma       0.60   0.60 0.03 0.03  0.55 0.66 1.00     2302     1830
// tau         1.11   0.83 0.85 0.60  0.27 2.86 1.01     1005     1178
// z_j[1]      0.43   0.40 0.73 0.71 -0.73 1.67 1.00     1659     1799
// z_j[2]     -0.49  -0.45 0.74 0.71 -1.79 0.64 1.00     1618     1473
// alpha_j[1]  0.29   0.30 0.76 0.51 -1.00 1.51 1.00     1495     1361
// alpha_j[2] -0.34  -0.32 0.76 0.52 -1.62 0.89 1.00     1493     1500
