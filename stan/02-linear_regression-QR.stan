// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// kidiq <- as.data.frame(scale(kidiq))
// kidiq data
// beta[K] is:
// 1. mom_hs
// 2. mom_iq
// 3. mom_age
data {
  int<lower=1> N;   // number of observations
  int<lower=1> K;   // number of independent variables
  matrix[N, K] X;   // data matrix
  vector[N] y;      // dependent variable vector
}
// new block with the QR transformations:
transformed data {
  matrix[N, K] Q_ast;
  matrix[K, K] R_ast;
  matrix[K, K] R_ast_inverse;
  // thin and scale the QR decomposition:
  Q_ast = qr_thin_Q(X) * sqrt(N - 1);
  R_ast = qr_thin_R(X) / sqrt(N - 1);
  R_ast_inverse = inverse(R_ast);
}
parameters {
  real alpha;           // intercept
  vector[K] theta;      // coefficients on Q_ast scale
  real<lower=0> sigma;  // model error
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  theta ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);

  // likelihood
  y ~ normal(alpha + Q_ast * theta, sigma);
}
// We need to construct back our betas from the thetas:
generated quantities {
  vector[K] beta;
  beta = R_ast_inverse * theta; // coefficients on X scale
}
// results:
//All 4 chains finished successfully.
//Mean chain execution time: 0.2 seconds.
//Total execution time: 0.2 seconds.
//
//variable    mean  median   sd  mad      q5     q95 rhat ess_bulk ess_tail
// lp__     -167.60 -167.25 1.64 1.49 -170.75 -165.61 1.00     2127     2564
// alpha       0.00    0.00 0.04 0.04   -0.07    0.07 1.00     5136     3219
// theta[1]    0.24    0.24 0.05 0.04    0.16    0.31 1.00     4783     2926
// theta[2]    0.40    0.40 0.04 0.04    0.33    0.47 1.00     5019     3037
// theta[3]    0.03    0.03 0.04 0.04   -0.04    0.10 1.00     5170     2903
// sigma       0.89    0.89 0.03 0.03    0.84    0.94 1.00     5277     2902
// beta[1]     0.11    0.11 0.05 0.05    0.04    0.19 1.00     4869     2874
// beta[2]     0.41    0.41 0.05 0.04    0.34    0.49 1.00     5012     3067
// beta[3]     0.03    0.03 0.04 0.05   -0.04    0.10 1.00     5169     2903
