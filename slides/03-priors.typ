#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *

#new-section-slide("Priors")

#slide(
  title: "Recommended References",
)[
  - #cite(<gelman2013bayesian>, form: "prose"):

    - Chapter 2: Single-parameter models
    - Chapter 3: Introduction to multiparameter models

  - #cite(<mcelreath2020statistical>, form: "prose") - Chapter 4: Geocentric Models

  - #cite(<gelman2020regression>, form: "prose"):
    - Chapter 9, Section 9.3: Prior information and Bayesian synthesis
    - Chapter 9, Section 9.5: Uniform, weakly informative, and informative priors in
      regression

  - #cite(<vandeschootBayesianStatisticsModelling2021>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/priors.jpg")]
]

#slide(
  title: "Prior Probability",
)[
  Bayesian statistics is characterized by the use of prior information as the
  prior probability $P(θ)$, often just prior:
  $ underbrace(P(θ | y), "Posterior") = (overbrace(P(y | θ), "Likelihood") dot overbrace(P(θ), "Prior")) / underbrace(P(y), "Normalizing Constant") $
]

#slide(
  title: "The Subjectivity of the Prior",
)[
  - Many critics to Bayesian statistics are due the subjectivity in eliciting priors
    probability on certain hypothesis or model parameter's values.
  - Subjectivity is something unwanted in the ideal picture of the scientist and the
    scientific method.
  - Anything that involves human action will never be free from subjectivity. We
    have subjectivity in everything and science is #text(fill: julia-red)[no] exception.
  - The creative and deductive process of theory and hypotheses formulations is
    *not* objective.
  - Frequentist statistics, which bans the use of prior probabilities is also
    subjective, since there is *A LOT* of subjectivity in choosing which model and
    likelihood function @jaynesProbabilityTheoryLogic2003
    @vandeschootBayesianStatisticsModelling2021.
]

#slide(
  title: "How to Incorporate Subjectivity",
)[
  - Bayesian statistics *embraces* subjectivity while frequentist statistics *bans*
    it.

  - For Bayesian statistics, *subjectivity guides our inferences* and leads to more
    robust and reliable models that can assist in decision making.

  - Whereas, for frequentist statistics, *subjectivity is a taboo* and all
    inferences should be objective, even if it resorts to *hiding and omitting model
    assumptions*.

  - Bayesian statistics also has assumptions and subjectivity, but these are
    *declared and formalized*
]

#slide(
  title: "Types of Priors",
)[
  In general, we can have 3 types of priors in a Bayesian approach
  @gelman2013bayesian @mcelreath2020statistical
  @vandeschootBayesianStatisticsModelling2021:
  - *uniform (flat)*: not recommended.

  - *weakly informative*: small amounts of real-world information along with common
    sense and low specific domain knowledge added.

  - *informative*: introduction of medium to high domain knowledge.
]

#slide(
  title: "Uniform Prior (Flat)",
)[
  Starts from the premise that "everything is possible". There is no limits in the
  degree of beliefs that the distribution of certain values must be or any sort of
  restrictions.

  Flat and super-vague priors are not usually recommended and some thought should
  included to have at least weakly informative priors.

  Formally, an uniform prior is an uniform distribution over all the possible
  support of the possible values:

  - *model parameters*: ${θ in RR : -oo < θ < oo}$

  - *model error or residuals*: ${σ in RR^+ : 0 < θ < oo}$
]

#slide(
  title: "Weakly Uninformative Prior",
)[
  Here we start to have "educated" guess about our parameter values. Hence, we
  don't start from the premise that "anything is possible".

  #v(1em)

  I recommend always to transform the priors of the problem at hand into something
  centered in $0$ with standard deviation of $1$ #footnote[
    this is called standardization, transforming all variables into $μ=0$ and $σ=1$.
  ]:

  - $θ tilde "Normal"(0, 1)$ (Andrew Gelman's preferred choice
    #footnote[see more about prior choices in the
      #link(
        "https://github.com/stan-dev/stan/wiki/Prior-Choice-Recommendations",
      )[Stan's GitHub wiki].] <fn-priors-1>)

  - $θ tilde "Student"(ν=3, 0, 1)$ (Aki Vehtari's preferred choice #footnote(<fn-priors-1>))
]

#slide(
  title: "An Example of a Robust Prior",
)[
  #text(
    size: 18pt,
  )[
    A nice example comes from a Ben Goodrich's lecture #footnote[
      https://youtu.be/p6cyRBWahRA, in case you want to see the full video, the
      section about priors related to the argument begins at minute 40
    ]
    (Columbia professor and member of Stan's research group).

    He discuss about one of the biggest effect sizes observed in social sciences. In
    the exit pools for the 2008 USA presidential election (Obama vs McCain), there
    was, in general, around 40% of support for Obama. If you changed the respondent
    race from non-black to black, this was associated with an increase of 60\% in
    the probability of the respondent to vote on Obama

    In logodds scales, 2.5x increase (from 40% to almost 100%) would be equivalent,
    on a Bernoulli/logistic/binomial model, to a coefficient value of $approx 0.92$ #footnote[
      $log("odds ratio") = log(2.5) = 0.9163$.
    ]. This effect size would be easily derived from a $"Normal"(0, 1)$ prior.
  ]
]

#slide(
  title: "Informative Prior",
)[
  In some contexts, it is interesting to use an informative prior. Good candidates
  are when data is scarce or expensive and prior knowledge about the phenomena is
  available.

  #v(1em)

  Some examples:

  - $"Normal"(5, 20)$

  - $"Log-Normal"(0, 5)$

  - $"Beta"(100, 9803)$ #footnote[
      this is used in COVID-19 models from the
      #link("https://codatmo.github.io")[CoDatMo Stan]
      research group.
    ]
]
