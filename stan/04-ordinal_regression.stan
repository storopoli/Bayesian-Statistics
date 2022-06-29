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
  y ~ ordered_logistic(X * beta, cutpoints);
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.5 seconds.
//Total execution time: 0.5 seconds.
//
//Warning: 4 of 4000 (0.0%) transitions ended with a divergence.
//See https://mc-stan.org/misc/warnings for details.
//
//     variable   mean median   sd  mad     q5    q95 rhat ess_bulk ess_tail
// lp__         -14.35 -14.03 1.77 1.59 -17.66 -12.19 1.00      883     1265
// cutpoints[1]  13.69  13.17 3.57 3.13   9.07  19.96 1.00      984     1219
// cutpoints[2]  24.02  23.20 5.75 5.12  16.74  34.37 1.00      878     1217
// cutpoints[3]  34.11  32.98 8.10 7.17  23.78  48.08 1.00      825     1087
// beta[1]       -0.46  -0.42 0.65 0.60  -1.55   0.54 1.00     1461     1261
// beta[2]       10.12   9.73 2.41 2.13   7.09  14.40 1.00      845     1095
