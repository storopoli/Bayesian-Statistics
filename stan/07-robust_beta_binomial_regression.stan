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
  int<lower=1> N;                     // number of observations
  int<lower=1> K;                     // number of independent variables
  matrix[N, K] X;                     // data matrix
  array[N] int<lower=0, upper=1> y;   // dependent variable vector
}
parameters {
  real alpha;                         // intercept
  vector[K] beta;                     // coefficients for independent variables
  real<lower=0> phi;                  // overdispersion parameter beta (renamed as phi)
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  phi ~ exponential(1);

  // likelihood
  // alternative parameterization
  y ~ beta_binomial(
    1,                                      // n in beta binomial
    inv_logit(alpha + X * beta) * phi,      // alpha in beta binomial
    (1 - inv_logit(alpha + X * beta)) * phi); // beta in beta binomial
  // you could also do beta_binomial(n, alpha, phi) if you can group the successes
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 9.0 seconds.
//Total execution time: 9.5 seconds.
//
// variable     mean   median   sd  mad       q5      q95 rhat ess_bulk ess_tail
//  lp__    -1958.10 -1957.77 1.81 1.62 -1961.64 -1955.85 1.00     1841     2105
//  alpha       0.34     0.34 0.04 0.04     0.27     0.40 1.00     4863     3010
//  beta[1]     0.52     0.52 0.05 0.05     0.44     0.59 1.00     4138     2742
//  beta[2]    -0.35    -0.35 0.04 0.04    -0.41    -0.28 1.00     4589     2885
//  beta[3]    -0.06    -0.06 0.04 0.04    -0.12     0.00 1.00     5347     3107
//  beta[4]     0.17     0.17 0.04 0.04     0.11     0.23 1.00     4809     2602
//  phi         1.01     0.65 1.05 0.69     0.05     3.22 1.00     3769     1885
