// There is no model or parameters block.
// So, run the model with stan fixed parameter arguments:
// fixed_param=TRUE
data {
  int<lower=1> N;
  vector[N] y;
}
generated quantities {
  real<lower=0, upper=1> p = beta_rng(1, 1);
  array[N] int y_rep;
  for (n in 1:N) {
    y_rep[n] = bernoulli_rng(p);
  }
}
