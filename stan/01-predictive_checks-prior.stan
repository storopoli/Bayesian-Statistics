// run the model with stan fixed parameter arguments:
// fixed_param=TRUE
data {
  int<lower=0> N;
  vector[N] y;
}
generated quantities {
  real p = beta_rng(1, 1);
  array[N] real y_sim = bernoulli_rng(y);
}
