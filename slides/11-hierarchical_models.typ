#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": *

#new-section-slide("Hierarchical Models")

#slide(title: "Recommended References")[
  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 5: Hierarchical models
    - Chapter 15: Hierarchical linear models

  - #cite(<mcelreath2020statistical>):
    - Chapter 13: Models With Memory
    - Chapter 14: Adventures in Covariance

  - #cite(<gelmanDataAnalysisUsing2007>, form: "prose")

  - Michael Betancourt's case study on #link(
      "https://betanalpha.github.io/assets/case_studies/hierarchical_modeling.html",
    )[Hierarchical modeling]

  - #cite(<kruschke2015bayesian>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/hierarchical_models.jpg")]
]

#slide(title: [I have many names...])[
  Hierarchical models are also known for several names #footnote[
    for the whole full list
    #link(
      "https://statmodeling.stat.columbia.edu/2019/09/18/all-the-names-for-hierarchical-and-multilevel-modeling/",
    )[check here].
  ]

  - Hierarchical Models

  - Random Effects Models

  - Mixed Effects Models

  - Cross-Sectional Models

  - Nested Data Models
]

#slide(title: [What are hierarchical models?])[
  Statistical model specified in multiple levels that estimates parameters from
  the posterior distribution using a Bayesian approach.

  The sub-models inside the model combines to form a hierarchical model, and
  Bayes' theorem is used to integrate it to observed data and account for all
  uncertain.

  #v(2em)

  Hierarchical models are mathematical descriptions that involves several
  parameters, where some parameters' estimates depend on another parameters'
  values.
]

