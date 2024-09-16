#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": *
#import "@preview/algo:0.3.3": algo, i, d, comment, code

#new-section-slide("Markov Chain Monte Carlo (MCMC) and Model Metrics")

#slide(title: "Recommended References")[
  #text(size: 18pt)[
    - #cite(<gelman2013bayesian>, form: "prose"):
      - Chapter 10: Introduction to Bayesian computation
      - Chapter 11: Basics of Markov chain simulation
      - Chapter 12: Computationally efficient Markov chain simulation

    - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 9: Markov Chain Monte
      Carlo

    - #cite(<neal2011mcmc>, form: "prose")

    - #cite(<betancourtConceptualIntroductionHamiltonian2017>, form: "prose")

    - #cite(<gelman2020regression>, form: "prose") - Chapter 22, Section 22.8:
      Computational efficiency

    - #cite(<chibUnderstandingMetropolisHastingsAlgorithm1995>, form: "prose")

    - #cite(<casellaExplainingGibbsSampler1992>, form: "prose")
  ]
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/computation.png")]
]

#slide(title: [Monte Carlo Methods])[
  #side-by-side(columns: (4fr, 1fr))[

    - #link("http://mc-stan.org/")[Stan] is named after the mathematician Stanislaw
      Ulam, who was involved in the Manhattan project, and while trying to calculate
      the neutron diffusion process for the hydrogen bomb ended up creating a whole
      class of methods called *Monte Carlo* @eckhardtStanUlamJohn1987.

    - Monte Carlo methods employ randomness to solve problems in principle are
      deterministic in nature. They are frequently used in physics and mathematical
      problems, and very useful when it is difficult or impossible to use other
      approaches.][
    #image("images/persons/stanislaw.jpg")
  ]
]

#slide(title: [
  History Behind the Monte Carlo Methods
  #footnote[those who are interested, should read #cite(<eckhardtStanUlamJohn1987>, form: "prose").]
])[
  #side-by-side(columns: (4fr, 1fr))[
    #text(size: 17pt)[
      - The idea came when Ulam was playing Solitaire while recovering from surgery.
        Ulam was trying to calculate the deterministic, i.e. analytical solution, of the
        probability of being dealt an already-won game. The calculations where almost
        impossible. So, he thought that he could play hundreds of games to statistically
        estimate, i.e. numerical solution, the probability of this result.

      - Ulam described the idea to John von Neumann in 1946.

      - Due to the secrecy, von Neumann and Ulam's work demanded a code name. Nicholas
        Metropolis suggested using "Monte Carlo", a homage to the "Casino Monte Carlo"
        in Monaco, where Ulam's uncle would ask relatives for money to play.
    ]
  ][
    #image("images/persons/stanislaw.jpg")
  ]
]

#slide(title: [Why Do We Need MCMC?])[
  #text(size: 18pt)[
    The main computation barrier for Bayesian statistics is the denominator in
    Bayes' theorem,
    $P("data")$:

    $
      P(θ | "data") = (P(θ) dot P("data" | θ)) / P("data")
    $

    In discrete cases, we can turn the denominator into a sum over all parameters
    using the *chain rule* of probability:

    $
      P(A,B | C) = P(A | B,C) dot P(B | C)
    $

    This is also known as *marginalization*:

    $
      P("data") = sum_θ P("data" | θ) dot P(θ)
    $
  ]
]

#slide(title: [Why Do We Need MCMC?])[
  However, in the case of continuous values, the denominator $P("data")$
  turns into a very big and nasty integral:

  $
    P("data") = ∫_θ P("data" | θ) dot P(θ) dif θ
  $

  In many cases the integral is intractable (not possible of being deterministic
  evaluated) and, thus, we must find other ways to compute the posterior
  $P(θ | "data")$ without using the denominator
  $P("data")$.

  #v(2em)

  *This is where Monte Carlo methods comes into play!*
]

#slide(title: [Why Do We Need the Denominator $P("data")$?])[
  To normalize the posterior with the intent of making it a *valid probability*.
  This means that the probability for all possible parameters' values must be $1$:

  - in the *discrete* case:
    $
      sum_θ P(θ | "data") = 1
    $

  - in the *continuous* case:
    $
      ∫_θ P(θ | "data") dif θ = 1
    $
]

#slide(title: [What If We Remove the Denominator $P("data")$?])[
  By removing the denominator $("data")$, we conclude that the posterior
  $P(θ | "data")$ is *proportional* to the product of the prior and the likelihood
  $P(θ) dot P("data" | θ)$:

  #v(3em)

  $
    P(θ | "data") ∝ P(θ) dot P("data" | θ)
  $
]

#slide(title: [Markov Chain Monte Carlo (MCMC)])[
  Here is where *Markov Chain Monte Carlo* comes in:

  MCMC is an ample class of computational tools to approximate integrals and
  generate samples from a posterior probability @brooksHandbookMarkovChain2011.

  MCMC is used when it is not possible to sample $bold(θ)$
  directly from the posterior probability
  $P(bold(θ) | "data")$.

  Instead, we collect samples in an iterative manner, where every step of the
  process we expect that the distribution which we are sampling from
  $P^*(bold(θ)^((*)) | "data")$
  becomes more similar in every iteration to the posterior
  $P(bold(θ) | "data")$.

  All of this is to *eliminate the evaluation* (often impossible) of the
  *denominator*
  $P("data")$.
]

#slide(title: [
  Markov Chains
])[
  #side-by-side(columns: (4fr, 1fr))[
    #v(2em)

    - We proceed by defining an *ergodic Markov chain* #footnote[
        meaning that there is an *unique stationary distribution*.
      ]
      in which the set of possible states is the sample size and the stationary
      distribution is the distribution to be _approximated_ (or _sampled_).

    - Let $X_0, X_1, dots, X_n$ be a simulation of the chain. The Markov chain
      *converges to the stationary distribution from any initial state*
      $X_0$ after a *sufficient large number of iterations* $r$. The distribution of
      the state $X_r$ will be similar to the stationary distribution, hence we can use
      it as a sample.
  ][
    #image("images/persons/andrei_markov.jpg")
  ]
]

