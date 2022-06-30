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
  int<lower=0> N;                       // number of observations
  int<lower=0> K;                       // number of independent variables
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
  y ~ ordered_logistic_glm(X, beta, cutpoints);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.2 seconds.
//Total execution time: 0.3 seconds.
//
//     variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
// lp__         -123.67 -123.32 1.60 1.36 -126.74 -121.74 1.00     1841     2380
// cutpoints[1]   -1.47   -1.47 0.63 0.63   -2.52   -0.45 1.00     2037     1967
// cutpoints[2]   -0.27   -0.27 0.61 0.60   -1.25    0.72 1.00     2193     2365
// cutpoints[3]    0.82    0.81 0.61 0.62   -0.18    1.83 1.00     2346     2678
// beta[1]        -0.08   -0.08 0.12 0.11   -0.27    0.11 1.00     2622     2353
// beta[2]        -0.08   -0.08 0.17 0.17   -0.36    0.20 1.00     2546     2534
