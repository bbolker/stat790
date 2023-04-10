library(rstan)
options(mc.cores = parallel::detectCores() - 1)
rstan_options(auto_write = TRUE)

library(broom.mixed)
library(tidyverse)
library(shinystan)

mtsc <- as.data.frame(scale(mtcars))
X <- model.matrix(mpg ~ ., data = mtsc)
mod <- stan_model("linreg.stan", model_name = "linreg0")

methods(class = "stanmodel")
            
opt1 <- optimizing(mod, data = list(N = nrow(X), K = ncol(X),
                                    X = X, y = mtsc$mpg))

opt1$par
opt1$value

samp1 <- sampling(mod, data = list(N = nrow(X), K = ncol(X),
                                    X = X, y = mtcars$mpg))

opt1$par
opt1$value
m1 <- lm(mpg ~ ., data = mtsc)
coef(m1)
logLik(m1)



methods("optimizing","stanmodel-method")
getMethod("optimizing", "stanmodel")

## eight schools data, from https://greta-stats.org/articles/analyses/eight_schools.html
## (ultimately from Rubin 1981
N <- letters[1:8]
treatment_effects <- c(28.39, 7.94, -2.75 , 6.82, -0.64, 0.63, 18.01, 12.16)
treatment_stddevs <- c(14.9, 10.2, 16.3, 11.0, 9.4, 11.4, 10.4, 17.6)

mod_ecp <- stan_model("eight_schools_centered.stan", model_name = "ec0")

e_data <-list(J = 8,
              y = treatment_effects,
              sigma = treatment_stddevs)
samp2 <- sampling(mod_ecp, data = e_data,
                  iter=1200, warmup=500, chains=1, seed=483892929, refresh=1200)


print(samp2)

pairs(samp2, gap = 0, pars = c("tau", sprintf("theta[%d]", 1:5)), log = TRUE)

pfun <- function(s, var = "theta[1]", log = "y") {
    divergent <- get_sampler_params(s, inc_warmup = FALSE)[[1]][,'divergent__']
    dd <- as.data.frame(s)
    dd0 <- subset(dd, divergent == 0)
    dd1 <- subset(dd, divergent == 1)
    plot(dd0[[var]], dd0$tau, log = log)
    points(dd1[[var]], dd1$tau, pch = 16, col = 2)
}

pfun(samp2)
par(mfrow = c(2,4))
for (i in 1:8) {
    pfun(samp2, var = sprintf("theta[%d]", i))
}

mod_encp <- stan_model("eight_schools_noncentered.stan", model_name = "ec1")

library(TMB)

treatment_effects <- c(28.39, 7.94, -2.75 , 6.82, -0.64, 0.63, 18.01, 12.16)
treatment_stddevs <- c(14.9, 10.2, 16.3, 11.0, 9.4, 11.4, 10.4, 17.6)
e_data <-list(J = 8,
              y = treatment_effects,
              sigma = treatment_stddevs)


compile("eight_schools_centered.cpp")
dyn.load(dynlib("eight_schools_centered"))
obj <- MakeADFun(data = e_data[-1],
                 parameters = list(mu = 0,
                                   logtau = 0,
                                   theta = rep(0, 8)),
                 random = "theta",
                 DLL="eight_schools_centered")


do.call(optim, obj)

library(glmmTMB)
g1 <- glmmTMB(y ~ 1 + (1|site),
        dispformula = ~ 0 + offset(2*log(sigma)),
        data = with(e_data, data.frame(y, sigma, site = factor(1:8))))
