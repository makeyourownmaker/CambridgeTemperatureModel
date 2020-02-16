
# Cambridge Weather History Inaccuracies
# https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html


# On 31st July 2008, the readings for humidity pressure and wind speed stuck at about 6pm BST. The logger was reset on 1st August at about 9:00am
weather.08.08.01 <- weather.raw[ds > '2008-08-01 00:00:00']
weather.08.08.01.cc <-  weather.08.08.01[complete.cases(weather.08.08.01)]

# Better not have -ve rainfall
weather.08.08.01.cc <-  weather.08.08.01.cc[rainfall >= 0]

# Low humidity problem from 2015-11-24 08:30:00 to 2015-11-27 13:00:00 - all 3 or less (very influential)
weather.08.08.01.cc <-  weather.08.08.01.cc[humidity >= 25] # 25 here is a bit arbitrary


# Exclude (individually)
weather.08.08.01.cc[sunny==1 & ds < sunrise]
weather.08.08.01.cc[sunny==1 & ds > sunset]


weather.08.08.01 <- weather.08.08.01[!(sunny==1 & ds < sunrise)]
weather.08.08.01 <- weather.08.08.01[!(sunny==1 & ds > sunset)]
dim(weather.08.08.01)


weather.08.08.01.cc <- weather.08.08.01.cc[, !c("rainfall", "sunshine")]


# TODO Find max UK and Cambridge recorded wind speeds?
#   Remove anything greater than 600
weather.08.08.01.cc <- weather.08.08.01.cc[wind.speed.max <= 600]
weather.08.08.01.cc <- weather.08.08.01.cc[wind.speed.mean <= 600]

# Unrealistic low temperature fix
weather.08.08.01.cc <- weather.08.08.01.cc[temperature != -400, ]

# Remove unusual wind bearings fix
weather.08.08.01.cc <- weather.08.08.01.cc[wind.bearing.mean %in% seq(0, 360, 45), ]

# Remove unusual secs values
weather.08.08.01.cc <- weather.08.08.01.cc[secs %in% seq(0, 86400, 1800), ]



# WARNING: Despite posted timestamps I exclude complete days below

# On 12th August 2008, rainfall was not recorded, despite heavy rain falling over Cambridge in the morning.
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2008-08-12', ]

# From 19th August 2008 to 27th August 2008 inclusive, rainfall was not recorded
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2008-08-19' | ds > '2008-08-27', ]

# From 3rd September 2008 to 4th September 2008 at about 1pm, rainfall was again not recorded due to a blocked sensor
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2008-09-03' & ds != '2008-09-04', ]

# From 25th October 2008 to 4th November 2008, rainfall was again not correctly recorded due to a partially blocked sensor. 
# Some rainfall was recorded, but the amounts recorded are far too small to be correct.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2008-10-25' | ds > '2008-11-04', ]

# On 3rd April 2009 the Sunshine and Humidity sensors became stuck. Readings for Temperature and Humidity until 17:30 are known to be wrong
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2009-04-03', ]

# The Sunshine sensor appears to have become a daylight sensor - the threshold for determining 'Sunny' has changed, possibly 
# from 3rd April when it was first noticed that it had become stuck.

# Over the Easter weekend of 10th April 2009 to 13th April 2009, the rainfall was not recorded (blocked sensor again). 
# It was unblocked on the Tuesday once we could gain access.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2009-04-10' | ds > '2009-04-13', ]

# Between 6th and 28th February, the rainfall sensor has not been recording any rainfall, due to water damage (!) to one of the cables.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2010-02-06' | ds > '2010-02-28', ]

# No results were recorded for 14th August 2010, and there was an interruption on 16th August 2010 due to a power failure
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2010-08-14', ]
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2010-08-16', ]

# A blocked rain sensor on 23rd August 2010 may have given high readings for rainfall on that day.
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2010-08-23', ]

# A blocked rain sensor on 26rd February 2011 gave extreme readings for rainfall on that day of >170mm. A few mm would be a more realistic amount.
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2011-02-26', ]

