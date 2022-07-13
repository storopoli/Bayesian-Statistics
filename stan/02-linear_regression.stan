// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// kidiq <- as.data.frame(scale(kidiq))
// kidiq data
// beta[K] is:
// 1. mom_hs
// 2. mom_iq
// 3. mom_age
data {
  int<lower=1> N;   // number of observations
  int<lower=1> K;   // number of independent variables
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
  y ~ normal(alpha + X * beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.1 seconds.
//Total execution time: 0.2 seconds.
//
// variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
//  lp__    -167.57 -167.24 1.60 1.43 -170.58 -165.59 1.00     2278     2794
//  alpha      0.00    0.00 0.04 0.04   -0.07    0.07 1.00     4673     3250
//  beta[1]    0.11    0.11 0.05 0.04    0.04    0.19 1.00     3944     3249
//  beta[2]    0.41    0.41 0.05 0.05    0.34    0.49 1.00     3949     3357
//  beta[3]    0.03    0.03 0.04 0.04   -0.04    0.11 1.00     4536     3114
//  sigma      0.89    0.89 0.03 0.03    0.84    0.94 1.00     4232     2945
