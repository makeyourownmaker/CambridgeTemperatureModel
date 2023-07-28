
######################################################################################################################################################
# 1. Remove known historical inaccuracies
#    https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html


# On 31st July 2008, the readings for humidity pressure and wind speed stuck
# at about 6pm BST. The logger was reset on 1st August at about 9:00am
weather.08.08.01 <- weather.raw[ds > '2008-08-01 00:00:00']
weather.08.08.01 <- data.table(weather.08.08.01)
weather.08.08.01 <- weather.08.08.01[, .(ds,
                                         temperature,
                                         humidity,
                                         dew.point,
                                         pressure,
                                         wind.speed.mean,
                                         wind.bearing.mean,
                                         wind.speed.max,
                                         rainfall,
                                         sunshine,
                                         secs)]
setkey(weather.08.08.01, ds)
summary(weather.08.08.01)

# Add missing observations to weather.08.08.01 as NAs
min.ds <- min(weather.08.08.01$ds)
max.ds <- max(weather.08.08.01$ds)
all.time.stamps <- seq(min.ds, max.ds, by='30 mins')
weather.08.08.01 <- merge(weather.08.08.01, data.table(ds=all.time.stamps), by='ds', all=TRUE, roll=NA)
weather.08.08.01[,  HMS:=strftime(ds, format = "%H:%M:%S")]
weather.08.08.01[, secs:=as.numeric(as.difftime(HMS))]
weather.08.08.01$HMS <- NULL
summary(weather.08.08.01)

weather.08.08.01$missing <- 0
weather.08.08.01$known_inaccuracy <- 0

# rainfall and sunny measurements are known to be very problematic
# Not using for now
# Better not have -ve rainfall
#weather.08.08.01 <-  weather.08.08.01[rainfall >= 0]

# Low humidity problem from 2015-11-24 08:30:00 to 2015-11-27 13:00:00
# all 3 or less (very influential)
# 20 here is a bit arbitrary but agrees with ISD Cam data
#weather.08.08.01[humidity < 20, 'humidity'] <- NA

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

# On 12th August 2008, rainfall was not recorded, despite heavy rain falling over
# Cambridge in the morning.
#weather.08.08.01 <- weather.08.08.01[ds != '2008-08-12', ]

# From 19th August 2008 to 27th August 2008 inclusive, rainfall was not recorded
#weather.08.08.01 <- weather.08.08.01[ds < '2008-08-19' | ds > '2008-08-27', ]

# From 3rd September 2008 to 4th September 2008 at about 1pm, rainfall was again not
# recorded due to a blocked sensor
#weather.08.08.01 <- weather.08.08.01[ds != '2008-09-03' & ds != '2008-09-04', ]

# From 25th October 2008 to 4th November 2008, rainfall was again not correctly recorded
# due to a partially blocked sensor.
# Some rainfall was recorded, but the amounts recorded are far too small to be correct.
#weather.08.08.01 <- weather.08.08.01[ds < '2008-10-25' | ds > '2008-11-04', ]

# On 3rd April 2009 the Sunshine and Humidity sensors became stuck. Readings for Temperature
# and Humidity until 17:30 are known to be wrong
weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'temperature'] <- NA
weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'humidity'] <- NA

weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'known_inaccuracy'] <- 1
weather.08.08.01[ds >= '2009-04-03 00:00' & ds < '2009-04-03 17:30', 'known_inaccuracy'] <- 1

# The Sunshine sensor appears to have become a daylight sensor - the threshold for
# determining 'Sunny' has changed, possibly from 3rd April when it was first noticed
# that it had become stuck.

# Over the Easter weekend of 10th April 2009 to 13th April 2009, the rainfall was not
# recorded (blocked sensor again).
# It was unblocked on the Tuesday once we could gain access.
#weather.08.08.01 <- weather.08.08.01[ds < '2009-04-10' | ds > '2009-04-13', ]

# Between 6th and 28th February, the rainfall sensor has not been recording any rainfall,
# due to water damage (!) to one of the cables.
#weather.08.08.01 <- weather.08.08.01[ds < '2010-02-06' | ds > '2010-02-28', ]

# No results were recorded for 14th August 2010, and there was an interruption on 16th
# August 2010 due to a power failure
weather.08.08.01[ds >= '2010-08-14 00:00' & ds < '2010-08-14 21:00', ]
# Insert missing NAs further below
weather.08.08.01[ds >= '2010-08-16 00:00' & ds < '2010-08-16 23:30', ]
# temperature may be stuck between 2010-08-16 00:30:00 and 2010-08-16 06:30:00
# otherwise looks OK - No changes

# A blocked rain sensor on 23rd August 2010 may have given high readings for rainfall on
# that day.
#weather.08.08.01 <- weather.08.08.01[ds != '2010-08-23', ]

# A blocked rain sensor on 26rd February 2011 gave extreme readings for rainfall on that
# day of >170mm. A few mm would be a more realistic amount.
#weather.08.08.01 <- weather.08.08.01[ds != '2011-02-26', ]

# A blocked rain sensor from 19th August 2011 to 23rd August 2011 gave gave extreme readings
# for rainfall whenever it rained.
# It really isn't clear why a blocked sensor registers an excess of rainfall, rather than
# just none. Perhaps 10mm for 19th,
# and 4mm up to 1pm on the 23rd would be a better estimate.
#weather.08.08.01 <- weather.08.08.01[ds < '2011-08-19' | ds > '2011-08-23', ]

