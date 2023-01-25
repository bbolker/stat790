## is there a "simple but not dump" RR?
## what's good data set?
## use mtcars for now ... not great but at least fast

## https://www.r-bloggers.com/2020/05/simple-guide-to-ridge-regression-in-r/
## https://www.statology.org/principal-components-regression-in-r/

## fitting
library(glmnet)
library(pls)
library(caret)
library(recipes)

## manipulation
library(reshape2)
library(dplyr)
library(broom)

## data viz
library(ggplot2); theme_set(theme_bw())
library(directlabels)

## glmnet needs X matrix
## all vars in mtcars are numeric, not expanding bases, so
## as.matrix() will suffice (no need for model.matrix())

X <- as.matrix(subset(mtcars, select = -mpg))
p <- ncol(X)  ## not counting intercept

y <- mtcars$mpg
ridge1 <- glmnet(X, y, family = gaussian, alpha = 0,
             standardize = TRUE,  ## default
             intercept = TRUE     ## default
             )

## methods(class = "glmnet")

plot(ridge1)
legend("topleft", legend = rownames(coef(ridge1))[-1], lty = 1, col = 1:p)

## ¿how does the plot method for "glmnet" objects work?
## specifically, how do we get the L1 norm?

## 't' for 'tidy'
ridge1t <- (
    tidy(ridge1)
    |> filter(term != "(Intercept)")
    |> group_by(step)
    |> mutate(L1_norm = sum(abs(estimate)))
    |> ungroup() ## clean up
)

gg1 <- ggplot(ridge1t, aes(L1_norm, estimate)) +
    geom_line(aes(colour=term))
print(gg1)
## magic ...
direct.label(gg1, "last.bumpup")


## could use a for() loop, *or* purrr::map()
pcrfits <- lapply(1:p,
               pcr,
               scale = TRUE,
               formula = mpg ~ .,
               data = mtcars)

## what can we do with these objects?
(cc <- class(fits[[1]]))
methods(class = cc)

## pls:::coef.mvr

## in fact we don't have to do this - pcr() gives results for
##  all numbers of components <= p
pcr1 <- pcr(formula = mpg ~ .,
              scale = TRUE,
              data = mtcars,
              validation = "CV"  ## include cross-validation results
              ## was originally validate = TRUE, silently ignored (!)
              )

try(tidy(pcr1))  ## oops, someone should write one
## see https://github.com/tidymodels/broom/pull/758

## coef excludes intercept by default
## have to figure out every time which dimensions are which from sapply()
## results come back as COLUMNS
coefmat <- sapply(1:p, coef, object = pcr1)
matplot(t(coefmat), type = "b", lty = 1)

set_dimnames <- function(x, nm) { dimnames(x) <- nm; x }
## too clever!
## set_dimnames <- `dimnames<-`

term_names <- setdiff(names(mtcars), "mpg")
## or
##   colnames(model.matrix(mpg ~ ., mtcars))
pcr1t <- (coefmat
    |> set_dimnames(list(term = term_names, ncomp = 1:p))
    |> reshape2::melt(value.name = "estimate")
    |> group_by(ncomp)
    |> mutate(L1_norm = sum(abs(estimate)))
)

gg2 <- ggplot(pcr1t, aes(ncomp, estimate, col = term)) +
    geom_line()

## use L1_norm on x-axis instead
print(gg2 + aes(x=L1_norm))

ridge1_cv <- cv.glmnet(X, y, family = gaussian, alpha = 0,
             standardize = TRUE,  ## default
             intercept = TRUE     ## default
             )


plot(ridge1_cv)
stopifnot(all(ridge1$lambda == ridge1_cv$lambda))
ss_ridge <- ridge1t |> select(lambda, L1_norm) |> unique()
## n.b. ?tidy.cv.glmnet is misleading. 'estimate' is
##  the $cvm component, which (see ?cv.glmnet) is
##  the "mean cross-validated error" (see 'type.measure' in ?cv.glmnet),
##  MSE in this case
ridge1_cvt <- (tidy(ridge1_cv)
    |> left_join(ss_ridge, by = "lambda")
    |> filter(L1_norm > 1e-10)
    |> rename(mse = "estimate")
)

gg3 <- ggplot(ridge1_cvt, aes(L1_norm, mse)) +
    geom_point() +
    scale_x_log10()
## add CIs
gg3A <- gg3 + geom_linerange(aes(ymin = conf.low, ymax = conf.high))

print(gg3A)
## or use geom_line(), geom_ribbon() ?

## extract validation info from pcr fit?
## str(pcr1)
## names(pcr1)

ss_pcr <- pcr1t |> select(ncomp, L1_norm) |> unique()

pcr1_cvt <- (
    tibble(
        ncomp = 1:p,
        pcr1_n = nrow(mtcars) - lengths(pcr1$validation$segments),
        mse = drop(pcr1$validation$PRESS)/pcr1_n
    )
    |> left_join(ss_pcr, by  = "ncomp")
)

gg3 %+% pcr1_cvt
## compute MSE from PRESS statistic (divide by n)

## TO DO

## do PCR first, extract scores as predictors, compare ridge and PCR
## (== sequence of lm() with different numbers of components
## (and lasso on PCR?)

## compute effective df [@jansonEffective2015] for comparison

## also see supervised PC:
## https://stats.stackexchange.com/questions/108614/regression-in-pn-setting-how-to-choose-regularization-method-lasso-pls-pc

## Training via caret?
## https://github.com/topepo/caret/blob/master/RegressionTests/Code/pcr.R
## https://topepo.github.io/caret/model-training-and-tuning.html

### UNFINISHED/UNNECESSARY?

## problem: cv.glmnet only returns median loss
## cross-validation in `pls` package only returns PRESS statistic
##  (predicted residual SS)

rec_reg <- (recipe(mpg ~ ., data = mtcars)
    |> step_center(all_predictors())
    |> step_scale(all_predictors())
)

train_ind <- createDataPartition(mtcars$mpg,
                                 p = 0.8, ## training proportion
                                 list = FALSE ## simplify
                                 )

train <- mtcars[train_ind, ]
test <- mtcars[-train_ind, ]

fit_control <- trainControl(
    method = "cv",
    number = 5)

train(mpg ~ ., data = train,
      method = "pcr",
      trControl = fit_control)