#slide(title: [
  Markov Chains
])[
  #side-by-side(columns: (4fr, 1fr))[

    - Markov chains have a property that the probability distribution of the next
      state *depends only on the current state and not in the sequence of events that
      preceded*:

      $
        P(X_(n + 1) = x | X_0, X_1, X_2, dots, X_n) = P(X_(n + 1)=x | X_n)
      $

      This property is called *Markovian*

    - Similarly, using this argument with $X_r$ as the initial state, we can use $X_(2r)$ as
      a sample, and so on. We can use the sequence of states $X_r, X_(2r), X_(3r), dots$
      as almost (independent samples) of Markov chain stationary distribution.][
    #image("images/persons/andrei_markov.jpg")
  ]
]

#slide(title: [
  Example of a Markov Chain
])[
  #align(center)[
    #canvas(
      length: 0.9cm,
      {
        import draw: *
        set-style(
          mark: (end: ">", fill: black),
          stroke: (thickness: 2pt),
          radius: 2,
        )
        circle((0, 0))
        content((0, 0), [#align(center)[Sun]])
        bezier-through((0, 2), (4, 4), (8, 2))
        content((4, 5), [#align(center)[$0.6$]])
        bezier-through((-2, 0), (-3, -1), (-4, 0), mark: (end: none))
        bezier-through((-4, 0), (-3, 1), (-2, 0))
        content((-5, 0), [#align(center)[$0.4$]])

        circle((8, 0))
        content((8, 0), [#align(center)[Rain]])
        content((4, -5), [#align(center)[$0.7$]])
        bezier-through((8, -2), (4, -4), (0, -2))
        bezier-through((10, 0), (11, -1), (12, 0), mark: (end: none))
        bezier-through((12, 0), (11, 1), (10, 0))
        content((13, 0), [#align(center)[$0.3$]])
      },
    )
  ]
]

#slide(title: [Markov Chains])[
  #text(size: 18pt)[
    The efficacy of this approach depends on:

    - *how big $r$ must be* to guarantee an *adequate sample*.

    - *computational power* required for every Markov chain iteration.

    Besides, it is custom to discard the first iterations of the algorithm because
    they are usually non-representative of the underlying stationary distribution to
    be approximate. In the initial iterations of MCMC algorithms, often the Markov
    chain is in a "warm-up"
    #footnote[some references call this "burnin".] process, and its state is very
    far away from an ideal one to begin a trustworthy sampling.

    Generally, it is recommended to *discard the first half iterations*
    @gelmanBasicsMarkovChain2013.
  ]
]

#slide(title: [MCMC Algorithms])[
  We have *TONS* of MCMC algorithms
  #footnote[
    see the #link(
      "https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo",
    )[Wikipedia page for a full list].
  ]. Here we are going to cover two classes of MCMC algorithms:

  #v(2em)

  - Metropolis-Hastings @metropolisEquationStateCalculations1953
    @hastingsMonteCarloSampling1970.

  #v(2em)

  - Hamiltonian Monte Carlo
    #footnote[sometimes called Hybrid Monte Carlo, specially in the physics literature.]
    @neal2011mcmc @betancourtConceptualIntroductionHamiltonian2017.
]

#slide(title: [MCMC Algorithms -- Metropolis-Hastings])[
  These are the first MCMC algorithms. They use an *acceptance/rejection rule for
  the proposals*. They are characterized by proposals originated from a random
  walk in the parameter space. The *Gibbs algorithm* can be seen as a *special
  case* of MH because all proposals are automatically accepted
  @gelmanIterativeNonIterativeSimulation1992

  #v(2em)

  Asymptotically, they have an acceptance rate of 23.4%, and the computational
  cost of every iteration is $cal(O)(d)$, where $d$ is the number of dimension in
  the parameter space @beskosOptimalTuningHybrid2013.
]

#slide(title: [MCMC Algorithms -- Hamiltonian Monte Carlo])[
  The current most efficient MCMC algorithms. They try to *avoid the random walk
  behavior by introducing an auxiliary vector of momenta
  using Hamiltonian dynamics*. The proposals are "guided" to higher density
  regions of the sample space. This makes *HMC more efficient in orders of
  magnitude when compared to MH and Gibbs*.

  #v(2em)

  Asymptotically, they have an acceptance rate of 65.1%, and the computational
  cost of every iteration is $cal(O)(d^(1 / 4))$, where $d$ is the number of
  dimension in the parameter space @beskosOptimalTuningHybrid2013.
]

#slide(title: [
  Metropolis Algorithm
])[
  #side-by-side(columns: (4fr, 1fr))[
    #text(size: 18pt)[
      The first broadly used MCMC algorithm to generate samples from a Markov chain
      was originated in the physics literature in the 1950s and is called Metropolis
      @metropolisEquationStateCalculations1953, in honor of the first author
      #link(
        "https://en.wikipedia.org/wiki/Nicholas_Metropolis",
      )[Nicholas Metropolis].

      In sum, the Metropolis algorithm is an adaptation of a random walk coupled with
      an acceptance/rejection rule to converge to the target distribution.

      Metropolis algorithm uses a "proposal distribution"
      $J_t (bold(θ)^*)$
      to define the next values of the distribution
      $P^*(bold(θ)^* | "data")$. This distribution must be symmetric:

      $
        J_t (bold(θ)^* | bold(θ)^(t-1)) = J_t (bold(θ)^(t-1) | bold(θ)^(*))
      $
    ]
  ][
    #image("images/persons/nicholas_metropolis.png")
  ]
]

