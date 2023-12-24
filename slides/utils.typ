// colors
#let julia-purple = rgb("#9558b2")
#let julia-blue = rgb("#4063d8")
#let julia-green = rgb("#389826")
#let julia-red = rgb("#cb3c33")

// functions
#let discreteuniform(a, b) = 1 / (b - a + 1)
#let binomial(x, n, p) = calc.fact(n) / (calc.fact(x) * calc.fact(n - x)) * calc.pow(p, x) * calc.pow(1 - p, n - x)
#let poisson(x, λ) = calc.pow(λ, x) * calc.exp(-λ) / calc.fact(x)
#let negativebinomial(x, r, p) = calc.fact(x + r - 1) / (calc.fact(r - 1) * calc.fact(x)) * (calc.pow(1 - p, x) * calc.pow(p, r))
#let continuousuniform(a, b) = 1 / (b - a)
#let gaussian(x, μ, σ) = 1 / (σ * calc.sqrt(2 * calc.pi)) * calc.exp(-(calc.pow(x - μ, 2)) / (2 * calc.pow(σ, 2)))
#let lognormal(x, μ, σ) = 1 / (x * σ * calc.sqrt(2 * calc.pi)) * calc.exp(-(calc.pow(calc.ln(x) - μ, 2)) / (2 * calc.pow(σ, 2)))
#let exponential(x, λ) = λ * calc.exp(-λ * x)
#let gamma(z) = (2.506628274631 * calc.sqrt(1 / z)) + (0.20888568 * calc.pow(1 / z, 1.5)) + (0.00870357 * calc.pow(1 / z, 2.5)) - ((174.2106599 * calc.pow(1 / z, 3.5)) / 25920) - ((715.6423511 * calc.pow(1 / z, 4.5)) / 1244160) * (calc.exp(-calc.ln(1 / z) - 1) * z)
#let gammadist(x, α, θ) = calc.pow(x, α - 1) * calc.exp(-x / θ) * gamma(α) * calc.pow(θ, α)
#let student(x, ν) = gamma((ν + 1) / 2) / (calc.sqrt(ν * calc.pi) * gamma(ν / 2)) * calc.pow(1 + (calc.pow(x, 2) / ν), (-(ν + 1) / 2))
#let cauchy(x, μ, σ) = 1 / (calc.pi * σ * (1 + (calc.pow((x - μ) / σ, 2))))
#let beta(x, α, β) = calc.pow(x, α - 1) * calc.pow(1 - x, β - 1) / ((gamma(α) * gamma(β)) / gamma(α + β))
#let logistic(x) = 1 / (1 + calc.exp(-x))
#let normcdf(x, μ, σ) = 1 / (
  1 + calc.exp(-0.07056 * calc.pow(((x - μ) / σ), 3) - 1.5976 * (x - μ) / σ)
)
#let logodds(p) = calc.ln(p / (1 - p))

