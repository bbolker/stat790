import Pkg;
## Pkg.add("CSV")
## Pkg.add("GLM")
using CSV, DataFrames, GLM;
dd = CSV.File("flights.csv", missingstring = "NA") |> DataFrame
fm = @formula(dep_delay ~ month);
m1 = lm(fm, dd);
