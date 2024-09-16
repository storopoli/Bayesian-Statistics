#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/plotst:0.2.0": plot as pplot, axis, scatter_plot, graph_plot, overlay

#new-section-slide("Linear Regression")

#slide(title: "Recommended References")[
  - #cite(<gelman2013bayesian>, form: "prose"):
    - Chapter 14: Introduction to regression models
    - Chapter 16: Generalized linear models

  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 4: Geocentric Models

  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 7: Linear regression with a single predictor
    - Chapter 8: Fitting regression models
    - Chapter 10: Linear regression with multiple predictors
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/linear_regression.jpg")]
]

#slide(title: "What is Linear Regression?")[
  #let data_scatter = (
    (0.5, 0.7),
    (1, 0.7),
    (2, 2.4),
    (3, 2.6),
    (4, 4.6),
    (5, 4.2),
  )
  #let data_graph = ((0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5))
  #let x_axis = axis(min: 0, max: 5, location: "bottom")
  #let y_axis = axis(min: 0, max: 5, location: "left")
  #let pl_scatter = pplot(data: data_scatter, axes: ((x_axis, y_axis)))
  #let scatter_display = scatter_plot(
    pl_scatter,
    70pt,
    stroke: 3pt,
    caption: none,
  )
  #let pl_graph = pplot(data: data_graph, axes: (x_axis, y_axis))
  #let graph_display = graph_plot(
    pl_graph,
    70pt,
    stroke: 2pt + julia-blue,
    markings: none,
    caption: none,
  )
  #overlay((scatter_display, graph_display), (360pt, 280pt))
]

#slide(title: "What is Linear Regression?")[
  The ideia here is to model a dependent variable as a linear combination of
  independent variables.

  $ bold(y) = α + bold(X) bold(β) + ε $

  where:

  - $bold(y)$ -- dependent variable
  - $α$ -- intercept (also called as constant)
  - $bold(β)$ -- coefficient vector
  - $bold(X)$ -- data matrix
  - $ε$ -- model error
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/assumptions.jpg")]
]

#slide(title: "Linear Regression Assumptions")[
  #v(3em)

  - model error $ε$ is independent of $bold(X)$ and $bold(y)$.

  - Dependent variable $bold(y)$ is continuous, unbounded, and, more importantly,
    "metric"-scaled, i.e. *equidistant*.

    - e.g. the increase from $1$ to $2$ is the same from $3$ to $4$. Generally
      violated when $bold(y)$ is interval-scaled.

  - Observations are I.I.D #footnote[independent and identically distributed.].
]

#slide(title: "Linear Regression Specification")[
  To estimate the intercept $α$ and coefficients $bold(β)$
  we use a Gaussian/normal likelihood function. Mathematically speaking, Bayesian
  linear regression is:

  #v(2em)

  $
    bold(y) &tilde "Normal"(α + bold(X) bold(β), σ) \
    α &tilde "Normal"(μ_α, σ_α) \
    bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β)) \
    σ &tilde "Exponential"(λ_σ)
  $
]

#slide(title: "Linear Regression Specification")[
  What we are missing is the prior probabilities for the model's parameters:

  #v(2em)

  - Prior Distribution for $α$ --
    Knowledge that we have about the model's intercept.

  - Prior Distribution for $bold(β)$ --
    Knowledge that we have about the model's independent variable coefficients.

  - Prior Distribution for $σ$ --
    Knowledge that we have about the model's error.
]

#slide(title: "Good Candidates for Prior Distributions")[
  First, center ($μ = 0$) and standardize ($σ = 1$) the independent variables.

  #v(2em)

  - $α$ -- either a normal or student-$t$ ($ν = 3$), with mean as $μ_bold(y)$
    and standard deviation as $2.5 dot σ_bold(y)$
    (also you can use the median and median absolute deviation).

  - $bold(β)$ -- either a normal or student-$t$ ($ν = 3$), with mean $0$ and
    standard deviation $2.5$.

  - $σ$ -- anything that is long-tailed (mass towards lower values) and restrained
    to positive values only. Exponential is a good candidate.
]

#slide(title: "Posterior Computation")[
  Our aim to is to *find the posterior distribution of the model's parameters of
  interest* ($α$ and $bold(β)$) by computing the full posterior distribution of:

  #v(3em)

  $ P(bold(θ) | bold(y)) = P(α, bold(β), σ | bold(y)) $
]
