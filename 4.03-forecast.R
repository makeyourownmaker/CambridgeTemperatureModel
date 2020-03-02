

load("data/CambridgeTemperatureModel.RData")

library(forecast)


################################################################################################################################
# Build tbats model

# Does not remove anything!
#weather.raw.cleaner <- tsclean(weather.raw$temperature)

# Does not detect any seasonality!
#mstl(weather.proph$y) %>% autoplot()

# Create daily and yearly multi-seasonal time series
x <- msts(weather.08.08.01.cc$temperature, seasonal.periods=c(48, 17532))

# approx 12 mins
system.time(tbats.x <- tbats(x, use.box.cox=FALSE, use.trend=FALSE, use.damped.trend=FALSE))

tbats.x
tbats.x$parameters
plot(tbats.x)
accuracy(tbats.x)
#                         ME     RMSE      MAE MPE MAPE      MASE       ACF1
# Training set -0.0004292643 5.672798 3.855186 NaN  Inf 0.9337696 0.01368714


################################################################################################################################
# Cross-validate tbats model

# tsCV without use.parallel=FALSE and num.cores=1 caused my laptop to run out of memory!

# approx 24 mins :-(
#system.time(e.tbats <- tsCV(x, tbats, h=1, window=1000, initial=90000,
#                            use.box.cox=FALSE, use.trend=FALSE, use.damped.trend=FALSE,
#                            use.parallel=FALSE, num.cores=1))
# Error in NextMethod("[<-") : replacement has length zero

# Same error on linux and mac
# Same error with different R versions
# See https://stackoverflow.com/questions/45999524/for-loop-using-tscv-error-in-nextmethod-replacement-has-length-zero
# So, no test set results :-(


