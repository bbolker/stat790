## utility sequence function
sfun <- function(x, log = FALSE, n = 61) {
    if (log) x <- log(x)
    s <- seq(min(x), max(x), length.out = n)
    if (log) exp(s) else s
}

ggpairs_hex <- function(df, hexbins = 10) {
    require(hexbin)
  # REF: https://stackoverflow.com/questions/20872133/using-stat-binhex-with-ggpairs
  p <- ggpairs(df, lower="blank")
  seq <- 1:ncol(df)
  for (x in seq)
    for (y in seq) 
      if (y>x) 
        p <- putPlot(p, ggplot(df, aes_string(x=names(df)[x],y=names(df)[y])) + stat_binhex(bins = hexbins), y,x)
  
  return(p)
}
