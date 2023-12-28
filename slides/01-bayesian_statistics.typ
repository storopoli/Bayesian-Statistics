#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": *

#new-section-slide("Bayesian Statistics")

#slide(
  title: "Recommended References",
)[
  #text(
    size: 18pt,
  )[
    - #cite(<gelman2013bayesian>, form: "prose") - Chapter 1: Probability and
      inference

    - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 1: The Golem of
      Prague

    - #cite(<gelman2020regression>, form: "prose") - Chapter 3: Some basic methods in
      mathematics and probability

    - #cite(<khanBayesianLearningRule2021>, form: "prose")

    - *Probability*:
      - A great textbook -
        #cite(<bertsekasIntroductionProbability2nd2008>, form: "prose")
      - Also a great textbook (skip the frequentist part) -
        #cite(<dekkingModernIntroductionProbability2010>, form: "prose")
      - Bayesian point-of-view and also a philosophical approach -
        #cite(<jaynesProbabilityTheoryLogic2003>, form: "prose")
      - Bayesian point-of-view with a simple and playful approach -
        #cite(<kurtBayesianStatisticsFun2019>, form: "prose")
      - Philosophical approach not so focused on mathematical rigor -
        #cite(<diaconisTenGreatIdeas2019>, form: "prose")
  ]
]

#focus-slide(background: julia-purple)[
  #quote(
    block: true,
    attribution: [Denis Lindley],
  )[Inside every nonBayesian there is a Bayesian struggling to get out]

]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/frequentists-vs-bayesians.png")]
]

#slide(
  title: [What is Bayesian Statistics?],
)[
  #v(2em)

  Bayesian statistics is a *data analysis approach based on Bayes' theorem* where
  available knowledge about the parameters of a statistical model is updated with
  the information of observed data. @gelman2013bayesian.

  #v(2em)

  Previous knowledge is expressed as a *prior* distribution and combined with the
  observed data in the form of a *likelihood* function to generate a *posterior*
  distribution.

  #v(2em)

  The posterior can also be used to make predictions about future events.
]

#slide(
  title: [What changes from Frequentist Statistics?],
)[
  #text(
    size: 16pt,
  )[
    - *Flexibility* - probabilistic building blocks to construct a model #footnote[like LEGO]:
      - Probabilistic conjectures about parameters:
        - Prior
        - Likelihood

    - Better *uncertainty* treatment:
      - Coherence
      - Propagation
      - We don't use _"if we sampled infinite times from a population that we do not observe..."_

    - No *$p$-values*:
      - All statistical intuitions makes *sense*
      - 95\% certainty that $θ$'s parameter value is between $x$ and $y$
      - Almost *impossible* to perform $p$-hacking
  ]
]

#slide(
  title: [A little bit more formal],
)[
  - Bayesian Statistics uses probabilistic statements:

    - one or more parameters $θ$

    - unobserved data $tilde(y)$

  - These statements are conditioned on the observed values of $y$:

    - $P(θ | y)$

    - $P(tilde(y) | y)$

  - We also, implicitly, condition on the observed data from any covariate $x$
]

#slide(
  title: [Definition of Bayesian Statistics],
)[
  #v(4em)
  The use of Bayes theorem as the procedure to *estimate parameters of interest
  $θ$ or unobserved data $tilde(y)$*. @gelman2013bayesian
]

#slide(
  title: [PROBABILITY DOES NOT EXIST! #footnote[#cite(<definettiTheoryProbability1974>, form: "prose")]],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #v(3em)

    - Yes, probability does not exist ...

    - Or even better, probability as a physical quantity, objective chance, *does NOT
      exist*

    - if we disregard objetive chance _nothing is lost_

    - The math of inductive rationality remains *exactly the same*
  ][
    #image("images/persons/finetti.jpg")
  ]
]