#slide(title: [Metropolis Algorithm])[
  #text(size: 18pt)[
    Metropolis is a random walk through the parameter sample space, where the
    probability of the Markov chain changing its state is defined as:

    $
      P_"change" = min(P(bold(θ)_"proposed") / (P(bold(θ)_"current")), 1).
    $

    This means that the Markov chain will only change to a new state based in one of
    two conditions:

    - when the probability of the random walk proposed parameters
      $P(bold(θ)_"proposed")$ is #text(fill: julia-blue)[*higher*]
      than the probability of the current state parameters
      $P(bold(θ)_"current")$, we change with 100% probability.

    - when the probability of the random walk proposed parameters
      $P(bold(θ)_"proposed")$ is #text(fill: julia-red)[lower]
      than the probability of the current state parameters
      $P(bold(θ)_"current")$, we change with probability equal to the proportion of
      this probability difference.
  ]
]

#slide(title: [Metropolis Algorithm])[
  #algo(line-numbers: false)[
    Define an initial set $bold(θ)^0 ∈ RR^p$ that $P(bold(θ)^0 | bold(y)) > 0$ \
    for $t = 1, 2, dots$ #i \
    Sample a proposal of $bold(θ)^*$ from a proposal distribution in time
    $t$, $J_t (bold(θ)^* | bold(θ)^(t - 1))$ \
    As an acceptance/rejection rule, compute the proportion of the probabilities: \

    $
      r = (P(bold(θ)^* | bold(y))) / (P(bold(θ)^(t - 1) | bold(y)))
    $

    Assign:

    $
      bold(θ)^t =
      cases(bold(θ)^* "with probability" min(r, 1), bold(θ)^(t - 1) "otherwise")
    $
  ]
]

#slide(title: [Visual Intuition -- Metropolis])[
  #align(center)[
    #import draw: *
    #canvas(
      length: 0.9cm,
      {
        set-style(stroke: (thickness: 2pt))
        plot.plot(
          size: (16, 9),
          x-label: none,
          y-label: "PDF",
          x-tick-step: 1,
          y-tick-step: 0.1,
          y-max: 0.55,
          {
            plot.add(
              domain: (-4, 4),
              samples: 200,
              style: (stroke: (paint: julia-purple, thickness: 2pt)),
              x => gaussian(x, 0, 1),
            )
          },
        )
        // mark: (end: ">", fill: black),
        content((4, 1.5), text(size: 24pt, fill: julia-blue)[🚶])
        content((8, 7), text(size: 24pt, fill: julia-blue)[🚶])
        content((12, 1.5), text(size: 24pt, fill: julia-blue)[🚶])
        {
          set-style(mark: (end: ">", fill: black))
          bezier-through((4, 2), (6, 8), (7.5, 7))
          bezier-through((8.5, 7), (10, 8), (12, 2))
        }
        content((3, 7), [$P = 1$])
        content((13, 7), [$P ≈ 1 / 4$])
      },
    )
  ]
]

#slide(title: [
  Metropolis-Hastings Algorithm
])[
  #side-by-side(columns: (4fr, 1fr))[
    In the 1970s emerged a generalization of the Metropolis algorithm, which *does
    not need that the proposal distributions be symmetric*:

    #v(2em)

    $
      J_t (bold(θ)^* | bold(θ)^(t - 1)) ≠ J_t (bold(θ)^(t - 1) | bold(θ)^*)
    $

    #v(2em)

    The generalization was proposed by #link("https://en.wikipedia.org/wiki/W._K._Hastings")[Wilfred Keith Hastings]
    @hastingsMonteCarloSampling1970 and is called *Metropolis-Hastings algorithm*.
  ][
    #image("images/persons/hastings.jpg")
  ]
]

#slide(title: [Metropolis-Hastings Algorithm])[
  #algo(line-numbers: false)[
    Define an initial set $bold(θ)^0 ∈ RR^p$ that $P(bold(θ)^0 | bold(y)) > 0$ \
    for $t = 1, 2, dots$ #i \
    Sample a proposal of $bold(θ)^*$ from a proposal distribution in time
    $t$, $J_t (bold(θ)^* | bold(θ)^(t - 1))$ \
    As an acceptance/rejection rule, compute the proportion of the probabilities: \

    $
      r = ((P(bold(θ)^* | bold(y))) / (J_t (
        bold(θ)^* | bold(θ)^(t - 1)
      ))) / ((P(bold(θ)^(t - 1) | bold(y))) / (J_t (
        bold(θ)^(t - 1) | bold(θ)^*
      )))
    $

    Assign:

    $
      bold(θ)^t =
      cases(bold(θ)^* "with probability" min(r, 1), bold(θ)^(t - 1) "otherwise")
    $
  ]
]

#slide(title: [Metropolis-Hastings Animation])[
  #v(4em)

  #align(center)[
    See Metropolis-Hastings in action at #link(
  "https://chi-feng.github.io/mcmc-demo/app.html?algorithm=RandomWalkMH&target=banana",
)[
`chi-feng/mcmc-demo`
].
  ]
]

#slide(title: [Limitations of the Metropolis Algorithms])[
  The limitations of the Metropolis-Hastings algorithms are mainly
  *computational*:

  - with the proposals randomly generated, it can take a large number of iterations
    for the Markov chain to enter higher posterior densities spaces.

  - even highly-efficient MH algorithms sometimes accept less than 25% of the
    proposals @robertsWeakConvergenceOptimal1997 @beskosOptimalTuningHybrid2013.

  - in lower-dimensional contexts, higher computational power can compensate the low
    efficiency up to a point. But in higher-dimensional (and higher-complexity)
    modeling situations, higher computational power alone are rarely sufficient to
    overcome the low efficiency.
]

