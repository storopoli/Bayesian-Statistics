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
  to_vector(beta_j) ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha + X * beta + X * beta_j * tau, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 3.6 seconds.
//Total execution time: 4.1 seconds.
//
//Warning: 141 of 4000 (4.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__        -25.92 -25.61 2.99 2.95 -31.28 -21.61 1.01     1515     2051
// alpha         0.00  -0.01 1.36 1.35  -2.11   2.23 1.00     1096     1973
// beta[1]       0.23   0.23 1.82 1.63  -2.66   3.12 1.00      784      641
// beta[2]      -0.80  -0.81 1.82 1.69  -3.66   2.31 1.01      704      209
// beta[3]       0.45   0.45 1.74 1.62  -2.33   3.27 1.00     1725     2050
// beta[4]       0.21   0.08 2.20 1.61  -2.88   3.37 1.01      327      163
// sigma         0.68   0.68 0.04 0.04   0.62   0.75 1.00     1475      752
// tau[1]        1.23   0.89 1.14 0.85   0.08   3.56 1.01      546      202
// tau[2]        1.17   0.91 1.01 0.82   0.09   3.23 1.01      761      297
// beta_j[1,1]   0.04   0.04 0.95 0.96  -1.53   1.55 1.00     2614     2054
// beta_j[2,1]  -0.13  -0.16 0.92 0.93  -1.63   1.39 1.01     2846     2437
// beta_j[3,1]   0.07   0.08 0.92 0.88  -1.44   1.53 1.00     2819     2091
// beta_j[4,1]   0.00   0.00 0.95 0.98  -1.57   1.61 1.00     1334      386
// beta_j[1,2]   0.02   0.02 0.94 0.91  -1.47   1.64 1.00     2421     2368
// beta_j[2,2]  -0.12  -0.15 0.93 0.89  -1.62   1.45 1.00     3345     2391
// beta_j[3,2]   0.08   0.10 0.93 0.93  -1.46   1.63 1.00     1691      756
// beta_j[4,2]  -0.03  -0.02 0.93 0.94  -1.56   1.50 1.00     2018     1908