# The rain sensor failed completely on 6th September. We will endeavour to find a
# replacement as soon as possible.

# On 30 October 2011, the data logging system experienced a failure at 1:00 AM. No data was
# recorded until 11:28 AM on 31 October 2011.
# We will investigate the issues that led to the interruption. A temporary fix was found for
# the rain sensor, but until replaced the
# recorded precipitation data should not be trusted.
weather.08.08.01[ds >= '2011-10-30 01:00' & ds < '2011-10-31 11:30', ]
# Insert missing NAs further below

# On Tuesday 10 January 2012, no data has been recorded between 8:30 AM and 3:30 PM. This
# was due to a scheduled power outage in the Computer Laboratory building, followed by some
# issues on cold-starting the weather logging system.
weather.08.08.01[ds >= '2012-01-10 08:30' & ds < '2012-01-10 15:30', ]
# Insert missing NAs further below

# On 30 January 2012, a planned interruption occured between 4:30 PM and 6:30 PM. On this
# occasion, we have updated our logging software to process data from the new precipitation
# sensor (Thies Clima). As a result of a data processing error, some precipitation readings
# later that day and early morning on 31 January are negative. A fix is in place as of 31
# Jan 2012, 4:30 PM.
#weather.08.08.01 <- weather.08.08.01[ds < '2012-01-30' | ds > '2012-01-31', ]
# 3 readings which look reasonable - no changes

# On 20 August 2012, a cottonwood seed stuck in the sensor area (protective caps) and moved
# around by the wind caused erroneous precipitation readings before 2:26 PM.
#weather.08.08.01 <- weather.08.08.01[ds != '2012-08-20', ]

# On the 28th January 2015 around 11:00 AM, the humidity sensor connection became
# intermittant due to corrosion.
# Humidity and Dew Point readings were unreliable and occasionally erratic until
# the issue was resolved on the 2nd February 2015 at 6:00PM
weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'humidity'] <- NA
weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'dew.point'] <- NA

weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'known_inaccuracy'] <- 1
weather.08.08.01[ds >= '2015-01-28 11:00' & ds < '2015-02-02 18:00', 'known_inaccuracy'] <- 1


######################################################################################################################################################
# 2. Compare Computer Lab and Cambridge Airport (ISD) measurements
#    Calculate correlations and plot observation distributions
#    Remove obvious outliers from both data sets
#    Annecdotally, Cambridge Airport appears to be higher quality data source


setkey(isd.filled, time)
setkey(weather.08.08.01, ds)

weather.08.08.01$isd_outlier <- 0

weather.cors <- weather.08.08.01[isd.filled, .(ds,
                                               temperature,
                                               temp,
                                               humidity,
                                               rh,
                                               dew.point,
                                               dew_point,
                                               wind.speed.mean,
                                               wind.speed.max,
                                               ws,
                                               wind.bearing.mean,
                                               wd,
                                               rainfall,
                                               sunshine,
                                               ceil_hgt,
                                               visibility)]

cor(weather.cors[complete.cases(weather.cors), .(temperature, temp*10)])
#             temperature        V2
# temperature   1.0000000 0.9745562
# V2            0.9745562 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(dew.point, dew_point*10)])
#           dew.point        V2
# dew.point 1.0000000 0.9117574
# V2        0.9117574 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(humidity, rh)])
#           humidity        rh
# humidity 1.0000000 0.8962506
# rh       0.8962506 1.0000000

cor(weather.cors[complete.cases(weather.cors), .(wind.speed.mean/10, ws)])
#           V1        ws
# V1 1.0000000 0.7881784
# ws 0.7881784 1.0000000
# Usable or not?
# What's the harm in using it and what's the harm in not using it?

cor(weather.cors[complete.cases(weather.cors), .(wind.speed.max/10, ws)])

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
weather.08.08.01[temperature < -70, 'isd_outlier'] <- 1
weather.08.08.01[temperature > 380, 'isd_outlier'] <- 1
weather.08.08.01[temperature < -70, 'temperature'] <- NA
weather.08.08.01[temperature > 380, 'temperature'] <- NA
isd.filled[temp < -7, 'temp'] <- NA
isd.filled[temp > 38, 'temp'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), dew.point]), col='blue')
lines(density(weather.cors[complete.cases(weather.cors), dew_point*10]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(dew.point, dew_point*10)])
# Restrict to -100 to 210
weather.08.08.01[dew.point < -100, 'isd_outlier'] <- 1
weather.08.08.01[dew.point >  210, 'isd_outlier'] <- 1
weather.08.08.01[dew.point < -100, 'dew.point'] <- NA
weather.08.08.01[dew.point >  210, 'dew.point'] <- NA
isd.filled[dew_point < -10, 'dew_point'] <- NA
isd.filled[dew_point >  21, 'dew_point'] <- NA

plot(density(weather.cors[complete.cases(weather.cors), humidity]), col='blue', ylim=c(0,0.035))
lines(density(weather.cors[complete.cases(weather.cors), rh]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(humidity, rh)])
# Restrict to 20 to 100
weather.08.08.01[humidity < 20,  'isd_outlier'] <- 1
weather.08.08.01[humidity > 100, 'isd_outlier'] <- 1
weather.08.08.01[humidity < 20,  'humidity'] <- NA
weather.08.08.01[humidity > 100, 'humidity'] <- NA
isd.filled[rh < 20,  'rh'] <- NA
isd.filled[rh > 100, 'rh'] <- NA
# NOTE Setting these NAs to 20 or 100 is not necessarily the right thing to do

