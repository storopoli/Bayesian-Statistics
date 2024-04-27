#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *

#new-section-slide("Model Comparison")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 7: Evaluating, comparing,
    and expanding models
  - #cite(<gelman2020regression>, form: "prose") - Chapter 11, Section 11.8: Cross
    validation
  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 7, Section 7.5: Model
    comparison
  - #cite(<vehtariPracticalBayesianModel2015>, form: "prose")
  - #cite(<spiegelhalter2002bayesian>, form: "prose")
  - #cite(<van2005dic>, form: "prose")
  - #cite(<watanabe2010asymptotic>, form: "prose")
  - #cite(<gelfand1996model>, form: "prose")
  - #cite(<watanabe2010asymptotic>, form: "prose")
  - #cite(<geisser1979predictive>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/model_comparison.jpg")]
]

#slide(
  title: [Why Compare Models?],
)[
  #v(3em)
  After model parameters estimation, many times we want to measure its *predictive
  accuracy* by itself, or for *model comparison*, *model selection*, or computing
  a *model performance metric* @geisser1979predictive.
]

#slide(
  title: [But What About Visual Posterior Predictive Checks?],
)[
  To analyze and compare models using visual posterior predictive checks is a
  *subjective and arbitrary approach*.

  #v(1em)

  There is an *objective approach to compare Bayesian models* which uses a robust
  metric that helps us select the best model in a set of candidate models.

  #v(1em)

  Having an objective way of comparing and choosing the best model is very
  important. In the *Bayesian workflow*, we generally have several iterations
  between priors and likelihood functions resulting in several different models
  @gelmanBayesianWorkflow2020.
]

#slide(
  title: [Model Comparison Techniques],
)[
  We have several model comparison techniques that use *predictive accuracy*, but
  the main ones are:
  - Leave-one-out cross-validation (LOO) @vehtariPracticalBayesianModel2015.

  - Deviance Information Criterion (DIC) @spiegelhalter2002bayesian, but it is known
    to have some issues, due to not being full-Bayesian, because it is only based on
    point estimates @van2005dic,

  - Widely Applicable Information Criteria (WAIC) @watanabe2010asymptotic,
    full-Bayesian, in the sense that uses the full posterior distribution density,
    and it is asymptotically equal to LOO @vehtariPracticalBayesianModel2015.
]

#slide(
  title: [Historical Interlude],
)[
  #text(
    size: 16pt,
  )[
    In the past, we did not have computational power and data abundance. Model
    comparison was done based on a theoretical divergence metric originated from
    information theory's entropy:

    $
      H(p) = - op("E") log(p_i) = -sum^N_(i = 1) p_i log(p_i)
    $

    We compute the divergence by multiplying entropy by $-2$ #footnote[historical reasons.],
    so lower values are preferable:

    $
      D(y, bold(θ)) = -2 dot underbrace(
        sum^N_(i = 1) log 1 / S sum^S_(s = 1) P(y_i | bold(θ)^s), "log pointwise predictive density - lppd",

      )
    $

    where $n$ is the sample size and $S$ is the number of posterior draws.
  ]
]

#slide(
  title: [Historical Interlude -- AIC @akaike1998information],
)[
  $
    "AIC" = D(y, bold(θ)) + 2k = -2 "lppd"_("mle") + 2k
  $

  where $k$ is the number of the model's free parameters and
  $"lppd"_("mle")$ is the maximum likelihood estimate of the log pointwise
  predictive density.

  #v(1em)

  AIC is an approximation and can only be reliable when:

  - The priors are uniform (flat priors) or totally dominated by the likelihood
    function.

  - The posterior is approximate a multivariate normal distribution.

  - The sample size $N$ is much larger than the number of the model's free
    parameters $k$: $N >> k$
]

