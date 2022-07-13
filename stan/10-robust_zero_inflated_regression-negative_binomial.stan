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
                            neg_binomial_2_log_lpmf(y[n] | alpha + X[n] * beta, phi));
    } else {
      target += bernoulli_lpmf(0 | gamma) +
                 neg_binomial_2_log_lpmf(y[n] | alpha + X[n] * beta, phi);
    }
  }
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 1.1 seconds.
//Total execution time: 1.2 seconds.
//
// variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
//  lp__    -899.31 -898.94 1.94 1.72 -903.01 -896.81 1.00     1567     1989
//  alpha      2.90    2.90 0.13 0.13    2.69    3.12 1.00     2298     1719
//  beta[1]    0.93    0.92 0.19 0.18    0.64    1.26 1.00     2785     2628
//  beta[2]   -0.37   -0.37 0.12 0.12   -0.57   -0.17 1.00     3044     2438
//  beta[3]   -0.14   -0.14 0.12 0.12   -0.34    0.07 1.00     3276     1801
//  beta[4]    0.18    0.16 0.20 0.19   -0.11    0.52 1.00     3399     2014
//  gamma      0.06    0.05 0.05 0.05    0.01    0.16 1.00     1692     1959
//  phi_inv    3.39    3.39 0.46 0.45    2.63    4.13 1.00     1927     1409
//  phi        0.30    0.29 0.04 0.04    0.24    0.38 1.00     1927     1417
