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
  int<lower=1> N;               // number of observations
  int<lower=1> K;               // number of independent variables
  matrix[N, K] X;               // data matrix
  array[N] int<lower=0> y;      // dependent variable vector
}
parameters {
  real alpha;                   // intercept
  vector[K] beta;               // coefficients for independent variables
  real<lower=0, upper=1> gamma; // overdispersion parameter for zero-inflated
  real phi_inv;              // overdispersion parameter of the negative binomial distribution
}
transformed parameters {
  real phi = 1/phi_inv;
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  gamma ~ beta(1, 1);
  phi_inv ~ gamma(0.01, 0.01);

  // likelihood
  for (n in 1:N) {
    if (y[n] == 0) {
      target += log_sum_exp(bernoulli_lpmf(1 | gamma),
                            bernoulli_lpmf(0 | gamma) +
                            neg_binomial_2_log_glm_lpmf(y[n] | to_matrix(X[n]), alpha, beta, phi));
    } else {
      target += bernoulli_lpmf(0 | gamma) +
                neg_binomial_2_log_glm_lpmf(y[n] | to_matrix(X[n]), alpha, beta, phi);
    }
  }
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 2.0 seconds.
//Total execution time: 2.2 seconds.
//
// variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
//  lp__    -899.38 -899.01 1.96 1.82 -903.11 -896.84 1.00     1527     2290
//  alpha      2.90    2.90 0.13 0.13    2.69    3.12 1.00     2527     2473
//  beta[1]    0.93    0.92 0.18 0.18    0.63    1.25 1.00     2930     2767
//  beta[2]   -0.37   -0.37 0.12 0.12   -0.57   -0.18 1.00     2841     2848
//  beta[3]   -0.14   -0.14 0.13 0.13   -0.34    0.07 1.00     3229     2601
//  beta[4]    0.18    0.17 0.20 0.19   -0.12    0.54 1.00     3252     2021
//  gamma      0.06    0.05 0.05 0.05    0.00    0.16 1.00     1417     1276
//  phi_inv    3.40    3.39 0.45 0.45    2.68    4.15 1.00     1991     2115
//  phi        0.30    0.29 0.04 0.04    0.24    0.37 1.00     1991     2115
