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
  int<lower=0> N;            // number of observations
  int<lower=0> K;            // number of independent variables
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
  y ~ poisson_log_glm(X, alpha, beta);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.1 seconds.
//Total execution time: 0.2 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    17602.09 17602.40 1.54 1.33 17599.10 17604.00 1.00     1669     2405
//  alpha       2.98     2.98 0.01 0.01     2.96     3.00 1.00     3922     2922
//  beta[1]     0.49     0.49 0.01 0.01     0.48     0.50 1.00     4528     3183
//  beta[2]    -0.25    -0.25 0.01 0.01    -0.27    -0.23 1.00     4881     2964
//  beta[3]    -0.18    -0.18 0.02 0.02    -0.20    -0.15 1.00     4642     2790
//  beta[4]     0.05     0.05 0.01 0.01     0.03     0.07 1.00     5037     3012
