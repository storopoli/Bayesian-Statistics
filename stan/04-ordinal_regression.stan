// run with 4 chains and 2k iters.
// esoph$agegp <- ordered( # 6 levels
//    esoph$agegp,
//    levels=c("25-34", "35-44", "45-54", "55-64", "65-74", "75+"))
// esoph$alcgp <- ordered( # 4 levels
//    esoph$alcgp,
//    levels=c("0-39g/day", "40-79", "80-119", "120+"))
// X <- data.matrix(esoph[1:2])
// y <- as.numeric(ordered(
//    esoph$tobgp,
//    levels=c("0-9g/day", "10-19", "20-29", "30+"))
// esoph data
// beta[K] is:
// 1. agegp
// 2. alcgp
data {
  int<lower=1> N;                       // number of observations
  int<lower=1> K;                       // number of independent variables
  int<lower=2> cat;                     // number of categories
  matrix[N, K] X;                       // data matrix
  array[N] int<lower=1, upper=cat> y;   // dependent variable vector
}
parameters {
  ordered[cat - 1] cutpoints;           // cutpoints for the K-1 intercepts
  vector[K] beta;                       // coefficients for independent variables
}
model {
  // priors
  cutpoints ~ student_t(3, 0, 5);
  beta ~ student_t(3, 0, 2.5);

  // likelihood
  y ~ ordered_logistic(X * beta, cutpoints);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.2 seconds.
//Total execution time: 0.4 seconds.
//
//     variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
// lp__         -123.66 -123.33 1.56 1.37 -126.72 -121.72 1.00     1485     2720
// cutpoints[1]   -1.47   -1.46 0.63 0.63   -2.49   -0.45 1.00     1908     2226
// cutpoints[2]   -0.26   -0.26 0.61 0.61   -1.24    0.75 1.00     1962     2309
// cutpoints[3]    0.83    0.82 0.62 0.61   -0.17    1.87 1.00     2231     2516
// beta[1]        -0.08   -0.08 0.12 0.11   -0.27    0.12 1.00     2690     2297
// beta[2]        -0.08   -0.08 0.17 0.17   -0.35    0.21 1.00     2671     2270
