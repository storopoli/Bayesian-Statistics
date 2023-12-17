#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *

#new-section-slide("Tools")

#slide(title: "Recommended References")[
  - #cite(<geTuringLanguageFlexible2018>, form: "prose") - Turing paper

  - #cite(<carpenterStanProbabilisticProgramming2017>, form: "prose") - Stan paper

  - #cite(<pymc3>, form: "prose") - PyMC paper

  - #link("https://storopoli.github.io/Bayesian-Julia/pages/1_why_Julia/")[
      Bayesian Statistics with Julia and Turing - Why Julia?
    ]
]

#focus-slide(background: julia-purple)[
  #quote(block: true, attribution: [Vita Sackville-West])[A man and his tools make a man and his trade]

  #quote(block: true, attribution: [Winston Churchill])[We shape our tools and then the tools shape us]
]

#focus-slide(background: julia-purple)[
  #align(center)[#image("images/memes/standards.png")]
]

#slide(title: "Tools")[
  - #link("https://mc-stan.org")[Stan] (BSD-3 License)

  - #link("https://turing.ml")[Turing] (MIT License)

  - #link("https://www.pymc.io/")[PyMC] (Apache License)

  - #link("https://mcmc-jags.sourceforge.io/")[JAGS] (GPL License)

  - #link("https://www.mrc-bsu.cam.ac.uk/software/bugs/")[BUGS] (GPL License)
]

#slide(title: [Stan #footnote[#cite(<carpenterStanProbabilisticProgramming2017>, form: "prose")]])[
  #side-by-side(columns: (4fr, 1fr))[
    #text(size: 16pt)[
      - High-performance platform for statistical
        modeling and  statistical computation
      - Financial support from
        #link("https://numfocus.org/")[NUMFocus]:
        - AWS Amazon
        - Bloomberg
        - Microsoft
        - IBM
        - RStudio
        - Facebook
        - NVIDIA
        - Netflix
      - Open-source language, similar to C++
      - Markov Chain Monte Carlo (MCMC) parallel sampler
    ]
  ][
    #image("images/logos/stan.png")
  ]
]