#slide(
  title: [Historical Interlude -- DIC @spiegelhalter2002bayesian],
)[
  A generalization of the AIC, where we replace the maximum likelihood estimate
  for the posterior mean and $k$ by a data-based bias correction:

  $
    "DIC" = D(y, bold(θ)) + k_("DIC") = -2 "lppd"_("Bayes")
    +2 underbrace(
      ("lppd"_("Bayes") - 1 / S sum^S_(s=1) log P(y | bold(θ)^s)), text("bias-corrected") k,

    )
  $

  DIC removes the restriction on uniform AIC priors, but still keeps the
  assumptions of the posterior being a multivariate Gaussian/normal distribution
  and that $N >> k$.
]

#slide(
  title: [Predictive Accuracy],
)[
  With current computational power, we do not need approximations #footnote[AIC, DIC etc.].

  #v(2em)

  We can discuss *predictive accuracy objective metrics*

  #v(2em)

  But, first, let's define what is predictive accuracy.
]

#slide(
  title: [Predictive Accuracy],
)[
  Bayesian approaches measure predictive accuracy using posterior draws
  $tilde(y)$ from the model. For that we have the predictive posterior
  distribution:

  $
    p(tilde(y) | y) = ∫ p(tilde(y)_i | θ) p(θ | y) dif θ
  $

  Where $p(θ | y)$ is the model's posterior distribution. The above equation means
  that we evaluate the integral with respect to the whole joint probability of the
  model's predictive posterior distribution and posterior distribution.

  #v(1em)

  The *higher* the predictive posterior distribution
  $p(tilde(y) | y)$, the *better* will be the model's predictive accuracy.
]

#slide(
  title: [Predictive Accuracy],
)[
  To make samples comparable, we calculate the expectation of this measure for
  each one of the $N$ sample observations:

  $
    op("elpd") = sum_(i=1)^N ∫ p_t(tilde(y)_i) log p(tilde(y)_i | y) dif tilde(y)
  $

  where $op("elpd")$ is the expected log pointwise predictive density, and $p_t(tilde(y)_i)$ is
  the distribution that represents the
  $tilde(y)_i$'s true underlying data generating process.

  The $p_t(tilde(y)_i)$ are unknown and we generally use cross-validation or
  approximations to estimate $op("elpd")$.
]

#slide(
  title: [Leave-One-Out Cross-Validation (LOO)],
)[
  #text(
    size: 18pt,
  )[
    We can compute the $op("elpd")$ using LOO @vehtariPracticalBayesianModel2015:

    $
      op("elpd")_("loo") = sum_(i=1)^N log p(y_i | y_(-i))
    $

    where

    $
      p(y_i | y_(-i)) = ∫ p(y_i | θ) p(θ | y_(-i)) dif θ
    $

    which is the predictive density conditioned on the data without a single
    observation $i$ ($y_(-i)$). Almost always we use the PSIS-LOO #footnote[upcoming...] approximation
    due to its robustness and low computational cost.
  ]
]

#slide(
  title: [Widely Applicable Information Criteria (WAIC)],
)[
  #text(
    size: 12pt,
  )[
    WAIC @watanabe2010asymptotic, like LOO, is also an alternative approach to
    compute the $op("elpd")$,

    and is defined as:

    $
      hat(op("elpd"))_("waic") = hat(op("lppd")) - hat(p)_("waic")
    $

    where $hat(p)_("waic")$ is the number of effective parameters based on:

    $
      hat(p)_("waic") = sum_(i = 1)^N op("var")_("post") (log p(y_i | θ))
    $

    which we can compute using the posterior variance of the log predictive density
    for each observation $y_i$:

    $
      hat(p)_("waic") = sum_(i = 1)^N V^S_(s = 1) (log p(y_i | θ^s))
    $

    where $V^S_(s=1)$ is the sample's variance:

    $
      V^S_(s = 1) a_s = 1 / (S-1) sum^S_(s = 1) (a_s - bar(a))^2
    $
  ]
]

