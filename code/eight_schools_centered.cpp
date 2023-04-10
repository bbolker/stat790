// https://kaskr.github.io/adcomp/_book/Examples.html
#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_VECTOR(y);
  DATA_VECTOR(sigma);

  PARAMETER(mu);
  PARAMETER(logtau);
  PARAMETER_VECTOR(theta);

  Type nll = -sum(dnorm(y, theta, sigma, 1));
  nll -= sum(dnorm(theta, mu, exp(logtau), 1));

  return nll;

}