#slide(title: [What are hierarchical models?])[
  #text(size: 16pt)[
    Hyperparameter $φ$ that parameterizes $θ_1, θ_2, dots, θ_K$, that are used to
    infer the posterior density of some random variable
    $bold(y) = y_1, y_2, dots, y_K$
  ]
  #align(center)[
    #canvas(
      length: 0.9cm,
      {
        import draw: *
        set-style(
          mark: (end: ">", fill: black, size: 0.3),
          stroke: (thickness: 2pt),
          radius: 1,
        )
        circle((6, 0))
        content((6, 0), [#align(center)[$φ$]])

        line((6, 1), (0, 2))
        circle((0, 3))
        content((0, 3), [#align(center)[$θ_1$]])

        line((6, 1), (3, 2))
        circle((3, 3))
        content((3, 3), [#align(center)[$dots$]])

        line((6, 1), (6, 2))
        circle((6, 3))
        content((6, 3), [#align(center)[$θ_k$]])

        line((6, 1), (9, 2))
        circle((9, 3))
        content((9, 3), [#align(center)[$dots$]])

        line((6, 1), (12, 2))
        circle((12, 3))
        content((12, 3), [#align(center)[$θ_K$]])

        line((0, 4), (0, 5))
        circle((0, 6), fill: julia-purple)
        content((0, 6), [#align(center)[#text(fill: white)[$y_1$]]])

        line((3, 4), (3, 5))
        circle((3, 6), fill: julia-purple)
        content((3, 6), [#align(center)[#text(fill: white)[$dots$]]])

        line((6, 4), (6, 5))
        circle((6, 6), fill: julia-purple)
        content((6, 6), [#align(center)[#text(fill: white)[$y_k$]]])

        line((9, 4), (9, 5))
        circle((9, 6), fill: julia-purple)
        content((9, 6), [#align(center)[#text(fill: white)[$dots$]]])

        line((12, 4), (12, 5))
        circle((12, 6), fill: julia-purple)
        content((12, 6), [#align(center)[#text(fill: white)[$y_K$]]])
      },
    )
  ]
]

#slide(title: [What are hierarchical models?])[
  #text(size: 14pt)[
    Even that the observations directly inform only a single set of parameters, a
    hierarchical model couples individual parameters, and provides a "backdoor" for
    information flow.
  ]
  #align(center)[
    #side-by-side[
      #canvas(
        length: 0.7cm,
        {
          import draw: *
          set-style(
            mark: (end: ">", fill: black, size: 0.3),
            stroke: (thickness: 2pt),
            radius: 1,
          )
          circle((6, 0))
          content((6, 0), [#align(center)[$φ$]])

          line((6, 1), (0, 2))
          circle((0, 3))
          content((0, 3), [#align(center)[$θ_1$]])

          line((6, 1), (3, 2))
          circle((3, 3))
          content((3, 3), [#align(center)[$dots$]])

          line((6, 1), (6, 2))
          circle((6, 3))
          content((6, 3), [#align(center)[$θ_k$]])

          line((6, 1), (9, 2))
          circle((9, 3))
          content((9, 3), [#align(center)[$dots$]])

          line((6, 1), (12, 2))
          circle((12, 3))
          content((12, 3), [#align(center)[$θ_K$]])

          circle((0, 6), fill: julia-purple.lighten(50%))
          content((0, 6), [#align(center)[#text(fill: white)[$y_1$]]])

          circle((3, 6), fill: julia-purple.lighten(50%))
          content((3, 6), [#align(center)[#text(fill: white)[$dots$]]])

          line((6, 5), (6, 4))
          circle((6, 6), fill: julia-purple)
          content((6, 6), [#align(center)[#text(fill: white)[$y_k$]]])

          circle((9, 6), fill: julia-purple.lighten(50%))
          content((9, 6), [#align(center)[#text(fill: white)[$dots$]]])

          circle((12, 6), fill: julia-purple.lighten(50%))
          content((12, 6), [#align(center)[#text(fill: white)[$y_K$]]])
        },
      )
    ][
      #canvas(
        length: 0.7cm,
        {
          import draw: *
          set-style(
            mark: (end: ">", fill: black, size: 0.3),
            stroke: (thickness: 2pt),
            radius: 1,
          )
          circle((6, 0))
          content((6, 0), [#align(center)[$φ$]])

          line((6, 1), (0, 2))
          circle((0, 3))
          content((0, 3), [#align(center)[$θ_1$]])

          line((6, 1), (3, 2))
          circle((3, 3))
          content((3, 3), [#align(center)[$dots$]])

          line((6, 1), (6, 2))
          circle((6, 3))
          content((6, 3), [#align(center)[$θ_k$]])

          line((6, 1), (9, 2))
          circle((9, 3))
          content((9, 3), [#align(center)[$dots$]])

          line((6, 1), (12, 2))
          circle((12, 3))
          content((12, 3), [#align(center)[$θ_K$]])

          line((0, 5), (0, 4))
          circle((0, 6), fill: julia-purple)
          content((0, 6), [#align(center)[#text(fill: white)[$y_1$]]])

          line((3, 5), (3, 4))
          circle((3, 6), fill: julia-purple)
          content((3, 6), [#align(center)[#text(fill: white)[$dots$]]])

          circle((6, 6), fill: julia-purple.lighten(50%))
          content((6, 6), [#align(center)[#text(fill: white)[$y_k$]]])

          line((9, 5), (9, 4))
          circle((9, 6), fill: julia-purple)
          content((9, 6), [#align(center)[#text(fill: white)[$dots$]]])

          line((12, 4), (12, 5))
          circle((12, 6), fill: julia-purple)
          content((12, 6), [#align(center)[#text(fill: white)[$y_K$]]])
        },
      )
    ]
  ]
  #text(size: 14pt)[
    For example, the observations from the $k$th group, $y_k$, informs directly the
    parameters that quantify the $k$th group's behavior,
    $θ_k$. These parameters, however, inform directly the population-level
    parameters,
    $φ$, that, in turn, informs others group-level parameters. In the same manner,
    observations that informs directly other group's parameters also provide
    indirectly information to population-level parameters, which then informs other
    group-level parameters, and so on...
  ]
]

#slide(title: [When to Use Hierarchical Models?])[
  #v(3em)

  *Hierarchical models* are used when information is available in *several levels
  of units of observation*. The hierarchical structure of analysis and
  organization assists in the understanding of *multiparameter problems*, while
  also performing a crucial role in the development of *computational strategies*.
]

#slide(title: [When to Use Hierarchical Models?])[
  #text(size: 16pt)[
    Hierarchical models are particularly appropriate for research projects where
    participant data can be organized in more than one level #footnote[
      also known as nested data.
    ].

    The units of analysis are generally individuals that are nested inside
    contextual/aggregate units (groups).

    An example is when we measure individual performance and we have additional
    information about distinct group membership such as:

    - sex
    - age group
    - income level
    - education level
    - state/province of residence
  ]
]

#slide(title: [When to Use Hierarchical Models?])[
  Another good use case is *big data* @gelman2013bayesian.

  - simple nonhierarchical models are usually inappropriate for hierarchical data:
    with few parameters, they generally _cannot_ fit large datasets accurately.

  - whereas with many parameters, they tend to *overfit*.

  - hierarchical models can have enough parameters to fit the data well, while using
    a population distribution to structure some dependence into the parameters,
    thereby *avoiding problems of overfitting*.
]

#slide(title: [When to Use Hierarchical Models?])[
  #v(2em)

  Most important is *not to violate* the *exchangeability assumption*
  @definettiTheoryProbability1974.

  #v(2em)

  This assumption stems from the principle that *groups are _exchangeable_*.
]

#slide(title: [Hyperprior])[
  In hierarchical models, we have a hyperprior, which is a prior's prior:

  #v(1em)

  $
    bold(y) &tilde "Normal"(10, bold(θ)) \
    bold(θ) &tilde "Normal"(0, φ) \
    φ &tilde "Exponential(1)"
  $

  #v(2em)

  Here $bold(y)$ is a variable of interest that belongs to distinct groups.
  $bold(θ)$, a prior for $bold(y)$, is a vector of group-level parameters with
  their own prior (which becomes a hyperprior) $φ$.
]

#slide(title: [Frequentist versus Bayesian Approaches])[
  #text(size: 18pt)[
    There are also hierarchical models in frequentist statistics. They are mainly
    available in the lme4 package @lme4, and also in MixedModels.jl @MixedModels.

    - *optimization of the likelihood function* versus *posterior approximation via
      MCMC*. Almost always lead to convergence failure for models that are not
      extremely simple.

    - *frequentist hierarchical models do not compute $p$-values for the group-level
      effects*
      #footnote[
        see #link("https://stat.ethz.ch/pipermail/r-help/2006-May/094765.html")
        [Douglas Bates, creator of the lme4 package explanation].
      ]. This is due to the underlying assumptions of the approximations that
      frequentist statistics has to to do in order to calculate the group-level
      effects $p$-values. The main one being that the groups must be balanced. In
      other words, the groups must be homogeneous in size. Hence, any unbalance in
      group compositions results in pathological $p$-values that should not be
      trusted.
  ]
]

#slide(title: [Frequentist versus Bayesian Approaches])[
  #v(3em)

  To sum up, *frequentist approach for hierarchical models is not robust* in both
  the *inference process* (*convergence flaws* during the maximum likelihood
  estimation), and also in the *results* from the inference process (do not
  provide $p$-values due to *strong assumptions that are almost always violated*).
]

#slide(title: [Approaches to Hierarchical Modeling])[
  #v(1em)

  - *Varying-intercept* model: One group-level intercept besides the
    population-level coefficients.

    #v(1em)

  - *Varying-slope* model: One or more group-level coefficient(s) besides the
    population-level intercept.

    #v(1em)

  - *Varying-intercept-slope* model: One group-level intercept and one or more
    group-level coefficient(s).
]

#slide(title: [Mathematical Specification of Hierarchical Models])[
  #v(4em)

  We have $N$ observations organized in $J$ groups with $K$ independent variables.
]

#slide(title: [Mathematical Specification -- Varying-Intercept Model])[
  This example is for linear regression:

  $
    bold(y) &tilde "Normal"(α_j + bold(X) dot bold(β), σ) \
    α_j &tilde "Normal"(α, τ) \
    α &tilde "Normal"(μ_α, σ_α) \
    bold(β) &tilde "Normal"(μ_{bold(β)}, σ_(bold(β))) \
    τ &tilde "Cauchy"^+(0, ψ_(α)) \
    σ &tilde "Exponential"(λ_σ)
  $
]

#slide(title: [Mathematical Specification -- Varying-Intercept Model])[

  #text(size: 14pt)[
    If you need to extend to more than one group, such as $J_1, J_2, dots$:

    $
      bold(y) &tilde "Normal"(α_j_1 + α_j_2 + bold(X) bold(β), σ) \
      α_(j_1) &tilde "Normal"(α_1, τ_α_j_1) \
      α_(j_2) &tilde "Normal"(α_2, τ_α_j_2) \
      α_1 &tilde "Normal"(μ_(α_1), σ_α_1) \
      α_2 &tilde "Normal"(μ_(α_2), σ_α_2) \
      bold(β) &tilde "Normal"(μ_(bold(β)), σ_(bold(β))) \
      τ_(α_j_1) &tilde "Cauchy"^+(0, ψ_α_j_1) \
      τ_(α_j_2) &tilde "Cauchy"^+(0, ψ_α_j_2) \
      σ &tilde "Exponential"(λ_σ)
    $
  ]
]

#slide(title: [Mathematical Specification -- Varying-(Intercept-)Slope Model])[
  If we want a varying intercept, we just insert a column filled with $1$s in the
  data matrix $bold(X)$.

  #v(1em)

  Mathematically, this makes the column behave like an "identity" variable
  (because the number $1$ in the multiplication operation $1 dot β$ is the
  identity element. It maps $x → x$ keeping the value of $x$ intact) and,
  consequently, we can interpret the column's coefficient as the model's
  intercept.
]

#slide(title: [Mathematical Specification -- Varying-(Intercept-)Slope Model])[
  Hence, we have as a data matrix:

  #v(2em)

  // typstfmt::off
  $
    bold(X) =
    mat(
      delim: "[",
      1, x_(11), x_(12), dots, x_(1K);
      1, x_(21), x_(22), dots, x_(2K);
      dots.v, dots.v, dots.v, dots.down, dots.v;
      1, x_(N 1), x_(N 2), dots, x_(N K);
    )
  $
  // typstfmt::on
]

#slide(title: [Mathematical Specification -- Varying-(Intercept-)Slope Model])[
  This example is for linear regression:

  $
    bold(y) &tilde "Normal"(bold(X) bold(β)_{j}, σ) \
    bold(β)_j &tilde "Multivariate Normal"(bold(μ)_j, bold(Σ))
    "for" j ∈ {1, dots, J} \
    bold(Σ) &tilde "LKJ"(η) \
    σ &tilde "Exponential"(λ_σ)
  $

  #v(1em)

  Each coefficient vector $bold(β)_j$ represents the model columns $bold(X)$ coefficients
  for every group $j ∈ J$. Also the first column of $bold(X)$ could be a column
  filled with $1$s (intercept).
]

#slide(title: [Mathematical Specification -- Varying-(Intercept-)Slope Model])[
  If you need to extend to more than one group, such as $J_1, J_2, dots$:

  $
    bold(y) &tilde "Normal"(α + bold(X) bold(β)_j_1 + bold(X) bold(β)_j_2, σ) \
    bold(β)_j_1 &tilde "Multivariate Normal"(bold(μ)_j_1, bold(Σ)_1)
    "for" j_1 ∈ {1, dots, J_1} \
    bold(β)_j_2 &tilde "Multivariate Normal"(bold(μ)_j_2, bold(Σ)_2)
    "for" j_2 ∈ {1, dots, J_2} \
    bold(Σ)_1 &tilde "LKJ"(η_1) \
    bold(Σ)_2 &tilde "LKJ"(η_2) \
    σ &tilde "Exponential"(λ_σ)
  $
]

#slide(title: [Priors for Covariance Matrices])[
  We can specify a prior for a covariance matrix $bold(Σ)$.

  #v(1em)

  For computational efficiency, we can make the covariance matrix $bold(Σ)$ into a
  correlation matrix. Every covariance matrix can be decomposed into:

  $
    bold(Σ)="diag"_"matrix" (bold(τ)) dot bold(Ω) dot "diag"_"matrix" (bold(τ))
  $

  where $bold(Ω)$ is a correlation matrix with
  $1$s in the diagonal and the off-diagonal elements between -1 e 1 $ρ ∈ (-1, 1)$.

  $bold(τ)$ is a vector composed of the variables' standard deviation from
  $bold(Σ)$ (is is the $bold(Σ)$'s diagonal).
]

#slide(title: [Priors for Covariance Matrices])[
  #text(size: 16pt)[
    Additionally, the correlation matrix $bold(Ω)$
    can be decomposed once more for greater computational efficiency.

    Since all correlations matrices are symmetric and positive definite (all of its
    eigenvalues are real numbers $RR$ and positive $>0$), we can use the
    #link("https://en.wikipedia.org/wiki/Cholesky_decomposition")[Cholesky Decomposition]
    to decompose it into a triangular matrix (which is much more computational
    efficient to handle):

    $
      bold(Ω) = bold(L)_Ω bold(L)^T_Ω
    $

    where $bold(L)_Ω$ is a lower-triangular matrix.

    What we are missing is to define a prior for the correlation matrix $bold(Ω)$.
    Not a long time ago, we've used a Wishart distribution as a prior
    @gelman2013bayesian.

    But this has been abandoned after the proposal of the LKJ distribution by
    #cite(<lewandowski2009generating>, form: "prose")
    #footnote[
      LKJ are the authors' last name initials -- Lewandowski, Kurowicka and Joe.
    ] as a prior for correlation matrices.
  ]
]
