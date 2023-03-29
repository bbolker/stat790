## utility sequence function
sfun <- function(x, log = FALSE, n = 61) {
    if (log) x <- log(x)
    s <- seq(min(x), max(x), length.out = n)
    if (log) exp(s) else s
}

ggally_hexbin <- function (data, mapping, ...)  {
    p <- ggplot(data = data, mapping = mapping) + geom_hex(...)
    p
}
