## read.table("http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data",
## 	sep=",",head=T,row.names=1)

library(mgcv)
library(effects)
library(gratia)

url <- "http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data"
fn <- "SAheart.txt"
if (!file.exists(fn)) download.file(url, destfile = fn)
dd <- read.csv(fn, row.names = 1)
exclude_vars <- c("chd", "famhist")
numvars <- setdiff(names(dd), exclude_vars)
library(splines)
spline_terms <- sprintf("ns(%s, df = 4)", numvars)
ff <- reformulate(c("famhist", spline_terms), response = "chd")
full_model <- glm(ff, family = binomial, data = dd)
reduced_model <- MASS::stepAIC(full_model, direction = "backward")
as.formula(model.frame(reduced_model))
plot(allEffects(full_model))
## includes tobacco, ldl, typea, obesity, age

s_terms <- sprintf("s(%s)", numvars)
ff2 <- reformulate(c("famhist", s_terms), response = "chd")
full_model2 <- gam(ff2, family = binomial, data = dd)
par(mfrow=c(2,4))
plot(full_model2)
gratia::draw(full_model2)

b_terms <- sprintf("s(%s, bs = 'bs')", numvars)
op <- par(mfrow= c(2,4))
ff_b <- reformulate(c("famhist", b_terms), response = "chd")
full_modelb <- update(full_model2, ff_b)
gratia::draw(full_modelb)

t_model <- gam(chd ~ te(obesity, age), family = binomial, data = dd)
gratia::draw(t_model)
plot(t_model, scheme = 2)
plot(t_model, scheme = 1)

t_model2 <- gam(chd ~ te(obesity, age, ldl), family = binomial, data = dd)


## 
url <- "http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data"
fn <- "SAheart.txt"
if (!file.exists(fn)) download.file(url, destfile = fn)
dd <- read.csv(fn, row.names = 1)
library(splines)
m <- glm(chd ~ bs(tobacco, df = 9, intercept = FALSE), family = binomial, data = dd)

###
m1 <- glm(chd ~ splines::bs(tobacco, 5), data = dd, family = binomial())
head(predict(m1, type = "response"))
head(splines::bs(dd$tobacco, 5))
