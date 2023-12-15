// run with 4 chains and 2k iters.
// all data should be scaled to mean 0 and std 1:
// sparse_regression data
data {
  int<lower=1> N;   // number of observations
  int<lower=1> K;   // number of independent variables
  matrix[N, K] X;   // data matrix
  vector[N] y;      // dependent variable vector
}
parameters {
  real alpha;                // intercept
  vector<lower=0>[K] lambda; // local shrinkage factor
  real<lower=0> eta;         // additional local shrinkage factor
  real<lower=0> sigma;       // model error
  real<lower=0> tau;         // global shinkrage factor
  vector[K] beta;            // coefficients for independent variables
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  lambda ~ cauchy(0, 1);
  sigma ~ exponential(1);
  tau ~ cauchy(0, (1 / K) + machine_precision()); // numerical stability
  eta ~ cauchy(0, 1);
  beta ~ normal(0, lambda * tau * eta);

  // likelihood
  y ~ normal(alpha + X * beta, sigma);
}
// results:
//Warmup took (2.2, 2.2, 2.1, 2.2) seconds, 8.7 seconds total
//Sampling took (2.2, 2.2, 2.4, 3.0) seconds, 9.8 seconds total
//                    Mean     MCSE   StdDev        5%       50%       95%  N_Eff  N_Eff/s    R_hat
//lp__            -1.2e+02  1.6e-01  5.6e+00  -1.3e+02  -1.2e+02  -1.1e+02   1194      122      1.0
//accept_stat__       0.92  3.6e-03  1.3e-01   6.7e-01      0.97      1.00   1366      139  1.0e+00
//stepsize__         0.010  7.2e-04  1.0e-03   8.3e-03     0.011     0.011    2.0     0.20  2.5e+13
//treedepth__          8.3  2.3e-01  6.2e-01   8.0e+00       8.0       9.0    7.1     0.73  1.2e+00
//n_leapfrog__         401  4.1e+01  1.4e+02   2.6e+02       511       511     12      1.3  1.1e+00
//divergent__        0.036  3.5e-03  1.9e-01   0.0e+00      0.00      0.00   2804      286  1.0e+00
//energy__             145  2.2e-01  7.3e+00   1.3e+02       145       158   1119      114  1.0e+00
//alpha            1.1e-01  2.3e-03  1.1e-01  -6.9e-02   1.1e-01   2.9e-01   2278      232      1.0
//lambda[1]        1.1e+01  4.0e-01  1.7e+01   2.3e+00   7.1e+00   3.4e+01   1774      181     1.00
//lambda[2]        8.5e-01  3.1e-02  1.7e+00   3.9e-02   4.8e-01   2.6e+00   2985      304     1.00
//lambda[3]        6.3e+00  2.1e-01  8.8e+00   1.3e+00   4.0e+00   1.7e+01   1688      172      1.0
//lambda[4]        8.9e-01  3.6e-02  1.9e+00   5.2e-02   5.0e-01   2.6e+00   2601      265      1.0
//lambda[5]        7.5e+00  3.4e-01  1.3e+01   1.5e+00   4.7e+00   2.0e+01   1345      137      1.0
//lambda[6]        5.0e+00  1.8e-01  7.2e+00   1.1e+00   3.2e+00   1.4e+01   1680      171      1.0
//lambda[7]        9.7e-01  3.6e-02  1.8e+00   5.6e-02   5.8e-01   2.9e+00   2408      246      1.0
//lambda[8]        3.4e+00  1.7e-01  6.1e+00   6.7e-01   2.1e+00   9.5e+00   1324      135      1.0
//lambda[9]        9.5e-01  8.0e-02  4.8e+00   4.3e-02   4.6e-01   2.8e+00   3623      370      1.0
//lambda[10]       1.1e+00  5.3e-02  2.3e+00   4.3e-02   5.8e-01   3.5e+00   1988      203      1.0
//lambda[11]       1.9e+00  5.6e-02  2.6e+00   2.2e-01   1.1e+00   5.5e+00   2167      221      1.0
//lambda[12]       9.5e-01  4.5e-02  1.9e+00   4.8e-02   5.1e-01   3.0e+00   1760      180      1.0
//lambda[13]       8.9e-01  2.6e-02  1.4e+00   5.5e-02   5.3e-01   2.7e+00   2697      275      1.0
//lambda[14]       9.5e+00  4.1e-01  1.5e+01   2.0e+00   6.0e+00   2.6e+01   1266      129      1.0
//lambda[15]       1.0e+00  4.2e-02  1.9e+00   4.8e-02   5.9e-01   3.1e+00   1918      196      1.0
//lambda[16]       8.6e-01  3.3e-02  1.5e+00   3.5e-02   4.9e-01   2.8e+00   2012      205      1.0
//
//lambda[17]       8.2e-01  3.0e-02  1.4e+00   3.5e-02   4.6e-01   2.6e+00   2278      232      1.0
//lambda[18]       8.6e-01  2.7e-02  1.2e+00   4.7e-02   5.0e-01   2.8e+00   2082      212      1.0
//lambda[19]       8.3e-01  3.1e-02  1.5e+00   4.8e-02   4.6e-01   2.5e+00   2250      230      1.0
//lambda[20]       9.4e+00  6.0e-01  2.5e+01   1.9e+00   5.9e+00   2.5e+01   1694      173      1.0
//eta              3.6e+13  3.9e+12  2.0e+14   7.0e+00   6.6e+07   1.4e+14   2599      265      1.0
//sigma            9.6e-01  1.5e-03  7.5e-02   8.5e-01   9.5e-01   1.1e+00   2496      255      1.0
//tau              8.3e-03  1.3e-03  7.8e-02   1.2e-15   2.7e-09   2.7e-02   3855      393     1.00
//beta[1]          1.4e+00  2.2e-03  1.0e-01   1.2e+00   1.4e+00   1.6e+00   2189      223      1.0
//beta[2]          2.0e-02  1.5e-03  6.8e-02  -8.1e-02   8.3e-03   1.4e-01   2164      221      1.0
//beta[3]          7.5e-01  2.1e-03  1.1e-01   5.7e-01   7.5e-01   9.3e-01   2662      272     1.00
//beta[4]          2.6e-02  1.5e-03  7.2e-02  -7.7e-02   1.4e-02   1.6e-01   2218      226      1.0
//beta[5]         -8.9e-01  1.9e-03  1.1e-01  -1.1e+00  -8.9e-01  -7.1e-01   3191      326      1.0
//beta[6]          5.8e-01  2.0e-03  1.0e-01   4.1e-01   5.8e-01   7.4e-01   2633      269     1.00
//beta[7]          5.0e-02  1.9e-03  8.1e-02  -5.7e-02   3.3e-02   2.1e-01   1767      180      1.0
//beta[8]          3.7e-01  1.9e-03  1.0e-01   2.0e-01   3.6e-01   5.3e-01   2848      291      1.0
//beta[9]         -7.3e-03  1.6e-03  7.2e-02  -1.4e-01  -2.2e-03   1.1e-01   2008      205      1.0
//beta[10]         5.1e-02  2.0e-03  8.2e-02  -5.6e-02   3.2e-02   2.1e-01   1755      179      1.0
//beta[11]         1.8e-01  2.7e-03  1.1e-01  -2.0e-03   1.8e-01   3.6e-01   1762      180      1.0
//beta[12]        -2.7e-02  1.7e-03  7.6e-02  -1.7e-01  -1.4e-02   8.6e-02   1874      191      1.0
//beta[13]        -2.9e-02  1.8e-03  7.7e-02  -1.8e-01  -1.6e-02   8.3e-02   1877      191      1.0
//beta[14]        -1.1e+00  1.8e-03  9.7e-02  -1.3e+00  -1.1e+00  -9.7e-01   2840      290      1.0
//beta[15]        -5.0e-02  2.3e-03  8.9e-02  -2.2e-01  -3.0e-02   7.3e-02   1537      157      1.0
//beta[16]        -1.7e-02  1.5e-03  7.2e-02  -1.5e-01  -7.4e-03   9.6e-02   2251      230      1.0
//beta[17]        -1.0e-02  1.4e-03  6.6e-02  -1.2e-01  -3.4e-03   9.4e-02   2331      238      1.0
//beta[18]         2.1e-02  1.6e-03  7.0e-02  -8.4e-02   9.3e-03   1.5e-01   2032      207      1.0
//beta[19]        -9.5e-04  1.3e-03  6.1e-02  -1.0e-01  -5.3e-05   9.8e-02   2095      214     1.00
//beta[20]        -1.1e+00  2.3e-03  1.2e-01  -1.3e+00  -1.1e+00  -9.2e-01   2663      272      1.0
