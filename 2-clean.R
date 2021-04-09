
# Cambridge Weather History Inaccuracies
# https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html


# On 31st July 2008, the readings for humidity pressure and wind speed stuck at about 6pm BST. The logger was reset on 1st August at about 9:00am
weather.08.08.01 <- weather.raw[ds > '2008-08-01 00:00:00']
weather.08.08.01 <- data.table(weather.08.08.01)
weather.08.08.01 <- weather.08.08.01[, .(ds, temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean, wind.speed.max, secs)]
setkey(weather.08.08.01, ds)

setkey(isd.filled, time)

weather.cors <- weather.08.08.01[isd.filled, .(ds, temperature, temp, humidity, rh, dew.point, dew_point, wind.speed.mean, ws, wind.bearing.mean, wd)]

cor(weather.cors[complete.cases(weather.cors), .(temperature, temp*10)])
#             temperature        V2
# temperature   1.0000000 0.9746221
# V2            0.9746221 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(dew.point, dew_point*10)])
#           dew.point        V2
# dew.point 1.0000000 0.9081663
# V2        0.9081663 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(humidity, rh)])
#           humidity        rh
# humidity 1.0000000 0.8946381
# rh       0.8946381 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(wind.speed.mean/10, ws)])
#           V1        ws
#.V1 1.0000000 0.7884483
# ws 0.7884483 1.0000000
# Usable or not?
# What's the harm in using it and what's the harm in not using it?

cor(weather.cors[complete.cases(weather.cors), .(wind.bearing.mean, wd)])
#                   wind.bearing.mean        wd
# wind.bearing.mean         1.0000000 0.6770643
# wd                        0.6770643 1.0000000
# Usable or not?
# What's the harm in using it and what's the harm in not using it?


plot(density(weather.cors[complete.cases(weather.cors), temperature]), col='blue', ylim=c(0,0.006))
lines(density(weather.cors[complete.cases(weather.cors), temp*10]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(temperature, temp*10)])
# Restrict to -70 to 380
weather.08.08.01[temperature < -70, 'temperature'] <- NA
weather.08.08.01[temperature > 380, 'temperature'] <- NA
isd.filled[temp < -7, 'temp'] <- NA
isd.filled[temp > 38, 'temp'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), dew.point]), col='blue')
lines(density(weather.cors[complete.cases(weather.cors), dew_point*10]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(dew.point, dew_point*10)])
# Restrict to -100 to 210
weather.08.08.01[dew.point < -100, 'dew.point'] <- NA
weather.08.08.01[dew.point >  210, 'dew.point'] <- NA
isd.filled[dew_point < -10, 'dew_point'] <- NA
isd.filled[dew_point >  21, 'dew_point'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), humidity]), col='blue', ylim=c(0,0.035))
lines(density(weather.cors[complete.cases(weather.cors), rh]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(humidity, rh)])
# Restrict to 20 to 100
weather.08.08.01[humidity < 20,  'humidity'] <- NA
weather.08.08.01[humidity > 100, 'humidity'] <- NA
isd.filled[rh < 20,  'rh'] <- NA
isd.filled[rh > 100, 'rh'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), wind.speed.mean/10]), col='blue', ylim=c(0, 0.2))
lines(density(weather.cors[complete.cases(weather.cors), ws]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(wind.speed.mean/10, ws)])
# Restrict to 0 to 350
weather.08.08.01[wind.speed.mean < 0,   'wind.speed.mean'] <- NA
weather.08.08.01[wind.speed.mean > 350, 'wind.speed.mean'] <- NA
weather.08.08.01[wind.speed.max  < 0,   'wind.speed.max']  <- NA
weather.08.08.01[wind.speed.max  > 350, 'wind.speed.max']  <- NA
isd.filled[ws < 0,   'ws'] <- NA
isd.filled[ws > 350, 'ws'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), wind.bearing.mean]), col='blue')
lines(density(weather.cors[complete.cases(weather.cors), wd]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(wind.bearing.mean, wd)])

plot(density(weather.08.08.01[, pressure], na.rm = TRUE))
boxplot(weather.08.08.01[, pressure], na.rm = TRUE)
# Restrict to 950 to 1055
weather.08.08.01[pressure < 950,  'pressure'] <- NA
weather.08.08.01[pressure > 1055, 'pressure'] <- NA