#slide(title: [Gibbs Algorithm])[
  #side-by-side(columns: (4fr, 1fr))[
    To circumvent Metropolis' low acceptance rate, the Gibbs algorithm was
    conceived. Gibbs *do not have an acceptance/rejection rule* for the Markov chain
    state change: *all proposals are accepted!*

    Gibbs algorithm was originally conceived by the physicist Josiah Willard Gibbs
    while referencing an analogy between a sampling algorithm and statistical
    physics (a physics field that originates from statistical mechanics).

    The algorithm was described by the Geman brothers in 1984
    @gemanStochasticRelaxationGibbs1984, about 8 decades after Gibbs death.
  ][
    #image("images/persons/josiah_gibbs.jpg")
  ]
]

#slide(title: [Gibbs Algorithm])[
  The Gibbs algorithm is very useful in multidimensional sample spaces. It is also
  known as *alternating conditional sampling*, because we always sample a
  parameter *conditioned* on the probability of the other model's parameters.

  The Gibbs algorithm can be seen as a *special case* of the Metropolis-Hastings
  algorithm, because all proposals are accepted
  @gelmanIterativeNonIterativeSimulation1992.

  The essence of the Gibbs algorithm is the sampling of parameters conditioned in
  other parameters:

  $
    P(θ_1 | θ_2, dots, θ_p)
  $
]

#slide(title: [Gibbs Algorithm])[
  #algo(line-numbers: false)[
    Define an initial set $bold(θ)^0 ∈ RR^p$ that $P(bold(θ)^0 | bold(y)) > 0$ \
    for $t = 1, 2, dots$ #i \
    Assign:

    $
      bold(θ)^t =
      cases(
        bold(θ)^t_1 tilde P(θ_1 | θ^0_2, dots, θ^0_p), bold(θ)^t_2 tilde P(θ_2 | θ^(t - 1)_1, dots, θ^(t - 1)_p), dots.v, bold(θ)^t_p tilde P(θ_p | θ^(t - 1)_1, dots, θ^(t - 1)_(p - 1)),

      )
    $
  ]
]

#slide(title: [Gibbs Animation])[
  #v(4em)

  #align(center)[
    See Gibbs in action at #link(
  "https://chi-feng.github.io/mcmc-demo/app.html?algorithm=GibbsSampling&target=banana",
)[
`chi-feng/mcmc-demo`
].
  ]
]

#slide(title: [Limitations of the Gibbs Algorithm])[
  The main limitation of Gibbs algorithm is with relation to *alternating
  conditional sampling*:

  - In Metropolis, the parameters' random proposals are sampled *unconditionally*,
    *jointly*, and *simultaneous*. The Markov chain state changes are executed in a
    *multidimensional* manner. This makes *multidimensional diagonal movements*.

  - In the case of the Gibbs algorithm, this movement only happens one parameter at
    a time, because we sample parameters in a *conditional* and *sequential* manner
    with respect to other parameters. This makes *unidimensional horizontal/vertical
    movements*, and never multidimensional diagonal movements.
]

#slide(title: [Hamiltonian Monte Carlo (HMC)])[
  #side-by-side(columns: (4fr, 1fr))[
    Metropolis' low acceptance rate and Gibbs' low performance in multidimensional
    problems (where the posterior geometry is highly complex) made a new class of
    MCMC algorithms to emerge.

    These are called Hamiltonian Monte Carlo (HMC), because they incorporate
    Hamiltonian dynamics (in honor of Irish physicist
    #link(
      "https://en.wikipedia.org/wiki/William_Rowan_Hamilton",
    )[William Rowan Hamilton]).
  ][
    #image("images/persons/hamilton.png")
  ]
]

#slide(title: [HMC Algorithm])[
  #text(size: 18pt)[
    HMC algorithm is an adaptation of the MH algorithm, and employs a guidance
    scheme to the generation of new proposals. It boosts the acceptance rate, and,
    consequently, has a better efficiency.

    More specifically, HMC uses the gradient of the posterior's log density to guide
    the Markov chain to higher density regions of the sample space, where most of
    the samples are sampled:

    $
      (dif log P(bold(θ) | bold(y))) / (dif θ)
    $

    As a result, a Markov chain that uses a well-adjusted HMC algorithm will accept
    proposals with a much higher rate than if using the MH algorithm
    @robertsWeakConvergenceOptimal1997 @beskosOptimalTuningHybrid2013.
  ]
]

#slide(title: [History of HMC Algorithm])[
  HMC was originally described in the physics literature
  #footnote[where is called "Hybrid" Monte Carlo (HMC)]
  @duaneHybridMonteCarlo1987.

  #v(2em)

  Soon after, HMC was applied to statistical problems by
  #cite(<nealImprovedAcceptanceProcedure1994>, form: "prose")
  who named it as Hamiltonian Monte Carlo (HMC).

  #v(2em)

  For a much more detailed and in-depth discussion (not our focus here) of HMC, I
  recommend #cite(<neal2011mcmc>, form: "prose")
  and #cite(<betancourtConceptualIntroductionHamiltonian2017>, form: "prose").
]

#slide(title: [What Changes With HMC?])[
  HMC uses Hamiltonian dynamics applied to particles efficiently exploring a
  posterior probability geometry, while also being robust to complex posterior's
  geometries.

  #v(2em)

  Besides that, HMC is much more efficiently than Metropolis and does _not_ suffer
  Gibbs' parameters correlation issues
]

#slide(title: [Intuition Behind the HMC Algorithm])[
  #text(size: 18pt)[
    For every parameter $θ_j$, HMC adds a momentum variable $φ_j$. The posterior
    density $P(bold(θ) | y)$ is incremented by an independent momenta distribution $P(bold(φ))$,
    hence defining the following joint probability:

    $
      P(bold(θ), bold(φ) | y) = P(bold(φ)) dot P(bold(θ) | y)
    $

    HMC uses a proposal distribution that changes depending on the Markov chain
    current state. HMC finds the direction where the posterior density increases,
    the *gradient*, and alters the proposal distribution towards the gradient
    direction.

    The probability of the Markov chain to change its state in HMC is defined as:

    $
      P_"change" = min(
        (P(bold(θ)_"proposed") dot P(bold(φ)_"proposed")) / (P(bold(θ)_"current") dot P(bold(φ)_"current")), 1,

      )
    $
  ]
]