plot(density(weather.cors[complete.cases(weather.cors), wind.speed.mean/10]), col='blue', ylim=c(0, 0.2))
lines(density(weather.cors[complete.cases(weather.cors), ws]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(wind.speed.mean/10, ws)])

plot(density(weather.cors[complete.cases(weather.cors), wind.speed.max/10]), col='blue', ylim=c(0, 0.2))
lines(density(weather.cors[complete.cases(weather.cors), ws]), col='green')
boxplot(weather.cors[complete.cases(weather.cors), .(wind.speed.max/10, ws)])

# Restrict to 0 to 350
weather.08.08.01[wind.speed.mean < 0,   'isd_outlier'] <- 1
weather.08.08.01[wind.speed.mean > 350, 'isd_outlier'] <- 1
weather.08.08.01[wind.speed.max  < 0,   'isd_outlier'] <- 1
weather.08.08.01[wind.speed.max  > 350, 'isd_outlier'] <- 1
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
weather.08.08.01[pressure < 950,  'isd_outlier'] <- 1
weather.08.08.01[pressure > 1055, 'isd_outlier'] <- 1
weather.08.08.01[pressure < 950,  'pressure'] <- NA
weather.08.08.01[pressure > 1055, 'pressure'] <- NA
# NOTE Setting these NAs to 950 or 1055 is not necessarily the right thing to do


######################################################################################################################################################
# 3. Remove long runs of consecutively equal values
#    TODO Generalise to find anomolously low (but non-zero) variance observations over varying window sizes

weather.08.08.01$long_run <- 0

get_consec_run_lengths <- function(df, varcol, tscol, sd.factor=3) {
  b <- rle(df[, get(varcol)])
  lengths.sd <- sd(b$lengths) * sd.factor
  cat(paste("sd threshold: ", round(lengths.sd, 2), "\n\n"))
  flush.console()

  weather.rle <- data.table(value = b$values, runlength = b$lengths)
  print(summary(weather.rle))
  cat("\n")
  flush.console()

  weather.rle$end   <- cumsum(weather.rle$runlength)
  weather.rle$start <- weather.rle$end - weather.rle$runlength + 1
  weather.rle$starttime <- df[weather.rle$start, get(tscol)]
  weather.rle$endtime   <- df[weather.rle$end, get(tscol)]
  print(weather.rle[runlength > lengths.sd,][order(runlength), .(value, runlength, start, end, starttime, endtime)])
  cat("\n")
  flush.console()

  x <- weather.rle[runlength > lengths.sd,][order(runlength), .(end, start)]

  return(sapply(1:nrow(x), function(i, x) { seq(x[i]$start, x[i]$end) }, x=x))
}

# Only removing the most extreme outliers
isd.temp.consecs <- get_consec_run_lengths(isd.filled, 'temp', 'time', 5) # No action
isd.rh.consecs   <- get_consec_run_lengths(isd.filled, 'rh',   'time', 5) # No action
isd.ws.consecs   <- get_consec_run_lengths(isd.filled, 'ws',   'time', 5) # No action
isd.wd.consecs   <- get_consec_run_lengths(isd.filled, 'wd',   'time', 5) # No action
isd.dp.consecs   <- get_consec_run_lengths(isd.filled, 'dew_point', 'time', 5) # No action

weather.dp.consecs <- get_consec_run_lengths(weather.08.08.01, 'dew.point', 'ds', 5) # No action
weather.pr.consecs <- get_consec_run_lengths(weather.08.08.01, 'pressure',  'ds', 5) # No action
weather.ws.consecs <- get_consec_run_lengths(weather.08.08.01, 'wind.speed.mean', 'ds', 5) # No action
weather.ws.consecs <- get_consec_run_lengths(weather.08.08.01, 'wind.speed.max',  'ds', 5) # No action

weather.wd.consecs <- get_consec_run_lengths(weather.08.08.01, 'wind.bearing.mean', 'ds', 12)
weather.08.08.01[unlist(weather.wd.consecs), 'long_run'] <- 1
weather.08.08.01[unlist(weather.wd.consecs), 'wind.bearing.mean'] <- NA

weather.rh.consecs <- get_consec_run_lengths(weather.08.08.01, 'humidity',  'ds', 50)
# max run lengths occur in winter months, all have max 100 value, none since 2015
weather.08.08.01[unlist(weather.rh.consecs), 'long_run'] <- 1
weather.08.08.01[unlist(weather.rh.consecs), 'humidity'] <- NA

weather.temp.consecs <- get_consec_run_lengths(weather.08.08.01, 'temperature', 'ds', 6)
# So far (30/03/21) the worst offender here is temperature which was
# stuck at the same value for 36 days!
# And not marked in the known inaccuracies :-(
# 2015-11-30 11:30:00 2016-01-08 15:00:00
weather.08.08.01[ds > '2015-11-30 11:30:00' & ds < '2016-01-08 15:00:00', 'long_run'] <- 1
weather.08.08.01[ds > '2015-11-30 11:30:00' & ds < '2016-01-08 15:00:00', 'temperature'] <- NA


######################################################################################################################################################
# 4. Check for measurement "spikes"
#    Where spikes are sudden large increasing/decreasing observations
#    followed by approximate return to previous value
#    So far, spikes are limited to lengths of 1 observation

weather.08.08.01$spike <- 0