#slide(
  title: [PROBABILITY DOES NOT EXIST! #footnote[#cite(<definettiTheoryProbability1974>, form: "prose")]],
)[
  #side-by-side(
    columns: (3fr, 2fr),
  )[
    - Consider flipping a biased coin
    - The trials are considered independent and, as a result, have an important
      property: *the order does not matter*
    - The frequency is considered a *sufficient statistic*
    - Saying that order does not matter or saying that the only thing that matters is
      frequency are two ways of saying the same thing
    - We say that the probability is *invariant under permutations*
  ][

    #align(
      center,
    )[
      #canvas(
        length: 0.65cm,
        {
          import draw: *
          set-style(mark: (fill: black, size: 0.3), stroke: (thickness: 2pt), radius: 1)
          circle((0, 0))
          arc((1, 0), start: 0deg, delta: 180deg, mode: "PIE", fill: julia-green)
          arc((-1, 0), start: 180deg, delta: 180deg, mode: "PIE", fill: julia-red)
          content((0, 0.5), [#align(center)[#text(fill: white, size: 14pt)[H]]])
          content((0, -0.5), [#align(center)[#text(fill: white, size: 14pt)[T]]])
          line((0, -1), (-3.5, -5))
          content((-2.5, -3))[#text(size: 14pt)[$0.5$]]
          line((0, -1), (3.5, -5))
          content((2.5, -3))[#text(size: 14pt)[$0.5$]]

          circle((-3.5, -6), fill: julia-green)
          content((-3.5, -6), [#align(center)[#text(fill: white, size: 14pt)[H]]])
          line((-3.5, -7), (-5, -11))
          content((-5, -9))[#text(size: 14pt)[$0.5$]]
          line((-3.5, -7), (-2, -11))
          content((-2, -9))[#text(size: 14pt)[$0.5$]]

          circle((3.5, -6), fill: julia-red)
          content((3.5, -6), [#align(center)[#text(fill: white, size: 14pt)[T]]])
          line((3.5, -7), (2, -11))
          content((2, -9))[#text(size: 14pt)[$0.5$]]
          line((3.5, -7), (5, -11))
          content((5, -9))[#text(size: 14pt)[$0.5$]]

          circle((-5, -12), fill: julia-green)
          content((-5, -12), [#align(center)[#text(fill: white, size: 14pt)[H]]])

          circle((-2, -12), fill: julia-red)
          content((-2, -12), [#align(center)[#text(fill: white, size: 14pt)[T]]])

          circle((2, -12), fill: julia-green)
          content((2, -12), [#align(center)[#text(fill: white, size: 14pt)[H]]])

          circle((5, -12), fill: julia-red)
          content((5, -12), [#align(center)[#text(fill: white, size: 14pt)[T]]])
        },
      )
    ]
  ]
]

#slide(title: [Probability Interpretations])[
  - *Objective* - frequency in the long run for an event:

    - $P("rain") = "days that rained" / "total days"$

    - $P("me being elected president") = 0$ (never occurred)

  #v(2em)

  - *Subjective* - degrees of belief in an event:

    - $P("rain") = "degree of belief that will rain"$

    - $P("me being elected president") = 10^(-10)$ (highly unlikely)
]

#slide(
  title: [What is Probability?],
)[
  We define $A$ is an event and $P(A)$ the probability of event $A$.

  $P(A)$ has to be between $0$ and $1$, where higher values defines higher
  probability of $A$ happening.

  $
    P(A) &∈ RR \
    P(A) &∈ [0,1] \
    0 <= &P(A) <= 1
  $
]

#slide(
  title: [Probability Axioms #footnote[#cite(<kolmogorovFoundationsTheoryProbability1933>, form: "prose")]],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    - *Non-negativity*: For every $A$:
      $P(A) >= 0$

    #v(2em)

    - *Additivity*: For every two _mutually exclusive_ $A$ and $B$:
      $P(A) = 1 - P(B) "and" P(B) = 1 - P(A)$

    #v(2em)

    - *Normalization*: The probability of all possible events $A_1, A_2, dots$
      must sum up to $1$:
      $sum_(n ∈ NN) A_n = 1$
  ][
    #image("images/persons/kolmogorov.jpg")
  ]
]

#slide(title: [Sample Space])[
  #v(3em)

  - Discrete: $Θ = {1, 2, dots}$

    #v(3em)

  - Continuous: $Θ ∈ (-oo, oo)$
]

#slide(title: [Discrete Sample Space])[
  8 planets in our solar system:

  - Mercury: ☿
  - Venus: ♀
  - Earth: ♁
  - Mars: ♂
  - Jupiter: ♃
  - Saturn: ♄
  - Uranus: ♅
  - Neptune: ♆
]

#slide(
  title: [Discrete Sample Space],
)[
  #side-by-side[
    #align(
      center,
    )[
      #canvas(
        length: 0.5cm,
        {
          import draw: *
          set-style(mark: (fill: black, size: 0.3), stroke: (thickness: 2pt), radius: 1)

          content((0, 0))[#text(size: 18pt, fill: white)[placeholder]]
          content((0, -2))[#text(size: 18pt)[
              The planet has a magnetic field
            ]]
          content((0, -6))[#text(size: 18pt)[
              The planet has moon(s)
            ]]
          content((0, -10))[#text(size: 18pt)[
              The planet has a magnetic field _and_ moon(s)
            ]]
          content((0, -14))[#text(size: 18pt)[
              The planet has a magnetic field _or_ moon(s)
            ]]
          content((0, -18))[#text(size: 18pt)[
              The planet does _not_ have a magnetic field
            ]]
        },
      )
    ]
  ][
    #align(
      center,
    )[
      #canvas(
        length: 0.5cm,
        {
          import draw: *
          set-style(mark: (fill: black, size: 0.3), stroke: (thickness: 2pt), radius: 1)

          content((0, 0))[#text(size: 18pt)[$θ ∈ E_1$]]
          circle((-7, -2))
          content((-7, -2))[#text(size: 18pt)[☿]]
          circle((-5, -2), fill: julia-purple)
          content((-5, -2))[#text(size: 18pt, fill: white)[♀]]
          circle((-3, -2), fill: julia-purple)
          content((-3, -2))[#text(size: 18pt, fill: white)[♁]]
          circle((-1, -2))
          content((-1, -2))[#text(size: 18pt)[♂]]
          circle((1, -2), fill: julia-purple)
          content((1, -2))[#text(size: 18pt, fill: white)[♃]]
          circle((3, -2), fill: julia-purple)
          content((3, -2))[#text(size: 18pt, fill: white)[♄]]
          circle((5, -2), fill: julia-purple)
          content((5, -2))[#text(size: 18pt, fill: white)[♅]]
          circle((7, -2), fill: julia-purple)
          content((7, -2))[#text(size: 18pt, fill: white)[♆]]

          content((0, -4))[#text(size: 18pt)[$θ ∈ E_2$]]
          circle((-7, -6))
          content((-7, -6))[#text(size: 18pt)[☿]]
          circle((-5, -6))
          content((-5, -6))[#text(size: 18pt)[♀]]
          circle((-3, -6), fill: julia-purple)
          content((-3, -6))[#text(size: 18pt, fill: white)[♁]]
          circle((-1, -6), fill: julia-purple)
          content((-1, -6))[#text(size: 18pt, fill: white)[♂]]
          circle((1, -6), fill: julia-purple)
          content((1, -6))[#text(size: 18pt, fill: white)[♃]]
          circle((3, -6), fill: julia-purple)
          content((3, -6))[#text(size: 18pt, fill: white)[♄]]
          circle((5, -6), fill: julia-purple)
          content((5, -6))[#text(size: 18pt, fill: white)[♅]]
          circle((7, -6), fill: julia-purple)
          content((7, -6))[#text(size: 18pt, fill: white)[♆]]

          content((0, -8))[#text(size: 18pt)[$θ ∈ E_1 sect E_2$]]
          circle((-7, -10))
          content((-7, -10))[#text(size: 18pt)[☿]]
          circle((-5, -10))
          content((-5, -10))[#text(size: 18pt)[♀]]
          circle((-3, -10), fill: julia-purple)
          content((-3, -10))[#text(size: 18pt, fill: white)[♁]]
          circle((-1, -10))
          content((-1, -10))[#text(size: 18pt)[♂]]
          circle((1, -10), fill: julia-purple)
          content((1, -10))[#text(size: 18pt, fill: white)[♃]]
          circle((3, -10), fill: julia-purple)
          content((3, -10))[#text(size: 18pt, fill: white)[♄]]
          circle((5, -10), fill: julia-purple)
          content((5, -10))[#text(size: 18pt, fill: white)[♅]]
          circle((7, -10), fill: julia-purple)
          content((7, -10))[#text(size: 18pt, fill: white)[♆]]

          content((0, -12))[#text(size: 18pt)[$θ ∈ E_1 union E_2$]]
          circle((-7, -14))
          content((-7, -14))[#text(size: 18pt)[☿]]
          circle((-5, -14), fill: julia-purple)
          content((-5, -14))[#text(size: 18pt, fill: white)[♀]]
          circle((-3, -14), fill: julia-purple)
          content((-3, -14))[#text(size: 18pt, fill: white)[♁]]
          circle((-1, -14), fill: julia-purple)
          content((-1, -14))[#text(size: 18pt, fill: white)[♂]]
          circle((1, -14), fill: julia-purple)
          content((1, -14))[#text(size: 18pt, fill: white)[♃]]
          circle((3, -14), fill: julia-purple)
          content((3, -14))[#text(size: 18pt, fill: white)[♄]]
          circle((5, -14), fill: julia-purple)
          content((5, -14))[#text(size: 18pt, fill: white)[♅]]
          circle((7, -14), fill: julia-purple)
          content((7, -14))[#text(size: 18pt, fill: white)[♆]]

          content((0, -16))[#text(size: 18pt)[$θ ∈ not E_1$]]
          circle((-7, -18), fill: julia-purple)
          content((-7, -18))[#text(size: 18pt, fill: white)[☿]]
          circle((-5, -18))
          content((-5, -18))[#text(size: 18pt)[♀]]
          circle((-3, -18))
          content((-3, -18))[#text(size: 18pt)[♁]]
          circle((-1, -18), fill: julia-purple)
          content((-1, -18))[#text(size: 18pt, fill: white)[♂]]
          circle((1, -18))
          content((1, -18))[#text(size: 18pt)[♃]]
          circle((3, -18))
          content((3, -18))[#text(size: 18pt)[♄]]
          circle((5, -18))
          content((5, -18))[#text(size: 18pt)[♅]]
          circle((7, -18))
          content((7, -18))[#text(size: 18pt)[♆]]
        },
      )
    ]
  ]
]

#slide(
  title: [Continuous Sample Space],
)[
  #side-by-side[
    #align(center)[
      #canvas(length: 0.5cm, {
        import draw: *
        set-style(mark: (fill: black, size: 0.3), stroke: (thickness: 2pt))

        content((0, 0))[#text(size: 18pt, fill: white)[placeholder]]
        content((0, -2))[#text(size: 18pt)[
            The distance is less than five centimeters
          ]]
        content((0, -6))[#text(size: 18pt)[
            The distance is between three and seven centimeters
          ]]
        content((0, -10))[#text(size: 18pt)[
            The distance is less than five centimeters \
            _and_ between three and seven centimeters
          ]]
        content((0, -14))[#text(size: 18pt)[
            The distance is less than five centimeters \
            _or_ between three and seven centimeters
          ]]
        content((0, -18))[#text(size: 18pt)[
            The distance is _not_ less than five centimeters
          ]]
      })
    ]
  ][
    #align(center)[
      #canvas(length: 0.5cm, {
        import draw: *
        set-style(
          mark: (start: "|", end: "|", fill: black, size: 1),
          stroke: (thickness: 4pt),
        )

        content((0, 0))[#text(size: 18pt)[$θ ∈ E_1$]]
        line((-7, -2), (7, -2))
        line((-7, -2), (-1, -2), stroke: julia-purple + 6pt)

        content((0, -4))[#text(size: 18pt)[$θ ∈ E_2$]]
        line((-7, -6), (7, -6))
        line((-3, -6), (1, -6), stroke: julia-purple + 6pt)

        content((0, -8))[#text(size: 18pt)[$θ ∈ E_1 sect E_2$]]
        line((-7, -10), (7, -10))
        line((-3, -10), (-1, -10), stroke: julia-purple + 6pt)

        content((0, -12))[#text(size: 18pt)[$θ ∈ E_1 union E_2$]]
        line((-7, -14), (7, -14))
        line((-7, -14), (1, -14), stroke: julia-purple + 6pt)

        content((0, -16))[#text(size: 18pt)[$θ ∈ not E_1$]]
        line((-7, -18), (7, -18))
        line((-1, -18), (7, -18), stroke: julia-purple + 6pt)
      })
    ]
  ]
]

#slide(
  title: [Discrete versus Continuous Parameters],
)[
  #text(
    size: 18pt,
  )[
    Everything that has been exposed here was under the assumption that the
    parameters are discrete.

    This was done with the intent to provide an intuition what is probability.

    Not always we work with discrete parameters.

    Parameters can be continuous, such as: age, height, weight etc. But don't
    despair! All probability rules and axioms are valid also for continuous
    parameters.

    The only thing we have to do is to change all s $sum$ for integrals $∫$. For
    example, the third axiom of *Normalization* for _continuous_
    random variables becomes:

    $
      ∫_(x ∈ X) p(x) dif x = 1
    $
  ]
]

#slide(
  title: [Conditional Probability],
)[
  Probability of an event occurring in case another has occurred or not.

  The notation we use is $P(A | B)$, that read as "the probability of observing $A$ given
  that we already observed $B$".

  $
    P(A | B) & = "number of elements in A and B" / "number of elements in B" \
    P(A | B) &= P(A sect B) / P(B)
  $

  assuming that $P(B) > 0$}.
]

#slide(
  title: [Example of Conditional Probability -- Poker Texas Hold'em],
)[
  - *Sample Space*: $52$ cards in a deck, $13$ types of cards and $4$ types of
    suits.

  - $P(A)$: Probability of being dealt an Ace $(4 / 52 = 1 / 13)$

  - $P(K)$: Probability of being dealt a King $(4 / 52 = 1 / 13)$

  - $P(A | K)$: Probability of being dealt an Ace, given that you have already a
    King $(4 / 51 ≈ 0.078)$

  - $P(K | A)$: Probability of being dealt a King, given that you have already an
    Ace $(4 / 51 ≈ 0.078)$
]

#slide(
  title: [Caution! Not always $P(A | B) = P(B | A)$],
)[
  In the previous example we have the symmetry $P(A | K) = P(K | A)$, *but not
  always this is true* #footnote[
    More specific, if the basal rates $P(A)$ and $P(B)$ aren't equal, the symmetry
    is broken $P(A | B) ≠ P(B | A)$
  ]

  #text(
    size: 14pt,
  )[
    The Pope is catholic:

    - $P("pope")$: Probability of some random person being the Pope, something really
      small, 1 in 8 billion $(1 / (8 dot 10^9))$

    - $P("catholic")$: Probability of some random person being catholic, 1.34 billion
      in 8 billion $(1.34 / 8 ≈ 0.17)$

    - $P("catholic" | "pope")$: Probability of the Pope being catholic
      $(999 / 1000 = 0.999)$

    - $P("pope" | "catholic")$: Probability of a catholic person being the Pope
      $(1 / (1.34 dot 10^9) dot 0.999 ≈ 7.46 dot 10^(-10))$
  ]

  - #text(size: 22pt)[*Hence*: $P("catholic" | "pope") ≠ P("pope" | "catholic")$]
]

#slide(title: [Joint Probability])[
  Probability of two or more events occurring.

  The notation we use is $P(A, B)$, that read as
  "the probability of observing $A$ and also observing $B$".

  $
    P(A, B) &= "number of elements in A or B" \
    P(A, B) &= P(A union B) \
    P(A, B) &= P(B, A)
  $
]

#slide(
  title: [Example of Joint Probability -- Revisiting Poker Texas Hold'em],
)[
  #text(
    size: 17pt,
  )[
    - *Sample Space*: $52$ cards in a deck, $13$ types of cards and $4$ types of
      suits.
    - $P(A)$: Probability of being dealt an Ace $(4 / 52 = 1 / 13)$
    - $P(K)$: Probability of being dealt a King $(4 / 52 = 1 / 13)$
    - $P(A | K)$: Probability of being dealt an Ace, given that you have already a
      King $(4 / 51 ≈ 0.078)$
    - $P(K | A)$: Probability of being dealt a King, given that you have already an
      Ace $(4 / 51 ≈ 0.078)$
    - $P(A, K)$: Probability of being dealt an Ace _and_ being dealt a King
      $
        P(A, K)           &= P(K, A) \
        P(A) dot P(K | A) &= P(K) dot P(A | K) \
        1 / 13 dot 4 / 51 &= 1 / 13 dot 4 / 51 \
                          &≈ 0.006
      $
  ]
]

#slide(
  title: [Visualization of Joint Probability versus Conditional Probability],
)[
  #figure(
    image("images/probability/joint_vs_conditional_probability.svg", height: 80%),
    caption: [$P(X,Y)$ versus $P(X | Y=-0.75)$],
  )
]

#slide(
  title: [Product Rule of Probability #footnote[also called the Product Rule of Probability.]],
)[
  #v(2em)

  We can decompose a joint probability $P(A,B)$ into the product of two
  probabilities:

  #v(2em)

  $
    P(A,B)            &= P(B,A) \
    P(A) dot P(B | A) &= P(B) dot P(A | B)
  $
]

#slide(
  title: [Who was Thomas Bayes?],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #text(
      size: 17pt,
    )[
      - *Thomas Bayes* (1701 - 1761) was a statistician, philosopher and Presbyterian
        minister who is known for formulating a specific case of the theorem that bears
        his name: Bayes' theorem.

      - Bayes never published what would become his most famous accomplishment; his
        notes were edited and published posthumously by his friend *Richard Price*.

      - The theorem official name is *Bayes-Price-Laplace*, because *Bayes* was the
        first to discover, *Price* got his notes, transcribed into mathematical
        notation, and read to the Royal Society of London, and *Laplace* independently
        rediscovered the theorem without having previous contact in the end of the XVIII
        century in France while using probability for statistical inference with census
        data in the Napoleonic era.
    ]
  ][
    #image("images/persons/thomas_bayes.png")
  ]
]

#slide(title: [Bayes Theorem])[
  Tells us how to "invert" conditional probability:

  #v(3em)

  $ P(A | B) = (P(A) dot P(B | A)) / P(B) $
]

#slide(title: [Bayes' Theorem Proof])[
  Remember the following probability identity:

  #text(size: 18pt)[

    $
      P(A,B)            &= P(B,A) \
      P(A) dot P(B | A) &= P(B) dot P(A | B)
    $

    OK, now divide everything by $P(B)$:

    $
      (P(A) dot P(B | A)) / P(B) &= (P(B) dot P(A | B)) / P(B) \
      (P(A) dot P(B | A)) / P(B) &= P(A | B) \
      P(A | B)                   &= (P(A) dot P(B | A)) / P(B)
    $
  ]
]

#slide(
  title: [A Probability Textbook Classic #footnote[Adapted from: #link(
        "https://www.yudkowsky.net/rational/bayes",
      )[Yudkowski - _An Intuitive Explanation of Bayes' Theorem_]]],
)[
  #text(
    size: 15pt,
  )[
    How accurate is a *breast cancer* test?

    - 1% of women have *breast cancer* (Prevalence)

    - 80% of mammograms detect *breast cancer* (True Positive)

    - 9.6% of mammograms detect *breast cancer* when there is no incidence (False
      Positive)

      $
        P(C | +) &= (P(+ | C) dot P(C)) / P(+) \
        P(C | +) &= (P(+ | C) dot P(C)) / (P(+ | C) dot P(C) + P(+ | not C) dot P(not C)) \
        P(C | +) &= (0.8 dot 0.01) / (0.8 dot 0.01 + 0.096 dot 0.99) \
        P(C | +) &≈ 0.0776
      $
  ]
]

#slide(
  title: [Why Bayes' Theorem is Important?],
)[
  We can invert the conditional probability:

  $
    P("hypothesis" | "data") = (P("data" | "hypothesis") dot P("hypothesis")) / P("data")
  $

  #v(2em)

  But isn't this the $p$-value?

  #align(center)[#text(size: 24pt, fill: julia-red)[NO!]]
]

#slide(
  title: [What are $p$-values?],
)[
  #v(2em)

  $p$-value is the probability of obtaining results at least as extreme as the
  observed, given that the null hypothesis $H_0$ is true:

  #v(2em)

  $ P(D | H_0) $
]

#slide(title: [What $p$-value is *not*!])[
  #align(center)[#image("images/memes/pvalue.jpg", height: 80%)]
]

#slide(
  title: [What $p$-value is *not*!],
)[
  #text(
    size: 18pt,
  )[
    - *$p$-value is not the probability of the null hypothesis*
      - #text(fill: julia-red)[No!]
      - Infamous confusion between $P(D | H_0)$ and $P(H_0 | D)$.
      - To get $P(H_0 | D)$ you need Bayesian statistics.

    - *$p$-value is not the probability of data being generated at random*
      - #text(fill: julia-red)[No again!]
      - We haven't stated nothing about randomness.

    - *$p$-value measures the effect size of a statistical test*
      - Also #text(fill: julia-red)[no]... $p$-value does not say anything about effect
        sizes.
      - Just about if the observed data diverge of the expected under the null
        hypothesis.
      - Besides, $p$-values can be hacked in several ways @head2015extent.
  ]
]

#slide(
  title: [The relationship between $p$-value and $H_0$],
)[
  To find out about any $p$-value, *find out what $H_0$ is behind it*. It's
  definition will never change, since it is always $P(D | H_0)$:

  - *$t$-test*: $P(D | "the difference between the groups is zero")$

  - *ANOVA*: $P(D | "there is no difference between groups")$

  - *Regression*: $P(D | "coefficient has a null value")$

  - *Shapiro-Wilk*: $P(D | "population is distributed as a Normal distribution")$
]

#slide(
  title: [What are Confidence Intervals?],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #v(2em)
    #quote(
      block: true,
      attribution: [
        #cite(<neyman1937outline>, form: "prose") the "father" of confidence intervals
      ],
    )[
      A confidence interval of X% for a parameter is an interval $(a, b)$
      generated by a repeated sampling procedure has probability X% of containing the
      true value of the parameter, for all possible values of the parameter.
    ]
  ][
    #image("images/persons/neyman.jpg")
  ]
]

#slide(
  title: [What are Confidence Intervals?],
)[
  #text(
    size: 18pt,
  )[
    Say you performed a statistical analysis to compare the efficacy of a public
    policy between two groups and you obtain a difference between the mean of these
    groups. You can express this difference as a confidence interval. Often we
    choose 95% confidence.

    In other words, 95% is _not_ the probability of obtaining data such that the
    estimate of the true parameter is contained in the interval that we obtained, it
    is the *probability of obtaining data such that, if we compute another
    confidence
    interval in the same way, it contains the true parameter*.

    The interval that we got in this particular instance is irrelevant and might as
    well be thrown away.

    #text(
      fill: julia-red,
    )[
      Doesn't say anything about you *target population*, but about you *sample* in an
      insane process of *infinite sampling* ...
    ]
  ]
]

#slide(
  title: [Confidence Intervals versus Posterior Intervals],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm,
      {
        plot.plot(
          size: (16, 9),
          x-label: $θ$,
          y-label: none,
          x-tick-step: 5,
          y-tick-step: 0.25,
          x-min: -0.1,
          x-max: 4,
          y-min: -0.01,
          y-max: 1.5,
          {
            plot.add(domain: (0.02, 4), samples: 200, x => lognormal(x, 0, 2))
            plot.add(
              domain: (0.25950495026507125, 3.8534910373715427),
              samples: 200,
              style: plot.palette.blue,
              hypograph: true,
              // label: "50% Posterior", // FIXME: depends on unreleased cetz 2.0.0
              x => lognormal(x, 0, 2),
            )
            plot.add(
              domain: (0.001, 0.09),
              samples: 50,
              style: (
                stroke: julia-red + 2pt,
                mark: (start: "|", end: "|", fill: julia-red, size: 0.05),
              ),
              // mark: "o",
              // mark-size: 0.4,
              // label: "MLE", // FIXME: depends on unreleased cetz 2.0.0
              x => 1.4739034450607542,
            )
          },
        )
      },
    )
  ]
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/assumptions-vs-reality.jpg")]
]

#slide(
  title: [But why I never see stats without $p$-values?],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #text(
      size: 17pt,
    )[
      We cannot understand $p$-values if we do no not comprehend its origins and
      historical trajectory. The first mention of $p$-values was made by the
      statistician Ronald Fischer in 1925:
      #quote(block: true, attribution: [
        #cite(<fisher1925statistical>, form: "prose")
      ])[
        $p$-value is a measure of evidence against the null hypothesis
      ]
      - To quantify the strength of the evidence against the null hypothesis, Fisher
        defended "$p<0.05$ as the standard level to conclude that there is evidence
        against the tested hypothesis"

      - "We should not be off-track if we draw a conventional line at 0.05"
    ]
  ][
    #image("images/persons/fisher.jpg")
  ]
]

#slide(
  title: [$p = 0.06$],
)[

  - Since $p$-value is a probability, it is also a continuous measure.

  #v(2em)

  - There is no reason for us to differentiate $p = 0.049$ against $p = 0.051$.

  #v(2em)

  - Robert Rosenthal, a psychologist said "surely, God loves the $.06$ nearly as
    much as the $.05$" @rosnow1989statistical.
]

#slide(
  title: [
    But why I never heard about Bayesian statistics? #footnote[
      _inverse probability_
      was how Bayes' theorem was called in the beginning of the 20th century.
    ]
  ],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #v(3em)

    #quote(
      block: true,
      attribution: [
        #cite(<fisher1925statistical>, form: "prose")
      ],
    )[
      ... it will be sufficient ... to reaffirm my personal conviction ... that the
      theory of inverse probability is founded upon an error, and must be wholly
      rejected.
    ]
  ][
    #image("images/persons/fisher.jpg")
  ]
]

