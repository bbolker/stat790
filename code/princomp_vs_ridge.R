## is there a "simple but not dump" RR?
## good data set?
## use mtcars for now ...

## https://www.r-bloggers.com/2020/05/simple-guide-to-ridge-regression-in-r/
## https://www.statology.org/principal-components-regression-in-r/
library(glmnet)
library(broom)
library(dplyr)
library(pls)
library(ggplot2); theme_set(theme_bw())

## glmnet needs X matrix
## all vars in mtcars are numeric, not expanding bases, so
## as.matrix() will suffice (no need for model.matrix())

X <- as.matrix(subset(mtcars, select = -mpg))
y <- mtcars$mpg
m1 <- glmnet(X, y, family = gaussian, alpha = 0,
             standardize = TRUE  ## default
             )
plot(m1)

m1t <-(tidy(m1)
    |> filter(term != "(Intercept)")
    |> group_by(step)
    |> mutate(L1_norm = sum(abs(estimate)))
)

ggplot(m1t, aes(L1_norm, estimate)) +
    geom_line(aes(colour=term))

## ¿how does the plot method for "glmnet" objects work?

## could use a for() loop, *or* purrr::map()
p <- ncol(mtcars)-1
fits <- lapply(1:p,
               pcr,
               scale = TRUE,
               formula = mpg ~ .,
               data = mtcars)

## what can we do with these objects?
(cc <- class(fits[[1]]))
methods(class = cc)

## pls:::coef.mvr

pcrfit <- pcr(formula = mpg ~ .,
              scale = TRUE,
              data = mtcars,
              validate = TRUE)

## coef excludes intercept by default
## have to figure out every time which dimensions are which from sapply()
## results come back as COLUMNS
coefmat <- sapply(1:p, coef, object = pcrfit)
matplot(t(coefmat), type = "b")

## too clever!
set_dimnames <- `dimnames<-`
term_names <- setdiff(names(mtcars), "mpg")
## or
##   colnames(model.matrix(mpg ~ ., mtcars))
(coefmat
    |> set_dimnames(list(ncomp = 1:p, term = term_names))
    |> reshape2::melt()
)
## TO DO