get_large_spikes  <- function(df, varcol, tscol, sd.factor=3) {
  df$row.no <- 1:nrow(df)
  diffs <- df[, .(time=get(tscol),
                  row.no,
                  value=get(varcol),
                  diff.before=get(varcol) - shift(get(varcol)),
                  diff.after=get(varcol) - shift(get(varcol), type='lead'))]
  print(summary(diffs[, .(value, diff.before, diff.after)]))
  cat("\n")
  flush.console()

  diff.before.sd <- sd.factor * sd(diffs$diff.before, na.rm=TRUE)
  diff.after.sd  <- sd.factor * sd(diffs$diff.after,  na.rm=TRUE)
  cat(paste("sd before threshold: ", round(diff.before.sd, 2), "\n"))
  cat(paste("sd after threshold:  ", round(diff.after.sd,  2), "\n\n"))
  flush.console()

  print(diffs[abs(diff.before) > diff.before.sd &
              abs(diff.after)  > diff.after.sd  &
              ((diff.before > 0 & diff.after > 0) |
               (diff.before < 0 & diff.after < 0)),])
  flush.console()

  return(diffs[abs(diff.before) > diff.before.sd &
               abs(diff.after)  > diff.after.sd  &
               ((diff.before > 0 & diff.after > 0) |
                (diff.before < 0 & diff.after < 0)), row.no])
}

weather.temp.spikes <- get_large_spikes(weather.08.08.01, 'temperature', 'ds', 5)
weather.rh.spikes   <- get_large_spikes(weather.08.08.01, 'humidity',    'ds', 5)
# 30 sporadic humidity spikes from 2015-11-29 20:00:00 to 2016-01-08 15:00:00
# The inaccuracies.html file lists an earlier humidity sensor problem (low measurements)
weather.pres.spikes <- get_large_spikes(weather.08.08.01, 'pressure',    'ds', 5)
weather.dp.spikes   <- get_large_spikes(weather.08.08.01, 'dew.point',   'ds', 5)
weather.ws.spikes   <- get_large_spikes(weather.08.08.01, 'wind.speed.mean', 'ds', 5)
weather.ws.spikes   <- get_large_spikes(weather.08.08.01, 'wind.speed.max',  'ds', 5)
weather.08.08.01[weather.temp.spikes, 'spike'] <- 1
weather.08.08.01[weather.rh.spikes,   'spike'] <- 1
weather.08.08.01[weather.pres.spikes, 'spike'] <- 1
weather.08.08.01[weather.dp.spikes,   'spike'] <- 1
weather.08.08.01[weather.ws.spikes,   'spike'] <- 1
weather.08.08.01[weather.temp.spikes, 'temperature']     <- NA
weather.08.08.01[weather.rh.spikes,   'humidity']        <- NA
weather.08.08.01[weather.pres.spikes, 'pressure']        <- NA
weather.08.08.01[weather.dp.spikes,   'dew.point']       <- NA
weather.08.08.01[weather.ws.spikes,   'wind.speed.mean'] <- NA
weather.08.08.01[weather.ws.spikes,   'wind.speed.max']  <- NA

isd.temp.spikes <- get_large_spikes(isd.filled, 'temp', 'time', 5)
isd.rh.spikes   <- get_large_spikes(isd.filled, 'rh',   'time', 3) # No action
isd.dp.spikes   <- get_large_spikes(isd.filled, 'dew_point', 'time', 5)
isd.ws.spikes   <- get_large_spikes(isd.filled, 'ws', 'time', 5)
isd.filled[isd.temp.spikes, 'temp'] <- NA
isd.filled[isd.dp.spikes,   'dp'] <- NA
isd.filled[isd.ws.spikes,   'ws'] <- NA


######################################################################################################################################################
# 5. Remove Computer Lab and Airport outliers using Cook's distance
#    See http://r-statistics.co/Outlier-Treatment-With-R.html
#    TODO Use more principled approach to outlier removal
#         Possibly seasonal - bin cooksd values into days 48 * 12 = 576 big bins :-)
#                             calculate 99th or higher centile
#                             build loess model

weather.08.08.01$cooksd_out <- 0

get_cooks_dist_outliers <- function(df, tscol, formula, cd.factor=3) {
  df[, year:=as.numeric(strftime(get(tscol), format = "%Y"))]
  df[,  doy:=as.numeric(strftime(get(tscol), format = "%j"))]
  df[,  HMS:=strftime(get(tscol), format = "%H:%M:%S")]
  df[, secs:=as.numeric(as.difftime(HMS))]

  mod <- lm(formula, df)
  print(summary(mod))

  cooksd <- cooks.distance(mod)
  cat("Cook's distance:\n")
  print(summary(cooksd))

  plot(cooksd, main="Influential Obs by Cooks distance") # slow
  text(x=1:length(cooksd)+1,
       y=cooksd,
       labels=ifelse(cooksd > 2*cd.factor**mean(cooksd, na.rm=T), names(cooksd), ""),
       col="red")  # add labels
  abline(h = cd.factor*mean(cooksd, na.rm=T), col="red")  # add cutoff line

  cat("\nInfluential:")
  print(table(cooksd > cd.factor*mean(cooksd, na.rm=T)))

  influential <- as.numeric(names(cooksd)[(cooksd > cd.factor*mean(cooksd, na.rm=T))])  # influential row numbers

  df$secs <- NULL
  df$year <- NULL
  df$HMS <- NULL
  df$doy <- NULL

  cat("\nOnly influential:\n")
  print(summary(df[ influential, ]))
  cat("\nNo influential:\n")
  print(summary(df[-influential, ]))

  return(influential)
}

