library(tidyverse); theme_set(theme_bw())
library(tidymodels)
library(spatialsample)
library(DALEX)
library(DALEXtra)
library(vip)
source("../code/utils.R")

housing <- (read_csv("../data/housing.csv")
    |> group_by(ocean_proximity)
    |> filter(n() >= 10)
    |> ungroup()
)

ggplot(housing, aes(longitude, latitude)) + geom_point(alpha = 0.5)

housing_sf <- sf::st_as_sf(
                      housing,
                      coords = c("longitude", "latitude"),
                      ## Set CRS to WGS84
                      crs = 4326
     )
plot(housing_sf)

folds <- spatial_block_cv(housing_sf, v = 10)
autoplot(folds)

## spatial split??
## how to handle geometry column?
data_split <- initial_split(housing, prop = 3/4)
train_data <- training(data_split)
testing_data <- testing(data_split)


b_recipe  <- (
    recipe(median_house_value ~ ., data = train_data)
    |> step_string2factor(all_nominal())
    |> step_dummy(all_nominal(), one_hot = TRUE)
    |> step_center(all_numeric())
    |> step_scale(all_numeric())
    |> step_nzv(all_numeric())
    |> prep()
)

boost_mod <- (
    boost_tree(mode = "regression",
               tree_depth = tune(),
               learn_rate = tune(),
               trees = tune())
    |> set_engine(engine = "xgboost")
)
print(boost_mod)
## Bayesian tuning?

## boost_wflow <-  (
##   workflow() 
##     |> add_model(boost_mod)
##     |> add_recipe(b_recipe)
## )

doParallel::registerDoParallel(cores = 12)

fn <- "boost_tune_grid.rds"
if (file.exists(fn)) {
    tt <- readRDS(fn)
} else {
    system.time(tt <-
                (boost_wflow
                    |> tune_grid(
                        grid = 200,
                        resamples = vfold_cv(train_data),
                        metrics   = metric_set(huber_loss),
                        control = control_grid(verbose = TRUE)
                    ))
            )
    saveRDS(tt, fn)
}
cc <- collect_metrics(tt)


show_best(tt)
ss <- select_best(tt)

bm <- finalize_model(boost_mod, select_best(tt))
bm_fit <- fit(bm, median_house_value ~ ., data = train_data)

vip(bm_fit)

explainer_boost <- 
  explain_tidymodels(
      bm_fit, 
      data = train_data,
      y = train_data$median_house_value
  )

set.seed(101)
predict_parts(explainer = explainer_boost, new_observation =
                                               train_data[120,],
              type = "shap",
              B = 20)

vip_boost <- model_parts(explainer_boost)
plot(vip_boost)

pdp_age <- model_profile(explainer_boost, N = 500,
                         variables = "median_income")

plot(pdp_age, geom = "profiles")