#slide(title: [Momenta Distribution -- $P(bold(φ))$])[
  Generally we give $bold(φ)$ a multivariate normal distribution with mean $0$ and
  covariance $bold(M)$, a "mass matrix".

  #v(2em)

  To keep things computationally simple, we used a *diagonal* mass matrix $bold(M)$.
  This makes that the diagonal elements (components)
  $bold(φ)$ are independent, each one having a normal distribution:

  $ φ_j tilde "Normal"(0, M_(j j)) $
]

#slide(title: [HMC Algorithm])[
  #text(size: 13pt)[
    #algo(line-numbers: false)[
      Define an initial set $bold(θ)^0 ∈ RR^p$ that $P(bold(θ)^0 | bold(y)) > 0$ \
      Sample $bold(φ)$ from a $"Multivariate Normal"(bold(0),bold(M))$ \
      Simultaneously sample $bold(θ)^*$ and $bold(φ)$ with $L$ steps and step-size $ε$ \
      Define the current value of $bold(θ)$ as the proposed value $bold(θ)^*$:
      $bold(θ)^* <- bold(θ)$ \
      for $1, 2, dots, L$ #i \
      Use the $log$ of the posterior's gradient $bold(θ)^*$ to produce a half-step of $bold(φ)$:
      $bold(φ) <- bold(φ) + 1 / 2 ε (dif log P(
          bold(θ)^* | bold(y)
        )) / (dif θ)$ \
      Use $bold(φ)$ to update $bold(θ)^*$:
      $bold(θ)^* <- bold(θ)^* + ε bold(M)^(-1) bold(φ)$ \
      Use again $bold(θ)^*$ $log$ gradient to produce a half-step of $bold(φ)$:
      $bold(φ) <- bold(φ) + 1 / 2 ε (dif log P(
          bold(θ)^* | bold(y)
        )) / (dif θ)$ #d \
      As an acceptance/rejection rule, compute: \
      $
        r = (P (bold(θ)^* | bold(y)) P (bold(φ)^*)) / (P (
          bold(θ)^(t - 1) | bold(y)
        ) P(bold(φ)^(t - 1)))
      $
      Assign:

      $
        bold(θ)^t =
        cases(bold(θ)^* "with probability" min(r, 1), bold(θ)^(t - 1) "otherwise")
      $
    ]
  ]
]

#slide(title: [HMC Animation])[
  #v(4em)

  #align(center)[
    See HMC in action at #link(
  "https://chi-feng.github.io/mcmc-demo/app.html?algorithm=HamiltonianHMC&target=banana",
)[
`chi-feng/mcmc-demo`
].
  ]
]

#slide(title: [An Interlude into Numerical Integration])[
  In the field of ordinary differential equations (ODE), we have the idea of "discretizing"
  a system of ODEs by applying a small step-size $ε$ #footnote[sometimes also called $h$].
  Such approaches are called "numerical integrators" and are composed by an ample
  class of tools.

  #v(2em)

  The most famous and simple of these numerical integrators is the Euler method,
  where we use a step-size $ε$ to compute a numerical solution of system in a
  future time $t$ from specific initial conditions.
]

#slide(title: [An Interlude into Numerical Integration])[
  #side-by-side(columns: (3fr, 2fr))[
    The problem is that Euler method, when applied to Hamiltonian dynamics, *does
    not preserve volume*.

    #v(1em)

    One of the fundamental properties of Hamiltonian dynamics if *volume
    preservation*.

    #v(1em)

    This makes the Euler method a bad choice as a HMC's numerical integrator.
  ][

    #figure(
      image("images/mcmc/euler_0_3.jpg", height: 55%),
      caption: [HMC numerically integrated using Euler with $ε = 0.3$ and $L = 20$],
    )
  ]
]

#slide(title: [
  An Interlude into Numerical Integration
  #footnote[
    An excellent textbook for numerical and symplectic integrator is
    #cite(<irseles2008numericalanalysis>, form: "prose").
  ]
])[
  #side-by-side(columns: (3fr, 2fr))[
    To preserve volume, we need a numerical *symplectic integrator*.

    #v(1em)

    Symplectic integrators are at most second-order and demands a constant step-size $ε$.

    #v(1em)

    One of the main numerical symplectic integrator used in Hamiltonian dynamics is
    the *Störmer–Verlet integrator*, also known as *leapfrog integrator*.
  ][

    #figure(
      image("images/mcmc/leapfrog_0_3.jpg", height: 55%),
      caption: [HMC numerically integrated using leapfrog with $ε = 0.3$ and $L = 20$],
    )
  ]
]

#slide(title: [Limitations of the HMC Algorithm])[
  #side-by-side(columns: (3fr, 2fr))[
    As you can see, HMC algorithm is highly sensible to the choice of leapfrog steps $L$ and
    step-size $ε$,

    #v(1em)

    More specific, the leapfrog integrator allows only a constant $ε$.

    #v(1em)

    There is a delicate balance between $L$ and $ε$, that are hyperparameters and
    need to be carefully adjusted.
  ][

    #figure(
      image("images/mcmc/leapfrog_1_2.jpg", height: 55%),
      caption: [HMC numerically integrated using leapfrog with $ε = 1.2$ and $L = 20$],
    )
  ]
]

