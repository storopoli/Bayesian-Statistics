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
  y ~ neg_binomial_2_log(alpha + X * beta, phi);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.4 seconds.
//Total execution time: 0.5 seconds.
//
// variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
//  lp__    -895.51 -895.13 1.74 1.59 -898.89 -893.36 1.00     1969     2709
//  alpha      2.84    2.84 0.12 0.12    2.64    3.05 1.00     5980     3147
//  beta[1]    0.98    0.97 0.19 0.18    0.68    1.31 1.00     6160     2848
//  beta[2]   -0.38   -0.37 0.12 0.12   -0.58   -0.17 1.00     6075     3104
//  beta[3]   -0.15   -0.15 0.12 0.12   -0.35    0.05 1.00     5584     3130
//  beta[4]    0.18    0.16 0.19 0.19   -0.11    0.52 1.00     5501     2923
//  phi_inv    3.79    3.78 0.35 0.35    3.24    4.42 1.00     5897     3107
//  phi        0.27    0.26 0.02 0.02    0.23    0.31 1.00     5897     3107
