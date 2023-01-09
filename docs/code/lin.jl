import Pkg;
pkgs = 
## Pkg.add("CSV")
## Pkg.add("GLM")
pkgs = ["CSV", "DataFrames", "GLM", "RData", "CategoricalArrays"]
for p in pkgs; Pkg.add(p); end
## or Pkg.add(pkgs)
## using CSV, DataFrames, GLM, RData;
for s in [Symbol(p) for p in pkgs]; @eval using $s; end
dd = CSV.File("flights.csv", missingstring = "NA") |> DataFrame
fm = @formula(dep_delay ~ month);
m1 = lm(fm, dd);

dd[!,:month_cat] = categorical(dd[!,:month]);
m2 = lm(@formula(dep_delay ~ month_cat), dd)