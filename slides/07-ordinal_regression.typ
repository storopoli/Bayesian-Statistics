#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/plotst:0.2.0": plot as pplot, axis, bar_chart, scatter_plot

#new-section-slide("Ordinal Regression")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 16: Generalized linear
    models, Section 16.2: Models for multivariate and multinomial responses

  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 12, Section 12.3:
    Ordered categorical outcomes

  - #cite(<gelman2020regression>, form: "prose") - Chapter 15, Section 15.5: Ordered
    and unordered categorical regression

  - #cite(<Burkner_Vuorre_2019>, form: "prose")

  - #cite(<Semenova_2019>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/categorical_data.jpg")]
]

#slide(
  title: [What is Ordinal Regression?],
)[
  #v(2em)

  *Ordinal regression* is a regression model for *discrete data* and, more
  specific, when the *values of the dependent variables have a "natural
  ordering"*.

  #v(2em)

  For example, opinion polls with its plausible ordered values from
  agree-disagree, or a patient perception of pain score.
]

#slide(
  title: [Why not just use Linear Regression?],
)[
  The main reason to not simply use linear regression with ordinal discrete
  outcomes is that the categories of the dependent variable could not be
  *equidistant*.

  #v(2em)

  This is an assumption in linear regression (and in almost all models that use "metric"
  dependent variables): the distance between, for example, $2$ and $3$ is not the
  same distance between $1$ and $2$.

  #v(2em)

  This assumption can be *violated in an ordinal regression*.
]

#slide(title: [How to deal with an Ordinal Dependent Variable?])[
  #v(2em)

  Surprise! Plot twist!

  #v(2em)

  Another *non-linear transformation*.
]

#slide(
  title: [Cumulative Distribution Function -- CDF],
)[
  In the case of ordinal regression, first we need to transform the *dependent
  variable into a cumulative scale*

  #v(2em)

  For this, we use the cumulative distribution function (CDF):

  $ P(Y <= y) = sum^y_(i=y_"min") P(Y = i) $

  CDF is a *monotonically increasing function* that represents the *probability of
  a random variable* $Y$ *taking values less than a certain value*
  $y$
]

#slide(
  title: [Log-cumulative-odds],
)[
  #text(
    size: 18pt,
  )[
    Still, this is not enough. We need to apply the *logit function onto the CDF*:

    $ op("logit")(x) = op("logistic")^(-1)(x) = ln(x / (1 -x)) $

    where $ln$ is the natural log function.

    The logit function is the inverse of the logistic function: it takes as input
    any value between $0$ and $1$ (e.g. a probability) and outputs an unconstrained
    real number which we call *logodds* #footnote[we already seen it in logistic regression.].

    As the transformation is performed onto the CDF, we call the result as the CDF
    logodds or *log-cumulative-odds*.
  ]
]

#slide(
  title: [$K-1$ Intercepts],
)[
  What do we do with this *log-cumulative-odds*?

  It allows us to construct *different intercepts for all possible values of the
  ordinal dependent variable*. We create an *unique intercept for* $k ∈ K$.

  #v(1em)

  Actually is $k ∈ K-1$. Notice that the maximum value of the CDF of $Y$ will
  always be $1$. Which translates to a log-cumulative-odds of $oo$, since $p = 1$:

  $ ln(p / (1-p)) = ln(1 / (1-1)) = ln(0) = oo $

  Hence, we need only $K-1$ *intercepts for all* $K$ *possible values that*
  $Y$ *can take*.
]

#slide(
  title: [Violation of the Equidistant Assumption],
)[
  #v(3em)

  Since each intercept implies a different CDF value for each $k ∈ K$, we can
  safely *violate the equidistant assumption* which is not valid in almost all
  ordinal variables.
]

#slide(
  title: [Cut Points],
)[
  Each intercept implies in a log-cumulative-odds for each $k ∈ K$; We need also
  to *undo the cumulative nature of the $K - 1$ intercepts*. Firstly, we *convert
  the log-cumulative-odds back to a valid probability with the logistic
  function*:

  $ op("logit")^(-1)(x) = op("logistic")(x) = (1 / (1 + e^(-x))) $

  Then, finally, we remove the cumulative nature of the CDF by *subtracting every
  one of the $k$ cut points by the
  $k - 1$ cut point*:

  $ P(Y = k) = P(Y <= k) - P(Y <= k - 1) $
]

