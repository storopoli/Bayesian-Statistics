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
  real<lower=0> tau_alpha;               // group-level SD intercepts
  vector[J] alpha_j;                     // group-level intercepts
  vector<lower=0>[J] tau_beta;           // group-level SD slopes
  matrix[K, J] beta_j;                   // group-level slopes
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  beta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  tau_alpha ~ cauchy(0, 2);
  tau_beta ~ cauchy(0, 2);
  alpha_j ~ normal(0, tau_alpha);
  to_vector(beta_j) ~ normal(0, 1);

  // likelihood
  y ~ normal(alpha + alpha_j[idx] + X * beta + X * beta_j * tau_beta, sigma);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 4.6 seconds.
//Total execution time: 5.2 seconds.
//
//Warning: 274 of 4000 (7.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//    variable  mean median   sd  mad     q5   q95 rhat ess_bulk ess_tail
// lp__        -7.31  -6.93 3.23 3.10 -13.10 -2.66 1.01     1291     1682
// alpha       -0.08  -0.08 1.47 1.52  -2.41  2.31 1.02      314     1409
// beta[1]      0.18   0.11 1.67 1.56  -2.25  2.92 1.01      431     2019
// beta[2]     -0.92  -1.06 1.68 1.47  -3.56  1.93 1.02     2061     2118
// beta[3]      0.17   0.43 2.36 1.74  -5.50  3.31 1.09       38       11
// beta[4]     -0.01  -0.04 1.73 1.67  -2.72  2.81 1.01      577     1784
// sigma        0.60   0.60 0.03 0.04   0.55  0.66 1.02      119     2755
// tau_alpha    1.30   0.92 1.43 0.65   0.28  3.68 1.02     1470     1676
// alpha_j[1]   0.28   0.30 0.89 0.46  -1.17  1.65 1.03     1072      622
// alpha_j[2]  -0.34  -0.33 0.89 0.47  -1.77  1.01 1.03     1072      639
// tau_beta[1]  1.41   0.98 1.37 0.92   0.08  4.66 1.08       33       21
// tau_beta[2]  1.09   0.80 0.98 0.76   0.09  3.01 1.01      463     2043
// beta_j[1,1]  0.08   0.12 0.92 0.83  -1.51  1.50 1.01     1107     2377
// beta_j[2,1] -0.08  -0.02 0.91 0.86  -1.60  1.40 1.01     3916     2889
// beta_j[3,1]  0.17   0.14 0.99 1.01  -1.47  1.69 1.05       59      463
// beta_j[4,1]  0.05   0.10 0.90 0.82  -1.51  1.49 1.01     2786     2232
// beta_j[1,2] -0.02  -0.06 0.88 0.81  -1.50  1.49 1.01     3136     2809
// beta_j[2,2] -0.12  -0.06 0.92 0.88  -1.64  1.40 1.03     3769     2595
// beta_j[3,2]  0.03  -0.03 0.90 0.85  -1.46  1.58 1.01     3601     2730
// beta_j[4,2]  0.06   0.11 0.92 0.92  -1.45  1.50 1.01      733     2424
