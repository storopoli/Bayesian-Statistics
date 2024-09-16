#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": canvas, plot

#new-section-slide("Sparse Regression")

#slide(title: "Recommended References")[
  - #cite(<gelman2020regression>, form: "prose") - Chapter 12, Section 12.8: Models
    for regression coefficients

  - Horseshoe Prior: #cite(<carvalho2009handling>, form: "prose")
  - Horseshoe+ Prior: #cite(<bhadra2015horseshoe>, form: "prose")
  - Regularized Horseshoe Prior: #cite(<piironen2017horseshoe>, form: "prose")
  - R2-D2 Prior: #cite(<zhang2022bayesian>, form: "prose")
  - Betancourt's Case study on Sparsity: #cite(<betancourtSparsityBlues2021>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/horseshoe.jpg")]
]

#slide(title: [What is Sparsity?])[
  #v(2em)

  Sparsity is a concept frequently encountered in statistics, signal processing,
  and machine learning, which refers to situations where the vast majority of
  elements in a dataset or a vector are zero or close to zero.
]

#slide(title: [How to Handle Sparsity?])[
  Almost all techniques deal with some sort of *variable selection*, instead of
  altering data.

  #v(2em)

  This makes sense from a Bayesian perspective, as data is *information*, and we
  don't want to throw information away.
]

#slide(title: [Frequentist Approach])[
  The frequentist approach deals with sparse regression by staying in the
  "optimization" context but adding *Lagrangian constraints* #footnote[
    this is called *LASSO* (least absolute shrinkage and selection operator) from #cite(<tibshirani1996regression>, form: "prose")
    #cite(<zou2005regularization>, form: "prose").
  ]:

  $
    min_β {sum_(i=1)^N (y_i - α - x_i^T bold(β))^2}
  $

  suject to $|| bold(β) ||_p <= t$.

  #v(1em)

  Here $|| dot ||_p$ is the $p$-norm.
]

#slide(title: [Variable Selection Techniques])[
  #v(4em)

  - *discrete mixtures*: _spike-and-slab_ prior

  - *shrinkage priors*: _Laplace_ prior and _horseshoe_ prior @carvalho2009handling
]

#slide(title: [Discrete Mixtures -- Spike-and-Slab Prior])[
  #text(size: 16pt)[
    Mixture of two distributions—one that is concentrated at zero (the "spike") and
    one with a much wider spread (the
    "slab"). This prior indicates that we believe most coefficients in our model are
    likely to be zero (or close to zero), but we allow the possibility that some are
    not.

    Here is the Gaussian case:

    $
      β_i | λ_i, c &tilde "Normal"(0, sqrt(λ_i^2 c^2)) \
      λ_i &tilde "Bernoulli"(p)
    $

    where:

    - $c$: _slab_ width
    - $p$: prior inclusion probability; encodes the prior information about the
      sparsity of the coefficient vector $bold(β)$
    - $λ_i ∈ {0, 1}$: whether the coefficient $β_i$ is close to zero (comes from the "spike", $λ_i = 0$)
      or nonzero (comes from the "slab", $λ_i = 1$)
  ]
]

#slide(title: [Discrete Mixtures -- Spike-and-Slab Prior])[
  #side-by-side[
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: -4,
                x-max: 4,
                y-max: 0.5,
                y-min: 0,
                {
                  plot.add(
                    domain: (-4, 4),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => hs(x, 1, 0.05),
                  )
                },
              )
            },
          )
        },
        caption: [$c = 1, λ = 0$],
        numbering: none,
      )
    ]
  ][
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: -4,
                x-max: 4,
                y-max: 0.5,
                y-min: 0,
                {
                  plot.add(
                    domain: (-4, 4),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => hs(x, 1, 1),
                  )
                },
              )
            },
          )
        },
        caption: [$c = 1, λ = 1$],
        numbering: none,
      )
    ]
  ]
]

#slide(title: [Shinkrage Priors -- Laplace Prior])[
  The Laplace distribution is a continuous probability distribution named after
  Pierre-Simon Laplace. It is also known as the double exponential distribution.

  It has parameters:

  - $μ$: location parameter
  - $b$: scale parameter

  The PDF is:

  $
    "Laplace"(μ, b) = 1 / (2b) e^(-((| x - μ |) / b))
  $

  It is a symmetrical exponential decay around $μ$ with scale governed by $b$.
]

