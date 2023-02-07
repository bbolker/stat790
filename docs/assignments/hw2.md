1. a. Derive/show how to compute linear regression coefficients (for general choice of y and X) using the following four methods: naive linear algebra; QR decomposition; SVD; and Cholesky decomposition.
b. Pick three of the four algorithms and implement them in the language of your choice. Benchmark your algorithms for a range of magnitudes of $p$ and $n$ covering at least one order of magnitude in $p$ and at least two orders of magnitude in $n$.  Plot your results on a log-log scale. Fit a log-log model to the average times (you can leave out some points if they mess up the scaling relationship).
c. **Optionally**, look up the computational (time) complexity of each of the original four methods as a function of $p$ (number of predictors/columns of X) and $n$ (number of observations/length of y/rows of X); do they agree with your computational results?

2. Implement ridge regression by data augmentation in the language of your choice.  Apply them to the [prostate cancer data](https://hastie.su.domains/ElemStatLearn/datasets/prostate.data) from the ESL web site; don't forget to read the [info about the data set](https://hastie.su.domains/ElemStatLearn/datasets/prostate.info.txt) first. Compare your results and timing with a native implementation of ridge regression.

3. From ESL: do exercises 3.6, 3.19 (ridge and lasso only), 3.28, 3.30

