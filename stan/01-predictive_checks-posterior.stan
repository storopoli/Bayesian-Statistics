data {
  int<lower=1> N;
  array[N] int y;
}
parameters {
  real<lower=0, upper=1> p;
}
model {
  p ~ beta(1, 1);
  y ~ bernoulli(p);
}
// just create a generated quantities block:
generated quantities {
  array[N] int y_rep;
  for (n in 1:N) {
    y_rep[n] = bernoulli_rng(p);
  }
}