#slide(title: [Stan Code Example])[
  #fit-to-height(1fr)[```cpp
        data {
          int<lower=0> N;
          vector[N] x;
          vector[N] y;
        }
        parameters {
          real alpha;
          real beta;
          real<lower=0> sigma;
        }
        model {
          alpha ~ normal(0, 20);
          beta ~ normal(0, 2);
          sigma ~ cauchy(0, 2.5);
          y ~ normal(alpha + beta * x, sigma);
        }
  ```
  ]
]

#slide(title: [Turing #footnote[#cite(<geTuringLanguageFlexible2018>, form: "prose")]])[
  #side-by-side(columns: (4fr, 1fr))[
    #text(size: 18pt)[
      - Ecosystem of Julia packages for Bayesian
        Inference using probabilistic programming

      - #link("https://www.julialang.org")[Julia] is a fast
        dynamic-typed language that just-in-time (JIT)
        compiles into native code using LLVM:
        #link("https://www.nature.com/articles/d41586-019-02310-3")[
        #quote[runs like C but reads like Python]
        ]\;
        meaning that is _blazing_ fast, easy to prototype and read/write code

      - Julia has Financial support from
        #link("https://numfocus.org/")[NUMFocus]

      - Composability with other Julia packages

      - Several other options of Markov Chain Monte Carlo (MCMC) samplers
    ]
  ][
    #image("images/logos/turing.png")
  ]
]

#slide(title: [Turing Ecosystem])[
  #text(size: 16pt)[
	We have several Julia packages under Turing's GitHub organization
    #link("https://github.com/TuringLang")[TuringLang],
	but I will focus on 6 of those:

      - #link("https://github.com/TuringLang/Turing.jl")[Turing]:
        main package that we use to *interface with all the Turing ecosystem*
        of packages and the backbone of everything

      - #link("https://github.com/TuringLang/MCMCChains.jl")[MCMCChains]:
        interface to *summarizing MCMC simulations* and
        has several utility functions for *diagnostics*
        and *visualizations*

      - #link("https://github.com/TuringLang/DynamicPPL.jl")[DynamicPPL]:
        specifies a domain-specific language for Turing,
        entirely written in Julia, and it is modular

      - #link("https://github.com/TuringLang/AdvancedHMC.jl")[AdvancedHMC]:
        modular and efficient implementation of advanced Hamiltonian Monte
        Carlo (HMC) algorithms

      - #link("https://github.com/TuringLang/DistributionsAD.jl")[DistributionsAD]:
        defines the necessary functions to enable automatic
        differentiation (AD) of the log PDF functions from
        #link("https://github.com/JuliaStats/Distributions.jl")[Distributions]

      - #link("https://github.com/TuringLang/Bijectors.jl")[Bijectors]:
        implements a set of functions for transforming constrained
        random variables (e.g. simplexes, intervals) to Euclidean space
  ]
]

#slide(title: [Turing #footnote[
  I believe in Julia's potential and wrote a whole set of
  #link("https://storopoli.github.io/Bayesian-Julia")[
      Bayesian Statistics tutorials using Julia and Turing
  ] @storopoli2021bayesianjulia ] Code Example])[

  #v(1em)

  ```julia
        @model function linreg(x,  y)
            α ~ Normal(0, 20)
            β ~ Normal(0, 2)
            σ ~ truncated(Cauchy(0, 2.5); lower=0)

            y .~ Normal(α .+ β * x, σ)
        end
  ```
]

#slide(title: [PyMC #footnote[#cite(form: "prose", <pymc3>)]])[
  #side-by-side(columns: (4fr, 1fr))[

    - Python package for Bayesian statistics with a Markov Chain Monte Carlo sampler

    - Financial support from #link("https://numfocus.org/")[NUMFocus]

    - Backend was based on Theano

    - Theano *died*, but PyMC developers create a fork named Aesara

    - We have no idea what will be the backend in the future.
      PyMC developers are still experimenting with other backends: 
      TensorFlow Probability, NumPyro, BlackJAX, and so on ...
  ][
  #v(2em)
  #image("images/logos/pymc.png")
  ]
]

#slide(title: [PyMC Code Example])[
  ```python
    with pm.Model() as model:
        alpha = pm.Normal("Intercept", mu=0, sigma=20)
        beta = pm.Normal("beta", mu=0, sigma=2)
        sigma = pm.HalfCauchy("sigma", beta=2.5)

        likelihood = pm.Normal("y",
                     mu=alpha + beta * x1,
                     sigma=sigma, observed=y)
  ```
]

#slide(title: [Which Tool Should You Use?])[
  #side-by-side(columns: (1fr, 1fr))[
  #align(center)[#image("images/logos/turing.png", width: 80%)
    Turing
  ]
  ][
  #align(center)[#image("images/logos/stan.png", width: 55%)
    Stan
  ]
  ]
]

#slide(title: [Why Turing])[
  - *Julia* all the way down...
  - Can *interface/compose* _any_ Julia package
  - Decoupling of *modeling DSL, inference algorithms and data*
  - Not only HMC-NUTS, but a whole *plethora of MCMC algorithms*,
    e.g. Metropolis-Hastings, Gibbs, SMC, IS etc.
  - Easy to *create/prototype/modify inference algorithms*
  - *Transparent MCMC workflow*,
    e.g. iterative sampling API allows step-wise execution
    and debugging of the inference algorithm
  - Very easy to *do stuff in the GPU*, e.g. NVIDIA's CUDA.jl,
    AMD's AMDGPU.jl, Intel's oneAPI.jl, and Apple's Metal.jl
  - Very easy to do *distributed model inference and prediction*.
]

#slide(title: [Why _Not_ Turing])[
  - *Not as fast*, but pretty close behind, as Stan.

  - *Not enough learning materials*, example models, tutorials.
    Also documentation is somewhat lacking in certain areas, e.g. Bijectors.jl.

  - *Not as many citations as Stan*,
    although not very far behind in GitHub stars.

  - *Not well-known in the academic community*.
]

#slide(title: [Why Stan])[
  - API for R, Python and Julia.

  - Faster than Turing.jl in 95% of models.

  - *Well-known in the academic community*.

  - *High citation count*.

  - *More tutorials, example models, and learning materials available*.
]

#slide(title: [Why _Not_ Stan])[
  - If you want to try *something new*, you'll have to do in *C++*.

  - Constrained *only to HMC-NUTS* as MCMC algorithm.

  - *Cannot decouple model DSL from data* (and also from inference algorithm).

  - *Does not compose well with other packages*.
    For anything you want to do, it has to "exist" in the Stan world,
    e.g. bayesplot.

  - A *not so easy and intuitive ODE interface*.

  - *GPU interface depends on OpenCL*.
    Also not easy to interoperate.
]
