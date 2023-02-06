## read.table("http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data",
## 	sep=",",head=T,row.names=1)

url <- "http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/SAheart.data"
dd <- read.csv(url, row.names = 1)
exclude_vars <- c("chd", "famhist")
numvars <- setdiff(names(dd), exclude_vars)
library(splines)
spline_terms <- sprintf("ns(%s, df = 4)", numvars)
ff <- reformulate(c("famhist", spline_terms), response = "chd")
full_model <- glm(ff, family = binomial, data = dd)
reduced_model <- MASS::stepAIC(full_model, direction = "backward")
as.formula(model.frame(reduced_model))
## includes tobacco, ldl, typea, obesity, age
