
library(forecast)

mae  <- function(obs, pred) mean(abs(obs - pred), na.rm=TRUE)
rmse <- function(obs, pred) sqrt(mean((obs - pred)^2, na.rm=TRUE))
mape <- function(obs, pred) mean(abs((obs - pred) / (obs + 1)) * 100, na.rm=TRUE)


# Mean temperature
mean.temp <- mean(weather.proph$y, na.rm=TRUE)
rmse(weather.proph$y, mean.temp)
# [1] 64.46543
mae(weather.proph$y, mean.temp)
# [1] 52.62924
mape(weather.proph$y, mean.temp)
# [1] 249.9146


# Persistent temperature
weather.proph[, yshift:=shift(y)]
rmse(weather.proph$y, weather.proph$yshift)
# [1] 6.265516
mae(weather.proph$y, weather.proph$yshift)
# [1] 4.128627
mape(weather.proph$y, weather.proph$yshift)
# [1] 9.493788



# Bit more than 1st year of data
weather.proph.small <- head(weather.proph$y, 20000)

# approx 15 mins :-(
system.time( e.ses <- tsCV(weather.proph.small, ses, h=1) )
sqrt(mean(e.ses^2, na.rm=TRUE))
# [1] 6.052966
mean(abs(e.ses), na.rm=TRUE)
# [1] 4.031792
mape(weather.proph.small, weather.proph.small + e.ses)
# [1] 9.811932


# approx 1 hour 2 mins :-(
system.time( e.holt <- tsCV(weather.proph.small, holt, h=1) )
sqrt(mean(e.holt^2, na.rm=TRUE))
# [1] 5.617949
mean(abs(e.holt), na.rm=TRUE)
# [1] 3.93713
mape(weather.proph.small, weather.proph.small + e.holt)
# [1] 10.24852




