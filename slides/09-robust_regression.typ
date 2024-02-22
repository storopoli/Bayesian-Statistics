#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": canvas, plot

#new-section-slide("Robust Regression")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 17: Models for robust
    inference

  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 12: Monsters and
    Mixtures

  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 15, Section 15.6: Robust regression using the t model
    - Chapter 15, Section 15.8: Going beyond generalized linear models
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/not_normal_transparent.png")]
]

#slide(
  title: [Robust Models],
)[
  Almost always data from real world are really strange.

  #v(1em)

  For the sake of convenience, we use simple models. But always ask yourself. How
  many ways might the posterior inference depends on the following:

  #v(1em)

  - extreme observations (outliers)?
  - unrealistic model assumptions?
]

#slide(
  title: [Outliers],
)[
  #v(2em)

  Models based on the *normal distribution are notoriously "non-robust" against
  outliers*, in the sense that a *single observation can greatly affect the
  inference of all model's parameters*, even those that has a shallow relationship
  with it.
]

#slide(
  title: [Overdispersion],
)[
  Superdispersion and underdispersion #footnote[
    rarer to find in the real world.
  ]
  refer to data that have more or fewer variation than expected under a
  probability model @gelman2020regression.

  #v(2em)

  For each one of the models we covered, there is a *natural extension* in which
  *a single parameter* is added to allow for overdispersion @gelman2013bayesian.
]

#slide(
  title: [Overdispersion Example],
)[
  Suppose you are analyzing data from car accidents. The model we generally use in
  this type of phenomena is *Poisson regression*.

  #v(1em)

  Poisson distribution has the same parameter for both the mean and variance: the
  rate parameter $λ$.

  #v(1em)

  Hence, if you find a higher variability than expected under the Poisson
  likelihood function allows, then probably you won't be able to model properly
  the desired phenomena.
]

#slide(
  title: [Student's $t$ instead of Normal],
)[
  Student's $t$ distribution has *wider #footnote[or "fatter".] tails* than the
  Normal distribution.

  #v(1em)

  This makes it a good candidate to *fit outliers without instabilities in the
  parameters' inference*.

  #v(1em)

  From the Bayesian viewpoint, there is nothing special or magical in the
  Gaussian/Normal likelihood.

  It is just another distribution specified in a statistical model. We can make
  our model robust by using the Student's $t$ distribution as a likelihood
  function.
]

#slide(
  title: [Student's $t$ instead of Normal],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm,
      {
        plot.plot(
          size: (16, 9),
          x-label: none,
          y-label: "PDF",
          x-tick-step: 1,
          y-tick-step: 0.1,
          y-min: -0.01,
          y-max: 0.42,
          {
            plot.add(
              domain: (-4, 4),
              samples: 200,
              // label: "Normal", // FIXME: depends on unreleased cetz 2.0.0
              x => gaussian(x, 0, 1),
            )
            plot.add(
              domain: (-4, 4),
              samples: 200,
              // label: [Student's $t$ with $ν = 3$], // FIXME: depends on unreleased cetz 2.0.0
              x => student(x, 3),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Student's $t$ instead of Normal],
)[
  #text(
    size: 16pt,
  )[
    By using a Student's $t$ distribution instead of the Normal distribution as
    likelihood functions, the model's error $σ$ does _not_ follow a Normal
    distribution, but a Student's $t$ distribution:

    $
      bold(y)  &tilde "Student"(ν, α + bold(X) bold(β), σ) \
      α       &tilde "Normal"(μ_α, σ_α) \
      bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β)) \
      ν       &tilde "Log-Normal"(2, 1) \
      σ       &tilde "Exponential"(λ_σ)
    $

    Note that we are including an extra parameter $ν$, which represents the
    Student's $t$ distribution degrees of freedom, to be estimated by the model
    @gelman2013bayesian.

    This controls how wide or narrow the "tails" of the distribution will be. A
    heavy-tailed, positive-only prior is advised.
  ]
]

#slide(
  title: [Beta-Binomial instead of the Binomial],
)[
  The binomial distribution has a practical limitation that we only have one free
  parameter to estimate #footnote[since $n$ already comes from data.] ($p$). This
  implies in the *variance to determined by the mean*. Hence, the binomial
  distribution *cannot* tolerate overdispersion.

  #v(1em)

  A robust alternative is the *beta-binomial distribution*, which, as the name
  suggests, is a *beta mixture of binomials distributions*. Most important, it
  *allows that the variance to be independent of the mean*, making it *robust
  against overdispersion*.
]

#slide(
  title: [Beta-Binomial instead of Binomial],
)[
  The *beta-binomial distribution* is a binomial distribution, where the
  probability of success $p$ is parameterized as a $"Beta"(α, β)$.

  #v(1em)

  Generally, we use $α$ as the binomial's probability of the success $p$, and $β$ #footnote[sometimes specified as $φ$] is
  the additional parameter to control and allow for overdispersion.

  #v(1em)

  Values of $β >= 1$ make the beta-binomial behave the same as a binomial.
]