# rainfall and sunny measurements are known to be very problematic
# Not using for now
# Better not have -ve rainfall
#weather.08.08.01 <-  weather.08.08.01[rainfall >= 0]

# Low humidity problem from 2015-11-24 08:30:00 to 2015-11-27 13:00:00 - all 3 or less (very influential)
#weather.08.08.01[humidity < 20, 'humidity'] <- NA # 20 here is a bit arbitrary but agrees with ISD Cam data

# Exclude (individually)
#weather.08.08.01[sunny==1 & ds < sunrise]
#weather.08.08.01[sunny==1 & ds > sunset]

#weather.08.08.01 <- weather.08.08.01[!(sunny==1 & ds < sunrise)]
#weather.08.08.01 <- weather.08.08.01[!(sunny==1 & ds > sunset)]
#dim(weather.08.08.01)

#weather.08.08.01 <- weather.08.08.01[, !c("rainfall", "sunshine")]

# Find max UK and Cambridge recorded wind speeds?
#   Remove anything greater than 350
#   Based on ISD Cam data and boxplot
#weather.08.08.01 <- weather.08.08.01[wind.speed.max <= 600]
#weather.08.08.01 <- weather.08.08.01[wind.speed.mean <= 600]
#weather.08.08.01[wind.speed.max >= 350, 'wind.speed.max'] <- NA
#weather.08.08.01[wind.speed.mean >= 350, 'wind.speed.mean'] <- NA

# Remove unusual wind bearings fix
# Don't remove - replace with NAs?!
#weather.08.08.01 <- weather.08.08.01[wind.bearing.mean %in% seq(0, 360, 45), 'wind.bearing.mean'] <- NA

# Unrealistic low temperature fix
#weather.08.08.01 <- weather.08.08.01[temperature != -400, ]


# Remove unusual secs values
weather.08.08.01 <- weather.08.08.01[secs %in% seq(0, 86400, 1800), ]



# On 12th August 2008, rainfall was not recorded, despite heavy rain falling over Cambridge in the morning.
#weather.08.08.01 <- weather.08.08.01[ds != '2008-08-12', ]

# From 19th August 2008 to 27th August 2008 inclusive, rainfall was not recorded
#weather.08.08.01 <- weather.08.08.01[ds < '2008-08-19' | ds > '2008-08-27', ]

# From 3rd September 2008 to 4th September 2008 at about 1pm, rainfall was again not recorded due to a blocked sensor
#weather.08.08.01 <- weather.08.08.01[ds != '2008-09-03' & ds != '2008-09-04', ]

# From 25th October 2008 to 4th November 2008, rainfall was again not correctly recorded due to a partially blocked sensor. 
# Some rainfall was recorded, but the amounts recorded are far too small to be correct.
#weather.08.08.01 <- weather.08.08.01[ds < '2008-10-25' | ds > '2008-11-04', ]

# On 3rd April 2009 the Sunshine and Humidity sensors became stuck. Readings for Temperature and Humidity until 17:30 are known to be wrong
weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'temperature'] <- NA
weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'humidity'] <- NA

# The Sunshine sensor appears to have become a daylight sensor - the threshold for determining 'Sunny' has changed, possibly 
# from 3rd April when it was first noticed that it had become stuck.

# Over the Easter weekend of 10th April 2009 to 13th April 2009, the rainfall was not recorded (blocked sensor again). 
# It was unblocked on the Tuesday once we could gain access.
#weather.08.08.01 <- weather.08.08.01[ds < '2009-04-10' | ds > '2009-04-13', ]

# Between 6th and 28th February, the rainfall sensor has not been recording any rainfall, due to water damage (!) to one of the cables.
#weather.08.08.01 <- weather.08.08.01[ds < '2010-02-06' | ds > '2010-02-28', ]

# No results were recorded for 14th August 2010, and there was an interruption on 16th August 2010 due to a power failure
weather.08.08.01[ds >= '2010-08-14 00:00' & ds < '2010-08-14 21:00', ]
# Insert missing NAs further below
weather.08.08.01[ds >= '2010-08-16 00:00' & ds < '2010-08-16 23:30', ]
# temperature may be stuck between 2010-08-16 00:30:00 and 2010-08-16 06:30:00
# otherwise looks OK - No changes