#slide(title: [No-U-Turn-Sampler (NUTS)])[
  In HMC, we can adjust $ε$ during the algorithm runtime. But, for $L$, we need to
  to "dry run" the HMC sampler to find a good candidate value for $L$.

  #v(2em)

  Here is where the idea for No-U-Turn-Sampler (NUTS) @hoffman2014no enters: you
  don't need to *adjust anything*, just "press the button".

  #v(2em)

  It will automatically find $ε$ and $L$.
]

#slide(title: [No-U-Turn-Sampler (NUTS)])[
  More specifically, we need a criterion that informs that we performed enough
  Hamiltonian dynamics simulation.

  In other words, to simulate past beyond would not increase the distance between
  the proposal $bold(θ)^*$ and the current value $bold(θ)$.

  NUTS uses a criterion based on the dot product between the current momenta
  vector
  $bold(φ)$ and the difference between the proposal vector $bold(θ)^*$
  and the current vector $bold(θ)$, which turns into the derivative with respect
  to time $t$ of half of the distance squared between
  $bold(θ)$ e $bold(θ)^*$:

  $
    (bold(θ)^* - bold(θ)) dot bold(φ)
    = (bold(θ)^* - bold(θ)) dot (dif) / (dif t) (bold(θ)^* - bold(θ))
    = (dif) / (dif t) ((bold(θ)^* - bold(θ)) dot (bold(θ)^* - bold(θ))) / 2
  $
]

#slide(title: [No-U-Turn-Sampler (NUTS)])[
  #v(2em)

  This suggests an algorithms that does not allow proposals be guided infinitely
  until the distance between the proposal $bold(θ)^*$ and the current
  $bold(θ)$ is less than zero.

  #v(2em)

  This means that such algorithm will *not allow u-turns*.
]

#slide(title: [No-U-Turn-Sampler (NUTS)])[
  #text(size: 18pt)[
    NUTS uses the leapfrog integrator to create a binary tree where each leaf node
    is a proposal of the momenta vector $bold(φ)$ tracing both a forward ($t + 1$)
    as well as a backward ($t - 1$) path in a determined fictitious time $t$.

    The growing of the leaf nodes are *interrupted* when an u-turn is detected, both
    forward or backward.

    #figure(
      image("images/mcmc/nuts.jpg", height: 40%),
      caption: [NUTS growing leaf nodes forward],
    )
  ]
]

#slide(title: [No-U-Turn-Sampler (NUTS)])[
  #v(2em)

  NUTS also uses a procedure called Dual Averaging @nesterov2009primal to
  simultaneously adjust $ε$ and $L$
  by considering the product $ε dot L$.

  #v(2em)

  Such adjustment is done during the warmup phase and the defined values of
  $ε$ and $L$ are kept fixed during the sampling phase.
]

#slide(title: [NUTS Algorithm])[
  #text(size: 7pt)[
    #algo(line-numbers: false)[
      Define an initial set $bold(θ)^0 ∈ RR^p$ that $P(bold(θ)^0 | bold(y)) > 0$ \
      #text(fill: julia-blue)[Instantiate an empty binary tree with $2^L$ leaf nodes] \
      Sample $bold(φ)$ from a $"Multivariate Normal"(bold(0),bold(M))$ \
      Simultaneously sample $bold(θ)^*$ and $bold(φ)$ with $L$ steps and step-size $ε$ \
      Define the current value of $bold(θ)$ as the proposed value $bold(θ)^*$:
      $bold(θ)^* <- bold(θ)$ \
      for $1, 2, dots, L$ #i \
      #text(fill: julia-blue)[Choose a direction $v tilde "Uniform"({-1, 1})$] \
      Use the $log$ of the posterior's gradient $bold(θ)^*$ to produce a half-step of $bold(φ)$:
      $bold(φ) <- bold(φ) + 1 / 2 ε (dif log P(
          bold(θ)^* | bold(y)
        )) / (dif θ)$ \
      Use $bold(φ)$ to update $bold(θ)^*$:
      $bold(θ)^* <- bold(θ)^* + ε bold(M)^(-1) bold(φ)$ \
      Use again $bold(θ)^*$ $log$ gradient to produce a half-step of $bold(φ)$:
      $bold(φ) <- bold(φ) + 1 / 2 ε (dif log P(
          bold(θ)^* | bold(y)
        )) / (dif θ)$ #d \
      #text(fill: julia-blue)[Define the node $L_t^v$ as the proposal $bold(θ)$] \
      #text(fill: julia-blue)[
        if the difference between proposal vector $bold(θ)^*$
        and current vector $bold(θ)$ in the direction $v$ is lower than zero: $v (dif) / (dif t) ((bold(θ)^* - bold(θ)^*) dot (bold(θ)^* - bold(θ)^*)) / 2 < 0$
        or $L$ steps have been reached
      ] #i \
      #text(fill: julia-red)[
        Stop sampling $bold(θ)^*$ in the direction $v$ and continue sampling only in the
        direction $-v$
      ] #i \
      #text(fill: julia-blue)[
        The difference between proposal vector $bold(θ)^*$
        and current vector $bold(θ)$ in the direction $-v$ is lower than zero: $-v (dif) / (dif t) ((bold(θ)^* - bold(θ)^*) dot (bold(θ)^* - bold(θ)^*)) / 2 < 0$
        or $L$ steps have been reached
      ] #i \
      #text(fill: julia-red)[Stop sampling $bold(θ)^*$] #d #d #d\
      #text(fill: julia-blue)[Choose a random node from the binary tree as the proposal] \
      As an acceptance/rejection rule, compute: \
      $
        r = (P (bold(θ)^* | bold(y)) P (bold(φ)^*)) / (P (
          bold(θ)^(t - 1) | bold(y)
        ) P(bold(φ)^(t - 1)))
      $
      Assign:

      $
        bold(θ)^t =
        cases(bold(θ)^* "with probability" min(r, 1), bold(θ)^(t - 1) "otherwise")
      $
    ]
  ]
]

