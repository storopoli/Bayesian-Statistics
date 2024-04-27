#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *
#import "@preview/cetz:0.1.2": *
#import "@preview/plotst:0.2.0": plot as pplot, axis, bar_chart, graph_plot, overlay

#new-section-slide("Statistical Distributions")

#slide(title: "Recommended References")[
  - #cite(<grimmettProbabilityRandomProcesses2020>, form: "prose"):
    - Chapter 3: Discrete random variables
    - Chapter 4: Continuous random variables

  - #cite(<dekkingModernIntroductionProbability2010>, form: "prose"):
    - Chapter 4: Discrete random variables
    - Chapter 5: Continuous random variables

  - #cite(<betancourtProbabilisticBuildingBlocks2019>, form: "prose")
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/statistical_distributions.jpg")]
]

#slide(
  title: [Probability Distributions],
)[
  Bayesian statistics uses probability distributions as the inference engine of
  the parameter and uncertainty estimates.

  #v(2em)

  Imagine that probability distributions are small "Lego" pieces. We can construct
  anything we want with these little pieces. We can make a castle, a house, a
  city; literally anything.

  The same is valid for Bayesian statistical models. We can construct models from
  the simplest ones to the most complex using probability distributions and their
  relationships.
]

#slide(
  title: [Probability Distribution Function],
)[
  A probability distribution function is a mathematical function that outputs the
  probabilities for different results of an experiment. It is a mathematical
  description of a random phenomena in terms of its sample space and the event
  probabilities (subsets of the sample space).

  $ P(X): X → RR ∈ [0, 1] $

  For discrete random variables, we define as "mass", and for continuous random
  variables, we define as "density".
]

#slide(
  title: [Mathematical Notation],
)[
  We use the notation
  $ X tilde "Dist"(θ_1, θ_2, dots) $

  where:

  - $X$: random variable

  - Dist: distribution name

  - $θ_1, θ_2, dots$: parameters that define how the distribution behaves

  Every probability distribution can be "parameterized" by specifying parameters
  that allow to control certain distribution aspects for a specific goal.
]

#slide(
  title: [Probability Distribution Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm, {
        plot.plot(
          size: (16, 9), x-label: $X$, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, y-max: 0.45, {
            plot.add(
              domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => gaussian(x, 0, 1),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Cumulative Distribution Function],
)[
  The cumulative distribution function (CDF) of a random variable
  $X$ evaluated at $x$ is the probability that $X$ will take values less or qual
  than $x$:

  $ "CDF" = P(X <= x) $
]

#slide(
  title: [Cumulative Distribution Function],
)[
  #align(
    center,
  )[
    #canvas(
      length: 0.9cm, {
        plot.plot(
          size: (16, 9), x-label: $X$, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.25, y-min: -0.01, y-max: 1.01, {
            plot.add(
              domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => normcdf(x, 0, 1),
            )
          },
        )
      },
    )
  ]
]

#slide(
  title: [Discrete Distributions],
)[
  Discrete probability distributions are distributions which the results are a
  discrete number:
  $-N, dots, -2, 1, 0, 1, 2, dots, N$ and $N ∈ ZZ$.

  #v(2em)

  In discrete probability distributions we call the probability of a distribution
  taking certain values as "mass". The probability mass function (PMF) is the
  function that specifies the probability of a random variable $X$ taking value $x$:

  #v(2em)

  $ "PMF"(x) = P(X = x) $
]

#slide(
  title: [Discrete Uniform],
)[
  The discrete uniform is a symmetric probability distribution in which a finite
  number of values are equally likely of being observable. Each one of the $n$ values
  have probability $1 / n$.

  #v(1em)

  The uniform discrete distribution has two parameters and its notation is
  $"Uniform"(a, b)$:

  - $a$ -- lower bound
  - $b$ -- upper bound

  #v(1em)

  Example: dice.
]

#slide(
  title: [Discrete Uniform],
)[
  #v(4em)

  $ "Uniform"(a, b) = f(x, a, b) = 1 / (b - a + 1) "for" a <= x <= b "and" x ∈ {a, a + 1, dots ,b - 1, b} $
]

#slide(
  title: [Discrete Uniform],
)[
  #align(
    center,
  )[
    #figure(
      {
        let data = for i in range(1, 7) {
          ((discreteuniform(1, 6), i),)
        }
        let x_axis = axis(min: 0, max: 7, step: 1, location: "bottom", title: none)
        let y_axis = axis(min: 0, max: 0.21, step: 0.1, location: "left", title: $"PMF"$)
        let pl = pplot(data: data, axes: ((x_axis, y_axis)))
        bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
      }, caption: [$a = 1, b = 6$], numbering: none,
    )
  ]
]

