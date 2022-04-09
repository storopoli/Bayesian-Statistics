# Bayesian Statistics

[![CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

<div class="figure" style="text-align: center">

<img src="images/bayes-meme.jpg" alt="Bayesian for Everyone!" width="500" />
<p class="caption">
Bayesian for Everyone!
</p>

</div>

This repository holds slides and code for a full Bayesian statistics graduate course.

**Bayesian statistics** is an approach to inferential statistics based on Bayes' theorem,
where available knowledge about parameters in a statistical model is updated with the information in observed data.
The background knowledge is expressed as a prior distribution and combined with observational data in the form of a likelihood function to determine the posterior distribution.
The posterior can also be used for making predictions about future events.


**Bayesian statistics** is a departure from classical inferential statistics that prohibits probability statements about parameters and is based on asymptotically sampling infinite samples from a theoretical population and finding parameter values that maximize the likelihood function.
Mostly notorious is null-hypothesis significance testing (NHST) based on *p*-values.
Bayesian statistics **incorporate uncertainty** (and prior knowledge) by allowing probability statements about parameters,
and the process of parameter value inference is a direct result of the **Bayes' theorem**.

## Content

The whole content is a set of several slides found at `slides/slides.pdf`.
Here is a brief table of contents

1. **What is Bayesian Statistics?**
2. **Common Probability Distributions**
3. **Priors and Posteriors**
4. **Bayesian Linear Regression**
5. **Bayesian Logistic Regression**
6. **Bayesian Ordinal Regression**
7. **Bayesian Regression with Count Data: Poisson Regression**
8. **Robust Bayesian Regression**
9. **Multilevel Models (a.k.a. Hierarchical Models)**
10. **Markov Chain Monte Carlo (MCMC)**
11. **Model Comparison**

## Probabilistic Programming Languages (PPLs)

Along with slides for the content, this repository also holds `Stan` code and also `Turing.jl` code for all models.
`Stan` and `Turing.jl` represents, respectively, the present and future of [probabilistic programming]((https://en.wikipedia.org/wiki/Probabilistic_programming) languages.

### `Stan`

[**`Stan`**](https://mc-stan.org) (Carpenter et al., 2017) `Stan` is a state-of-the-art platform for statistical modeling and high-performance statistical computation.
Thousands of users rely on `Stan` for statistical modeling, data analysis, and prediction in the social, biological, and physical sciences, engineering, and business.

`Stan` models are specified in its own language (similar to C++) and compiled into an executable binary that can generate Bayesian statistical inferences using a high-performance Markov Chain Montecarlo (MCMC).

### `Turing.jl`

[**`Turing.jl`**](http://turing.ml/) (Ge, Xu & Ghahramani, 2018) is a ecosystem of [**Julia**](https://www.julialang.org) packages for Bayesian Inference using [probabilistic programming](https://en.wikipedia.org/wiki/Probabilistic_programming).
Models specified using `Turing.jl` are easy to read and write — models work the way you write them.
Like everything in Julia, `Turing.jl` is [fast](https://arxiv.org/abs/2002.02702).

## Author

Jose Storopoli, PhD - [*Lattes* CV](http://lattes.cnpq.br/2281909649311607) - [ORCID](https://orcid.org/0000-0002-0559-5176) - <https://storopoli.io>


## How to use the content?

The content is licensed under a very permissive Creative Commons license (CC BY-SA).
You are mostly welcome to contribute with [issues](https://www.github.com/storopoli/Bayesian-Statistics/issues) and [pull requests](https://github.com/storopoli/Bayesian-Statistics/pulls).
My hope is to have **more people into Bayesian statistics**.
The content is aimed towards PhD candidates in applied sciences.
I chose to provide an **intuitive approach** along with some rigorous mathematical formulations.
I've made it to be how I would have liked to be introduced to Bayesian statistics.

## References

The references are divided in **books**, **papers** and **software**.

### Books

-   Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A.,
    & Rubin, D. B. (2013). *Bayesian Data Analysis*. Chapman and
    Hall/CRC.
-   McElreath, R. (2020). *Statistical rethinking: A Bayesian course
    with examples in R and Stan*. CRC press.
-   Gelman, A., Hill, J., & Vehtari, A. (2020). *Regression and other
    stories*. Cambridge University Press.
-   Brooks, S., Gelman, A., Jones, G., & Meng, X.-L. (2011). *Handbook
    of Markov Chain Monte Carlo*. CRC Press.
    <http://books.google.com?id=qfRsAIKZ4rIC>
    -   Geyer, C. J. (2011). Introduction to markov chain monte carlo.
        In S. Brooks, A. Gelman, G. L. Jones, & X.-L. Meng (Eds.),
        *Handbook of markov chain monte carlo*.

### Papers

The papers section of the references are divided into **required** and **complementary**.

#### Required

-   van de Schoot, R., Depaoli, S., King, R., Kramer, B., Märtens, K.,
    Tadesse, M. G., Vannucci, M., Gelman, A., Veen, D., Willemsen, J., &
    Yau, C. (2021). Bayesian statistics and modelling. *Nature Reviews
    Methods Primers*, *1*(1, 1), 1–26.
    https://doi.org/[10.1038/s43586-020-00001-2](https://doi.org/10.1038/s43586-020-00001-2)
-   Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., & Gelman, A.
    (2019). Visualization in Bayesian workflow. *Journal of the Royal
    Statistical Society: Series A (Statistics in Society)*, *182*(2),
    389–402.
    https://doi.org/[10.1111/rssa.12378](https://doi.org/10.1111/rssa.12378)
-   Gelman, A., Vehtari, A., Simpson, D., Margossian, C. C., Carpenter,
    B., Yao, Y., Kennedy, L., Gabry, J., Bürkner, P.-C., & Modr’ak, M.
    (2020, November 3). *Bayesian Workflow*.
    <http://arxiv.org/abs/2011.01808>
-   Benjamin, D. J., Berger, J. O., Johannesson, M., Nosek, B. A.,
    Wagenmakers, E.-J., Berk, R., Bollen, K. A., Brembs, B., Brown, L.,
    Camerer, C., Cesarini, D., Chambers, C. D., Clyde, M., Cook, T. D.,
    De Boeck, P., Dienes, Z., Dreber, A., Easwaran, K., Efferson, C., …
    Johnson, V. E. (2018). Redefine statistical significance. *Nature
    Human Behaviour*, *2*(1), 6–10.
    https://doi.org/[10.1038/s41562-017-0189-z](https://doi.org/10.1038/s41562-017-0189-z)
-   Etz, A. (2018). Introduction to the Concept of Likelihood and Its
    Applications. *Advances in Methods and Practices in Psychological
    Science*, *1*(1), 60–69.
    https://doi.org/[10.1177/2515245917744314](https://doi.org/10.1177/2515245917744314)
-   Etz, A., Gronau, Q. F., Dablander, F., Edelsbrunner, P. A., &
    Baribault, B. (2018). How to become a Bayesian in eight easy steps:
    An annotated reading list. *Psychonomic Bulletin & Review*, *25*(1),
    219–234.
    https://doi.org/[10.3758/s13423-017-1317-5](https://doi.org/10.3758/s13423-017-1317-5)
-   McShane, B. B., Gal, D., Gelman, A., Robert, C., & Tackett, J. L.
    (2019). Abandon Statistical Significance. *American Statistician*,
    *73*, 235–245.
    https://doi.org/[10.1080/00031305.2018.1527253](https://doi.org/10.1080/00031305.2018.1527253)
-   Amrhein, V., Greenland, S., & McShane, B. (2019). Scientists rise up
    against statistical significance. *Nature*, *567*(7748), 305–307.
    https://doi.org/[10.1038/d41586-019-00857-9](https://doi.org/10.1038/d41586-019-00857-9)
-   van Ravenzwaaij, D., Cassey, P., & Brown, S. D. (2018). A simple
    introduction to Markov Chain Monte–Carlo sampling. *Psychonomic
    Bulletin and Review*, *25*(1), 143–154.
    https://doi.org/[10.3758/s13423-016-1015-8](https://doi.org/10.3758/s13423-016-1015-8)
-   Vandekerckhove, J., Matzke, D., Wagenmakers, E.-J., & others.
    (2015). Model comparison and the principle of parsimony. In J. R.
    Busemeyer, Z. Wang, J. T. Townsend, & A. Eidels (Eds.), *Oxford
    handbook of computational and mathematical psychology* (pp.
    300–319). Oxford University Press Oxford.
-   van de Schoot, R., Kaplan, D., Denissen, J., Asendorpf, J. B.,
    Neyer, F. J., & van Aken, M. A. G. (2014). A Gentle Introduction to
    Bayesian Analysis: Applications to Developmental Research. *Child
    Development*, *85*(3), 842–860.
    https://doi.org/[10.1111/cdev.12169](https://doi.org/10.1111/cdev.12169)
    <span class="csl-block">\_eprint:
    https://srcd.onlinelibrary.wiley.com/doi/pdf/10.1111/cdev.12169</span>
-   Wagenmakers, E.-J. (2007). A practical solution to the pervasive
    problems of p values. *Psychonomic Bulletin & Review*, *14*(5),
    779–804.
    https://doi.org/[10.3758/BF03194105](https://doi.org/10.3758/BF03194105)

#### Complementary

-   Cohen, J. (1994). The earth is round (p &lt; .05). *American
    Psychologist*, *49*(12), 997–1003.
    https://doi.org/[10.1037/0003-066X.49.12.997](https://doi.org/10.1037/0003-066X.49.12.997)
-   Dienes, Z. (2011). Bayesian Versus Orthodox Statistics: Which Side
    Are You On? *Perspectives on Psychological Science*, *6*(3),
    274–290.
    https://doi.org/[10.1177/1745691611406920](https://doi.org/10.1177/1745691611406920)
-   Etz, A., & Vandekerckhove, J. (2018). Introduction to Bayesian
    Inference for Psychology. *Psychonomic Bulletin & Review*, *25*(1),
    5–34.
    https://doi.org/[10.3758/s13423-017-1262-3](https://doi.org/10.3758/s13423-017-1262-3)
-   J’unior, C. A. M. (2020). Quanto vale o valor-p? *Arquivos de
    Ciências Do Esporte*, *7*(2).
-   Kerr, N. L. (1998). HARKing: Hypothesizing after the results are
    known. *Personality and Social Psychology Review*, *2*(3), 196–217.
    https://doi.org/[10.1207/s15327957pspr0203\_4](https://doi.org/10.1207/s15327957pspr0203_4)
-   Kruschke, J. K., & Vanpaemel, W. (2015). Bayesian estimation in
    hierarchical models. In J. R. Busemeyer, Z. Wang, J. T. Townsend,
    & A. Eidels (Eds.), *The Oxford handbook of computational and
    mathematical psychology* (pp. 279–299). Oxford University Press
    Oxford, UK.
-   Kruschke, J. K., & Liddell, T. M. (2018). Bayesian data analysis for
    newcomers. *Psychonomic Bulletin & Review*, *25*(1), 155–177.
    https://doi.org/[10.3758/s13423-017-1272-1](https://doi.org/10.3758/s13423-017-1272-1)
-   Kruschke, J. K., & Liddell, T. M. (2018). The Bayesian New
    Statistics: Hypothesis testing, estimation, meta-analysis, and power
    analysis from a Bayesian perspective. *Psychonomic Bulletin &
    Review*, *25*(1), 178–206.
    https://doi.org/[10.3758/s13423-016-1221-4](https://doi.org/10.3758/s13423-016-1221-4)
-   Lakens, D., Adolfi, F. G., Albers, C. J., Anvari, F., Apps, M. A.
    J., Argamon, S. E., Baguley, T., Becker, R. B., Benning, S. D.,
    Bradford, D. E., Buchanan, E. M., Caldwell, A. R., Van Calster, B.,
    Carlsson, R., Chen, S. C., Chung, B., Colling, L. J., Collins, G.
    S., Crook, Z., … Zwaan, R. A. (2018). Justify your alpha. *Nature
    Human Behaviour*, *2*(3), 168–171.
    https://doi.org/[10.1038/s41562-018-0311-x](https://doi.org/10.1038/s41562-018-0311-x)
-   Morey, R. D., Hoekstra, R., Rouder, J. N., Lee, M. D., &
    Wagenmakers, E.-J. (2016). <span class="nocase">The fallacy of
    placing confidence in confidence intervals</span>. *Psychonomic
    Bulletin & Review*, *23*(1), 103–123.
    https://doi.org/[10.3758/s13423-015-0947-8](https://doi.org/10.3758/s13423-015-0947-8)
-   Murphy, K. R., & Aguinis, H. (2019). HARKing: How Badly Can
    Cherry-Picking and Question Trolling Produce Bias in Published
    Results? *Journal of Business and Psychology*, *34*(1).
    https://doi.org/[10.1007/s10869-017-9524-7](https://doi.org/10.1007/s10869-017-9524-7)
-   Stark, P. B., & Saltelli, A. (2018). Cargo-cult statistics and
    scientific crisis. *Significance*, *15*(4), 40–43.
    https://doi.org/[10.1111/j.1740-9713.2018.01174.x](https://doi.org/10.1111/j.1740-9713.2018.01174.x)

### Software

-   Carpenter, B., Gelman, A., Hoffman, M. D., Lee, D., Goodrich, B.,
    Betancourt, M., Brubaker, M., Guo, J., Li, P., & Riddell, A. (2017).
    Stan : A Probabilistic Programming Language. *Journal of Statistical
    Software*, *76*(1).
    https://doi.org/[10.18637/jss.v076.i01](https://doi.org/10.18637/jss.v076.i01)
-   Ge, H., Xu, K., & Ghahramani, Z. (2018). Turing: A Language for Flexible Probabilistic Inference. International Conference on Artificial Intelligence and Statistics, 1682–1690. http://proceedings.mlr.press/v84/ge18b.html
-   Tarek, M., Xu, K., Trapp, M., Ge, H., & Ghahramani, Z. (2020). DynamicPPL: Stan-like Speed for Dynamic Probabilistic Models. ArXiv:2002.02702 [Cs, Stat]. http://arxiv.org/abs/2002.02702
-   Xu, K., Ge, H., Tebbutt, W., Tarek, M., Trapp, M., & Ghahramani, Z. (2020). AdvancedHMC.jl: A robust, modular and efficient implementation of advanced HMC algorithms. Symposium on Advances in Approximate Bayesian Inference, 1–10. http://proceedings.mlr.press/v118/xu20a.html

## How to cite

To cite this course, please use:

    Storopoli (2022). Bayesian Statistics: a graduate course. https://github.com/storopoli/Bayesian-Statistics.

Or in BibTeX format (LaTeX):

    @misc{storopoli2022bayesian,
      author = {Storopoli, Jose},
      title = {Bayesian Statistics: a graduate course},
      url = {https://github.com/storopoli/Bayesian-Statistics},
      year = {2022}
    }

## License

This content is licensed under [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