#slide(
  title: [
    Inside every nonBayesian, there is a Bayesian struggling to get out
    #footnote[
      quote from Dennis Lindley.
    ]
  ],
)[
  #side-by-side(
    columns: (4fr, 1fr),
  )[
    #v(2em)

    - In his final year of life, Fisher published a paper
      @fisherExamplesBayesMethod1962 examining the possibilities of Bayesian methods,
      but with the prior probabilities being determined experimentally.

    #v(2em)

    - Some authors speculate @jaynesProbabilityTheoryLogic2003 that if Fisher were
      alive today, he would probably be a Bayesian.
  ][
    #image("images/persons/fisher.jpg")
  ]
]

#slide(
  title: [Bayes' Theorem as an Inference Engine],
)[
  #text(
    size: 13pt,
  )[
    Now that you know what is probability and Bayes' theorem, I will propose the
    following:

    $
      underbrace(P(θ | y), "Posterior") =
      (overbrace(P(y | θ), "Likelihood") dot overbrace(P(θ), "Prior")) /
      underbrace(P(y), "Normalizing Constant")
    $

    - $θ$ -- parameter(s) of interest

    - $y$ -- observed data

    - *Priori*: prior probability of the parameter(s) value(s)

    - *Likelihood*: probability of the observed data given the parameter(s) value(s)

    - *Posterior*: posterior probability of the parameter(s) value(s) after we
      observed data $y$

    - *Normalizing Constant* #footnote[sometimes also called _evidence_.]:
      $P(y)$ does not make any intuitive sense. This probability is transformed and
      can be interpreted as something that only exists so that the result $P(y | θ) P(θ)$ be
      constrained between $0$ and $1$
      -- a valid probability.
  ]
]

