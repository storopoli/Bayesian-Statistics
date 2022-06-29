// run with 4 chains and 2k iters.
// esoph$agegp <- ordered( # 6 levels
//    esoph$agegp,
//    levels=c("25-34", "35-44", "45-54", "55-64", "65-74", "75+"))
// esoph$alcgp <- ordered( # 4 levels
//    esoph$alcgp,
//    levels=c("0-39g/day", "40-79", "80-119", "120+"))
// X <- data.matrix(esoph[2:3])
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
//Mean chain execution time: 0.4 seconds.
//Total execution time: 0.5 seconds.
//
//Warning: 1 of 4000 (0.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//     variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__         -14.34 -13.96 1.76 1.58 -17.79 -12.18 1.00      960     1026
// cutpoints[1]  13.68  13.15 3.55 3.14   9.12  20.11 1.00     1099     1232
// cutpoints[2]  24.05  23.09 5.78 4.99  16.67  34.60 1.00      894     1043
// cutpoints[3]  34.13  32.76 8.04 6.91  23.99  48.58 1.00      841      937
// beta[1]       -0.45  -0.40 0.66 0.61  -1.58   0.52 1.00     1394     1119
// beta[2]       10.12   9.69 2.39 2.07   7.15  14.38 1.00      807      903
