#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *

#show: clean-theme.with(
  footer: [Bayesian Statistics, Jose Storopoli],
  short-title: [Bayesian Statistics],
  logo: image("images/logos/juliadatascience_white.png"),
  color: julia-purple,
)

// customizations
#set bibliography(style: "harvard-cite-them-right")
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

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/main.jpg")]
]

#slide(
  title: "License",
)[
  #v(2em)

  #align(
    center,
  )[
    The text and images from these slides have a

    #link(
      "https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en",
    )[
      Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
    ]

    #v(1.5em)

    #image("images/badges/cc-by-nc-sa.svg", width: 20%)

    #v(1.5em)

    All links are in #text(julia-blue)[blue]. Feel free to click on them.
  ]
]

#slide(title: [Outline])[
  #utils.polylux-outline()
]

#include "00-tools.typ"
// #include "01-bayesian_statistics.typ"
#include "02-statistical_distributions.typ"
#include "03-priors.typ"
#include "04-bayesian_workflow.typ"
#include "05-linear_regression.typ"
#include "06-logistic_regression.typ"
#include "07-ordinal_regression.typ"
#include "08-poisson_regression.typ"
#include "09-robust_regression.typ"
#include "10-sparse_regression.typ"
// #include "11-hierarchical_models.typ"
// #include "12-mcmc.typ"
// #include "13-model_comparison.typ"
#include "backup_slides.typ"

#slide(title: "Bibliography")[
  #bibliography(title: none, "references.yml")
]

