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

n <- 8
X <- matrix(seq(0, 2*pi, length=n), ncol=1)
y <- sin(X)
D <- distance(X) 
Sigma <- exp(-D) + diag(eps, ncol(D))

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