#slide(title: [NUTS Animation])[
  #v(4em)

  #align(center)[
    See NUTS in action at #link(
  "https://chi-feng.github.io/mcmc-demo/app.html?algorithm=EfficientNUTS&target=banana",
)[
`chi-feng/mcmc-demo`
].
  ]
]

#slide(title: [Limitations of HMC and NUTS Algorithms -- #cite(<nealSliceSampling2003>, form: "prose")'s
  Funnel])[
  The famous "Devil's Funnel"
  #footnote[very common em hierarchical models.].

  Here we see that HMC and NUTS, during the exploration of the posterior, have to
  change often $L$ and $ε$ values
  #footnote[
    remember that $L$ and $ε$ are defined in the warmup phase and kept fixed during
    sampling.
  ].

  #align(center)[#image("images/funnel/funnel.png", height: 40%)]
]

#slide(title: [#cite(<nealSliceSampling2003>, form: "prose")'s Funnel and Non-Centered
  Parameterization (NCP)])[
  #text(size: 18pt)[
    The funnel occurs when we have a variable that its variance depends on another
    variable variance in an exponential scale. A canonical example of a centered
    parameterization (CP) is:

    $
      P(y,x) = "Normal"(y | 0 ,3) dot
      "Normal"(x | 0, e^(y / 2))
    $

    This occurs often in hierarchical models, in the relationship between
    group-level priors and population-level hyperpriors. Hence, we reparameterize in
    a non-centered way, changing the posterior geometry to make life easier for our
    MCMC sampler:

    $
      P(tilde(y),tilde(x)) &= "Normal"(tilde(y) | 0, 1) dot
      "Normal"(tilde(x) | 0, 1) \
      y &= tilde(y) dot 3 + 0 \
      x &= tilde(x) dot e^(y / 2) + 0
    $
  ]
]

#slide(title: [Non-Centered Parameterization -- Varying-Intercept Model])[
  This example is for linear regression:

  $
    bold(y) &tilde "Normal"(α_j + bold(X) dot bold(β), σ) \
    α_j &= z_j dot τ + α \
    z_j &tilde "Normal"(0, 1) \
    α &tilde "Normal"(μ_α, σ_α) \
    bold(β) &tilde "Normal"(μ_bold(β), σ_bold(β)) \
    τ &tilde "Cauchy"^+(0, ψ_α) \
    σ &tilde "Exponential"(λ_σ)
  $
]

#slide(title: [Non-Centered Parameterization -- Varying-(Intercept-)Slope Model])[
  This example is for linear regression:

  $
    bold(y) &tilde "Normal"(bold(X) bold(β)_j, σ) \
    bold(β)_j &= bold(γ)_j dot bold(Σ) dot bold(γ)_j \
    bold(γ)_j &tilde "Multivariate Normal"(bold(0), bold(I))
    "for" j ∈ {1, dots, J} \
    bold(Σ) &tilde "LKJ"(η) \
    σ &tilde "Exponential"(λ_σ)
  $

  Each coefficient vector $bold(β)_j$ represents the model columns $bold(X)$ coefficients
  for every group $j ∈ J$. Also the first column of $bold(X)$ could be a column
  filled with $1$s (intercept).
]

#slide(title: [Stan and NUTS])[
  Stan was the first MCMC sampler to implement NUTS.

  Besides that, it has an automatic optimized adjustment routine for values of $L$ and $ε$ during
  warmup.

  It has the following default NUTS hyperparameters' values
  #footnote[
    for more information about how to change those values, see #link(
      "https://mc-stan.org/docs/reference-manual/hmc-algorithm-parameters.html",
    )[
      Section 15.2 of the Stan Reference Manual
    ].
  ]:

  #v(2em)

  - *target acceptance rate of Metropolis proposals*: 0.8

  - *max tree depth* (in powers of $2$): 10 (which means $2^(10) = 1024$)
]

#slide(title: [Turing and NUTS])[
  Turing also implements NUTS which lives, along with other MCMC samplers, inside
  the package AdvancedHMC.jl.

  It also has an automatic optimized adjustment routine for values of $L$ and $ε$ during
  warmup.

  It has the same default NUTS hyperparameters' values
  #footnote[
    for more information about how to change those values, see #link("https://turinglang.org/dev/docs/library")[
      Turing Documentation
    ].
  ]:
  #v(2em)

  - *target acceptance rate of Metropolis proposals*: 0.65

  - *max tree depth* (in powers of $2$): 10 (which means $2^(10) = 1024$)
]

#slide(title: [Markov Chain Convergence])[
  MCMC has an interesting property that it will *asymptotically converge to the
  target distribution*
  #footnote[
    this property is not present on neural networks.
  ].

  That means, if we have all the time in the world, it is guaranteed, irrelevant
  of the target distribution posterior geometry, *MCMC will give you the right
  answer*.

  However, we don't have all the time in the world Different MCMC algorithms, like
  HMC and NUTS, can reduce the sampling (and warmup) time necessary for
  convergence to the target distribution.
]

#slide(title: [Convergence Metrics])[
  #v(2em)

  We have some options on how to measure if the Markov chains converged to the
  target distribution, i.e. if they are "reliable":

  #v(2em)

  - *Effective Sample Size* (ESS): an approximation of the "number of independent
    samples" generated by a Markov chain.

  #v(2em)

  - $hat(R)$ (*Rhat*): potential scale reduction factor, a metric to measure if the
    Markov chain have mixed, and, potentially, converged.
]

#slide(title: [Convergence Metrics -- Effective Sample Size @gelman2013bayesian])[
  $ hat(n)_"eff" = (m n) / (1 + sum_(t = 1)^T hat(ρ)_t) $

  where:

  - $m$: number of Markov chains.

  - $n$: total samples per Markov chain (discarding warmup).

  - $hat(ρ)_t$: an autocorrelation estimate.
]

