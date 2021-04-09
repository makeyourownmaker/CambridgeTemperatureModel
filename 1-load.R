
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


library(stationaRy)

#stations_uk <-
#  get_station_metadata() %>%
#  dplyr::filter(country == "UK")
#
#get_station_metadata() %>%
#  dplyr::filter(name == "CAMBRIDGE")
#
## For field descriptions
#?get_met_data


# Not using data before 2008 but retrieving for completeness
isd <- get_met_data( station_id = "035715-99999", years = 1977:2021)
isd.orig <- isd
summary(isd) # Lot of NAs

basename <- paste0("data/CamAirportISD", format(Sys.time(), "%Y.%m.%d"))
saveRDS(isd, paste0(basename, ".RData"))

# Remove atmos_pres - all NAs :-(
# ceil_hgt, visibility - too many NAs :-(
isd <- data.table(isd)
isd <- isd[, .(time, temp, wd, ws, dew_point, rh)]
class(isd)
dim(isd)
str(isd)
head(isd)
summary(isd)


# Remove worst of NAs
isd.08 <- isd[time >= '2008-07-31 08:00:00',]

# Add missing 30 min times
missing.30.mins  <- seq(ymd_hm('2008-07-31 07:30'), ymd_hm('2020-12-31 23:00'), by = '60 mins')
missing.30.mins.dt <- data.table(time=missing.30.mins, temp=NA, wd=NA, ws=NA, dew_point=NA, rh=NA)
isd.08.30 <- rbind(isd.08, missing.30.mins.dt)[order(time),]
isd.08.30.orig <- isd.08.30

# Fill in missing values - simple averages
#   limit to 6 hours or 12 consecutive observations
# for (col in c("temp")) {

isd.08.30$row <- 1:nrow(isd.08.30)
for (col in c("temp","wd","ws","dew_point","rh")) {
    print(col)
    isd.08.30[, rle := rleid(get(col))][,missing := max(.N +  1 , 2), by = rle]
    yy <- isd.08.30[missing <= 13, ..col][[1]]
    xx <- isd.08.30[missing <= 13, row]
    nas <- isd.08.30[missing <= 13 & is.na(get(col)), row]
    isd.08.30[nas, col] <- approx(xx, yy, xout=nas)$y
}
summary(isd.08.30)
isd.08.30
isd.08.30[nas,]
isd.08.30$row <- NULL
isd.08.30$rle <- NULL
isd.08.30$missing <- NULL

isd.filled <- isd.08.30[!is.na(temp) | !is.na(wd) | !is.na(ws) | !is.na(dew_point) | !is.na(rh),]
summary(isd.filled)


