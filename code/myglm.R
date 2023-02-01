myglmfit <- function(y, X, family, tol=1e-8, maxit=50,
                     lambda = 0) {
    ## ASSUME (1) X is already scaled (2) X has an intercept
    mu <- y  ## set initial values
    ## set up 'oldbeta' and 'beta' so they're not identical
    oldbeta <- rep(0,ncol(X))
    beta    <- rep(1,ncol(X))
    p <- ncol(X)
    it <- 1  ## number of iterations
    while (it < maxit && max(abs((1-beta/oldbeta)))>tol) {
        oldbeta <- beta 
        eta <- family$linkfun(mu)    ## calc. linear predictor
        mm <- family$mu.eta(eta)     ## calc. d(mu)/d(eta)
        z <- eta + (y-mu)/mm    ## adjusted response
        W <- c(1/(mm^2*family$variance(mu)))  ## weights
        if (lambda > 0) {
            X <- rbind(X, diag(c(0, rep(sqrt(ridge_lambda), p-1))))
            W <- c(W, rep(1, p))
            z <- c(z, rep(0, p))
        }
        beta <- lm.wfit(X, z, W)$coefficients  ## weighted least-squares
        mu <- family$linkinv(X %*% beta)          ## compute new mu
        it <- it+1                                ## update
    }
    beta
}
