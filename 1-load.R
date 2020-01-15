
library(lubridate)
library(data.table)


#weather.raw <- read.csv("weather-raw.csv")
weather.raw <- read.csv("https://www.cl.cam.ac.uk/research/dtg/weather/weather-raw.csv")
weather.raw.orig <- weather.raw
colnames(weather.raw) <- c("timestamp", "temperature", "humidity", "dew.point", "pressure", "wind.speed.mean", "wind.bearing.mean", "sunshine", "rainfall", "wind.speed.max")
str(weather.raw)

weather.raw <- data.table(weather.raw)

weather.raw[, ds:=as.POSIXct(timestamp, tz="GMT")]
weather.raw[, year:=strftime(ds, format = "%Y")]
weather.raw[, doy:=strftime(ds, format = "%j")]
weather.raw$doy <- as.numeric(weather.raw$doy)
weather.raw[, time:=strftime(ds, format = "%H:%M:%S")]
weather.raw[, secs:=as.numeric(as.difftime(time))]

# From: https://www.cl.cam.ac.uk/research/dtg/weather/
#   "There is a known issue with the sunlight and rain sensors sometimes over-reporting readings.
#    We are investigating how best to fix this and we should be able to correct archived records once the problem is resolved."
# INSTEAD I replace rainfall and/or sunshine with binary - 0 if 0, 1 if > 0
weather.raw[, rainy:=ifelse(rainfall > 0, 1, 0)]
weather.raw[, sunny:=ifelse(sunshine > 0, 1, 0)]


# ADDITIONALLY find sunrise and sunset times and infer if cloudy
#              https://cran.r-project.org/web/packages/suncalc/suncalc.pdf
#              Remove sunshine before sunrise and after sunset
#              TODO add cloudy variable later

# Add approx (nearest min) sunrise and sunset
library(suncalc)

# Not certain about lat & long (used https://www.latlong.net/)
#   TODO Check daylight saving time
#getSunlightTimes(date=as.Date("2019-03-08"), lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"))
#getSunlightTimes(date=as.Date("2019-03-08"), lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"), tz="GMT")

weather.raw$date <- as.Date(weather.raw$ds)
weather.rise.set <- as.data.table(unique(weather.raw$date))
colnames(weather.rise.set) <- "date"

# Approx. 15 secs each for next two commands
weather.rise.set[, sunrise:=round_date(getSunlightTimes(date=date, lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"))$sunrise, unit="1 minute")]
weather.rise.set[,  sunset:=round_date(getSunlightTimes(date=date, lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"))$sunset,  unit="1 minute")]

setkey(weather.raw, "date")
setkey(weather.rise.set, "date")
weather.raw <- weather.rise.set[weather.raw]
str(weather.raw)