#slide(
  title: [Bayes' Theorem as an Inference Engine],
)[
  Bayesian statistics allows us to *quantify directly the uncertainty* related to
  the value of one or more parameters of our model given the observed data.

  #v(1em)

  This is the *main feature* of Bayesian statistics, since we are estimating
  directly $P(θ | y)$ using Bayes' theorem.

  #v(1em)

  The resulting estimate is totally intuitive: simply quantifies the uncertainty
  that we have about the value of one or more parameters given the data, model
  assumptions (likelihood) and the prior probability of these parameter's values.
]

// typstfmt::off
#slide(
title: [Bayesian vs Frequentist Stats],
)[
  #table(
    columns: (auto, auto, auto),
    inset: 10pt,
    align: (left + horizon, center + horizon, center + horizon),
    [],              [#text(fill: julia-blue)[Bayesian Statistics]], [#text(fill: julia-red)[Frequentist Statistics]],
    [*Data*],        [Fixed -- Non-random],                          [Uncertain -- Random],
    [*Parameters*],  [Uncertain -- Random],                          [Fixed -- Non-random],
    [*Inference*],   [Uncertainty regarding the parameter value],    [Uncertainty regarding the sampling process from an infinite population],
    [*Probability*], [Subjective],                                   [Objective (but with several model assumptions)],
    [*Uncertainty*], [Posterior Interval -- $P(θ | y)$],             [Confidence Interval -- $P(y | θ)$],
  )
]
// typstfmt::on

