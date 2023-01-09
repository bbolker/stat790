## aside: finding and evaluating R packages

library("sos")
library("KernSmooth")
library("caret")

findFn("Nadaraya-Watson")

## judging R packages

### active development: Github or other devel site? issues? date of last release?)
### maturity: first release?
### popularity
### code/documentation quality
##    https://www.ericrscott.com/post/2021-10-27-assessing-the-reliability-of-an-r-package/
##    https://rfortherestofus.com/2020/07/how-to-evaluate-r-packages/


data("USArrests")
plot(Assault ~ UrbanPop, data = USArrests)
m1 <- lm(Assault ~ UrbanPop, data = USArrests)
abline(m1)
with(USArrests,
     lines(ksmooth(UrbanPop, Assault, kernel = "normal", bandwidth = 5, n.points = 1000), col = 2)
     )
knn1 <- knnreg(Assault ~ UrbanPop, data = USArrests, k = 1)
usa <- USArrests
usa$knnpred <- predict(knn1, USArrests)
## construct x-vector of nearest values?

library(ggplot2)
(ggplot(usa)
    + aes(x = UrbanPop, y = Assault)
    + geom_point()
    + geom_smooth(method = "lm")
    + geom_step(aes(y = knnpred)) ## so-so
)

#####

library(nycflights13)
m1 <- lm(dep_delay ~ factor(month), flights)
summary(m1)

library(sjPlot)
plot_model(m1, "pred")
write.csv(flights, file = "flights.csv") ## for Julia input
saveRDS(flights, file = "flights.rds")


remotes::install_github("sfirke/packagemetrics")
library("packagemetrics")
package_list_metrics("lme4")


