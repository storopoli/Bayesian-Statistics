// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// kidiq <- as.data.frame(scale(kidiq))
// kidiq data
// beta[K] is:
// 1. mom_hs
// 2. mom_iq
// 3. mom_age
data {
  int<lower=0> N;   // number of observations
  int<lower=0> K;   // number of independent variables
  matrix[N, K] X;   // data matrix
  vector[N] y;      // dependent variable vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for independent variables
  real<lower=0> sigma;  // model error
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);

  // likelihood
  y ~ normal_id_glm(X, alpha, beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.1 seconds.
//Total execution time: 0.2 seconds.
//
// variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
//  lp__    -167.54 -167.21 1.62 1.40 -170.69 -165.61 1.00     1802     2538
//  alpha      0.00    0.00 0.04 0.04   -0.07    0.07 1.00     4240     2996
//  beta[1]    0.11    0.11 0.05 0.05    0.04    0.19 1.00     3932     2790
//  beta[2]    0.41    0.41 0.05 0.04    0.34    0.49 1.00     4357     3146
//  beta[3]    0.03    0.03 0.04 0.04   -0.04    0.10 1.00     4603     2745
//  sigma      0.89    0.89 0.03 0.03    0.84    0.94 1.00     4535     3089