#slide(
  title: [Bernoulli],
)[
  Bernoulli distribution describes a binary event of the success of an experiment.
  We represent $0$ as failure and $1$ as success, hence the result of a Bernoulli
  distribution is a binary variable $Y ∈ {0, 1}$.

  Bernoulli distribution is often used to model binary discrete results where
  there is only two possible results.

  Bernoulli distribution has only a single parameter and its notation is
  $"Bernoulli"(p)$:

  - $p$ -- probability of success

  #v(1em)

  Example: If the patient survived or died or if the client purchased or not.
]

#slide(title: [Bernoulli])[
  #v(4em)

  $ "Bernoulli"(p) = f(x, p)=p^(x)(1 - p)^(1 - x) "for" x ∈ {0, 1} $
]

#slide(
  title: [Bernoulli],
)[
  #align(
    center,
  )[
    #figure(
      {
        let data = ((0.666, "0"), (0.333, "1"))
        let x_axis = axis(values: ("", "0", "1"), location: "bottom", title: none)
        let y_axis = axis(
          min: 0, max: 0.7, step: 0.2, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
        )
        let pl = pplot(data: data, axes: ((x_axis, y_axis)))
        bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
      }, caption: [$p = 1 / 3$], numbering: none,
    )
  ]
]

#slide(
  title: [Binomial],
)[
  The binomial distribution describes an event in which the number of successes in
  a sequence $n$ independent experiments, each one making a yes--no question with
  probability of success $p$. Notice that Bernoulli distribution is a special case
  of the binomial distribution where $n = 1$.

  #v(1em)

  The binomial distribution has two parameters and its notation is
  $"Binomial"(n, p)$ :

  - $n$ -- number of experiments
  - $p$ -- probability of success

  #v(1em)

  Example: number of heads in five coin throws.
]

#slide(
  title: [Binomial],
)[
  #v(4em)

  $ "Binomial"(n,p) = f(x, n, p) = binom(n, x)p^(x)(1-p)^(n-x) "for" x ∈ {0, 1, dots, n} $
]

#slide(
  title: [Binomial],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 11) {
            ((binomial(i, 10, 1 / 5), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 11).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$n = 10, p = 1 / 5$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 11) {
            ((binomial(i, 10, 1 / 2), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 11).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$n = 10, p = 1 / 2$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Poisson],
)[
  Poisson distribution describes the probability of a certain number of events
  occurring in a fixed time interval if these events occur with a constant mean
  rate which is known and independent since the time of last occurrence. Poisson
  distribution can also be used for number of events in other type of intervals,
  such as distance, area or volume.

  #v(1em)

  Poisson distribution has one parameter and its notation is $"Poisson"(λ)$:

  - $λ$ -- rate

  #v(1em)

  Example: number of e-mails that you receive daily or the number of the potholes
  you'll find in your commute.
]

#slide(title: [Poisson])[
  #v(4em)
  $ "Poisson"(λ) = f(x, λ) = (λ^x e^(-λ)) / (x!) "for" λ > 0 $
]

#slide(
  title: [Poisson],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 9) {
            ((poisson(i, 2), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 9).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$λ = 2$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 9) {
            ((poisson(i, 3), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 9).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$λ = 3$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [
    Negative Binomial #footnote[
      any phenomena that can be modeles as a Poisson distribution can be modeled also
      as negative binomial distribution @gelman2013bayesian, @gelman2020regression.
    ]
  ],
)[
  #text(
    size: 16pt,
  )[
    The binomial distribution describes an event in which the number of successes in
    a sequence $n$ independent experiments, each one making a yes--no question with
    probability of success $p$
    until $k$ successes.

    Notice that it becomes the Poisson distribution in the limit as $k → oo$. This
    makes it a robust option to replace a Poisson distribution to model phenomena
    with overdispersion (presence of greater variability in data than would be
    expected).

    The negative binomial has two parameters and its notation is
    $"Negative Binomial"(k, p)$:

    - $k$ -- number of successes
    - $p$ -- probability of success

    Example: annual occurrence of tropical cyclones.
  ]
]