# A blocked rain sensor on 23rd August 2010 may have given high readings for rainfall on that day.
#weather.08.08.01 <- weather.08.08.01[ds != '2010-08-23', ]

# A blocked rain sensor on 26rd February 2011 gave extreme readings for rainfall on that day of >170mm. A few mm would be a more realistic amount.
#weather.08.08.01 <- weather.08.08.01[ds != '2011-02-26', ]

# A blocked rain sensor from 19th August 2011 to 23rd August 2011 gave gave extreme readings for rainfall whenever it rained. 
# It really isn't clear why a blocked sensor registers an excess of rainfall, rather than just none. Perhaps 10mm for 19th, 
# and 4mm up to 1pm on the 23rd would be a better estimate.
#weather.08.08.01 <- weather.08.08.01[ds < '2011-08-19' | ds > '2011-08-23', ]

# The rain sensor failed completely on 6th September. We will endeavour to find a replacement as soon as possible.

# On 30 October 2011, the data logging system experienced a failure at 1:00 AM. No data was recorded until 11:28 AM on 31 October 2011. 
# We will investigate the issues that led to the interruption. A temporary fix was found for the rain sensor, but until replaced the 
# recorded precipitation data should not be trusted.
weather.08.08.01[ds >= '2011-10-30 01:00' & ds < '2011-10-31 11:30', ]
# Insert missing NAs further below

# On Tuesday 10 January 2012, no data has been recorded between 8:30 AM and 3:30 PM. This was due to a scheduled power outage in the 
# Computer Laboratory building, followed by some issues on cold-starting the weather logging system.
weather.08.08.01[ds >= '2012-01-10 08:30' & ds < '2012-01-10 15:30', ]
# Insert missing NAs further below

# On 30 January 2012, a planned interruption occured between 4:30 PM and 6:30 PM. On this occasion, we have updated our logging software to 
# process data from the new precipitation sensor (Thies Clima). As a result of a data processing error, some precipitation readings later 
# that day and early morning on 31 January are negative. A fix is in place as of 31 Jan 2012, 4:30 PM.
#weather.08.08.01 <- weather.08.08.01[ds < '2012-01-30' | ds > '2012-01-31', ]
# 3 readings which look reasonable - no changes

# On 20 August 2012, a cottonwood seed stuck in the sensor area (protective caps) and moved around by the wind caused erroneous precipitation readings before 2:26 PM.
#weather.08.08.01 <- weather.08.08.01[ds != '2012-08-20', ]

# On the 28th January 2015 around 11:00 AM, the humidity sensor connection became intermittant due to corrosion. 
# Humidity and Dew Point readings were unreliable and occasionally erratic until the issue was resolved on the 
# 2nd February 2015 at 6:00PM
weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'humidity'] <- NA
weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'dew.point'] <- NA


# See http://r-statistics.co/Outlier-Treatment-With-R.html
weather.08.08.01[,year:=as.numeric(strftime(ds, format = "%Y"))]
weather.08.08.01[, doy:=as.numeric(strftime(ds, format = "%j"))]
mod <- lm(secs+doy+year ~ temperature+humidity+dew.point+pressure+wind.speed.mean+wind.bearing.mean, data=weather.08.08.01)
summary(mod)

cooksd <- cooks.distance(mod)
plot(cooksd, main="Influential Obs by Cooks distance") # slow
text(x=1:length(cooksd)+1, y=cooksd, labels=ifelse(cooksd > 20*mean(cooksd, na.rm=T), names(cooksd), ""), col="red")  # add labels

# TODO Use more principled approach to outlier removal - possibly seasonal
# TODO Repeat with lm() model and Cook's distance calculation with isd.filled data
# 10*mean(cooksd) is a bit arbitrary
abline(h = 10*mean(cooksd, na.rm=T), col="red")  # add cutoff line

table(cooksd > 10*mean(cooksd, na.rm=T))

influential <- as.numeric(names(cooksd)[(cooksd > 10*mean(cooksd, na.rm=T))])  # influential row numbers
head(weather.08.08.01[influential, ])
tail(weather.08.08.01[influential, ])

