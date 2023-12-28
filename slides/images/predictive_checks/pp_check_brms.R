library(brms)
library(ggplot2)
library(bayesplot)
library(svglite)

brms_fit <- brm(mpg ~ wt + am, data = mtcars)

p1 <- pp_check(brms_fit, nreps = 10, seed = 123)
ggsave("pp_check_brms.svg", plot = p1, device = "svg")

p2 <- pp_check(brms_fit, nreps = 10, seed = 123, type = "ecdf_overlay")
ggsave("pp_check_brms_ecdf.svg", plot = p2, device = "svg")
