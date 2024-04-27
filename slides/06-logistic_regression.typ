#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": canvas, plot

#new-section-slide("Logistic Regression")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 16: Generalized linear
    models

  - #cite(<mcelreath2020statistical>, form: "prose")
    - Chapter 10: Big Entropy and the Generalized Linear Model
    - Chapter 11, Section 11.1: Binomial regression

  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 13: Logistic regression
    - Chapter 14: Working with logistic regression
    - Chapter 15, Section 15.3: Logistic-binomial model
    - Chapter 15, Section 15.4: Probit regression
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/logistic_regression.jpg")]
]

#slide(
  title: [Welcome to the Magical World of the Linear Generalized Models],
)[
  Leaving the realm of the linear models, we start to adventure to the generalized
  linear models -- GLM.

  #v(2em)

  The first one is *logistic regression* (also called Bernoulli regression or
  binomial regression).
]

#slide(
  title: [Binary Data #footnote[
      also known as dichotomous, dummy, indicator variable, etc.
    ]
  ],
)[
  #v(5em)

  We use logistic regression when our dependent variable is *binary*. It only
  takes two distinct values, usually coded as $0$ and $1$.
]

#slide(
  title: [What is Logistic Regression],
)[
  Logistic regression behaves exactly as a linear model: it makes a prediction by
  simply computing a weighted sum of the independent variables $bold(X)$ using the
  estimated coefficients $bold(β)$, along with a constant term $α$.

  #v(2em)

  However, instead of outputting a continuous value $bold(y)$, it returns the
  *logistic function* of this value:

  $ "logistic"(x) = 1/(1 + e^(-x)) $
]

#slide(
  title: [Logistic Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm, {
        plot.plot(
          size: (16, 9), x-label: $x$, y-label: $"logistic"(x)$, x-tick-step: 5, y-tick-step: 0.25, y-min: -0.01, y-max: 1.01, {
            plot.add(
              domain: (-10, 10), samples: 200,
              // label: $"logistic"(x)$, // FIXME: depends on unreleased cetz 2.0.0
              x => logistic(x),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Probit Function],
)[
  We can also opt to choose to use the *probit function* (usually represented by
  the Greek letter $Φ$) which is the CDF of a normal distribution:

  #v(2em)

  $ Φ(x)= 1/(sqrt(2π)) ∫_(-oo)^(x)e^((-t^2)/2) dif t $
]

#slide(
  title: [Probit Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm, {
        plot.plot(
          size: (16, 9), x-label: $x$, y-label: $Φ(x)$, x-tick-step: 5, y-tick-step: 0.25, y-min: -0.01, y-max: 1.01, {
            plot.add(
              domain: (-10, 10), samples: 200,
              // label: $"probit"(x)$, // FIXME: depends on unreleased cetz 2.0.0
              x => normcdf(x, 0, 1),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Logistic Function versus Probit Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm, {
        plot.plot(
          size: (16, 9), x-label: $x$, y-label: $Φ(x)$, x-tick-step: 5, y-tick-step: 0.25, y-min: -0.01, y-max: 1.01, {
            plot.add(
              domain: (-10, 10), samples: 200,
              // label: $"logistic"(x)$, // FIXME: depends on unreleased cetz 2.0.0
              x => logistic(x),
            )
            plot.add(
              domain: (-10, 10), samples: 200,
              // label: $"probit"(x)$, // FIXME: depends on unreleased cetz 2.0.0
              x => normcdf(x, 0, 1),
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
  Linear regression follows the following mathematical expression:

  $ "linear" = α + β_1 x_1 + β_2 x_2 + dots + β_k x_k $

  - $α$ -- intercept.
  - $bold(β) = β_1, β_2, dots, β_k$ -- independent variables' $x_1, x_2, dots, x_k$ coefficients.
  - $k$ -- number of independent variables.

  If you implement a small mathematical transformation, you'll have *logistic
  regression*:

  - $hat(p) = "logistic"("linear") = 1 / (1 + e^(-op("linear")))$ --
    probability of an observation taking value $1$.
  - $hat(y) = cases(0 &"if" hat(p) < 0.5, 1 &"if" hat(p) >= 0.5)$ --
    $bold(y)$'s predicted binary value.
]

#slide(
  title: [Logistic Regression Specification],
)[
  We can model logistic regression using two approaches:

  #v(3em)

  - *Bernoulli likelihood* --
    *binary* dependent variable $bold(y)$ which results from a Bernoulli trial with
    some probability $p$.

  - *binomial likelihood* --
    *discrete and positive* dependent variable $bold(y)$
    which results from $k$ successes in $n$ independent Bernoulli trials.
]

#slide(title: [Bernoulli Likelihood])[
  #text(size: 16pt)[
    $
      bold(y) &tilde "Bernoulli"(p) \
      p       &= "logistic/probit"(α + bold(X) bold(β)) \
      α       &tilde "Normal"(μ_α, σ_α) \
      bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β))
    $

    where:

    - $bold(y)$ - dependent binary variable.
    - $p$ - probability of $bold(y)$ taking value of $1$ --
      success in an independent Bernoulli trial.
    - $"logistic/probit"$ -- logistic or probit function.
    - $α$ -- intercept (also called constant).
    - $bold(β)$ -- coefficient vector.
    - $bold(X)$ -- data matrix.
  ]
]

#slide(title: [Binomial Likelihood])[
  #text(size: 16pt)[
    $
      bold(y) &tilde "Binomial"(n, p) \
      p       &= "logistic/probit"(α + bold(X) bold(β)) \
      α       &tilde "Normal"(μ_α, σ_α) \
      bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β))
    $

    where:

    - $bold(y)$ - dependent binary variable.
    - $n$ - number of independent Bernoulli trials.
    - $p$ - probability of $bold(y)$ taking value of $1$ --
      success in an independent Bernoulli trial.
    - $"logistic/probit"$ -- logistic or probit function.
    - $α$ -- intercept (also called constant).
    - $bold(β)$ -- coefficient vector.
    - $bold(X)$ -- data matrix.
  ]
]

#slide(
  title: [Posterior Computation],
)[
  Our aim to is to *find the posterior distribution of the model's parameters of
  interest* ($α$ and $bold(β)$) by computing the full posterior distribution of:

  #v(3em)

  $ P(bold(θ) | bold(y)) = P(α, bold(β) | bold(y)) $
]

#slide(
  title: [How to Interpret Coefficients],
)[
  If we revisit logistic transformation mathematical expression, we see that, in
  order to interpret coefficients $bold(β)$, we need to perform a transformation.

  #v(3em)

  Specifically, we need to undo the logistic transformation. We are looking for
  its inverse function.
]