weather.form <- 'secs+doy+year ~ temperature+humidity+dew.point+pressure+wind.speed.mean+wind.bearing.mean+wind.speed.max'
weather.cooksd.influential <- get_cooks_dist_outliers(weather.08.08.01, 'ds', weather.form, 15)
weather.08.08.01[weather.cooksd.influential, 'cooksd_out'] <- 1
weather.08.08.01[weather.cooksd.influential, c('temperature', 'humidity', 'dew.point', 'pressure', 'wind.speed.mean', 'wind.bearing.mean', 'wind.speed.max')] <- NA

isd.filled[, time:=as.POSIXct(time, tz="GMT")]
isd.form <- 'secs+doy+year ~ temp+rh+dew_point+ws+wd'
isd.cooksd.influential <- get_cooks_dist_outliers(isd.filled, 'time', isd.form, 15)
isd.filled[isd.cooksd.influential, c('temp', 'wd', 'ws', 'dew_point', 'rh')] <- NA


######################################################################################################################################################
# 6. Use Cambridge Airport (weather.isd) to find Computer Lab (weather.08.08.01) outliers
#    Potentially exclude 1 or 2 thousand more measurements


isd.renamed <- isd.filled[, .(ds=time,
                              temperature=temp*10,
                              humidity=rh,
                              dew.point=dew_point,
                              pressure=NA,
                              wind.speed.mean=ws*10,
                              wind.bearing.mean=wd,
                              wind.speed.max=ws*10,
                              ceil_hgt=ceil_hgt,
                              visibility=visibility)]
weather.isd <- merge(weather.08.08.01, isd.renamed, by='ds', all.x=TRUE, all.y=TRUE)
weather.isd$isd_3_sigma <- 0

get_cl_outliers_using_isd <- function(df, varcol, tscol, sd.factor=3) {
  varcol.x <- paste0(varcol, '.x')
  varcol.y <- paste0(varcol, '.y')
  varcol.sd <- sd.factor * sd(df[, .(get(varcol.x) - get(varcol.y))][!is.na(V1), V1], na.rm=TRUE)
  cat(paste("sd threshold: ", round(varcol.sd, 2), "\n\n"))
  flush.console()

  print(summary(df[, .(diff=get(varcol.x) - get(varcol.y))][!is.na(diff)]))
  cat("\n")
  flush.console()

  df$row.no <- as.numeric(rownames(df))
  print(df[, .(get(tscol),
               get(varcol.x),
               get(varcol.y),
               get(varcol.x) - get(varcol.y),
               row.no)][!is.na(V4) & abs(V4) > varcol.sd, .(row.no,
                                                            time=V1,
                                                            varcol.x=V2,
                                                            varcol.y=V3,
                                                            diff=V4)])
  flush.console()

  return(df[, .(get(varcol.x) - get(varcol.y),
                row.no)][!is.na(V1) & abs(V1) > varcol.sd, row.no])
}

cl.isd.temp.outliers <- get_cl_outliers_using_isd(weather.isd, 'temperature',     'ds', 5)
cl.isd.rh.outliers   <- get_cl_outliers_using_isd(weather.isd, 'humidity',        'ds', 5)
cl.isd.dp.outliers   <- get_cl_outliers_using_isd(weather.isd, 'dew.point',       'ds', 4)
cl.isd.ws.outliers   <- get_cl_outliers_using_isd(weather.isd, 'wind.speed.mean', 'ds', 5)
cl.isd.ws.max.outliers   <- get_cl_outliers_using_isd(weather.isd, 'wind.speed.max',  'ds', 5)
weather.isd[cl.isd.temp.outliers, 'isd_3_sigma'] <- 1
weather.isd[cl.isd.rh.outliers,   'isd_3_sigma'] <- 1
weather.isd[cl.isd.dp.outliers,   'isd_3_sigma'] <- 1
weather.isd[cl.isd.ws.outliers,   'isd_3_sigma'] <- 1
weather.isd[cl.isd.temp.outliers, 'temperature.x']     <- NA
weather.isd[cl.isd.rh.outliers,   'humidity.x']        <- NA
weather.isd[cl.isd.dp.outliers,   'dew.point.x']       <- NA
weather.isd[cl.isd.ws.outliers,   'wind.speed.mean.x'] <- NA
weather.isd[cl.isd.ws.max.outliers,   'wind.speed.max.x'] <- NA

weather.isd$missing <- as.integer(!complete.cases(weather.isd[, .(ds, temperature.x, humidity.x, dew.point.x, pressure.x, wind.speed.mean.x, wind.bearing.mean.x, wind.speed.max.x)]))

na_names <- sapply(colnames(weather.isd), function(x) paste0(x, '.na'))
weather.isd[, as.vector(na_names) := lapply(.SD, function(x) as.integer(is.na(x))), .SDcols = 1:length(weather.isd)]


######################################################################################################################################################
# 7. Fill in NAs by simple linear interpolation
#    Limit to 6 hours or 12 consecutive observations

weather.isd.orig <- weather.isd
weather.isd$temperature.x <- as.numeric(weather.isd$temperature.x)
weather.isd$humidity.x  <- as.numeric(weather.isd$humidity.x)
weather.isd$dew.point.x <- as.numeric(weather.isd$dew.point.x)
weather.isd$pressure.x  <- as.numeric(weather.isd$pressure.x)
weather.isd$wind.speed.mean.x   <- as.numeric(weather.isd$wind.speed.mean.x)
weather.isd$wind.speed.max.x    <- as.numeric(weather.isd$wind.speed.max.x)
weather.isd$wind.bearing.mean.x <- as.numeric(weather.isd$wind.bearing.mean.x)

