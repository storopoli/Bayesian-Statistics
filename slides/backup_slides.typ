#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "utils.typ": *

#new-section-slide("Backup Slides")

#slide(
  title: [How the Normal distribution arose
    #footnote[Origins can be traced back to Abraham de Moivre in 1738. A better explanation
      can be found by
      #link(
        "http://www.stat.yale.edu/~pollard/Courses/241.fall2014/notes2014/Bin.Normal.pdf",
      )[clicking here].]],
)[
  #text(
    size: 16pt,
  )[

    $
      "Binomial"(n, k)                         &= binom(n, k) p^k (1-p)^(n-k) \
      n!                                       &≈ sqrt(2 π n) (n / e)^n \
      lim_(n → oo) binom(n, k) p^k (1-p)^(n-k) &=
      1 / (sqrt(2 π n p q)) e^(-((k - n p)^2) / (2 n p q))
    $

    We know that in the binomial: $op("E") = n p$ and $op("Var") = n p q$; hence
    replacing $op("E")$ by $μ$ and $op("Var")$ by $σ^2$:

    $
      lim_(n → oo) binom(n, k) p^k (1-p)^(n-k) = 1 / (σ sqrt(2 π)) e^(-((k - μ)^2) / (σ^2))
    $
  ]
]

#slide(
  title: [QR Decomposition],
)[
  #text(
    size: 13pt,
  )[
    In Linear Algebra 101, we learn that any matrix (even non-square ones) can be
    decomposed into a product of two matrices:

    - $bold(Q)$: an orthogonal matrix (its columns are orthogonal unit vectors, i.e. $bold(Q)^T = bold(Q)^(-1)$)
    - $bold(R)$: an upper-triangular matrix

    Now, we incorporate the QR decomposition into the linear regression model. Here,
    I am going to use the "thin" QR instead of the "fat", which scales $bold(Q)$ and $bold(R)$ matrices
    by a factor of
    $sqrt(n - 1)$ where $n$ is the number of rows in $bold(X)$. In practice, it is
    better to implement the thin QR, than the fat QR decomposition. It is more
    numerical stable. Mathematically speaking, the thing QR decomposition is:

    $
      bold(X)   &= bold(Q)^* bold(R)^* \
      bold(Q)^* &= bold(Q) dot sqrt(n - 1) \
      bold(R)^* &= 1 / (sqrt(n - 1)) dot bold(R) \
      bold(μ)   &= α + bold(X) dot bold(β) + σ \
                &= α + bold(Q)^* dot bold(R)^* dot bold(β) + σ \
                &= α + bold(Q)^* dot (bold(R)^* dot bold(β)) + σ \
                &= α + bold(Q)^* dot tilde(bold(β)) + σ
    $
  ]
]