#slide(
  title: [Beta-Binomial instead of Binomial],
)[
  #text(
    size: 18pt,
  )[
    $
      bold(y)  & tilde "Beta-Binomial"(n, p, φ) \
      p        & tilde "Logistic/Probit"(α + bold(X) bold(β)) \
      α       & tilde "Normal"(μ_α, σ_α) \
      bold(β) & tilde "Normal"(μ_bold(β), σ_bold(β)) \
      φ       & tilde "Exponential"(1)
    $

    #v(1em)

    It is also proper to include the overdispersion $β$ parameter as an additional
    parameter to be estimated by the model @gelman2013bayesian
    @mcelreath2020statistical. A heavy-tailed, positive-only prior is advised.
  ]
]

#slide(
  title: [Student's $t$ instead Binomial],
)[
  #text(
    size: 15pt,
  )[
    Also known as Robit #footnote[there is a great discussion between Gelman, Vehtari and Kurz at
      #link("https://discourse.mc-stan.org/t/robit-regression-not-robust/21245/")[
        Stan's Discourse
      ].] @gelman2013bayesian @gelman2020regression. The idea is to make the
    logistic regression robust by using a *latent variable* $z$ as the linear
    predictor.
    $z$'s errors, $ε$, are distributed as a Student's $t$ distribution:

    $
      y_i  &= cases(0 "if" z_i < 0, 1 "if" z_i > 0) \
      z_i  &= X_i bold(β) + ε_i \
      ε_i &tilde "Student"(ν, 0, sqrt((ν - 2) / ν)) \
      ν   &tilde "Gamma"(2, 0.1) ∈ [2, oo)
    $

    Here we are using the gamma distribution as a truncated Student's $t$
    distribution for the degrees of freedom parameter $ν >= 2$. Another option would
    be to fix $ν = 4$.
  ]
]

#slide(
  title: [Negative Binomial instead of Poisson],
)[
  This is the overdispersion example. The Poisson distribution uses a *single
  parameter for both its mean and variance*.

  #v(1em)

  Hence, if you find overdispersion, probably you'll need a robust alternative to
  Poisson. This is where the *negative binomial*, with an extra parameter $φ$,
  that makes it *robust to overdispersion*.

  #v(1em)

  $φ$ controls the probability of success $p$, and we generally use a gamma
  distribution as its prior.
  $φ$ is also known as a "reciprocal dispersion" parameter.
]

#slide(
  title: [Negative Binomial instead of Poisson],
)[
  $
    bold(y)  &tilde "Negative Binomial"(e^((α + bold(X) bold(β))), φ) \
    φ       &tilde "Gamma"(0.01, 0.01) \
    α       &tilde "Normal"(μ_α, σ_α) \
    bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β))
  $

  #v(2em)

  Here we also give a heavy-tailed, positive-only prior to $φ$. Something like the $"Gamma"(0.01, 0.01)$ works.
]

#slide(title: [Negative Binomial Mixture instead of Poisson])[
  Even using a negative binomial likelihood, if you encounter acute
  overdispersion, specially when there is a lot of zeros in your data
  (zero-inflated), your model can still perform a bad fit to the data.

  #v(1em)

  Another suggestion is to use a mixture of negative binomial
  @mcelreath2020statistical.
]

#slide(
  title: [Negative Binomial Mixture instead of Poisson],
)[
  Here, $S_i$ is a dummy variable, taking value $1$ if the $i$th observation has a
  value $≠ 0$.
  $S_i$ can be modeled using logistic regression:
  $
    bold(y)    &cases(
      = 0 "if" S_i = 0,
      tilde "Negative Binomial"(e^((α + bold(X) bold(β))), φ ) "if" S_i = 1,

    ) \
    P(S_i = 1) &= "Logistic/Probit"(bold(X) bold(γ)) \
    γ         &tilde "Beta"(1, 1)
  $

  #v(1em)

  $γ$ is a new coefficients which we give uniform prior of $"Beta"(1, 1)$.
]

#slide(
  title: [Why Use Non-Robust Models?],
)[
  The *central limit theorem* tells us that the *normal distribution* is an
  appropriate model for data that arises as a *sum of independent components*.

  Even when they are naturally not implicit in a phenomena structure, *simpler
  non-robust models are computational efficient*.

  Finally, there's *occam's razor*, also known as the *principle of parsimony*,
  which states the preference for simplicity in the scientific method.

  Of course, you must always guide the model choice in a *principled manner*,
  taking into account the underlying phenomena data generating process. And make
  sure to make *posterior predictive checks*.
]
