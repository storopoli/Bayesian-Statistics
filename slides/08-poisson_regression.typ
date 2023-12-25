#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": canvas, plot

#new-section-slide("Poisson Regression")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 16: Generalized linear
    models

  - #cite(<mcelreath2020statistical>, form: "prose"):
    - Chapter 10: Big Entropy and the Generalized Linear Model
    - Chapter 11, Section 11.2: Poisson regression

  - #cite(<gelman2020regression>, form: "prose") - Chapter 15, Section 15.2: Poisson
    and negative binomial regression
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/poisson-distribution.jpg")]
]

#slide(
  title: [Count Data],
)[
  #v(3em)

  Poisson regression is used when our dependent variable can only take *positive
  values*, usually in the context of *count data*.
]

#slide(
  title: [What is Poisson Regression?],
)[
  Poisson regression behaves exactly like a linear model: it makes a prediction by
  simply computing a weighted sum of the independent variables $bold(X)$ with the
  estimated coefficients $bold(β)$:
  $bold(y)$.

  But, different from linear regression, it outputs the *natural log* of $bold(y)$:

  $
    log(bold(y))= α dot β_1 x_1 dot β_2 x_2 dot dots dot β_k x_k
  $

  which is the same as:

  $
    bold(y) = e^((α + β_1 x_1 + β_2 x_2 + dots + β_k x_k))
  $
]

#slide(
  title: [Exponential Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm,
      {
        plot.plot(
          size: (16, 9),
          x-label: $x$,
          y-label: $e^x$,
          x-tick-step: 1,
          y-tick-step: 20,
          y-min: -0.01,
          {
            plot.add(
              domain: (-1, 5),
              samples: 200,
              // label: $"exponential"(x)$, // FIXME: depends on unreleased cetz 2.0.0
              x => calc.exp(x),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Comparison with Linear Regression],
)[
  Linear regression has the following mathematical expression:

  $
    "linear" = α + β_1 x_1 + β_2 x_2 + dots + β_k x_k
  $
  where:

  - $α$ -- intercept.
  - $bold(β) = β_1, β_2, dots, β_k$ -- independent variables' $x_1, x_2, dots, x_k$ coefficients.
  - $k$ -- number of independent variables.

  If you implement a small mathematical transformation, you'll have *Poisson
  regression*:

  - $log(y) = e^("Linear") = e^(α + β_1 x_1 + β_2 x_2 + dots + β_k x_k)$
]

#slide(
  title: [Poisson Regression Specification],
)[
  We can use Poisson regression if the dependent variable
  $bold(y)$ has count data, i.e.,
  $bold(y)$ only takes positive values.

  *Poisson likelihood function* uses an intercept $α$ and coefficients $bold(β)$,
  however these are "exponentiated" ($e^x$):

  #v(1em)

  $
    bold(y)  &tilde "Poisson"(e^((α + bold(X) bold(β)))) \
    α       &tilde "Normal"(μ_α, σ_α) \
    bold(β) &tilde "Normal"(μ_(bold(β)), σ_(bold(β)))
  $
]

#slide(
  title: [Interpreting the Coefficients],
)[
  When we see the Poisson regression specification, we realize that the
  coefficient interpretation requires a transformation. What we need to do is undo
  the logarithm transformation:

  $
    log^(-1)(x) = e^x
  $

  So, we need to "exponentiate" the values of $α$ and $bold(β)$:

  $
    bold(y) &= e^((α + bold(X) bold(β))) \
            &= e^(α) dot e^(( X_((1)) dot β_((1)) )) dot e^(( X_((2)) dot β_((2)) )) dot dots dot e^(( X_((k)) dot β_((k)) ))
  $
]

#slide(
  title: [Interpreting the Coefficients],
)[
  Finally, notice that, when transformed, our dependent variables is no more a "weighted
  sum of an intercept and independent variables":

  #v(1em)

  $
    bold(y) &= e^((α + bold(X) bold(β))) \
            &= e^(α) dot e^(( X_((1)) dot β_((1)) )) dot e^(( X_((2)) dot β_((2)) )) dot dots dot e^(( X_((k)) dot β_((k)) ))
  $

  #v(1em)

  It becomes a *"weighted product"*.
]