#slide(title: [Shinkrage Priors -- Laplace Prior])[
  #align(center)[
    #figure(
      {
        canvas(
          length: 0.9cm,
          {
            plot.plot(
              size: (16, 9),
              x-label: none,
              y-label: "PDF",
              x-tick-step: 1,
              y-tick-step: 0.1,
              x-min: -4,
              x-max: 4,
              y-max: 0.55,
              y-min: 0,
              {
                plot.add(
                  domain: (-4, 4),
                  samples: 200,
                  style: (stroke: (paint: julia-purple, thickness: 2pt)),
                  x => laplace(x, 1),
                )
              },
            )
          },
        )
      },
      caption: [$μ = 0, b = 1$],
      numbering: none,
    )
  ]
]

#slide(title: [Shinkrage Priors -- Horseshoe Prior])[
  #text(size: 17pt)[
    The horseshoe prior @carvalho2009handling assumes that each coefficient
    $β_i$ is conditionally independent with density
    $P_("HS")(β_i | τ )$, where $P_("HS")$
    can be represented as a scale mixture of Gaussians:

    $
      β_i | λ_i, τ &tilde "Normal"(0, sqrt(λ_i^2 τ^2)) \
      λ_i &tilde "Cauchy"^+ (0, 1)
    $

    where:
    - $τ$: _global_ shrinkage parameter
    - $λ_i$: _local_ shrinkage parameter
    - $"Cauchy"^+$ is the half-Cauchy distribution for the standard deviation $λ_i$

    Note that it is similar to the spike-and-slab, but the discrete mixture becomes
    a "continuous" mixture with the $"Cauchy"^+$.
  ]
]

#slide(title: [Discrete Mixtures -- Spike-and-Slab Prior])[
  #side-by-side[
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: -4,
                x-max: 4,
                y-max: 0.8,
                y-min: 0,
                {
                  plot.add(
                    domain: (-4, 4),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => hs(x, 1, 1),
                  )
                },
              )
            },
          )
        },
        caption: [$τ = 1, λ = 1$],
        numbering: none,
      )
    ]
  ][
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: -4,
                x-max: 4,
                y-max: 0.8,
                y-min: 0,
                {
                  plot.add(
                    domain: (-4, 4),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => hs(x, 1, 1 / 2),
                  )
                },
              )
            },
          )
        },
        caption: [$τ = 1, λ = 1 / 2$],
        numbering: none,
      )
    ]
  ]
]

#slide(title: [Discrete Mixtures versus Shinkrage Priors])[
  *Discrete mixtures* offer the correct representation of sparse problems
  @carvalho2009handling by placing positive prior probability on
  $β_i = 0$ (regression coefficient), but pose several difficulties: mostly
  computational due to the *non-continuous nature*.

  #v(2em)

  *Shrinkage priors*, despite not having the best representation of sparsity, can
  be very attractive computationally: again due to the *continuous property*.
]

#slide(title: [Horseshoe versus Laplace])[
  #text(size: 17pt)[
    The advantages of the Horseshoe prior over the Laplace prior are primarily:

    - *shrinkage*: The Horseshoe prior has infinitely heavy tails and an infinite
      spike at zero. Parameters estimated under the Horseshoe prior can be shrunken
      towards zero more aggressively than under the Laplace prior, promoting sparsity
      without sacrificing the ability to detect true non-zero signals.
    - *signal* detection: Due to its heavy tails, the Horseshoe prior does not overly
      penalize large values, which allows significant effects to stand out even in the
      presence of many small or zero effects.
    - *uncertainty* quantification: With its heavy-tailed nature, the Horseshoe prior
      better captures uncertainty in parameter estimates, especially when the truth is
      close to zero.
    - *regularization*: In high-dimensional settings where the number of predictors
      can exceed the number of observations, the Horseshoe prior acts as a strong
      regularizer, automatically adapting to the underlying sparsity level without the
      need for external tuning parameters.
  ]
]

#slide(title: [Effective Shinkrage Comparison])[
  Makes more sense to compare the shinkrage effects of the proposed approaches so
  far. Assume for now that $σ^2 = τ^2 = 1$, and define $κ_i = 1 / (1 + λ_i^2)$.

  #v(1em)

  Then $κ_i$ is a random shrinkage coefficient, and can be interpreted as the
  amount of weight that the posterior mean for
  $β_i$ places on $0$ once the data $bold(y)$ have been observed:

  #v(1em)

  $
    op(E)(β_i | y_i, λ_i^2) =
    (λ_i^2) / (1 + λ_i^2) y_i +
    1 / (1 + λ_i^2) 0 =
    (1 - κ_i) y_i
  $
]

