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
  real phi_inv;              // overdispersion parameter of the negative binomial distribution
}
transformed parameters {
  real phi = 1/phi_inv;
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  phi_inv ~ gamma(0.01, 0.01);

  // likelihood
  y ~ neg_binomial_2_log_glm(X, alpha, beta, phi);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.2 seconds.
//Total execution time: 0.2 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    22802.42 22802.80 1.77 1.63 22799.10 22804.60 1.00     1855     2499
//  alpha       2.84     2.84 0.12 0.12     2.64     3.05 1.00     6039     2740
//  beta[1]     0.98     0.97 0.19 0.18     0.69     1.31 1.00     5735     3173
//  beta[2]    -0.38    -0.37 0.12 0.12    -0.57    -0.18 1.00     6237     2911
//  beta[3]    -0.15    -0.15 0.12 0.12    -0.36     0.05 1.00     5817     3275
//  beta[4]     0.18     0.17 0.20 0.19    -0.11     0.53 1.00     4593     2750
//  phi_inv     3.78     3.76 0.36 0.35     3.25     4.40 1.00     5702     2794
//  phi         0.27     0.27 0.02 0.03     0.23     0.31 1.00     5702     2794