#slide(
  title: [Negative Binomial],
)[
  #v(4em)
  $
    "Negative Binomial"(k, p) &= f(x, k, p) &= binom(x + k - 1, k - 1)p^(x)(1-p)^(k) \
    \
                              &             &"for" x ∈ {0, 1, dots, n}
  $
]

#slide(
  title: [Negative Binomial],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 9) {
            ((negativebinomial(i, 1, 0.5), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 9).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$k = 1, p = 1 / 2$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          let data = for i in range(0, 9) {
            ((negativebinomial(i, 5, 0.5), str(i)),)
          }
          data.insert(0, (0, ""))
          let x_ticks = range(0, 9).map(str)
          x_ticks.insert(0, "")
          let x_axis = axis(values: x_ticks, location: "bottom", title: none)
          let y_axis = axis(
            min: 0, max: 0.5, step: 0.1, value_formatter: "{:.1}", location: "left", title: $"PMF"$,
          )
          let pl = pplot(data: data, axes: ((x_axis, y_axis)))
          bar_chart(pl, (350pt, 275pt), bar_width: 70%, caption: none)
        }, caption: [$k = 5, p = 1 / 2$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Continuous Distributions],
)[
  #text(
    size: 16pt,
  )[
    Continuous probability distributions are distributions which the results are
    values in a continuous real number line:
    $(-oo, +oo) ∈ RR$.

    In continuous probability distributions we call the probability of a
    distribution taking values as "density".

    Since we are referring to real numbers we cannot obtain the probability of a
    random variable $X$ taking exactly the value $x$.

    This will always be $0$, since we cannot specify the exact value of $x$. $x$ lies
    in the real number line, hence, we need to specify the probability of $X$ taking
    values in an interval $[a,b]$.

    The probability density function (PDF) is defined as:

    $ "PDF"(x) = P(a <= X <= b) = ∫_a^b f(x) dif x $
  ]
]

#slide(
  title: [Continuous Uniform],
)[
  The continuous uniform distribution is a symmetric probability distribution in
  which an infinite number of value intervals are equally likely of being
  observable. Each one of the infinite $n$ intervals have probability $1 / n$.

  #v(1em)

  The continuous uniform distribution has two parameters and its notation is $"Uniform"(a, b)$:

  - $a$ -- lower bound
  - $b$ -- upper bound
]

#slide(
  title: [Continuous Uniform],
)[
  #v(4em)

  $ "Uniform"(a,b) = f(x, a, b) = 1 / (b-a) "for" a <= x <= b "and" x ∈ [a, b] $
]

#slide(
  title: [Continuous Uniform],
)[
  #align(
    center,
  )[
    #figure(
      {
        canvas(
          length: 0.9cm, {
            plot.plot(
              size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: 0, x-max: 6, y-max: 0.4, y-min: 0, {
                plot.add(
                  domain: (0, 6), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => continuousuniform(0, 6),
                )
              },
            )
          },
        )
      }, caption: [$a = 0, b = 6$], numbering: none,
    )
  ]
]

#slide(
  title: [Normal],
)[
  This distribution is generally used in social and natural sciences to represent
  continuous variables in which its underlying distribution are unknown.

  #v(1em)

  This assumption is due to the central limit theorem (CLT) that, under precise
  conditions, the mean of many samples (observations) of a random variable with
  finite mean and variance is itself a random variable which the underlying
  distribution converges to a normal distribution as the number of samples
  increases (as $n → oo$).

  #v(1em)

  Hence, physical quantities that we assume that are the sum of many independent
  processes (with measurement error) often have underlying distributions that are
  similar to normal distributions.
]

#slide(
  title: [Normal],
)[
  The normal distribution has two parameters and its notation is
  $"Normal"(μ, σ)$ or $"N"(μ, σ)$:

  - $μ$ -- mean of the distribution, and also median and mode
  - $σ$ -- standard deviation #footnote[sometimes is also parameterized as variance $σ^2$.],
    a dispersion measure of how observations occur in relation from the mean

  #v(1em)

  Example: height, weight etc.
]

#slide(
  title: [Normal #footnote[
      see how the normal distribution was derived from the binomial distribution in
      the backup slides.
    ]
  ],
)[
  #v(4em)

  $
    "Normal"(μ, σ) = f(x, μ, σ) = 1 / (σ sqrt(2π)) e^(- 1 / 2
    ((x-μ) / σ)^2) "for" σ > 0
  $
]