#slide(title: [Effective Shinkrage Comparison #footnote[spike-and-slab with $p = 1 / 2$
      would be very similar to Horseshoe but with discontinuities.]])[
  #side-by-side[
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: 0,
                x-max: 1,
                y-max: 0.8,
                y-min: 0,
                {
                  plot.add(
                    domain: (0.01, 0.99),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => beta(x, 0.5, 0.5),
                  )
                },
              )
            },
          )
        },
        caption: [Laplace],
        numbering: none,
      )
    ]
  ][
    #align(center)[
      #figure(
        {
          canvas(
            length: 0.75cm,
            {
              plot.plot(
                size: (16, 9),
                x-label: none,
                y-label: "PDF",
                x-tick-step: 1,
                y-tick-step: 0.1,
                x-min: 0,
                x-max: 1,
                y-max: 0.8,
                y-min: 0,
                {
                  plot.add(
                    domain: (0.1, 0.9),
                    samples: 200,
                    style: (stroke: (paint: julia-purple, thickness: 2pt)),
                    x => shinkragelaplace(x, 1 / 2),
                  )
                },
              )
            },
          )
        },
        caption: [Horseshoe],
        numbering: none,
      )
    ]
  ]
]

#slide(title: [Shinkrage Priors -- Horseshoe+])[
  #text(size: 17pt)[
    Natural extension from the Horseshoe that has improved performance with highly
    sparse data @bhadra2015horseshoe.

    Just introduce a new half-Cauchy mixing variable $η_i$ in the Horseshoe:

    $
      β_i | λ_i, η_i, τ &tilde "Normal"(0, λ_i) \
      λ_i | η_i, τ &tilde "Cauchy"^+(0, τ η_i) \
      η_i &tilde "Cauchy"^+ (0, 1)
    $

    where:

    - $τ$: _global_ shrinkage parameter
    - $λ_i$: _local_ shrinkage parameter
    - $η_i$: additional _local_ shrinkage parameter
    - $"Cauchy"^+$ is the half-Cauchy distribution for the standard deviation $λ_i$ and $η_i$
  ]
]

#slide(title: [Shinkrage Priors -- Regularized Horseshoe])[
  The Horseshoe and Horseshoe+ guarantees that the strong signals will not be
  overshrunk. However, this property can also be harmful, especially when the
  parameters are weakly identified.

  #v(2em)

  The solution, Regularized Horseshoe @piironen2017horseshoe (also known as the "Finnish
  Horseshoe"), is able to control the amount of shrinkage for the largest
  coefficient.
]

#slide(title: [Shinkrage Priors -- Regularized Horseshoe])[
  #text(size: 16pt)[
    $
      β_i | λ_i, τ, c &tilde "Normal" (0, sqrt(τ^2 tilde(λ_i)^2)) \
      tilde(λ_i)^2 &= (c^2 λ_i^2) / (c^2 + τ^2 λ_i^2) \
      λ_i &tilde "Cauchy"^+(0, 1)
    $

    where:

    - $τ$: _global_ shrinkage parameter
    - $λ_i$: _local_ shrinkage parameter
    - $c > 0$: regularization constant
    - $"Cauchy"^+$ is the half-Cauchy distribution for the standard deviation $λ_i$

    Note that when $τ^2 λ_i^2 << c^2$ (coefficient $β_i ≈ 0$), then $tilde(λ_i)^2 → λ_i^2$;
    and when $τ^2 λ_i^2 >> c^2$ (coefficient $β_i$ far from $0$), then $tilde(λ_i)^2 → (c^2) / (τ^2)$ and $β_i$ prior
    approaches $"Normal"(0,c)$.
  ]
]

#slide(title: [Shinkrage Priors -- R2-D2])[ Still, we can do better. The *R2-D2* #footnote[
    $R^2$-induced Dirichlet Decomposition
  ] prior @zhang2022bayesian has heavier tails and higher concentration around
  zero than the previous approaches.

  #v(2em)

  The idea is to, instead of specifying a prior on $bold(β)$, we construct a prior
  on the coefficient of determination $R^2$\footnote{ square of the correlation
  coefficient between the dependent variable and its modeled expectation.}. Then
  using that prior to "distribute" throughout the $bold(β)$. ]

#slide(title: [Shinkrage Priors -- R2-D2])[
  #text(size: 16pt)[
    $
      R^2 &tilde "Beta"(μ_(R^2) σ_(R^2), (1 - μ_(R^2)) σ_(R^2)) \
      bold(φ) &tilde "Dirichlet"(J, 1) \
      τ^2 &= (R^2) / (1 - R^2) \
      bold(β) &= Z dot sqrt(bold(φ) τ^2)
    $

    where:

    - $τ$: _global_ shrinkage parameter
    - $bold(φ)$: proportion of total variance allocated to each covariate, can be
      interpreted as the _local_ shrinkage parameter
    - $μ_(R^2)$ is the mean of the $R^2$ parameter, generally $1 / 2$
    - $σ_(R^2)$ is the precision of the $R^2$ parameter, generally $2$
    - $Z$ is the standard Gaussian, i.e. $"Normal"(0, 1)$
  ]
]
