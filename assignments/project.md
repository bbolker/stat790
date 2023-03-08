## project

A project for a first data science class would typically use off-the-shelf implementations of one or more machine/statistical learning methods to analyze some set of data. For this project, I want you to go beyond using off-the-shelf methods to (possibly) start creating your own 'bespoke' methods. You have a variety of options:

### implement an existing machine/statistical learning method from scratch

This should be something more complex than "I implemented ridge regression by augmenting the modle matrix"; for example, if you were going to reimplement lasso your implementation should probably fit the whole pathway (series of penalization parameters) by warm starts, etc..

### do a detailed comparison of several implementations of a particular M/SL method

In this case, you would take a bunch of implementations that should be of the *same* method, ideally across multiple languages. Do they actually give identical (up to floating-point accuracy) answers on a series of test problems? How do their memory and time usage compare for a series of benchmark problems? Describe how/whether their function arguments and default values differ.

### extend a M/SL method

For example:

* implement jackknife+ methods for computing prediction intervals; incorporate them into an existing modeling pipeline
* create a 'dependence-aware' version of some method that relies on resampled ensembles: e.g., implement random forest but with the bootstrap sampling at each split done as spatially blocked/stratified bootstrap
* For a prediction problem with many categories, invent an algorithm for merging categories (based on rarity, similarity to other categories based on other predictors, etc.); ideally this algorithm should have a *continuous* tuning/complexity parameter. Implement it and try it out; compare it e.g. with using group lasso.
* take a method that currently allows only least-squares loss functions and extend it to allow either Huber loss or GLM deviances
