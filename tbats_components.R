
library(forecast)
library(lubridate)
library(data.table)

df <- read.csv(xzfile("data/CamMetCleanish2021.04.22.csv.xz"))
df <- data.table(df)
str(df)
summary(df)

df[, ds:=as.POSIXct(ds, tz="GMT")] 
df[, time:=strftime(ds, format = "%H:%M:%S")]
df[, secs:=as.numeric(as.difftime(time))]

df.y.mean <- df[, mean(y), by=.(doy, secs)][order(doy, secs)]
y.msts <- msts(df.y.mean$V1, seasonal.periods=c(48, 17568))

# less than 3 mins
system.time(y.tbats <- tbats(y.msts, use.box.cox=FALSE, use.trend=FALSE, use.damped.trend=FALSE))

y.tbats
plot(y.tbats)

y.tbats.comps <- tbats.components(y.tbats)

# cbind
y.tbats.comps.dated <- cbind(df.y.mean[, .(doy, secs)], y.tbats.comps.dt)

# write.csv
write.csv(y.tbats.comps.dated, file=xzfile('data/tbats_components.2021.04.22.csv.xz'), row.names=FALSE)