summary(weather.08.08.01[influential, .(temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean, wind.speed.max)])
summary(weather.08.08.01[-influential, .(temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean, wind.speed.max)])
# Influential points are mostly low temperature and low dew_point

weather.08.08.01 <- weather.08.08.01[-influential,]

weather.08.08.01$wind.speed.max <- NULL
weather.08.08.01$secs <- NULL
weather.08.08.01$year <- NULL
weather.08.08.01$doy <- NULL



# Remove long runs of consecutively equal values
# What threshold to use for number of consecutive values?
# So far (30/03/21) temperature has this problem
# and only once but for almost 36 days!
# And not marked in the known inaccuracies :-(
# TODO Establish better exclusion threshold values for weather.filled
get_consec_run_lengths <- function(data, column, n=6) {
  b <- rle(data[, ..column])
  weather.rle <- data.frame(number = b$values, lengths = b$lengths)
  weather.rle$end <- cumsum(weather.rle$lengths)
  weather.rle$start <- weather.rle$end - weather.rle$lengths + 1
  weather.rle[order(weather.rle$lengths), ]
  print(tail(weather.rle[order(weather.rle$lengths), ], n))
  flush.console()
  cat("\n")
  print(data[unlist(weather.rle[weather.rle$lengths==max(weather.rle$lengths), c('start', 'end')]), 'ds'])
  flush.console()
}

get_consec_run_lengths(weather.08.08.01, 'humidity')
get_consec_run_lengths(weather.08.08.01, 'dew.point')
get_consec_run_lengths(weather.08.08.01, 'pressure')
get_consec_run_lengths(weather.08.08.01, 'wind.speed.mean')
get_consec_run_lengths(weather.08.08.01, 'wind.bearing.mean')
get_consec_run_lengths(weather.08.08.01, 'temperature')
# [1] 2015-11-30 11:30:00 2016-01-08 15:00:00
weather.08.08.01 <- weather.08.08.01[ds < '2015-11-30 11:30:00' | ds > '2016-01-08 15:00:00', ]



# Check for measurement spikes
# Where spikes are sudden large increasing/decreasing observations
# followed by approximate return to previous value
# TODO Establish exclusion threshold values for weather.filled
get_large_spikes  <- function(data, col, ts, sd.factor=3) {
  diffs <- data[, .(get(ts), get(col), diff.before=get(col) - shift(get(col)), diff.after=get(col) - shift(get(col), type='lead'))]
  print(summary(diffs))
  flush.console()
  cat("\n")
  diff.before.sd <- sd.factor * sd(diffs$diff.before, na.rm=TRUE)
  diff.after.sd  <- sd.factor * sd(diffs$diff.after,  na.rm=TRUE)
  diffs[abs(diff.before) > diff.before.sd & abs(diff.after) > diff.after.sd,]
}
get_large_spikes(weather.filled, 'temperature', 'ds')
get_large_spikes(weather.filled, 'humidity',  'ds')
get_large_spikes(weather.filled, 'pressure',  'ds')
get_large_spikes(weather.filled, 'dew.point', 'ds')
get_large_spikes(weather.filled, 'wind.speed.mean', 'ds')

get_large_spikes(isd.filled, 'temp', 'time')
get_large_spikes(isd.filled, 'rh', 'time')
get_large_spikes(isd.filled, 'dew_point', 'time')
get_large_spikes(isd.filled, 'ws', 'time')


# Fill weather.isd NAs with isd.filled values
isd.renamed <- isd.filled[, .(ds=time, temperature=temp*10, humidity=rh, dew.point=dew_point, pressure=NA, wind.speed.mean=ws*10, wind.bearing.mean=wd)]
weather.isd <- merge(weather.08.08.01, isd.renamed, by='ds', all.x=TRUE, all.y=TRUE)
weather.filled <- weather.isd[, .(ds,
                                  temperature=ifelse(is.na(temperature.x) & !is.na(temperature.y), temperature.y, temperature.x),
                                  humidity=ifelse(is.na(humidity.x) & !is.na(humidity.y), humidity.y, humidity.x),
                                  pressure=pressure.x,
                                  dew.point=ifelse(is.na(dew.point.x) & !is.na(dew.point.y), dew.point.y, dew.point.x),
                                  wind.speed.mean=ifelse(is.na(wind.speed.mean.x) & !is.na(wind.speed.mean.y), wind.speed.mean.y, wind.speed.mean.x),
                                  wind.bearing.mean=ifelse(is.na(wind.bearing.mean.x) & !is.na(wind.bearing.mean.y), wind.bearing.mean.y, wind.bearing.mean.x))]
