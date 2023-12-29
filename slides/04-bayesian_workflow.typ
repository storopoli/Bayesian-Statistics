#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2"

#new-section-slide("Bayesian Workflow")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose") - Chapter 6: Model checking

  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 4: Geocentric Models

  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 6: Background on regression modeling
    - Chapter 11: Assumptions, diagnostics, and model evaluation

  - #cite(<gelmanBayesianWorkflow2020>, form: "prose") - "Workflow Paper"
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/workflow.jpg")]
]

#slide(
  title: "All Models Are Wrong",
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #align(
      center + horizon,
    )[#quote(block: true, attribution: [George Box @boxScienceStatistics1976])[
        All models are wrong but some are useful
      ]]
  ][
    #image("images/persons/george_box.jpg")
  ]
]

#slide(title: [Bayesian Workflow #footnote[
    based on #cite(<gelmanBayesianWorkflow2020>, form: "prose")
  ]])[
  #v(2em)
  #align(center)[#cetz.canvas({
      import cetz.draw: *
      set-style(
        mark: (start: ">", end: ">", fill: black, size: 0.3),
        stroke: (thickness: 2pt),
        radius: 3,
      )
      circle((0, 0))
      content((0, 0), [#align(center)[Prior \ Elicitation]])
      line((3, 0), (7, 0))
      content((5, 2), [#align(center)[Prior \ Predictive \ Check]])
      circle((10, 0))
      content((10, 0), [#align(center)[Model \ Specification]])
      line((13, 0), (17, 0))
      content((15, 2), [#align(center)[Posterior \ Predictive \ Check]])
      circle((20, 0))
      content((20, 0), [#align(center)[Posterior \ Inference]])
    })]
]

#slide(
  title: [Bayesian Workflow #footnote[
      adapted from #link("https://github.com/elizavetasemenova")[Elizaveta Semenova].
    ]],
)[
  - Understand the domain and problem.
  - Formulate the model mathematically.
  - Implement model, test, and debug.
  - Perform prior predictive checks.
  - Fit the model.
  - Assess convergence diagnostics.
  - Perform posterior predictive checks.
  - Improve the model iteratively: from baseline to complex and computationally
    efficient models.
]

#slide(
  title: "Actual Bayesian Workflow",
)[
  #figure(
    image("images/workflow/workflow_overview.svg", height: 80%),
    caption: [Bayesian workflow by #cite(<gelmanBayesianWorkflow2020>, form: "prose").],
  )
]

#slide(title: [Not a "new idea"])[
  #figure(
    image("images/workflow/box_loop.png", height: 80%),
    caption: [Box's Loop from
      #cite(<boxScienceStatistics1976>, form: "prose")
      but taken from
      #cite(<Blei_Workflow2014>, form: "prose").],
  )
]

#slide(
  title: "Prior Predictive Check",
)[
  Before we feed data into our model, we need to check all of our priors.

  #v(1em)

  In a very simple way, it consists in simulate parameter values based on prior
  distribution without conditioning on any data or employing any likelihood
  function.

  #v(1em)

  Independent of the level of information specified in the priors, it is always
  important to perform a prior sensitivity analysis in order to have a deep
  understanding of the prior influence onto the posterior.
]

#slide(
  title: "Prior Predictive Check",
)[
  #text(
    size: 18pt,
  )[
    We need to make sure that the posterior distribution of $bold(y)$, namely $bold(tilde(y))$,
    can capture all the nuances of the real distribution density/mass of $bold(y)$.

    #v(1em)

    This procedure is called *posterior predictive check*, and it is generally
    carried on by a visual inspection #footnote[
      we also perform mathematical/exact inspections, see the section on _Model Comparison_.
    ]
    of the real density/mass of $bold(y)$ against generated samples of $bold(y)$ by
    the Bayesian model.

    #v(1em)

    The purpose is to compare the histogram of the dependent variable $bold(y)$
    against the histograms of simulated dependent variables $bold(y)_"rep"$
    by the model after parameter inference.

    #v(1em)

    The idea is that the real and simulated histograms blend together and we do not
    observer any divergences.
  ]
]

#slide(
  title: "Examples of Posterior Predictive Checks",
)[
  #side-by-side(
    columns: (1fr, 1fr),
  )[
    #figure(
      image("images/predictive_checks/pp_check_brms.svg", height: 80%),
      caption: [#text(size: 18pt)[Real versus Simulated Densities]],
    )
  ][
    #figure(
      image("images/predictive_checks/pp_check_brms_ecdf.svg", height: 80%),
      caption: [#text(size: 18pt)[Real versus Simulated Empirical CDFs]],
    )
  ]
]