#slide(title: [Convergence Metrics -- Rhat @gelman2013bayesian])[
  #text(size: 18pt)[
    $ hat(R) = sqrt((hat("var")^+ (ψ | y)) / W) $

    where $hat("var")^+ (ψ | y)$ is the Markov chains' sample variance for a certain
    parameter $ψ$.

    We calculate it by using a weighted sum of the within-chain $W$
    and between-chain $B$ variances:
    $ hat("var")^+ (ψ | y) = (n - 1) / n W + 1 / n B $

    Intuitively, the value is $1.0$ if all chains are totally convergent.

    As a heuristic, if $hat(R) > 1.1$, you need to worry because probably the chains
    have not converged adequate.
  ]
]

#slide(title: [Traceplot -- Convergent Markov Chains])[
  #align(center)[
    #figure(
      image("images/funnel/good_chains_traceplot.svg", height: 80%),
      caption: [A convergent Markov chains traceplot],
    )
  ]
]

#slide(title: [Traceplot -- Divergent Markov Chains])[
  #align(center)[
    #figure(
      image("images/funnel/bad_chains_traceplot.svg", height: 80%),
      caption: [A divergent Markov chains traceplot],
    )
  ]
]

#slide(title: [
  Stan's Warning Messages
  #footnote[
    also see #link(
      "https://mc-stan.org/misc/warnings.html",
    )[Stan's #text(fill: julia-red)[warnings] guide].
  ]
])[
  #fit-to-height(1fr)[
    ```shell
    Warning messages:
    1: There were 275 divergent transitions after warmup. See
    http://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
    to find out why this is a problem and how to eliminate them.
    2: Examine the pairs() plot to diagnose sampling problems

    3: The largest R-hat is 1.12, indicating chains have not mixed.
    Running the chains for more iterations may help. See
    http://mc-stan.org/misc/warnings.html#r-hat
    4: Bulk Effective Samples Size (ESS) is too low, indicating posterior
    means and medians may be unreliable.
    Running the chains for more iterations may help. See
    http://mc-stan.org/misc/warnings.html#bulk-ess
    5: Tail Effective Samples Size (ESS) is too low, indicating posterior
    variances and tail quantiles may be unreliable.
    Running the chains for more iterations may help. See
    http://mc-stan.org/misc/warnings.html#tail-ess
    ```
  ]
]

#slide(title: [
  Turing's Warning Messages
])[
  #fit-to-height(1fr)[
    *Turing does not give warning messages!*
    But you can check divergent transitions with `summarize(chn;
sections=[:internals])`:

    ```shell
    Summary Statistics
          parameters     mean      std  naive_se     mcse      ess     rhat  ess_per_sec
              Symbol  Float64  Float64   Float64  Float64  Float64  Float64  Float64

                  lp  -3.9649   1.7887   0.0200   0.1062  179.1235  1.0224   6.4133
             n_steps   9.1275  11.1065   0.1242   0.7899   38.3507  1.3012   1.3731
     acceptance_rate   0.5944   0.4219   0.0047   0.0322   40.5016  1.2173   1.4501
          tree_depth   2.2444   1.3428   0.0150   0.1049   32.8514  1.3544   1.1762
     numerical_error   0.1975   0.3981   0.0045   0.0273   59.8853  1.1117   2.1441
    ```
  ]
]

#slide(title: [What To Do If the Markov Chains Do Not Converge?])[
  *First*: before making any fine adjustments in the number of Markov chains or
  the number of iterations per chain, etc.

  #v(2em)

  Acknowledge that both Stan's and Turing's NUTS sampler is *very efficient and
  effective in exploring the most crazy and diverse target
  posterior densities*.

  #v(2em)

  And the standard settings, *2,000 iterations and 4 chains*, works perfectly for
  99% of the time.
]

#slide(title: [What To Do If the Markov Chains Do Not Converge?])[
  #v(4em)

  #quote(
    block: true,
    attribution: [#cite(<gelmanFolkTheoremStatistical2008>, form: "prose")],
  )[
    When you have computational problems, often there’s a problem with your model.
  ]
]

#slide(title: [What To Do If the Markov Chains Do Not Converge?])[
  If you experiencing convergence issues, *and you've discarded that something is
  wrong with you model*, here is a few steps to try
  #footnote[
    besides that, maybe should be worth to do a QR decomposition in the data matrix $bold(X)$,
    thus having an orthogonal basis (non-correlated) for the sampler to explore.
    This makes the target distribution's geometry much more friendlier, in the
    topological/geometrical sense, for the MCMC sampler explore. Check the backup
    slides.
  ].

  Here listed in increasing complexity:

  1. *Increase the number of iterations and chains*: try first increasing the number
    of iterations, then try increasing the number of chains. (remember the default
    is 2,000 iterations and 4 chains).
]

#slide(title: [What To Do If the Markov Chains Do Not Converge?])[
  2. *Change the HMC's warmup adaptation routine*: make the HMC sampler to be more
    conservative in the proposals. This can be changed by increasing the
    hyperparameter *target acceptance rate of Metropolis proposals*
    #footnote[
      Stan's default is 0.8 and Turing's default is 0.65.
    ]. The maximum value is $1.0$ (not recommended). Then, any value between $0.8$ and $1.0$ is
    more conservative.

  3. *Model reparameterization*: there are two approaches. Centered parameterization
    (CP) and non-centered parameterization (NCP).
]

#slide(title: [What To Do If the Markov Chains Do Not Converge?])[
  4. *Collect more data*: sometimes the model is too complex and we need a higher
    sample size for stable estimates.

  5. *Rethink the model*: convergence issues with an adequate sample size might be
    due to incompatibility between priors and likelihood function(s). In this case
    you need to rethink the whole data generating process underlying the model, in
    which the model assumptions stems from.
]
