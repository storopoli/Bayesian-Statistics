library(rstan)
library(ggplot2)
library(ggdark)
library(bayesplot)
library(tikzDevice)
theme_set(dark_theme_light())
bayesplot_theme_set(dark_theme_light())

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


tikz(file = "slides/images/bad_chains_traceplot.tex")
mcmc_trace(funnel_cp, pars = "y") + ylab(NULL)
dev.off()

tikz(file = "slides/images/good_chains_traceplot.tex")
mcmc_trace(funnel_ncp, pars = "y") + ylab(NULL)
dev.off()
