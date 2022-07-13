// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// cheese$y <- as.numeric(scale(cheese$y))
// cheese$cheese_A <- ifelse(cheese$cheese == "A", 1, 0)
// cheese$cheese_B <- ifelse(cheese$cheese == "B", 1, 0)
// cheese$cheese_C <- ifelse(cheese$cheese == "C", 1, 0)
// cheese$cheese_D <- ifelse(cheese$cheese == "D", 1, 0)
// cheese$background_int <- ifelse(cheese$background == "urban", 1, 2)
// cheese data
// beta[K, J] rows are:
// 1. cheese_A
// 2. cheese_B
// 3. cheese_C
// 4. cheese_D
// beta [K, J] columns are:
// 1. urban
// 2. rural
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
  vector<lower=0>[J] tau;                // group-level SD slopes
  matrix[K, J] beta_j;                   // group-level slopes
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau ~ cauchy(0, 2);
  for (j in 1:J) to_vector(beta_j[, j]) ~ normal(0, tau[j]);

  // likelihood
  y ~ normal(alpha + X * beta + X * beta_j * tau, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 2.7 seconds.
//Total execution time: 3.0 seconds.
//
//Warning: 96 of 4000 (2.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__        -20.59 -21.16 5.52 5.32 -28.68 -10.38 1.02      186      264
// alpha         0.05   0.06 1.29 1.20  -2.04   2.20 1.00     1277     1366
// beta[1]       0.22   0.21 1.53 1.36  -2.28   2.72 1.00     1482     1439
// beta[2]      -1.01  -1.09 1.62 1.42  -3.49   1.68 1.00     1454     1049
// beta[3]       0.62   0.64 1.59 1.34  -2.00   3.24 1.00     1714     1756
// beta[4]       0.08   0.06 1.57 1.37  -2.29   2.53 1.00     1407     1725
// sigma         0.68   0.68 0.04 0.04   0.62   0.75 1.01     1310     2576
// tau[1]        0.76   0.70 0.52 0.53   0.07   1.74 1.01      328      323
// tau[2]        0.71   0.60 0.55 0.55   0.03   1.75 1.02      157       81
// beta_j[1,1]   0.02   0.00 0.78 0.50  -1.31   1.33 1.01     2633     1616
// beta_j[2,1]  -0.11  -0.02 0.80 0.53  -1.58   1.12 1.01     2257     1505
// beta_j[3,1]   0.03   0.00 0.80 0.57  -1.30   1.46 1.00     2199     1472
// beta_j[4,1]   0.02   0.01 0.78 0.55  -1.30   1.33 1.01     2289     1526
// beta_j[1,2]   0.03   0.00 0.74 0.46  -1.16   1.31 1.02     2637     1463
// beta_j[2,2]  -0.08  -0.01 0.75 0.45  -1.37   1.09 1.02     2573     1402
// beta_j[3,2]   0.02   0.00 0.74 0.44  -1.21   1.33 1.02     2887     1460
// beta_j[4,2]   0.00   0.00 0.75 0.44  -1.26   1.20 1.01     2921     1817