summary(weather.filled) # lot of pressure NAs :-(
summary(weather.filled[is.na(wind.speed.mean)])
summary(weather.filled[is.na(wind.bearing.mean)])
summary(weather.filled[is.na(temperature)])


# Use weather.isd to find weather.08.08.01 outliers
# Which data source is more correct though?
# Potentially exclude 1 or 2 thousand more measurements
# Consider using 4 or 5 * sd
# TODO Establish exclusion threshold values for weather.filled
sd.factor <- 5
temp.sd <- sd.factor * sd(weather.isd[, .(ds, temperature.x - temperature.y)][!is.na(V2), V2])
# [1] 42.93843
summary(weather.isd[, .(temperature.x - temperature.y)][!is.na(V1)])
weather.isd[, .(ds, temperature.x, temperature.y, temperature.x - temperature.y)][!is.na(V4) & abs(V4) > temp.sd, .(ds, V4, temperature.x, temperature.y)]

humidity.sd <- sd.factor * sd(weather.isd[, .(ds, humidity.x - humidity.y)][!is.na(V2), V2])
# [1] 23.66685
summary(weather.isd[, .(humidity.x - humidity.y)][!is.na(V1)])
weather.isd[, .(ds, humidity.x, humidity.y, humidity.x - humidity.y)][!is.na(V4) & abs(V4) > humidity.sd, .(ds, V4, humidity.x, humidity.y)]

sd.factor <- 4
dew.point.sd <- sd.factor * sd(weather.isd[, .(ds, dew.point.x - dew.point.y)][!is.na(V2), V2])
# [1] 139.5939
summary(weather.isd[, .(dew.point.x - dew.point.y)][!is.na(V1)])
weather.isd[, .(ds, dew.point.x, dew.point.y, dew.point.x - dew.point.y)][!is.na(V4) & abs(V4) > dew.point.sd, .(ds, V4, dew.point.x, dew.point.y)]

sd.factor <- 5
wind.speed.sd <- sd.factor * sd(weather.isd[, .(ds, wind.speed.mean.x - wind.speed.mean.y)][!is.na(V2), V2])
# [1] 72.53462
summary(weather.isd[, .(wind.speed.mean.x - wind.speed.mean.y)][!is.na(V1)])
weather.isd[, .(ds, wind.speed.mean.x, wind.speed.mean.y, wind.speed.mean.x - wind.speed.mean.y)][!is.na(V4) & abs(V4) > wind.speed.sd, .(ds, V4, wind.speed.mean.x, wind.speed.mean.y)]

wind.bearing.sd <- sd.factor * sd(weather.isd[, .(ds, wind.bearing.mean.x - wind.bearing.mean.y)][!is.na(V2), V2])
# [1] 207.7295
summary(weather.isd[, .(wind.bearing.mean.x - wind.bearing.mean.y)][!is.na(V1)])
weather.isd[, .(ds, wind.bearing.mean.x, wind.bearing.mean.y, wind.bearing.mean.x - wind.bearing.mean.y)][!is.na(V4) & abs(V4) > wind.bearing.sd, .(ds, V4, wind.bearing.mean.x, wind.bearing.mean.y)]


fnRDS <- paste0("data/CamMetCleanish", format(Sys.time(), "%Y.%m.%d"), ".RData")
fnCSV <- paste0("data/CamMetCleanish", format(Sys.time(), "%Y.%m.%d"), ".csv")
fnRData <- paste0("data/CambridgeTemperatureModel", format(Sys.time(), "%Y.%m.%d"), ".RData")
saveRDS(weather.filled[, .(temperature, dew.point, humidity, pressure, wind.speed.mean, wind.bearing.mean, ds)], fnRDS)
write.csv(weather.filled[, .(ds, y=temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean)], fnCSV, row.names=FALSE)
save.image(fnRData)

