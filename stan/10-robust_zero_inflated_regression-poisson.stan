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
  int<lower=0> N;               // number of observations
  int<lower=0> K;               // number of independent variables
  matrix[N, K] X;               // data matrix
  array[N] int<lower=0> y;      // dependent variable vector
}
parameters {
  real alpha;                   // intercept
  vector[K] beta;               // coefficients for independent variables
  real<lower=0, upper=1> gamma; // overdispersion parameter for zero-inflated
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  gamma ~ beta(1, 1);

  // likelihood
  for (n in 1:N) {
    if (y[n] == 0) {
      target += log_sum_exp(bernoulli_lpmf(1 | gamma),
                            bernoulli_lpmf(0 | gamma) +
                            poisson_log_lpmf(y[n] | alpha + X[n] * beta));
    } else {
      target += bernoulli_lpmf(0 | gamma) +
                poisson_log_lpmf(y[n] | alpha + X[n] * beta);
    }
  }
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.5 seconds.
//Total execution time: 0.6 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    -4405.71 -4405.31 1.80 1.56 -4409.11 -4403.51 1.00     1801     2571
//  alpha       3.41     3.41 0.01 0.02     3.38     3.43 1.00     4171     3256
//  beta[1]     0.39     0.39 0.01 0.01     0.38     0.40 1.00     4916     3047
//  beta[2]    -0.22    -0.22 0.01 0.01    -0.24    -0.20 1.00     5039     2638
//  beta[3]    -0.08    -0.08 0.02 0.02    -0.10    -0.05 1.00     5637     3125
//  beta[4]     0.03     0.03 0.01 0.01     0.01     0.05 1.00     5874     3171
//  gamma       0.36     0.36 0.03 0.03     0.31     0.41 1.00     5250     2539