#slide(
  title: [Normal],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.65, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => gaussian(x, 0, 1),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 0, σ = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.65, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => gaussian(x, 1, 2 / 3),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 1, σ = 2 / 3$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Log-Normal],
)[
  The log-normal distribution is a continuous probability distribution of a random
  variable which its natural logarithm is distributed as a normal distribution.
  Thus, if the natural logarithm a random variable $X$, $ln(X)$, is distributed as
  a normal distribution, then $Y = ln(X)$ is normally distributed and
  $X$ is log-normally distributed.

  A log-normal random variable only takes positive real values. It is a convenient
  and useful model for measurements in exact and engineering sciences, as well as
  in biomedical, economical and other sciences. For example, energy,
  concentrations, length, financial returns and other measurements.

  A log-normal process is the statistical realization of a multiplicative product
  of many independent positive random variables.
]

#slide(
  title: [Log-Normal],
)[
  The log-normal distribution has two parameters and its notation is
  $"Log-Normal"(μ, σ^2)$:

  #v(2em)

  - $μ$ -- mean of the distribution's natural logarithm
  - $σ$ -- square root of the variance of the distribution's natural logarithm
]

#slide(
  title: [Log-Normal],
)[
  #v(4em)

  $ "Log-Normal"(μ,σ) = f(x, μ, σ) = 1 / (x σ sqrt(2π))e^((-ln(x) - μ)^2 / (2 σ^2)) "for" σ > 0 $
]

#slide(
  title: [Log-Normal],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: 0, x-max: 5, y-max: 0.7, y-min: 0, {
                  plot.add(
                    domain: (0.001, 5), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => lognormal(x, 0, 1),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 0, σ = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: 0, x-max: 5, y-max: 0.7, y-min: 0, {
                  plot.add(
                    domain: (0.001, 5), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => lognormal(x, 1, 2 / 3),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 1, σ = 2 / 3$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Exponential],
)[
  The exponential distribution is the probability distribution of the time between
  events that occurs in a continuous manner, are independent, and have constant
  mean rate of occurrence.

  #v(1em)

  The exponential distribution has one parameter and its notation is
  $"Exponential"(λ)$:

  - $λ$ -- rate

  #v(1em)

  Example: How long until the next earthquake or how long until the next bus
  arrives.
]

#slide(title: [Exponential])[
  #v(4em)

  $ "Exponential"(λ) = f(x, λ) = λ e^(-λ x) "for" λ > 0 $
]

#slide(
  title: [Exponential],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.25, x-min: 0, x-max: 5, y-max: 0.95, y-min: 0, {
                  plot.add(
                    domain: (0.001, 5), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => exponential(x, 1),
                  )
                },
              )
            },
          )
        }, caption: [$λ = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.25, x-min: 0, x-max: 5, y-max: 0.95, y-min: 0, {
                  plot.add(
                    domain: (0.001, 5), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => exponential(x, 1 / 2),
                  )
                },
              )
            },
          )
        }, caption: [$λ = 1 / 2$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Gamma],
)[
  The gamma distribution is a long-tailed distribution with support only for
  positive real numbers.

  #v(1em)

  The gamma distribution has two parameters and its notation is
  $"Gamma"(α, θ)$:

  - $α$ -- shape parameter
  - $θ$ -- rate parameter

  #v(1em)

  Example: Any waiting time can be modelled with a gamma distribution.
]

#slide(
  title: [Gamma],
)[
  #v(4em)

  $ "Gamma"(α, θ) = f(x, α, θ) = (x^(α-1) e^(-x / θ)) / (Γ(α) θ^α) "for" x, α, θ > 0 $
]

#slide(
  title: [Gamma],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.2, x-min: 0, x-max: 6, y-max: 0.95, y-min: 0, {
                  plot.add(
                    domain: (0.001, 6), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => gammadist(x, 1, 1),
                  )
                },
              )
            },
          )
        }, caption: [$α = 1, θ = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.2, x-min: 0, x-max: 6, y-max: 0.95, y-min: 0, {
                  plot.add(
                    domain: (0.001, 6), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => gammadist(x, 2, 1 / 2),
                  )
                },
              )
            },
          )
        }, caption: [$α = 2, θ = 1 / 2$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Student's $t$],
)[
  #text(
    size: 18pt,
  )[
    Student's $t$ distribution arises by estimating the mean of a
    normally-distributed population in situations where the sample size is small and
    the standard deviation is known #footnote[this is where the ubiquitous Student's $t$ test.].

    #v(1em)

    If we take a sample of $n$ observations from a normal distribution, then
    Student's $t$ distribution with $ν = n - 1$ degrees of freedom can be defined as
    the distribution of the location of the sample mean in relation to the true
    mean, divided by the sample's standard deviation, after multiplying by the
    scaling term $sqrt(n)$.

    #v(1em)

    Student's $t$ distribution is symmetric and in a bell-shape, like the normal
    distribution, but with long tails, which means that has more chance to produce
    values far away from its mean.
  ]
]

