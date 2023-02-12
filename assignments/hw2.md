1. a. Derive/show how to compute linear regression coefficients (for general choice of y and X) using the following four methods: naive linear algebra; QR decomposition; SVD; and Cholesky decomposition.
b. Pick three of the four algorithms and implement them in the language of your choice. Benchmark your algorithms for a range of magnitudes of $p$ and $n$ covering at least one order of magnitude in $p$ and at least two orders of magnitude in $n$.  Plot your results on a log-log scale. Fit a log-log model to the average times (you can leave out some points if they mess up the scaling relationship).

For example: suppose you have written a function `my_lm` that takes `X` and `y` and returns a set of coefficients. You want to test it on an example where `X` is 1000 x 10 (observations, predictors).

This example uses `microbenchmark::microbenchmark()`, you could also use `rbenchmark::benchmark()` (or the equivalent testing framework in Python or Julia or other language of your choice).
```r
library(microbenchmark)
my_lm <- function(X,y) rnorm(ncol(X)) ## trivial: for testing
simfun <- function(n, p) {
    y <- rnorm(n)
    X <- matrix(rnorm(p*n), ncol = p)
    list(X = X, y = y)
}
set.seed(101)
s <- simfun(1000, 10)
## a test to make sure we get the same coefficients -- FAILS in this case
## (also see the 'check' argument of microbenchmark())
stopifnot(all.equal(lm.fit(s$X, s$y)$coefficients,
                    my_lm(s$X, s$y)))
## consider setting the `times` argument to a value less than the default of 100
## if the individual fits are too slow
m <- microbenchmark(
    lm.fit(s$X, s$y),
    my_lm(s$X, s$y))
results <- summary(m) ## store the components you need from this    
```

Then try something like looping over values of `n`:

```r
nvec <- round(10^seq(2, 5, by = 0.25))
## set aside some storage for the results ...
for (i in seq_along(n)) {
    s <- simfun(nvec[i], p = 10)
    m <- microbenchmark(
        lm.fit(s$X, s$y),
        my_lm(s$X, s$y))
    ## store results
}
```

Then do something like `plot(nvec, timevec_lm.fit, log = "xy"); lines(nvec, timevec_my_lm); lm(log(timevec) ~ log(nvec))` etc. (Or use `matplot` or `ggplot` if you like, for more compact/prettier code.)

c. **Optionally**, look up the computational (time) complexity of each of the original four methods as a function of $p$ (number of predictors/columns of X) and $n$ (number of observations/length of y/rows of X); do they agree with your computational results?

2. Implement ridge regression by data augmentation in the language of your choice.  Apply them to the [prostate cancer data](https://hastie.su.domains/ElemStatLearn/datasets/prostate.data) from the ESL web site; don't forget to read the [info about the data set](https://hastie.su.domains/ElemStatLearn/datasets/prostate.info.txt) first. Compare your results and timing with a native implementation of ridge regression.

3. From ESL: do exercises 3.6, 3.19 (ridge and lasso only), 3.28, 3.30

