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

  // beta_j
  for (k in 1:K) {
    for (j in 1:J) {
      beta_j[k, j] ~ normal(0, 1);
    }
  }

  // likelihood
  y ~ normal(alpha + X * beta + X * beta_j * tau, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 3.6 seconds.
//Total execution time: 3.9 seconds.
//
//Warning: 110 of 4000 (3.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__        -25.75 -25.29 3.09 2.89 -31.47 -21.50 1.00     1309     2028
// alpha         0.04   0.05 1.34 1.28  -2.15   2.29 1.00     1737     1549
// beta[1]       0.17   0.21 1.74 1.54  -2.57   2.86 1.00     1677     1379
// beta[2]      -0.85  -0.86 1.69 1.58  -3.51   1.90 1.00     2238     2058
// beta[3]       0.50   0.52 1.79 1.59  -2.37   3.37 1.00     1479     1032
// beta[4]       0.01   0.02 1.72 1.55  -2.76   2.71 1.00     1951     1750
// sigma         0.68   0.68 0.04 0.04   0.62   0.75 1.00     3194     2427
// tau[1]        1.18   0.88 1.07 0.81   0.08   3.18 1.00     1377      966
// tau[2]        1.17   0.93 1.01 0.81   0.08   3.20 1.00     1494     1027
// beta_j[1,1]   0.05   0.06 0.90 0.90  -1.41   1.58 1.00     3112     2606
// beta_j[2,1]  -0.14  -0.17 0.91 0.89  -1.64   1.40 1.00     2877     2263
// beta_j[3,1]   0.04   0.05 0.93 0.94  -1.47   1.57 1.00     2248     1452
// beta_j[4,1]   0.02   0.01 0.95 0.90  -1.54   1.56 1.00     2927     1334
// beta_j[1,2]   0.03   0.05 0.92 0.91  -1.49   1.50 1.00     3020     1705
// beta_j[2,2]  -0.13  -0.14 0.94 0.91  -1.68   1.44 1.00     2436     2397
// beta_j[3,2]   0.11   0.10 0.95 0.93  -1.45   1.63 1.00     2259     1258
// beta_j[4,2]   0.02   0.02 0.91 0.90  -1.49   1.54 1.00     2867     1343
