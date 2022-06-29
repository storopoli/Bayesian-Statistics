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
  int<lower=0> N;                     // number of observations
  int<lower=0> K;                     // number of independent variables
  matrix[N, K] X;                     // data matrix
  array[N] int<lower=0, upper=1> y;   // dependent variable vector
}
parameters {
  real alpha;                         // intercept
  vector[K] beta;                     // coefficients for independent variables
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);

  // likelihood
  y ~ bernoulli_logit(alpha + X * beta);
  // you could also do binomial_logit(n, logitp) if you can group the successes
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 1.5 seconds.
//Total execution time: 1.8 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    -1956.47 -1956.13 1.62 1.41 -1959.66 -1954.54 1.00     2083     2702
//  alpha       0.34     0.34 0.04 0.04     0.28     0.40 1.00     4202     3061
//  beta[1]     0.52     0.52 0.05 0.04     0.44     0.60 1.00     4421     3238
//  beta[2]    -0.35    -0.35 0.04 0.04    -0.41    -0.28 1.00     4923     3470
//  beta[4]     0.17     0.17 0.04 0.04     0.11     0.24 1.00     4036     3218
//  beta[3]    -0.06    -0.06 0.04 0.04    -0.12     0.00 1.00     4604     3243
