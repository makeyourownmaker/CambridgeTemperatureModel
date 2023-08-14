
library(riem)
library(data.table)

# https://github.com/ropensci/riem
# https://docs.ropensci.org/riem/reference/riem_measures.html
# List of ASOS stations with codes
# https://www.aviationweather.gov/docs/metar/stations.txt


# Download all available data
egsc <- riem_measures(station = 'EGSC', date_start = "1977-02-01", date_end = as.character(Sys.Date()))
egsc <- data.table(egsc)
egsc_orig <- egsc

# Drop all NA columns
dim(egsc)
# 221972     32
egsc <- egsc[, which(unlist(lapply(egsc, function(x) !all(is.na(x))))), with=F]
dim(egsc)
# 221972     24
summary(egsc)

# Keep only select columns
# Other columns are either categorical or have majority NA values
sel_cols <- c("valid", "tmpf", "dwpf", "relh", "alti", "drct", "sknt", "vsby")
summary(egsc[, sel_cols, with=FALSE])

# Save data to CSV
fnCSV <- paste0("data/ASOS_unclean.", format(Sys.time(), "%Y.%m.%d"), ".csv.xz")
write.csv(egsc, xzfile(fnCSV), row.names=FALSE)


# NEXT Convert tmpf and dwpf from F to C
#      Convert alti from hgIn to mBar
#      Clean data
#      Calculate windowed correlations and/or distances with ISD, nasapower and Comp Lab data
#      Watch out for measurements at differing time points