#slide(title: [Advantages of Bayesian Statistics])[
  - Natural approach to express uncertainty

  - Ability to incorporate previous information

  - Higher model flexibility

  - Full posterior distribution of the parameters

  - Natural propagation of uncertainty

  #v(2em)

  *Main disadvantage*: Slow model fitting procedure
]

#slide(title: [The beginning of the end of Frequentist Statistics])[
  #text(
    size: 18pt
  )[
  - Know that you are in a very special moment in history of great changes in statistics

  - I believe that frequentist statistics, specially the way we qualify evidence and hypotheses with
    $p$-values will transform in a "significant" #footnote[pun intended ...] way.

  - 8 years ago, the _American Statistical Association_ (ASA) published a declaration about
    $p$-values @Wasserstein2016.
    It states exactly what we exposed here:
    The main concepts of the null hypothesis significant testing and,
    in particular $p$-values, cannot provide what researchers demand of them.
    Despite what says several textbooks, learning materials and published content,
    $p$-values below $0.05$ doesn't "prove" anything.
    Not, on the other way around, $p$-values higher than $0.05$ refute anything.

  - ASA statement has more than 4.700 citations with relevant impact.
  ]
]

#slide(title: [The beginning of the end of Frequentist Statistics])[
  #text(
    size: 17pt
  )[
    - An international symposium was promoted in 2017 which originated
      an open-access special edition of _The American Statistician_ dedicated to
      practical ways to abandon $p < 0.05$ @wassersteinMovingWorld052019.

    - Soon there were more attempts and claims.
      In September 2017, _Nature Human Behaviour_ published an editorial proposing
      that the $p$-value's significance level be decreased from $0.05$ to $0.005$
      @benjaminRedefineStatisticalSignificance2018.
      Several authors,
      including highly important and influential statisticians argued that this
      simple step would help to tackle the replication crisis problem in science,
      that many believe be the main consequence of the abusive use of $p$-values
      @Ioannidis2019.

    - Furthermore,
      many went a step ahead and suggested that science banish
      once for all $p$-values
      @ItTimeTalk2019 @lakensJustifyYourAlpha2018.
      Many suggest (including myself) that the main tool of statistical inference
      be Bayesian statistics @amrheinScientistsRiseStatistical2019 @Goodman1180
      @vandeschootBayesianStatisticsModelling2021.
  ]
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/stats-phil.png")]
]
