// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// cheese$y <- as.numeric(scale(cheese$y))
// cheese$cheese_A <- ifelse(cheese$cheese == "A", 1, 0)
// cheese$cheese_B <- ifelse(cheese$cheese == "B", 1, 0)
// cheese$cheese_C <- ifelse(cheese$cheese == "C", 1, 0)
// cheese$cheese_D <- ifelse(cheese$cheese == "D", 1, 0)
// cheese$background_int <- ifelse(cheese$background == "urban", 1, 2)
// cheese data
// beta[K] is:
// 1. cheese_A
// 2. cheese_B
// 3. cheese_C
// 4. cheese_D
data {
  int<lower=1> N;                        // number of observations
  int<lower=1> K;                        // number of independent variables
  matrix[N, K] X;                        // data matrix
  vector[N] y;                           // dependent variable vector
  int<lower=2> J;                        // number of groups
  array[N] int<lower=1, upper=J> idx;    // group membership
}
parameters {
  real alpha;                            // intercept
  vector[K] beta;                        // coefficients for independent variables
  real<lower=0> sigma;                   // model error
  real<lower=0> tau;                     // group-level SD intercepts
  vector[J] alpha_j;                     // group-level intercepts
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau ~ cauchy(0, 2);
  alpha_j ~ normal(alpha, tau);

  // likelihood
  y ~ normal(alpha_j[idx] + X * beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 1.0 seconds.
//Total execution time: 1.1 seconds.
//
//   variable  mean median   sd  mad    q5  q95 rhat ess_bulk ess_tail
// lp__       -2.14  -1.77 2.37 2.24 -6.57 1.07 1.00     1024     1655
// alpha       0.04   0.03 1.39 1.23 -2.16 2.28 1.01      833      870
// beta[1]     0.26   0.29 1.09 1.06 -1.51 1.99 1.01      746     1003
// beta[2]    -1.29  -1.27 1.09 1.06 -3.07 0.43 1.01      741     1008
// beta[3]     0.68   0.70 1.09 1.06 -1.10 2.38 1.01      743     1000
// beta[4]     0.05   0.07 1.09 1.06 -1.71 1.76 1.01      752     1022
// sigma       0.61   0.60 0.03 0.03  0.55 0.66 1.00     2169     1812
// tau         1.32   0.90 1.42 0.67  0.28 3.74 1.01      763      782
// alpha_j[1]  0.35   0.31 1.09 0.57 -1.24 1.99 1.01      592      305
// alpha_j[2] -0.27  -0.32 1.10 0.56 -1.85 1.36 1.01      586      299
