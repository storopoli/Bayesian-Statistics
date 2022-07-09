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
  real<lower=2> nu;                   // degrees of freedom
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  nu ~ gamma(2, 0.1);

  // likelihood
  vector[N] p_hat;
  for (n in 1:N) p_hat[n] = student_t_cdf(alpha + X[n] * beta, nu, 0, sqrt((nu - 2)/nu));
  y ~ bernoulli(p_hat);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 210.0 seconds.
//Total execution time: 215.7 seconds.
//
//Warning: 6 of 4000 (0.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
// variable     mean   median    sd   mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    -1953.58 -1953.26  1.69  1.50 -1956.78 -1951.51 1.00     2018     2857
//  alpha       0.19     0.19  0.02  0.03     0.15     0.23 1.00     3352     2449
//  beta[1]     0.29     0.29  0.03  0.03     0.24     0.34 1.00     2828     2065
//  beta[2]    -0.20    -0.20  0.03  0.03    -0.24    -0.16 1.00     2900     2196
//  beta[3]    -0.04    -0.04  0.02  0.02    -0.07     0.00 1.00     4352     2548
//  beta[4]     0.10     0.10  0.02  0.02     0.06     0.14 1.00     4084     2697
//  nu         19.65    16.06 13.64 11.40     4.95    47.08 1.00     2325     1635