interpolate_nas <- function(df, cols) {
  df$row <- 1:nrow(df)
  df$lin_interp <- 0

  for (col in cols) {
    print(col)
    df[, rle := rleid(get(col))][,num_missing := max(.N +  1 , 2), by=rle]
    yy  <- df[num_missing <= 13, ..col][[1]]
    xx  <- df[num_missing <= 13, row]
    nas <- df[num_missing <= 13 & is.na(get(col)), row]
    df[nas, col] <- approx(xx, yy, xout=nas)$y
    df[nas, 'lin_interp'] <- 1
    df[nas, ]
  }

  summary(df)
  df
  df[nas,]
  df$row <- NULL
  df$rle <- NULL
  df$num_missing <- NULL

  return(df)
}

cols.1 <- c("temperature.x", "humidity.x", "dew.point.x", "pressure.x", "wind.speed.mean.x", "wind.bearing.mean.x", "wind.speed.max.x")
weather.isd.interp.1 <- interpolate_nas(weather.isd, cols.1)

cols.2 <- c("temperature.y", "humidity.y", "dew.point.y", "wind.speed.mean.y", "wind.bearing.mean.y", "wind.speed.max.y")
weather.isd.interp.2 <- interpolate_nas(weather.isd.interp.1, cols.2)


######################################################################################################################################################
# 8. Fill Computer Lab (weather.isd) NAs with Cambridge Airport (isd.filled) values

weather.isd.interp.2$isd_filled <- 0
weather.isd.interp.2[is.na(temperature.x) & !is.na(temperature.y),             'isd_filled'] <- 1
weather.isd.interp.2[is.na(humidity.x) & !is.na(humidity.y),                   'isd_filled'] <- 1
weather.isd.interp.2[is.na(dew.point.x) & !is.na(dew.point.y),                 'isd_filled'] <- 1
weather.isd.interp.2[is.na(wind.speed.mean.x) & !is.na(wind.speed.mean.y),     'isd_filled'] <- 1
weather.isd.interp.2[is.na(wind.speed.max.x) & !is.na(wind.speed.max.y),       'isd_filled'] <- 1
weather.isd.interp.2[is.na(wind.bearing.mean.x) & !is.na(wind.bearing.mean.y), 'isd_filled'] <- 1

weather.isd.filled <- weather.isd.interp.2[,
                      .(ds,
                        temperature=ifelse(is.na(temperature.x) & !is.na(temperature.y), temperature.y, temperature.x),
                        humidity=ifelse(is.na(humidity.x) & !is.na(humidity.y), humidity.y, humidity.x),
                        pressure=pressure.x,
                        dew.point=ifelse(is.na(dew.point.x) & !is.na(dew.point.y), dew.point.y, dew.point.x),
                        wind.speed.mean=ifelse(is.na(wind.speed.mean.x) & !is.na(wind.speed.mean.y), wind.speed.mean.y, wind.speed.mean.x),
                        wind.speed.max=ifelse(is.na(wind.speed.max.x) & !is.na(wind.speed.max.y), wind.speed.max.y, wind.speed.max.x),
                        wind.bearing.mean=ifelse(is.na(wind.bearing.mean.x) & !is.na(wind.bearing.mean.y), wind.bearing.mean.y, wind.bearing.mean.x),
                        rainfall,
                        sunshine,
                        ceil_hgt,
                        visibility,
                        missing,
                        known_inaccuracy,
                        isd_outlier,
                        long_run,
                        spike,
                        cooksd_out,
                        isd_3_sigma,
                        isd_filled)]
summary(weather.isd.filled) # lot of pressure NAs :-(
summary(weather.isd.filled[is.na(wind.speed.mean)])
summary(weather.isd.filled[is.na(wind.speed.max)])
summary(weather.isd.filled[is.na(wind.bearing.mean)])
summary(weather.isd.filled[is.na(temperature)])

cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(temperature.x, temperature.y)]), .(temperature.x, temperature.y)])
#               temperature.x temperature.y
# temperature.x     1.0000000     0.9783566
# temperature.y     0.9783566     1.0000000
cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(dew.point.x, dew.point.y)]), .(dew.point.x, dew.point.y)])
#             dew.point.x dew.point.y
# dew.point.x   1.0000000   0.9500148
# dew.point.y   0.9500148   1.0000000
# Increase over 0.9117574
cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(humidity.x, humidity.y)]), .(humidity.x, humidity.y)])
#            humidity.x humidity.y
# humidity.x  1.0000000  0.9064502
# humidity.y  0.9064502  1.0000000
cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(wind.speed.mean.x, wind.speed.mean.y)]), .(wind.speed.mean.x, wind.speed.mean.y)])
#                   wind.speed.mean.x wind.speed.mean.y
# wind.speed.mean.x         1.0000000         0.8689842
# wind.speed.mean.y         0.8689842         1.0000000
# Increase over 0.7881784
cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(wind.speed.max.x, wind.speed.max.y)]), .(wind.speed.max.x, wind.speed.max.y)])

cor(weather.isd.interp.2[complete.cases(weather.isd.interp.2[, .(wind.bearing.mean.x, wind.bearing.mean.y)]), .(wind.bearing.mean.x, wind.bearing.mean.y)])
#                     wind.bearing.mean.x wind.bearing.mean.y
# wind.bearing.mean.x           1.0000000           0.6827114
# wind.bearing.mean.y           0.6827114           1.0000000