#slide(
  title: [Example - Probability Mass Function of an Ordinal Variable],
)[
  #align(
    center,
  )[
    #let data = ((0.10, 1), (0.15, 2), (0.33, 3), (0.25, 4), (0.10, 5), (0.07, 6),)
    #let x_axis = axis(
      min: 0, max: 6.1, step: 1, location: "bottom", helper_lines: false, title: "values",
    )
    #let y_axis = axis(
      min: 0, max: 0.46, step: 0.1, location: "left", show_markings: true, helper_lines: true, value_formatter: "{:.1}", title: "PDF",
    )
    #let pl = pplot(data: data, axes: (x_axis, y_axis))
    #bar_chart(pl, 80%, bar_width: 70%, caption: none)
  ]
]

#slide(
  title: [Example - CDF versus log-cumulative-odds],
)[
  #side-by-side[
    #align(
      center,
    )[
      #let data = ((0.10, 1), (0.25, 2), (0.58, 3), (0.83, 4), (0.93, 5), (1.00, 6),)
      #let x_axis = axis(
        min: 0, max: 6.1, step: 1, location: "bottom", helper_lines: false, title: "values",
      )
      #let y_axis = axis(
        min: 0, max: 1.2, step: 0.1, location: "left", show_markings: true, helper_lines: true, value_formatter: "{:.1}", title: "CDF",
      )
      #let pl = pplot(data: data, axes: (x_axis, y_axis))
      #bar_chart(pl, 80%, bar_width: 70%, caption: none)
    ]
  ][
    #align(
      center,
    )[
      #let data = (
        (1, -2.19722), (2, -1.09861), (3, 0.322773), (4, 1.58563), (5, 2.58669), (6, 10.0),
      )
      #let x_axis = axis(
        min: 0, max: 6.1, step: 1, location: "bottom", helper_lines: false, title: "values",
      )
      #let y_axis = axis(
        min: -3, max: 3, step: 1, location: "left", show_markings: true, helper_lines: true, value_formatter: "{:.1}", title: "log-cumulative-odds",
      )
      #let pl = pplot(data: data, axes: (x_axis, y_axis))
      #scatter_plot(pl, 80%, stroke: 4pt, caption: none)
    ]
  ]
]

#slide(
  title: [Adding Coefficients $bold(β)$],
)[
  #v(3em)

  With the equidistant assumption solved with $K - 1$ intercepts, we can add
  coefficients to represent the independent variable's effects into our ordinal
  regression model.
]

#slide(
  title: [More Log-cumulative-odds],
)[
  We've transformed all intercepts into log-cumulative-odds so that we can add
  effects as weighted sums of the independent variables to our basal rates
  (intercepts).

  For every $k ∈ K - 1$, we calculate:

  $ φ = α_k + β_i x_i $

  where $α_k$ is the log-cumulative-odds for the $k ∈ K - 1$ intercepts,
  $β_i$ is the coefficient for the $i$th independent variable $x_i$.

  Lastly, $φ_k$ represents the linear predictor for the $k$th intercept.
]

#slide(
  title: [Matrix Notation],
)[
  This can become more elegant and computationally efficient if we use
  matrix/vector notation:

  $ bold(φ) = bold(α) + bold(X) \cdot bold(β) $

  #v(2em)

  where $bold(φ)$, $bold(α)$ e
  $bold(β)$ #footnote[
    note that both the coefficients and intercepts will have to be interpret as
    odds, like we did in logistic regression.
  ]
  are vectors and $bold(X)$ is the data matrix, in which every line is an
  observation and every column an independent variable.
]

#slide(
  title: [Ordinal Regression Specification],
)[
  #text(
    size: 13pt,
  )[
    $
      bold(y) &tilde "Categorical"(bold(p)) \
      bold(p) &= "logistic"(bold(φ)) \
      bold(φ) &= bold(α) + bold(c) + bold(X) \cdot bold(β) \
      c_1     &= "logit"("CDF"(y_1)) \
      c_k     &= "logit"("CDF"(y_k) - "CDF"(y_(k-1))) "for" 2 <= k <= K-1 \
      c_K     &= "logit"(1 - "CDF"(y_(K-1))) \
      bold(α) &tilde "Normal"(μ_α, σ_α) \
      bold(β) &tilde "Normal"(μ_(bold(β)), σ_{bold(β)})
    $
  ]
  #text(
    size: 12pt,
  )[
    - $bold(y)$ -- ordinal discrete dependent variable.
    - $bold(p)$ -- probability vector of size $K$.
    - $K$: number of possible values that $bold(y)$ can take, i.e. number of ordered
      discrete values.
    - $bold(φ)$: log-cumulative-odds, i.e. the cut points considering the intercepts
      and the weighted sum of the independent variables.
    - $c_k$: cutpoint in log-cumulative-odds for every $k ∈ K-1$.
    - $α_k$: intercept in log-cumulative-odds for every $k ∈ K-1$.
    - $bold(X)$: data matrix of the independent variables.
    - $bold(β)$: coefficient vector with size the same as the number of columns of $bold(X)$.
  ]
]
