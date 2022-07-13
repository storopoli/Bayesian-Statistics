// run with 4 chains and 2k iters.
// X data should be scaled to mean 0 and std 1:
// roaches[2:5] <- as.data.frame(scale(roaches[2:5]))
// roaches data
// beta[K] is:
// 1. roach1
// 2. treatment
// 3. senior
// 4. exposure2
data {
  int<lower=1> N;            // number of observations
  int<lower=1> K;            // number of independent variables
  matrix[N, K] X;            // data matrix
  array[N] int<lower=0> y;   // dependent variable vector
}
parameters {
  real alpha;                // intercept
  vector[K] beta;            // coefficients for independent variables
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);

  // likelihood
  y ~ poisson_log(alpha + X * beta);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.1 seconds.
//Total execution time: 0.3 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    17602.02 17602.30 1.58 1.48 17598.90 17604.00 1.00     1778     2471
//  alpha       2.98     2.98 0.01 0.01     2.96     3.01 1.00     3899     2610
//  beta[1]     0.49     0.49 0.01 0.01     0.48     0.50 1.00     4415     3108
//  beta[2]    -0.25    -0.25 0.01 0.01    -0.27    -0.23 1.00     4788     3050
//  beta[3]    -0.18    -0.18 0.02 0.02    -0.20    -0.15 1.00     4777     3035
//  beta[4]     0.05     0.05 0.01 0.01     0.03     0.07 1.00     5083     3017
