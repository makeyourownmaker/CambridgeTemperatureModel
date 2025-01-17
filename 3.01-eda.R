

library(data.table)
library(tseries)

load('data/CambridgeTemperatureModel.RData')


################################################################################################################################
# Exploratory data analysis - plot temperature time series

ifelse(!dir.exists(file.path('figures')), dir.create(file.path('figures')), FALSE)

png('figures/temperature.time.series.01.png', units = 'in', width = 6, height = 4, res = 600)
plot(weather.08.08.01.cc[, .(date, temperature)], type='l', 
     main='Cambridge University Computer Laboratory\nWeather Station Temperature')
dev.off()


################################################################################################################################
# Exploratory data analysis - stationarity tests

adf.test(weather.08.08.01.cc$temperature)
#
# 	Augmented Dickey-Fuller Test
#
# data:  weather.08.08.01.cc$temperature
# Dickey-Fuller = -14.602, Lag order = 57, p-value = 0.01
# alternative hypothesis: stationary

kpss.test(weather.08.08.01.cc$temperature)
#
#  	KPSS Test for Level Stationarity
#
# data:  weather.08.08.01.cc$temperature
# KPSS Level = 0.70143, Truncation lag parameter = 101, p-value = 0.01342


