library(plgp)
library(mvtnorm)
par(las = 1, bty = "l") ## cosmetic
n <- 100
## being careful about matrix shape
X <- matrix(seq(0, 10, length=n), ncol=1)

D <- distance(X)  ## actually L2^2
eps <- sqrt(.Machine$double.eps)
Sigma <- exp(-D) + diag(eps, n)

set.seed(101)
Y <- mvtnorm::rmvnorm(1, sigma = Sigma)

plot(X, Y, type = "l")

## scale of correlation ~ 1

nsim <- 100
Ym <- rmvnorm(nsim, sigma=Sigma)
matplot(X, t(Ym), type="l", ylab="Y", col = 1, lty = 1)

sc <- 1
len <- 1
n <- 8
X <- matrix(seq(0, 2*pi, length=n), ncol=1)
y <- sin(X)
D <- distance(X/len) 
Sigma <- sc*(exp(-D) + diag(eps, ncol(D)))

ns <- 100
margin <- 5
XX <- matrix(seq(-margin, 2*pi + margin, length=ns), ncol=1)
DXX <- distance(XX)
SXX <- exp(-DXX) + diag(eps, ns)


## test vs train
DX <- distance(XX, X)
SX <- exp(-DX)

## brute force!

Si <- solve(Sigma)
mup <- SX %*% Si %*% y
Sigmap <- SXX - SX %*% Si %*% t(SX)


YY <- rmvnorm(100, mup, Sigmap)
q1 <- mup + qnorm(0.05, 0, sqrt(diag(Sigmap)))
q2 <- mup + qnorm(0.95, 0, sqrt(diag(Sigmap)))


matplot(XX, t(YY), type="l", col="gray", lty=1, xlab="x", ylab="y")
points(X, y, pch=20, cex=2)
lines(XX, sin(XX), col="blue")
lines(XX, mup, lwd=2)
matlines(XX, cbind(q1, q2), lwd=2, lty=2, col=2)


## replicating figure

## data (eyeballed)

sos::findFn("{gaussian process}")

matern_fun <- function(d, nu) {
    if (nu == 0.5) return(exp(-d))
    if (nu == 1.5) return((1+sqrt(3)*d)*exp(-sqrt(3)*d))
    if (nu == 2.5) return((1+sqrt(5)*d + 5/3*d^2)*exp(-sqrt(5)*d))
    2^(1-nu)/gamma(nu)*(sqrt(2*nu)*d)^nu*besselK(sqrt(2*nu)*d, nu)
}

kern <- function(x, x2 = x, lsc, sigma_f, sigma_y, type = "rbf",
                 nu = NULL) {
    eps <- sqrt(.Machine$double.eps)
    n <- length(x)
    d <- sqrt(distance(x, x2))/lsc
    r <- switch(type,
                rbf = exp(-d^2/2),
                matern = matern_fun(d, nu)
                )
    ## matern limit might be bad
    if (nrow(r) == ncol(r) && any(is.na(diag(r)))) diag(r) <- 1
    r <- sigma_f^2*r
    if (sigma_y>0) r <- r + diag(sigma_y^2 + eps, n)
    r
}

my_gp <- function(x, y, x2, lsc, sigma_f, sigma_y, alpha = 0.9,
                  nu = 0.5,
                  ktype = "rbf") {
    K <-  kern(x, x, lsc, sigma_f, sigma_y, type = ktype, nu = nu)
    KX <-  kern(x2, x,  lsc, sigma_f, 0, type = ktype, nu = nu)
    KXX <- kern(x2, x2, lsc, sigma_f, 0, type = ktype, nu = nu)
    Ki <-  solve(K)
    ## 
    mup <- drop(KX %*% Ki %*% y)
    Sigmap <- KXX - KX %*% Ki %*% t(KX)
    sdp <- sqrt(diag(Sigmap))
    data.frame(mu = mup,
               lwr = qnorm((1-alpha)/2, mean = mup, sd = sdp),
               upr = qnorm((1+alpha)/2, mean = mup, sd = sdp))
}


dd <- data.frame(x = -3:3,
                 y = c(-0.1, -0.4, -1.25, 0.6, 1.3, 1.4, 0.2))
x2 <- seq(-5, 5, length = 201)

pfun <- function(lsc = 1, sigma_y = 1, sigma_f = 0, alpha = 0.95,
                 ylim = NULL, ktype = "rbf", nu = 0.5) {
    d1 <- my_gp(dd$x, dd$y, x2 = x2, lsc = lsc,
                sigma_y = sigma_y, sigma_f = sigma_f,
                alpha = alpha, ktype = ktype, nu = nu)
    if (is.null(ylim)) ylim <- c(min(d1$lwr), max(d1$upr))
    main <- sprintf("lsc = %1.1f, sigma_f = %1.1f, sigma_y = %1.1f",
                    lsc, sigma_f, sigma_y)
    if (ktype == "matern") {
        main <- paste0(main, sprintf("\n(nu = %1.1f)", nu))
    }
    plot(x2, d1$mu, type = "l", ylim = ylim,
         main = main,
         xlab = "", ylab = "")
    points(dd$x, dd$y, col = "red", pch = 4, cex = 1.5)
    polygon(c(x2, rev(x2)),  c(d1$lwr, rev(d1$upr)),
            col = adjustcolor("blue", alpha.f = 0.1),
            border = NA)
}    


png("gauss_proc2.png", width = 400, height = 600)
par(mfrow = c(3, 2), las = 1, mar = c(2,3,2,2))
yl <- c(-2.5, 2.5)
pfun(lsc = 0.3, sigma_f = 1,   sigma_y = 0.2, ylim = yl)
pfun(lsc = 3,   sigma_f = 1,   sigma_y = 0.2, ylim = yl)
pfun(lsc = 1,   sigma_f = 0.3, sigma_y = 0.2, ylim = yl)
pfun(lsc = 1,   sigma_f = 3,   sigma_y = 0.2, ylim = yl)
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 0.05, ylim = yl)
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 1.5, ylim = yl)
dev.off()

png("gauss_proc3.png", width = 400, height = 400)
par(mfrow = c(2, 2), las = 1, mar = c(2,3,2.5,2))
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 0.2, ylim = yl)
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 0.2,
     ktype = "matern", nu = 2.5, ylim = yl)
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 0.2,
     ktype = "matern", nu = 1.5, ylim = yl)
pfun(lsc = 1,   sigma_f = 1,   sigma_y = 0.2,
     ktype = "matern", nu = 0.5, ylim = yl)
dev.off()


kern(1:3, 1:3, lsc = 1, sigma_f = 1, sigma_y = 0, type = "matern", nu = 1.5)

## converges to RBF OK
kern(1:3, 1:3, lsc = 1, sigma_f = 1, sigma_y = 0, type = "matern", nu = 50)
kern(1:3, 1:3, lsc = 1, sigma_f = 1, sigma_y = 0)

