

library(data.table)
library(lubridate)
library(prophet)

load("data/CambridgeTemperatureModel.RData")

mae  <- function(obs, pred) mean(abs(obs - pred), na.rm=TRUE)
rmse <- function(obs, pred) sqrt(mean((obs - pred)^2, na.rm=TRUE))
mape <- function(obs, pred) mean(abs((obs - pred) / (obs + 1)) * 100, na.rm=TRUE)

################################################################################################################################
# Build logistic model

weather.proph <- weather.08.08.01.cc[, .(ds=as.POSIXct(timestamp, tz="GMT"), y=temperature)]
weather.proph$cap <- 400
weather.proph$floor <- -150

# approx 10 mins
# The yearly.seasonality=2 is deliberate
# It specifies the number of Fourier terms to use
system.time( m.proph.log <- prophet(weather.proph,
                                    growth='logistic',
                                    daily.seasonality=TRUE,
                                    weekly.seasonality=FALSE,
                                    yearly.seasonality=2))


################################################################################################################################
# Plot seasonal components of the logistic model

# All of these take approx 15 mins!
#future.proph.log <- make_future_dataframe(m.proph.log.cp.50, periods = 365)       # 1 year
#future.proph.log <- make_future_dataframe(m.proph.log, periods = 1, freq = "day") # 1 day
future.proph.log <- make_future_dataframe(m.proph.log, periods = 1, freq = 3600)   # 1 hour
#future.proph.log <- make_future_dataframe(m.proph.log, periods = 1, freq = 1)     # 1 sec
future.proph.log$cap <- 400
future.proph.log$floor <- -150

# approx 15 mins
system.time( forecast.proph.log <- predict(m.proph.log, future.proph.log) )

pro.mod.comps <- prophet_plot_components(m.proph.log, forecast.proph.log)


ifelse(!dir.exists(file.path("figures")), dir.create(file.path("figures")), FALSE)

png("figures/prophet.yearly.component.01.png", units = "in", width = 6, height = 4, res = 600)
pro.mod.comps[2]
dev.off()

png("figures/prophet.daily.component.01.png", units = "in", width = 6, height = 4, res = 600)
pro.mod.comps[3]
dev.off()


################################################################################################################################
# Cross-validate the logistic model

# approx 2 hours
system.time( cv.proph.log <- cross_validation(m.proph.log,
                                              horizon=1,
                                              period=1000,
                                              units='hours',
                                              initial=90000) )
cv.proph.log
performance_metrics(cv.proph.log)

rmse(cv.proph$y, cv.proph$yhat)
mae(cv.proph$y, cv.proph$yhat)
mape(cv.proph$y, cv.proph$yhat)

rmse(cv.proph.log$y, cv.proph.log$yhat)
# [1] 28.82351
mae(cv.proph.log$y, cv.proph.log$yhat)
# [1] 25.88272
mape(cv.proph.log$y, cv.proph.log$yhat)
# [1] 50.2522


################################################################################################################################
# Build and cross-validate a logistic model with more changepoints

# n.changepoints=50
# based on recommendation from https://towardsdatascience.com/implementing-facebook-prophet-efficiently-c241305405a3
# approx 50 mins :-(
system.time( m.proph.log.cp.50 <- prophet(weather.proph,
                                          growth='logistic',
                                          n.changepoints=50,
                                          daily.seasonality=TRUE,
                                          weekly.seasonality=FALSE,
                                          yearly.seasonality=2))


# approx 10 hours :-(
system.time( cv.proph.log.cp.50 <- cross_validation(m.proph.log.cp.50,
                                                    horizon=1,
                                                    period=1000,
                                                    units='hours',
                                                    initial=90000))
cv.proph.log.cp.50
performance_metrics(cv.proph.log.cp.50)

rmse(cv.proph.log.cp.50$y, cv.proph.log.cp.50$yhat)
# [1] 28.65922
mae(cv.proph.log.cp.50$y, cv.proph.log.cp.50$yhat)
# [1] 25.80077
mape(cv.proph.log.cp.50$y, cv.proph.log.cp.50$yhat)
# [1] 50.13084
# Marginally better than the logistic model :-(
# Not worth the extra compute time


################################################################################################################################
# Build logistic growth and multiplicative seasonality model and cross-validate it

# approx 7 mins
system.time( m.proph.log.mult <- prophet(weather.proph,
                                         growth='logistic',
                                         seasonality.mode='multiplicative',
                                         daily.seasonality=TRUE,
                                         weekly.seasonality=FALSE,
                                         yearly.seasonality=2))

# approx 1 hour 42 mins :-(
system.time( cv.proph.log.mult <- cross_validation(m.proph.log.mult,
                                                   horizon=1,
                                                   period=1000,
                                                   units='hours',
                                                   initial=90000) )
cv.proph.log.mult
performance_metrics(cv.proph.log.mult)

rmse(cv.proph.log.mult$y, cv.proph.log.mult$yhat)
# [1] 41.55893
mae(cv.proph.log.mult$y, cv.proph.log.mult$yhat)
# [1] 38.37446
mape(cv.proph.log.mult$y, cv.proph.log.mult$yhat)
# [1] 81.1511
# Worse than additive seasonality model

