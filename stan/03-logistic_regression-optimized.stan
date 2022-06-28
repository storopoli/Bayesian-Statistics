// run with 4 chains and 2k iters.
// X data should be scaled to mean 0 and std 1:
// wells[2:5] <- as.data.frame(scale(wells[2:5]))
// wells data
// beta[K] is:
// 1. arsenic
// 2. dist
// 3. assoc
// 4. educ
data {
  int<lower=0> N;   // number of observations
  int<lower=0> K;   // number of independent variables
  matrix[N, K] X;   // data matrix
  array[N] int y;   // dependent variable vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for independent variables
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);

  // likelihood
  y ~ bernoulli_logit_glm(X, alpha, beta);
  // no binomial_logit_glm available in Stan <=2.29
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 1.0 seconds.
//Total execution time: 1.1 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    -1956.49 -1956.14 1.60 1.45 -1959.56 -1954.52 1.00     2246     2928
//  alpha       0.34     0.34 0.04 0.04     0.27     0.40 1.00     4628     2899
//  beta[1]     0.52     0.52 0.05 0.05     0.45     0.59 1.00     4535     3108
//  beta[2]    -0.35    -0.35 0.04 0.04    -0.41    -0.28 1.00     4220     3329
//  beta[3]    -0.06    -0.06 0.04 0.04    -0.12     0.00 1.00     4826     2916
//  beta[4]     0.17     0.17 0.04 0.04     0.11     0.24 1.00     4728     3176