#slide(
  title: [Probability versus Odds],
)[
  #text(
    size: 17pt,
  )[
    But before that, we need to discern between *probability and odds* #footnote[mathematically speaking.].

    - *Probability*: a real number between $0$ and $1$
      that represents the certainty that an event will occur, either by long-term
      frequencies (frequentist approach) or degrees of belief (Bayesian approach).

    - *Odds*: a positive real number ($RR^+$) that also measures the certainty of an
      event happening. However this measure is not expressed as a probability (between $0$ and $1$),
      but as the *ratio between the number of results that generate our desired event
      and the
      number of results that
      _do not_ generate our desired event*:

      $ "odds" = p / (1 - p) $

      where $p$ is the probability.
  ]
]

#slide(
  title: [Probability versus Odds],
)[
  $ "odds" = p / (1 - p) $

  where $p$ is the probability.

  #v(2em)

  - Odds with a value of $1$ is a neutral odds, similar to a fair coin: $p = 1 / 2$
  - Odds below $1$ decrease the probability of seeing a certain event.
  - Odds over $1$ increase the probability of seeing a certain event.
]

#slide(
  title: [Logodds],
)[
  If you revisit the logistic function, you'll se that the intercept $α$
  and coefficients $bold(β)$ are literally the *log of the odds* (logodds):
  $
    p       &= "logistic"(α + bold(X) bold(β) ) \
    p       &= "logistic"(α) + "logistic"( bold(X) bold(β)) \
    p       &= 1 / (1 + e^(-bold(β))) \
    bold(β) &= log("odds")
  $
]

#slide(
  title: [Logodds],
)[
  Hence, the coefficients of a logistic regression are expressed in logodds, in
  which $0$ is the neutral element, and any number above or below it increases or
  decreases, respectively, the changes of obtaining a "success" in $bold(y)$. To
  have a more intuitive interpretation (similar to the betting houses), we need to
  *convert the logodds into chances* by undoing the $log$ function. We need to
  perform an *exponentiation* of $α$ and $bold(β)$
  values:

  $
    "odds"(α)       & = e^α \
    "odds"(bold(β)) & = e^(bold(β))
  $
]
