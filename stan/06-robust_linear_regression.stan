// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
//  duncan[3:5]<- as.data.frame(scale(duncan[3:5]))
// duncan data
// beta[K] is:
// 1. income
// 2. education
data {
  int<lower=0> N;   // number of observations
  int<lower=0> K;   // number of independent variables
  matrix[N, K] X;   // data matrix
  vector[N] y;      // dependent variable vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for independent variables
  real<lower=0> sigma;  // model error
  real<lower=0> nu;     // student's t degrees of freedom
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  nu ~ lognormal(2, 1);

  // likelihood
  y ~ student_t(nu, alpha + X * beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.1 seconds.
//Total execution time: 0.3 seconds.
//
// variable  mean median    sd  mad    q5   q95 rhat ess_bulk ess_tail
//  lp__    -2.13  -1.79  1.61 1.42 -5.15 -0.19 1.00     1870     2526
//  alpha    0.00   0.00  0.06 0.06 -0.10  0.10 1.00     2873     2399
//  beta[1]  0.54   0.54  0.10 0.10  0.37  0.70 1.00     1576     2189
//  beta[2]  0.46   0.46  0.10 0.10  0.30  0.62 1.00     1806     2361
//  sigma    0.36   0.36  0.07 0.07  0.25  0.47 1.01     1565     1358
//  nu      10.15   6.65 12.12 4.88  2.05 30.17 1.01     1557     1895
