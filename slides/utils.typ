// colors
#let julia-purple = rgb("#9558b2")
#let julia-blue = rgb("#4063d8")
#let julia-green = rgb("#389826")
#let julia-red = rgb("#cb3c33")

// functions
#let logistic(x) = 1 / (1 + calc.exp(-x))
#let normcdf(x, μ, σ) = 1 / (
  1 + calc.exp(-0.07056 * calc.pow(((x - μ) / σ), 3) - 1.5976 * (x - μ) / σ)
)