#slide(
  title: [Student's $t$],
)[
  Student's $t$ distribution has one parameter and its notation is
  $"Student"(ν)$:

  - $ν$ -- degrees of freedom, controls how much it resembles a normal distribution

  #v(1em)

  Example: a dataset full of outliers.
]

#slide(
  title: [Student's $t$],
)[
  #v(4em)

  $ "Student"(ν) = f(x, ν) = (Γ ((ν + 1) / 2) ) / (sqrt(ν π) Γ (ν / 2 )) (1+ x^2 / ν)^(-(ν+1) / 2) "for" ν >= 1 $
]

#slide(
  title: [Student's $t$],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.45, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => student(x, 1),
                  )
                },
              )
            },
          )
        }, caption: [$ν = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.45, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => student(x, 3),
                  )
                },
              )
            },
          )
        }, caption: [$ν = 3$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Cauchy],
)[
  The Cauchy distribution is bell-shaped distribution and a special case for
  Student's $t$ with $ν = 1$.

  #v(1em)

  But, differently than Student's $t$, the Cauchy distribution has two parameters
  and its notation is
  $"Cauchy"(μ, σ)$:

  - $μ$ -- location parameter
  - $σ$ -- scale parameter

  #v(1em)

  Example: a dataset full of outliers.
]

#slide(title: [Cauchy])[
  #v(4em)

  $ "Cauchy"(μ, σ) = 1 / (π σ (1 + ((x - μ) / σ )^2 )) "for" σ >= 0 $
]

#slide(
  title: [Cauchy],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.65, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => cauchy(x, 0, 1),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 0, σ = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: -4, x-max: 4, y-max: 0.65, y-min: 0, {
                  plot.add(
                    domain: (-4, 4), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => cauchy(x, 0, 1 / 2),
                  )
                },
              )
            },
          )
        }, caption: [$μ = 0, σ = 1 / 2$], numbering: none,
      )
    ]
  ]
]

#slide(
  title: [Beta],
)[
  The beta distribution is a natural choice to model anything that is restricted
  to values between $0$ e $1$. Hence, it is a good candidate to model
  probabilities and proportions.

  #v(1em)

  The beta distribution has two parameters and its notations is
  $"Beta" (α, β)$:

  - $α$ (or sometimes $a$) -- shape parameter, controls how much the shape is
    shifted towards $1$
  - $β$ (or sometimes $b$) -- shape parameter, controls how much the shape is
    shifted towards $0$

  #v(1em)

  Example: A basketball player that has already scored 5 free throws and missed 3
  in a total of 8 attempts -- $"Beta"(3, 5)$
]

#slide(
  title: [Beta],
)[
  #v(4em)

  $ "Beta"(α, β) = f(x, α, β) (x^(α - 1)(1 - x)^(β - 1)) / ((Γ(α)Γ(β)) / (Γ(α +β ))) "for" α, β > 0 "and" x ∈ [0, 1] $
]

#slide(
  title: [Beta],
)[
  #side-by-side[
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: 0, x-max: 1, y-max: 0.3, y-min: 0, {
                  plot.add(
                    domain: (0.0001, 0.9999), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => beta(x, 1, 1),
                  )
                },
              )
            },
          )
        }, caption: [$α = 1, β = 1$], numbering: none,
      )
    ]
  ][
    #align(
      center,
    )[
      #figure(
        {
          canvas(
            length: 0.75cm, {
              plot.plot(
                size: (16, 9), x-label: none, y-label: "PDF", x-tick-step: 1, y-tick-step: 0.1, x-min: 0, x-max: 1, y-max: 0.3, y-min: 0, {
                  plot.add(
                    domain: (0.0001, 0.9999), samples: 200, style: (stroke: (paint: julia-purple, thickness: 2pt)), x => beta(x, 3, 2),
                  )
                },
              )
            },
          )
        }, caption: [$α = 3, β = 2$], numbering: none,
      )
    ]
  ]
]

