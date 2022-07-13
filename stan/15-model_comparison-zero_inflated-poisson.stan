// run with 4 chains and 2k iters.
// X data should be scaled to mean 0 and std 1:
// roaches[2:5] <- as.data.frame(scale(roaches[2:5]))
// loo_zero_inflated_poisson <- zero_inflated_poisson_fit$loo()
// loo_compare(loo_poisson, loo_neg_binomial, loo_zero_inflated_poisson, loo_zero_inflated_neg_binomial)
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
generated quantities{
  vector[N] log_lik;
  for (n in 1:N) {
    if (y[n] == 0) {
      log_lik[n] = log_sum_exp(bernoulli_lpmf(1 | gamma),
                               bernoulli_lpmf(0 | gamma) +
                               poisson_log_lpmf(y[n] | alpha + X[n] * beta));
    } else {
      log_lik[n] = bernoulli_lpmf(0 | gamma) +
                   poisson_log_lpmf(y[n] | alpha + X[n] * beta);
    }
  }
}
// loo results:
//       elpd_diff se_diff
//model2     0.0       0.0
//model4    -0.9       0.6
//model3 -3648.4     545.5
//model1 -5364.1     717.6
