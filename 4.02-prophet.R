

load("data/CambridgeTemperatureModel.RData")
library(data.table)
library(lubridate)
library(prophet)

weather.proph <- weather.08.08.01.cc[, .(ds=as.POSIXct(timestamp, tz="GMT"), y=temperature)]

date() # approx 7 mins
m.proph <- prophet(weather.proph, daily.seasonality=TRUE, weekly.seasonality=FALSE, yearly.seasonality=TRUE)
date()

# All of these take approx 15 mins! WTF?
#future.proph <- make_future_dataframe(m, periods = 365)                   # 1 year
#future.proph <- make_future_dataframe(m.proph, periods = 1, freq = "day") # 1 day
future.proph <- make_future_dataframe(m.proph, periods = 1, freq = 3600)   # 1 hour
#future.proph <- make_future_dataframe(m.proph, periods = 1, freq = 1)     # 1 sec

date() # approx 15 mins
forecast.proph <- predict(m.proph, future.proph)
date()

pro.mod.comps <- prophet_plot_components(m.proph, forecast.proph)
#dev.off()


ifelse(!dir.exists(file.path("figures")), dir.create(file.path("figures")), FALSE)

png("figures/prophet.yearly.component.01.png", units = "in", width = 4, height = 3, res = 600)
pro.mod.comps[2]
dev.off()

png("figures/prophet.daily.component.01.png", units = "in", width = 4, height = 3, res = 600)
pro.mod.comps[3]
dev.off()