######################################################################################################################################################
# 9. Fill in remaining missing values with historical averages


get_historical_average <- function(df, varcol, tscol, yearval=2019) {
  df[, year:=as.numeric(strftime(get(tscol), format = "%Y"))]
  df[,  doy:=as.numeric(strftime(get(tscol), format = "%j"))]
  df[,  HMS:=strftime(get(tscol), format = "%H:%M:%S")]
  df[, secs:=as.numeric(as.difftime(HMS))]

  df.not.year <- unique(df[year != yearval | doy != 366, mean.var:=mean(get(varcol), na.rm=TRUE), by=.(doy, secs)][, .(doy, secs, mean.var)])
  df.not.year <- df.not.year[doy != 366 & !is.na(mean.var),]

  df.year <- df[year == yearval, .(doy, secs, get(varcol))]
  df.year <- df.year[doy != 366 & !is.na(V3),]

  setkey(df.not.year, doy, secs)
  setkey(df.year,     doy, secs)

  rmse <- function(obs, pred) sqrt(mean((obs - pred)^2, na.rm=TRUE))

  print(cor(df.not.year[df.year, .(mean.var, V3)]))
  flush.console()

  # rmse values ignore missing values so will be overestimates
  cat(paste0("\nrmse (historical): ",
             round(rmse(df.not.year[df.year, mean.var], df.not.year[df.year, V3]), 2),
             "\n"))
  mean.var <- mean(df[, get(varcol)], na.rm=TRUE)
  cat(paste0("rmse (mean):\t   ",
             round(rmse(df[!is.na(get(varcol)), get(varcol)], jitter(rep(mean.var, nrow(df[!is.na(get(varcol)),])))), 2),
             "\n"))
  flush.console()

  historical <- df[, mean.var:=mean(get(varcol), na.rm=TRUE), by=.(doy, secs)][, .(doy, secs, mean.var)]
  historical <- unique(historical[!is.na(mean.var),])
  setkey(historical, doy, secs)

  return(historical)
}