# A blocked rain sensor from 19th August 2011 to 23rd August 2011 gave gave extreme readings for rainfall whenever it rained. 
# It really isn't clear why a blocked sensor registers an excess of rainfall, rather than just none. Perhaps 10mm for 19th, 
# and 4mm up to 1pm on the 23rd would be a better estimate.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2011-08-19' | ds > '2011-08-23', ]

# The rain sensor failed completely on 6th September. We will endeavour to find a replacement as soon as possible.

# On 30 October 2011, the data logging system experienced a failure at 1:00 AM. No data was recorded until 11:28 AM on 31 October 2011. 
# We will investigate the issues that led to the interruption. A temporary fix was found for the rain sensor, but until replaced the 
# recorded precipitation data should not be trusted.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2011-10-30' | ds > '2011-10-31', ]

# On Tuesday 10 January 2012, no data has been recorded between 8:30 AM and 3:30 PM. This was due to a scheduled power outage in the 
# Computer Laboratory building, followed by some issues on cold-starting the weather logging system.
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2012-01-10', ]

# On 30 January 2012, a planned interruption occured between 4:30 PM and 6:30 PM. On this occasion, we have updated our logging software to 
# process data from the new precipitation sensor (Thies Clima). As a result of a data processing error, some precipitation readings later 
# that day and early morning on 31 January are negative. A fix is in place as of 31 Jan 2012, 4:30 PM.
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2012-01-30' | ds > '2012-01-31', ]

# On 20 August 2012, a cottonwood seed stuck in the sensor area (protective caps) and moved around by the wind caused erroneous precipitation readings before 2:26 PM.
weather.08.08.01.cc <- weather.08.08.01.cc[ds != '2012-08-20', ]

# On the 28th January 2015 around 11:00 AM, the humidity sensor connection became intermittant due to corrosion. 
# Humidity and Dew Point readings were unreliable and occasionally erratic until the issue was resolved on the 
# 2nd February 2015 at 6:00PM
weather.08.08.01.cc <- weather.08.08.01.cc[ds < '2015-01-28' | ds > '2015-02-02', ]


# See http://r-statistics.co/Outlier-Treatment-With-R.html
#mod <- lm(secs+doy+as.numeric(year) ~ temperature+humidity+dew.point+pressure+wind.speed.mean+wind.bearing.mean+wind.speed.max+rainy+sunny, data=weather.08.08.01.cc)
mod <- lm(secs+doy+as.numeric(year) ~ temperature+humidity+dew.point+pressure+wind.speed.mean+wind.bearing.mean+rainy+sunny, data=weather.08.08.01.cc)
summary(mod)

cooksd <- cooks.distance(mod)
plot(cooksd, main="Influential Obs by Cooks distance") # slow
text(x=1:length(cooksd)+1, y=cooksd, labels=ifelse(cooksd > 20*mean(cooksd, na.rm=T), names(cooksd), ""), col="red")  # add labels

# 10*mean(cooksd) is a bit arbitrary
# TODO Use more principled approach to outlier removal
abline(h = 10*mean(cooksd, na.rm=T), col="red")  # add cutoff line

table(cooksd > 10*mean(cooksd, na.rm=T))

influential <- as.numeric(names(cooksd)[(cooksd > 10*mean(cooksd, na.rm=T))])  # influential row numbers
head(weather.08.08.01.cc[influential, ])

summary(weather.08.08.01.cc[influential, .(temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean, wind.speed.max)])
summary(weather.08.08.01.cc[-influential, .(temperature, humidity, dew.point, pressure, wind.speed.mean, wind.bearing.mean, wind.speed.max)])

weather.08.08.01.cc <- weather.08.08.01.cc[-influential,]


saveRDS(weather.08.08.01.cc[, .(temperature, dew.point, humidity, pressure, wind.speed.mean, wind.bearing.mean, ds)], "data/CamMetCleanish.RData")
save.image("data/CambridgeTemperatureModel.RData")

