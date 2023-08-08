
library(lubridate)
library(data.table)


#############################################################################################################################################
# 1. Get Cambridge Computer Lab weather station data
#    See https://www.cl.cam.ac.uk/research/dtg/weather/

temporaryFile <- tempfile()
download.file("https://www.cl.cam.ac.uk/research/dtg/weather/weather-raw.csv", destfile=temporaryFile, method="wget", extra="--no-check-certificate")
weather.raw <- read.csv(temporaryFile)
weather.raw.orig <- weather.raw
weather.cols <- c("timestamp", "temperature", "humidity", "dew.point", "pressure",
                  "wind.speed.mean", "wind.bearing.mean", "sunshine", "rainfall",
                  "wind.speed.max")
colnames(weather.raw) <- weather.cols
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
#    We are investigating how best to fix this and we should be able to correct archived records
#    once the problem is resolved."
# INSTEAD I replace rainfall and/or sunshine with binary - 0 if 0, 1 if > 0
weather.raw[, rainy:=ifelse(rainfall > 0, 1, 0)]
weather.raw[, sunny:=ifelse(sunshine > 0, 1, 0)]


# ADDITIONALLY find sunrise and sunset times and infer if cloudy
#              https://cran.r-project.org/web/packages/suncalc/suncalc.pdf
#              Remove sunshine before sunrise and after sunset
#              TODO add cloudy variable later

# Add approx (nearest min) sunrise and sunset
library(suncalc)

# TODO Check daylight saving time
#getSunlightTimes(date=as.Date("2019-03-08"), lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"))
#getSunlightTimes(date=as.Date("2019-03-08"), lat=52.210922, lon=0.091964, keep=c("sunrise", "sunset"), tz="GMT")

weather.raw$date <- as.Date(weather.raw$ds)
weather.rise.set <- as.data.table(unique(weather.raw$date))
colnames(weather.rise.set) <- "date"

# Approx. 15 secs each for next two commands
weather.rise.set[, sunrise:=round_date(getSunlightTimes(date=date,
                                                        lat=52.210922,
                                                        lon=0.091964,
                                                        keep=c("sunrise", "sunset"))$sunrise,
                                       unit="1 minute")]
weather.rise.set[,  sunset:=round_date(getSunlightTimes(date=date,
                                                        lat=52.210922,
                                                        lon=0.091964,
                                                        keep=c("sunrise", "sunset"))$sunset,
                                       unit="1 minute")]

setkey(weather.raw, "date")
setkey(weather.rise.set, "date")
weather.raw <- weather.rise.set[weather.raw]
str(weather.raw)



#############################################################################################################################################
# 2. Get NOAA ISD data for Cambridge Airport weather station
#    Used for filling missing values in Computer Lab data
#    See https://www.ncdc.noaa.gov/isd

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


####################################################################################################
# Monkey patch the get_years_available_for_station() function in the stationaRy package
# See: https://dlukes.github.io/monkey-patching-in-r.html

stationaRy <- getNamespace("stationaRy")
unlockBinding("get_years_available_for_station", stationaRy)


get_years_available_for_station <- function(station_id) {
  first_year <- 2008
  last_year <- as.numeric(format(Sys.time(), "%Y"))

  first_year:last_year
}


stationaRy$get_years_available_for_station <- get_years_available_for_station
lockBinding("get_years_available_for_station", stationaRy)

####################################################################################################


next_year <- as.numeric(format(Sys.time(), "%Y"))
isd <- get_met_data( station_id = "035715-99999", years = 2008:next_year)
isd.orig <- isd
summary(isd) # Lot of NAs

basename <- paste0("data/CamAirportISD", format(Sys.time(), "%Y.%m.%d"))
saveRDS(isd, paste0(basename, ".RData"))

# Remove atmos_pres - all NAs!
# ceil_hgt, visibility - too many NAs to deal with for now :-(
isd <- data.table(isd)
isd <- isd[, .(time, temp, wd, ws, dew_point, rh, ceil_hgt, visibility)]
class(isd)
dim(isd)
str(isd)
head(isd)
summary(isd)


# Remove worst of NAs and synchronise with weather data
isd.08.08.01 <- isd[time >= '2008-08-01 00:00:00',]

# Add NAs - on 30 mins past each hour
max.isd.time <- max(isd.08.08.01$time)
all.isd.time.stamps <- seq(ymd_hm('2008-08-01 00:00'), max.isd.time, by='60 mins')
missing.30.mins.dt <- data.table(time=all.isd.time.stamps, temp=NA, wd=NA, ws=NA, dew_point=NA, rh=NA, ceil_hgt=NA, visibility=NA)
isd.08.08.01_30 <- rbind(isd.08.08.01, missing.30.mins.dt)[order(time),]
isd.08.08.01_30.orig <- isd.08.08.01_30

# Fill in 30 mins NAs and other missing data
# Use simple averages
# Limit to 6 hours or 12 consecutive observations
isd.08.08.01_30$row <- 1:nrow(isd.08.08.01_30)
for (col in c("temp", "wd", "ws", "dew_point", "rh")) {
    print(col)
    isd.08.08.01_30[, rle := rleid(get(col))][,missing := max(.N +  1 , 2), by=rle]
    yy <- isd.08.08.01_30[missing <= 13, ..col][[1]]
    xx <- isd.08.08.01_30[missing <= 13, row]
    nas <- isd.08.08.01_30[missing <= 13 & is.na(get(col)), row]
    isd.08.08.01_30[nas, col] <- approx(xx, yy, xout=nas)$y
}
summary(isd.08.08.01_30)
isd.08.08.01_30
isd.08.08.01_30[nas,]
isd.08.08.01_30$row <- NULL
isd.08.08.01_30$rle <- NULL
isd.08.08.01_30$missing <- NULL

isd.filled <- isd.08.08.01_30[!is.na(temp) | !is.na(wd) | !is.na(ws) | !is.na(dew_point) | !is.na(rh),]
summary(isd.filled)


