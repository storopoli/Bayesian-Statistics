#import "@preview/polylux:0.3.1": *
#import themes.clean: *

// colors
#let julia-purple = rgb("#9558b2")
#let julia-blue = rgb("4063d8")

#show: clean-theme.with(
    footer: [Bayesian Statistics, Jose Storopoli],
    short-title: [Bayesian Statistics],
    logo: image("logos/juliadatascience_white.png"),
    color: julia-purple,
)

// customizations
#show link: set text(rgb("4063d8"))
#set text(font: "Fira Sans", size: 20pt)
// #show heading: set text(font: "Vollkorn")
#show raw: set text(font: "Fira Mono", size: 20pt)
#show cite: set text(fill: julia-blue)

// begin slides
#title-slide(
  title: [Bayesian Statistics],
  // subtitle: [TODO],
  authors: [Jose Storopoli#footnote[Universidade Nove de Julho, Pumas-AI \ #v(0.5em)]],
)

#slide(title: "License")[
  #v(2em)

  #align(center)[
    The text and images from these slides have a

    #link(
      "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en"
    )[
      Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
    ]

    #v(1.5em)

    #image("images/cc-by-nc-sa.svg", width: 20%)

    #v(1.5em)

    All links are in #text(julia-blue)[blue].
    Feel free to click on them.
  ]
]

#slide[
  == Outline
  #utils.polylux-outline()
]

// #include "00-Tools.typ"
// #include "01-Bayesian_Statistics.typ"
// #include "02-Statistical_Distributions.typ"
// #include "03-Priors.typ"
// #include "04-Predictive_Checks.typ"
// #include "05-Linear_Regression.typ"
// #include "06-Logistic_Regression.typ"
// #include "07-Ordinal_Regression.typ"
// #include "08-Poisson_Regression.typ"
// #include "09-Robust_Regression.typ"
// #include "10-Sparse_Regression.typ"
// #include "11-Hierarchical_Models.typ"
// #include "12-MCMC.typ"
// #include "13-Model_Comparison.typ"

#slide(title: "Bibliography")[
    #bibliography(title: none, style: "harvard-cite-them-right", "references.bib")
]
