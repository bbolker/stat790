// https://kaskr.github.io/adcomp/_book/Examples.html
// eight schools example, conditioning on first element (theta(0))

#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_VECTOR(y);
  DATA_VECTOR(sigma);

  PARAMETER(mu);
  PARAMETER(logtau);
  PARAMETER_VECTOR(theta);
  PARAMETER(theta0);

  Type nll = 0;

  nll -= dnorm(y(0), theta0, sigma(0), 1);
  nll -= dnorm(theta(0), mu, exp(logtau), 1);
  for (int i = 1; i < y.size(); i++) {
    nll -= dnorm(y(i), theta(i), sigma(i), 1);
    nll -= dnorm(theta(i), mu, exp(logtau), 1);
  }

  return nll;

}
