library(rstan)
library(ggplot2)
library(bayesplot)
library(svglite)

funnel_cp_code <-
"
parameters {
  real y;
  real x;
}
model {
  y ~ normal(0, 3);
  x ~ normal(0, exp(y/2));
}
"

funnel_ncp_code <-
"
parameters {
  real y_raw;
  real x_raw;
}
transformed parameters {
  real y;
  real x;

  y = 3.0 * y_raw;
  x = exp(y/2) * x_raw;
}
model {
  y_raw ~ std_normal(); // implies y ~ normal(0, 3)
  x_raw ~ std_normal(); // implies x ~ normal(0, exp(y/2))
}
"

funnel_cp <- stan(model_code = funnel_cp_code,
                  chains = 4, iter = 1001, warmup = 100,
                  control = list(adapt_delta = 0.65))

funnel_ncp <- stan(model_code = funnel_ncp_code,
                  chains = 4, iter = 1001, warmup = 100,
                  control = list(adapt_delta = 0.65))


p1 <- mcmc_trace(funnel_cp, pars = "y") + ylab(NULL)
ggsave("bad_chains_traceplot.svg", plot = p1, device = "svg")

p2 <- mcmc_trace(funnel_ncp, pars = "y") + ylab(NULL)
ggsave("good_chains_traceplot.svg", plot = p2, device = "svg")
