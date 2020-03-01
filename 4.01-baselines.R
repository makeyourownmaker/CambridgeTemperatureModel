
# NOTE: Most of these baselines are from the forecast package

library(ggplot)
library(forecast)

mae  <- function(obs, pred) mean(abs(obs - pred), na.rm=TRUE)
rmse <- function(obs, pred) sqrt(mean((obs - pred)^2, na.rm=TRUE))
mape <- function(obs, pred) mean(abs((obs - pred) / (obs + 1)) * 100, na.rm=TRUE)

weather.bl <- weather.08.08.01.cc[, .(ds=as.POSIXct(timestamp, tz="GMT"), y=temperature)]

cv.weather.data <- function(weather.data, forecastfunc, horizon=1, t=20000) {
  x <- ts(weather.data[1:t])
  e <- tsCV(x, forecastfunc, h=horizon)

  if ( horizon == 1 ) {
    rmse.vals <- sqrt(mean(e^2, na.rm=TRUE))
    mae.vals  <- mean(abs(e), na.rm=TRUE)
    mape.vals <- mape(x, x + e)
  } else if ( horizon > 1 ) {
    rmse.vals <- sqrt(colMeans(e^2, na.rm = T))
    mae.vals  <- colMeans(abs(e), na.rm = T)
    mape.vals <- colMeans(abs(e * 100 / matrix(rep(weather.data + 1, horizon), ncol=horizon)), na.rm=TRUE)
  } else {
    stop("Bad horizon value!\nShould be 1 or greater but less than time series length.\n")
  }

  return(list(rmse=rmse.vals, mae=mae.vals, mape=mape.vals, errors=e))
}



################################################################################################################################
# One step ahead accuracy

# Mean temperature - full data set
mean.temp <- mean(weather.bl$y, na.rm=TRUE)
rmse(weather.bl$y, mean.temp)
# [1] 64.46543
mae(weather.bl$y, mean.temp)
# [1] 52.62924
mape(weather.bl$y, mean.temp)
# [1] 249.9146

# Persistent temperature - full data set
weather.bl[, yshift:=shift(y)]
rmse(weather.bl$y, weather.bl$yshift)
# [1] 6.265516
mae(weather.bl$y, weather.bl$yshift)
# [1] 4.128627
mape(weather.bl$y, weather.bl$yshift)
# [1] 9.493788


# approx 44 secs
# Mean temperature - smaller data set
system.time( meanf.t.20000.h.1 <- cv.weather.data(weather.bl$y, meanf))
meanf.t.20000.h.1[1:3]
# [1] 61.47279
# [1] 49.36652
# [1] 245.4268

# approx 4 mins
# Persistent temperature - smaller data set
system.time( naive.t.20000.h.1 <- cv.weather.data(weather.bl$y, naive))
naive.t.20000.h.1[1:3]
# [1] 6.052059
# [1] 4.031153
# [1] 9.811477
# Very similar to ses & thetaf on this data

# approx 15 mins :-(
system.time( ses.t.20000.h.1 <- cv.weather.data(weather.bl$y, ses))
ses.t.20000.h.1[1:3]
# [1] 6.052966
# [1] 4.031792
# [1] 9.811932
# Very similar to naive & thetaf on this data

# approx 1 hour 2 mins :-(
system.time( holt.t.20000.h.1 <- cv.weather.data(weather.bl$y, holt))
holt.t.20000.h.1[1:3]
# [1] 5.617949
# [1] 3.93713
# [1] 10.24852

# approx 15 mins :-(
system.time( thetaf.t.20000.h.1 <- cv.weather.data(weather.bl$y, thetaf))
thetaf.t.20000.h.1[1:3]
# [1] 6.053951
# [1] 4.035425
# [1] 9.828778
# Very similar to ses & naive on this data



################################################################################################################################
# Daily accuracy

# approx 5 mins
system.time( e.meanf.t.20000.h.48 <- cv.weather.data(weather.bl$y, meanf, h=48))

# approx 10 mins
system.time( e.naive.t.20000.h.48 <- cv.weather.data(weather.bl$y, naive, h=48))

# approx 19 mins :-(
system.time( e.ses.t.20000.h.48 <- cv.weather.data(weather.bl$y, ses, h=48))

# approx 64 mins :-(
system.time( e.holt.t.20000.h.48 <- cv.weather.data(weather.bl$y, holt, h=48))

# approx 21 mins :-(
system.time( e.thetaf.t.20000.h.48 <- cv.weather.data(weather.bl$y, thetaf, h=48))


rmse.t.20000.h.48 <- rbind(data.frame(horizon = 1:48, method = 'meanf',  rmse = e.meanf.t.20000.h.48[1]),
                           data.frame(horizon = 1:48, method = 'naive',  rmse = e.naive.t.20000.h.48[1]),
                           data.frame(horizon = 1:48, method = 'ses',    rmse = e.ses.t.20000.h.48[1]),
                           data.frame(horizon = 1:48, method = 'holt',   rmse = e.holt.t.20000.h.48[1]))

ifelse(!dir.exists(file.path("figures")), dir.create(file.path("figures")), FALSE)

png("figures/baseline.daily.accuracy.01.png", units = "in", width = 6, height = 4, res = 600)
rmse.t.20000.h.48 %>%
  ggplot(aes(x = horizon, y = rmse)) + geom_line(aes(color = method)) + ggtitle("Baseline daily forecast accuracy")
dev.off()


