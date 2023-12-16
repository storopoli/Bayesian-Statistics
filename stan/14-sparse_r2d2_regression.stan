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
  vector[K] z;               // standard normal for coefficients
  real<lower=0> sigma;       // model error
  real<lower=0, upper=1> r2; // coefficient of determination
  simplex[K] phi;            // local shrinkage parameter
}
transformed parameters {
  real tau_2 = sigma^2 * r2 / (1 - r2);    // global shrinkage parameter
  vector[K] beta = z .* sqrt(phi .* tau_2); // coefficients
}
model {
  // priors
  alpha ~ student_t(3, 0, 2.5);
  sigma ~ exponential(1);
  r2 ~ beta(0.5 * 2, (1 - 0.5) * 2); // mean_r2 = 0.5 and prec_r2 = 2
  phi ~ dirichlet(rep_vector(1, K)); // cons_d2 = 1

  // likelihood
  y ~ normal(alpha + X * beta, sigma);
}
// results:
//Warmup took (6.4, 6.5, 6.4, 6.4) seconds, 26 seconds total
//Sampling took (7.8, 7.9, 7.8, 7.9) seconds, 31 seconds total
//                    Mean     MCSE   StdDev        5%       50%       95%  N_Eff  N_Eff/s    R_hat
//lp__            -1.7e+02  1.0e+00  4.7e+00  -1.8e+02  -1.7e+02  -1.6e+02     20     0.63      1.1
//accept_stat__       0.96  3.9e-03  6.4e-02      0.83      0.98      1.00    267      8.5  1.0e+00
//stepsize__         0.038  2.4e-03  3.4e-03     0.033     0.038     0.042    2.0    0.064  2.0e+13
//treedepth__         10.0      nan  2.7e-02        10        10        10    nan      nan      nan
//n_leapfrog__        1023      nan  5.0e+00      1023      1023      1023    nan      nan      nan
//divergent__         0.00      nan  0.0e+00      0.00      0.00      0.00    nan      nan      nan
//energy__             191  9.1e-01  6.4e+00       181       190       202     50      1.6  1.0e+00
//alpha            8.9e-02  1.4e-02  1.1e-01  -8.7e-02   9.1e-02   2.6e-01     59      1.9      1.0
//z[1]             2.4e+12  6.0e+11  1.6e+12   7.4e+11   1.9e+12   6.1e+12    7.1     0.23      1.9
//z[2]            -2.9e+09  5.1e+10  1.2e+11  -1.9e+11   2.1e+09   2.0e+11    5.2     0.17      2.1
//z[3]             1.2e+12  2.7e+11  6.2e+11   3.6e+11   1.1e+12   2.3e+12    5.2     0.17      1.7
//z[4]             2.8e+11  1.2e+11  2.8e+11  -6.2e+10   2.0e+11   8.8e+11    5.2     0.16      2.1
//z[5]            -1.8e+12  5.2e+11  1.2e+12  -4.4e+12  -1.5e+12  -5.0e+11    5.2     0.16      1.9
//z[6]             1.2e+12  3.7e+11  9.2e+11   3.5e+11   8.6e+11   2.8e+12    6.1     0.19      1.6
//z[7]             1.3e+08  2.9e+10  1.1e+11  -1.8e+11   1.2e+10   1.9e+11     16     0.51      1.3
//z[8]             5.8e+11  1.1e+11  2.9e+11   1.9e+11   5.4e+11   1.2e+12    6.9     0.22      1.6
//z[9]             2.0e+10  6.1e+10  1.4e+11  -1.7e+11  -3.7e+09   3.1e+11    4.9     0.15      1.4
//z[10]            1.6e+11  1.1e+11  2.6e+11  -2.0e+11   7.4e+10   7.4e+11    5.3     0.17      1.4
//z[11]            2.5e+11  6.4e+10  1.3e+11   5.5e+10   2.5e+11   4.7e+11    4.2     0.13      1.7
//z[12]           -9.8e+09  7.9e+10  1.6e+11  -2.8e+11  -1.5e+10   2.6e+11    4.1     0.13      1.6
//z[13]           -1.2e+11  1.0e+11  1.8e+11  -4.7e+11  -5.8e+10   9.6e+10    3.2     0.10      1.9
//z[14]           -2.0e+12  6.4e+11  1.3e+12  -4.6e+12  -1.5e+12  -6.1e+11    4.3     0.14      1.9
//z[15]           -2.0e+11  1.7e+11  2.7e+11  -7.3e+11  -9.6e+10   4.7e+10    2.4    0.078      2.9
//z[16]            1.7e+11  7.6e+10  1.8e+11  -4.0e+10   1.2e+11   4.6e+11    5.4     0.17      2.0
//z[17]           -3.9e+10  2.5e+10  8.6e+10  -1.7e+11  -3.6e+10   8.4e+10     12     0.39      1.4
//z[18]            3.0e+09  6.9e+10  1.6e+11  -2.5e+11  -8.9e+09   2.7e+11    5.3     0.17      1.5
//z[19]           -4.8e+10  4.3e+10  1.7e+11  -3.4e+11  -7.0e+09   1.9e+11     16     0.50      1.3
//z[20]           -1.8e+12  2.8e+11  8.0e+11  -3.2e+12  -1.7e+12  -5.6e+11    8.0     0.26      1.4
//sigma            9.5e-01  2.9e-03  7.2e-02   8.4e-01   9.4e-01   1.1e+00    635       20      1.0
//r2               1.8e-23  8.4e-24  2.5e-23   2.2e-24   9.7e-24   6.5e-23    8.7     0.28      1.3
//phi[1]           6.3e-02  8.8e-03  4.4e-02   1.6e-02   5.0e-02   1.5e-01     25     0.81      1.2
//phi[2]           4.5e-02  6.3e-03  4.7e-02   2.1e-03   2.9e-02   1.4e-01     56      1.8      1.0
//phi[3]           6.9e-02  7.9e-03  4.8e-02   2.0e-02   5.6e-02   1.7e-01     37      1.2      1.0
//phi[4]           3.3e-02  6.1e-03  3.6e-02   1.2e-03   2.1e-02   1.1e-01     34      1.1      1.1
//phi[5]           5.5e-02  9.9e-03  4.4e-02   3.4e-03   4.4e-02   1.4e-01     19     0.62      1.1
//phi[6]           5.3e-02  6.2e-03  4.2e-02   1.1e-02   4.1e-02   1.4e-01     45      1.4      1.1
//phi[7]           4.3e-02  4.1e-03  4.7e-02   1.5e-03   2.7e-02   1.4e-01    131      4.2      1.0
//phi[8]           7.0e-02  1.8e-02  5.2e-02   1.1e-02   5.8e-02   1.7e-01    8.0     0.26      1.2
//phi[9]           4.3e-02  1.9e-03  4.3e-02   1.8e-03   2.9e-02   1.3e-01    531       17      1.0
//phi[10]          4.4e-02  7.1e-03  4.3e-02   2.4e-03   3.0e-02   1.3e-01     37      1.2      1.0
//phi[11]          6.7e-02  7.1e-03  5.2e-02   8.3e-03   5.5e-02   1.7e-01     54      1.7      1.0
//phi[12]          4.2e-02  3.2e-03  4.5e-02   1.7e-03   2.7e-02   1.4e-01    192      6.1      1.0
//phi[13]          4.1e-02  3.7e-03  4.1e-02   2.1e-03   2.7e-02   1.2e-01    119      3.8      1.0
//phi[14]          6.9e-02  1.8e-02  5.3e-02   1.3e-02   5.3e-02   1.8e-01    9.0     0.29      1.3
//phi[15]          4.4e-02  7.2e-03  4.4e-02   2.6e-03   3.1e-02   1.3e-01     37      1.2      1.0
//phi[16]          3.4e-02  7.1e-03  4.0e-02   1.1e-03   2.0e-02   1.2e-01     31     0.99      1.1
//phi[17]          4.4e-02  1.2e-03  4.3e-02   2.2e-03   3.0e-02   1.3e-01   1400       45      1.0
//phi[18]          3.9e-02  2.5e-03  4.2e-02   1.6e-03   2.5e-02   1.2e-01    282      9.0      1.0
//phi[19]          3.6e-02  2.3e-03  3.9e-02   1.4e-03   2.4e-02   1.1e-01    290      9.2      1.0
//phi[20]          6.8e-02  7.8e-03  4.5e-02   1.7e-02   5.7e-02   1.5e-01     33      1.1      1.1
//tau_2            1.6e-23  7.2e-24  2.1e-23   2.0e-24   8.8e-24   5.6e-23    8.2     0.26      1.4
//beta[1]          1.4e+00  5.2e-03  1.0e-01   1.2e+00   1.4e+00   1.6e+00    363       12      1.0
//beta[2]          1.7e-03  2.8e-02  6.0e-02  -1.0e-01   1.2e-03   1.0e-01    4.7     0.15      1.7
//beta[3]          7.6e-01  7.7e-03  1.0e-01   5.9e-01   7.6e-01   9.3e-01    180      5.7      1.0
//beta[4]          8.3e-02  1.6e-02  7.8e-02  -3.6e-02   8.0e-02   2.2e-01     25     0.79      1.1
//beta[5]         -8.9e-01  4.8e-03  1.1e-01  -1.1e+00  -8.9e-01  -7.1e-01    522       17      1.0
//beta[6]          5.8e-01  5.2e-03  9.1e-02   4.3e-01   5.8e-01   7.2e-01    311      9.9      1.0
//beta[7]          9.0e-03  1.3e-02  6.3e-02  -8.8e-02   4.4e-03   1.2e-01     22     0.70      1.2
//beta[8]          3.7e-01  2.0e-02  9.7e-02   2.1e-01   3.7e-01   5.3e-01     23     0.73      1.1
//beta[9]          3.5e-03  2.1e-02  6.0e-02  -8.9e-02  -1.8e-03   1.1e-01    7.8     0.25      1.3
//beta[10]         6.8e-02  3.0e-02  8.3e-02  -4.4e-02   5.6e-02   2.2e-01    7.7     0.24      1.2
//beta[11]         1.6e-01  1.6e-02  8.4e-02   4.0e-02   1.6e-01   3.2e-01     28     0.88      1.1
//beta[12]        -1.2e-02  2.5e-02  7.1e-02  -1.4e-01  -7.8e-03   1.0e-01    8.2     0.26      1.3
//beta[13]        -4.3e-02  2.8e-02  6.7e-02  -1.6e-01  -3.4e-02   5.1e-02    5.6     0.18      1.3
//beta[14]        -1.1e+00  8.8e-03  9.5e-02  -1.3e+00  -1.1e+00  -9.9e-01    117      3.7      1.0
//beta[15]        -7.8e-02  3.8e-02  8.4e-02  -2.4e-01  -5.8e-02   2.4e-02    4.9     0.16      1.4
//beta[16]         4.6e-02  1.9e-02  6.0e-02  -4.3e-02   3.9e-02   1.5e-01     10     0.33      1.2
//beta[17]        -2.1e-02  1.2e-02  5.1e-02  -1.1e-01  -1.6e-02   5.2e-02     20     0.62      1.3
//beta[18]         7.3e-03  3.0e-02  7.6e-02  -1.1e-01  -3.2e-03   1.4e-01    6.5     0.21      1.4
//beta[19]        -5.6e-03  1.5e-02  6.6e-02  -1.2e-01  -2.6e-03   9.9e-02     21     0.65      1.2
//beta[20]        -1.1e+00  8.5e-03  1.2e-01  -1.3e+00  -1.1e+00  -9.5e-01    187      5.9      1.0