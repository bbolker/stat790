dd$log_London <- log10(dd$London)
ww <- analyze.wavelet(dd[-1,], "log_London",
                loess.span = 0,
                dt = 1/52,
                dj = 1/100,
                lowerPeriod = 0.1,
                upperPeriod = 10)
par(las=1, bty = "l")
wt.image(ww, show.date = TRUE)
reconstruct(ww)