#slide(
  title: [$K$-fold Cross-Validation ($K$-fold CV)],
)[
  In the same manner that we can compute the $op("elpd")$
  using LOO with $N-1$ sample partitions, we can also compute it with any desired
  partition number.

  #v(1em)

  Such approach is called *$K$-fold cross-validation* ($K$-fold CV).

  #v(1em)

  Contrary to LOO, we cannot approximate the actual $op("elpd")$
  using $K$-fold CV, and we need to compute the actual $op("elpd")$ over $K$ partitions,
  which almost involves a *high computational cost*.
]

#slide(
  title: [Pareto Smoothed Importance Sampling LOO (PSIS-LOO)],
)[
  PSIS uses *importance sampling* #footnote[another class of MCMC algorithm that we did not cover yet.],
  which means a importance weighting scheme approach.

  #v(3em)

  The *Pareto smoothing* is a technique to increase the importance weights'
  reliability.
]

#slide(
  title: [Importance Sampling],
)[
  If the $N$ samples are conditionally independent #footnote[
    that is, they are independent if conditioned on the model's parameters, which is
    a basic assumption in any Bayesian (and frequentist) model
  ]
  @gelfand1992model, we can compute LOO with $bold(θ)^s$ posterior' samples
  $P(θ | y)$ using *importance weights*:

  $
    r_i^s=1 / (P(y_i|θ^s)) ∝ (P(θ^s|y_(-i))) / (P(θ^s|y))
  $

  Hence, to get Importance Sampling Leave-One-Out (IS-LOO):

  $
    P(tilde(y)_i | y_(-i))
    ≈
    (sum_(s=1)^S r_i^s P(tilde(y)_i|θ^s)) / (sum_(s=1)^S r_i^s)
  $
]

#slide(
  title: [Importance Sampling],
)[
  However, the posterior $P(θ | y$ often has low variance and shorter tails than
  the LOO distributions $P(θ | y_(-1))$. Hence, if we use:
  $
    P(tilde(y)_i | y_(-i)) ≈ (sum_(s=1)^S r_i^s P(tilde(y)_i|θ^s)) / (sum_(s=1)^S r_i^s)
  $

  #v(1em)

  we will have *instabilities* because the $r_i$ can have *high, or even infinite,
  variance*.
]

#slide(
  title: [Pareto Smoothed Importance Sampling],
)[
  We can enhance the IS-LOO estimate using a *Pareto Smoothed Importance Sampling*
  @vehtariPracticalBayesianModel2015.

  #v(2em)

  When the tails of the importance weights' distribution are long, a direct usage
  of the importance is sensible to one or more large value. By *fitting a
  generalized Pareto distribution to the importance weights' upper-tail*, we
  smooth out these values.
]

#slide(title: [Pareto Smoothed Importance Sampling LOO (PSIS-LOO)])[
  Finally, we have PSIS-LOO:

  $
    hat(op("elpd"))_("psis-loo") =
    sum_(i=1)^n log
    ((sum_(s=1)^S w_i^s P(y_i|θ^s)) / (sum_(s=1)^S w_i^s))
  $

  #v(1em)

  where $w$ is the truncated weights.
]

#slide(
  title: [Pareto Smoothed Importance Sampling LOO (PSIS-LOO)],
)[
  #text(
    size: 17pt,
  )[
    We use the importance weights Pareto distribution's estimated shape parameter
    $hat(k)$ to assess its reliability:

    - $k < 1 / 2$: the importance weights variance is finite, the central limit
      theorem holds, and the estimate rapidly converges.

    - $1 / 2 < k < 1$ the importance weights variance is infinite, but the mean exists
      (is finite), the generalized central limit theorem for stable distributions
      holds, and the estimate converges, but slower. The PSIS variance estimate is
      finite, but could be large.

    - $k > 1$ both the importance weights variance and mean do not exist (they are
      infinite). The PSIS variance estimate is finite, but could be large.

    #v(1em)

    Any $hat(k) > 0.5$ is a warning sign, but empirically there is still a good
    performance up to $hat(k) < 0.7$.
  ]
]