historical.temp <- get_historical_average(weather.isd.filled, 'temperature', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.8801195
# V3       0.8801195 1.0000000
#
# rmse (historical): 30.79
# rmse (mean):	     65.25
historical.rh <- get_historical_average(weather.isd.filled, 'humidity', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.7671816
# V3       0.7671816 1.0000000
#
# rmse (historical): 11.91
# rmse (mean):	     17.28
historical.dp <- get_historical_average(weather.isd.filled, 'dew.point', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.7608672
# V3       0.7608672 1.0000000
#
# rmse (historical): 33.03
# rmse (mean):	     51.7
historical.pres <- get_historical_average(weather.isd.filled, 'pressure', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.5405856
# V3       0.5405856 1.0000000
#
# rmse (historical): 12.1
# rmse (mean):	     16.77
historical.ws <- get_historical_average(weather.isd.filled, 'wind.speed.mean', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.4838662
# V3       0.4838662 1.0000000
#
# rmse (historical): 35.7
# rmse (mean):	     40.31
historical.ws <- get_historical_average(weather.isd.filled, 'wind.speed.max', 'ds')

historical.wd <- get_historical_average(weather.isd.filled, 'wind.bearing.mean', 'ds')
#           mean.var        V3
# mean.var 1.0000000 0.2966302
# V3       0.2966302 1.0000000
#
# rmse (historical): 77.57
# rmse (mean):	     83.31

# Despite the low correlation values for some variables they are all better than raw mean values.
# Historical values for pressure, wind.speed.mean and wind.bearing.mean give better results than
# multiple imputation values below.  Not an ideal substition :-(
weather.hist.filled <- weather.isd.filled
summary(weather.hist.filled)
weather.hist.filled[,  doy:=as.numeric(strftime(ds, format = "%j"))]
weather.hist.filled[,  HMS:=strftime(ds, format = "%H:%M:%S")]
weather.hist.filled[, secs:=as.numeric(as.difftime(HMS))]
setkey(weather.hist.filled, doy, secs)

weather.hist.filled$hist_average <- 0
weather.hist.filled[is.na(wind.speed.mean),   'hist_average'] <- 1
weather.hist.filled[is.na(wind.speed.max),    'hist_average'] <- 1
weather.hist.filled[is.na(wind.bearing.mean), 'hist_average'] <- 1
weather.hist.filled[is.na(pressure),          'hist_average'] <- 1

weather.hist.filled[is.na(wind.speed.mean),   'wind.speed.mean']   <- historical.ws[weather.hist.filled[is.na(wind.speed.mean)],   mean.var]
weather.hist.filled[is.na(wind.speed.max),    'wind.speed.max']   <- historical.ws[weather.hist.filled[is.na(wind.speed.max)],     mean.var]
weather.hist.filled[is.na(wind.bearing.mean), 'wind.bearing.mean'] <- historical.wd[weather.hist.filled[is.na(wind.bearing.mean)], mean.var]
weather.hist.filled[is.na(pressure), 'pressure'] <- historical.pres[weather.hist.filled[is.na(pressure)], mean.var]
weather.hist.filled$doy <- NULL
weather.hist.filled$HMS <- NULL
weather.hist.filled$year <- NULL
weather.hist.filled$secs <- NULL
weather.hist.filled$mean.var <- NULL
setkey(weather.hist.filled, ds)
summary(weather.hist.filled)


######################################################################################################################################################
# 10. Multiple imputation for remaining temperature, humidity and dew.point NAs
#     Using Hmisc library which FWIW is included in base R install
#     I suspect imputation suffers when NAs co-occur across variables


library(Hmisc)
# Very slow - approx. 10 mins :-(
impute_arg_tlin <- aregImpute(~ temperature + humidity + pressure + dew.point + wind.speed.mean + wind.bearing.mean + wind.speed.max,
                              data=weather.hist.filled, n.impute = 20, tlinear=FALSE)
impute_arg_tlin
# aregImpute(formula = ~temperature + humidity + pressure + dew.point +
#     wind.speed.mean + wind.bearing.mean, data = weather.hist.filled,
#     n.impute = 20, tlinear = FALSE)
#
# n: 220799 	p: 6 	Imputations: 20  	nk: 3
#
# Number of NAs:
#       temperature          humidity          pressure         dew.point
#               899               736                 0               268
#   wind.speed.mean wind.bearing.mean
#                 0                 0
#
#                   type d.f.
# temperature          s    2
# humidity             s    2
# pressure             s    2
# dew.point            s    2
# wind.speed.mean      s    2
# wind.bearing.mean    s    2
#
# R-squares for Predicting Non-Missing Values for Each Variable
# Using Last Imputations of Predictors
# temperature    humidity   dew.point
#       0.970       0.922       0.958

weather.mi.filled <- weather.hist.filled
summary(weather.mi.filled)

weather.mi.filled$mi_filled <- 0
weather.mi.filled[is.na(temperature), 'mi_filled'] <- 1
weather.mi.filled[is.na(humidity),    'mi_filled'] <- 1
weather.mi.filled[is.na(dew.point),   'mi_filled'] <- 1

weather.mi.filled[is.na(temperature), 'temperature'] <- rowMeans(impute_arg_tlin$imputed$temperature)
weather.mi.filled[is.na(humidity),    'humidity']    <- rowMeans(impute_arg_tlin$imputed$humidity)
weather.mi.filled[is.na(dew.point),   'dew.point']   <- rowMeans(impute_arg_tlin$imputed$dew.point)
summary(weather.mi.filled)


# Adding imputed and historical values introduces a few large values which are
# straight-forward to correct
wf.temp.spikes <- get_large_spikes(weather.mi.filled, 'temperature', 'ds', 6)
wf.rh.spikes   <- get_large_spikes(weather.mi.filled, 'humidity',    'ds', 6)
wf.pres.spikes <- get_large_spikes(weather.mi.filled, 'pressure',    'ds', 6)
wf.dp.spikes   <- get_large_spikes(weather.mi.filled, 'dew.point',   'ds', 6)
wf.ws.spikes   <- get_large_spikes(weather.mi.filled, 'wind.speed.mean', 'ds', 5) # No action
wf.ws.spikes   <- get_large_spikes(weather.mi.filled, 'wind.speed.max',  'ds', 5) # No action

weather.mi.filled$mi_spike_interp <- 0
weather.mi.filled[wf.temp.spikes, 'mi_spike_interp'] <- 1
weather.mi.filled[wf.rh.spikes,   'mi_spike_interp'] <- 1
weather.mi.filled[wf.pres.spikes, 'mi_spike_interp'] <- 1
weather.mi.filled[wf.dp.spikes,   'mi_spike_interp'] <- 1

weather.mi.filled[wf.temp.spikes, 'temperature'] <- NA
weather.mi.filled[wf.rh.spikes,   'humidity']    <- NA
weather.mi.filled[wf.pres.spikes, 'pressure']    <- NA
weather.mi.filled[wf.dp.spikes,   'dew.point']   <- NA
summary(weather.mi.filled)

cols.3 <- c("temperature", "humidity", "dew.point", "pressure")
weather.mi.filled.interp <- interpolate_nas(weather.mi.filled, cols.3)
weather.mi.filled.interp <- unique(weather.mi.filled.interp)
summary(weather.mi.filled.interp)


######################################################################################################################################################
# 11. Save data


fnRDS <- paste0("data/CamMetCleanish", format(Sys.time(), "%Y.%m.%d"), ".RData")
fnCSV <- paste0("data/CamMetCleanish", format(Sys.time(), "%Y.%m.%d"), ".csv.xz")
fnRData <- paste0("data/CambridgeTemperatureModel", format(Sys.time(), "%Y.%m.%d"), ".RData")
fnXCSV <- paste0("data/CamMetCleanishMissAnnotated", format(Sys.time(), "%Y.%m.%d"), ".csv.xz")
fnRData <- paste0("data/CambridgeTemperatureModel", format(Sys.time(), "%Y.%m.%d"), ".RData")

saveRDS(weather.mi.filled.interp[, .(temperature,
                                     dew.point,
                                     humidity,
                                     pressure,
                                     wind.speed.mean,
                                     wind.speed.max,
                                     wind.bearing.mean,
                                     rainfall,
                                     sunshine,
                                     ceil_hgt,
                                     visibility,
                                     ds)], fnRDS)
write.csv(weather.mi.filled.interp[, .(ds,
                                       y=temperature,
                                       humidity,
                                       dew.point,
                                       pressure,
                                       wind.speed.mean,
                                       wind.speed.max,
                                       wind.bearing.mean,
                                       rainfall,
                                       sunshine,
                                       ceil_hgt,
                                       visibility)], xzfile(fnCSV), row.names=FALSE)
write.csv(weather.mi.filled.interp, xzfile(fnXCSV), row.names=FALSE)
save.image(fnRData)

