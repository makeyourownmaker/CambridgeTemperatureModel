

library(data.table)

load('data/CambridgeTemperatureModel.RData')


################################################################################################################################
# Exploratory data analysis

ifelse(!dir.exists(file.path('figures')), dir.create(file.path('figures')), FALSE)

png('figures/temperature.time.series.01.png', units = 'in', width = 6, height = 4, res = 600)
plot(weather.08.08.01.cc[, .(date, temperature)], type='l', 
     main='Cambridge University Computer Laboratory\nWeather Station Temperature')
dev.off()


