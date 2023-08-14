
library(lubridate)
library(nasapower)
library(data.table)

# https://github.com/ropensci/nasapower
# https://docs.ropensci.org/nasapower/articles/nasapower.html


# lon=0.091964, lat=52.210922
long_lat <- c(0.091964, 52.210922)

query_parameters(community = "ag", temporal_api = "hourly")

ag_pars <- c("T2M", "T2MDEW", "RH2M", "PS", "WS2M", "WD2M",
             "PRECTOTCORR", "CLOUD_AMT", "TS"
             )

# Features to consider
#ag_pars <- c("ALLSKY_SFC_LW_DWN", "ALLSKY_SFC_SW_DWN",
#             "AOD_55", "AOD_84", "CLOUD_OD")
#             "T2M", "T2MDEW", "RH2M", "PS", "WS2M", "WD2M",
#             "PRECTOTCORR", "CLOUD_AMT"
#             "QV10M", "QV2M", "TS", "U10M",
#             "U2M", "V2M", "U50M", "V10M", 
#             "V50M", "PSC", "T2MWET", "WD10M",
#             "WD50M", "WS10M", 
#             "WS50M", "WSC", 
#             "ALLSKY_SFC_LW_DWN", "ALLSKY_SFC_SW_DIFF", "ALLSKY_SFC_SW_DWN",
#             "ALLSKY_SFC_UV_INDEX", "ALLSKY_SFC_UVA", "ALLSKY_SFC_UVB",
#             "AOD_55", "AOD_84", 
#             "CLOUD_OD", "CLRSKY_SFC_LW_DWN",
#             "CLRSKY_SFC_SW_DIFF", "CLRSKY_SFC_SW_DWN", "PW", "SZA", 
#             "TOA_SW_DWN", "ALLSKY_KT", "ALLSKY_NKT", "ALLSKY_SFC_PAR_TOT",
#             "ALLSKY_SFC_SW_DNI", "ALLSKY_SRF_ALB", "CLRSKY_KT", "CLRSKY_NKT",
#             "CLRSKY_NKT", "CLRSKY_SFC_SW_DNI", "CLRSKY_SRF_ALB", 
#             "DIFFUSE_ILLUMINANCE", "DIRECT_ILLUMINANCE", "GLOBAL_ILLUMINANCE",
#             "TOA_SW_DNI", "ZENITH_LUMINANCE", 
#             )

# Times out after 30 secs :-(
#daily_ag <- get_power(community = "ag",
#                      lonlat = long_lat,
#                      pars = ag_pars,
#                      dates = c("2001-01-01", format(Sys.time(), "%Y-%m-%d")),
#                      temporal_api = "hourly"
#                      )
#daily_ag <- data.table(daily_ag)


nasap <- data.frame()
this_year <- format(Sys.time(), "%Y")
start_year <- 2001
for (y in start_year:this_year) {
    print(y)
    start_date <- paste0(y, "-01-01")

    if(y == this_year) {
        # Data updated daily but currently 3 day latency
        xdays <- 3 * 24 * 60 * 60
        end_date <- format(Sys.time() - xdays, "%Y-%m-%d")
    } else {
        end_date <- paste0(y, "-12-31")
    }

    daily_ag <- get_power(community = "ag",
                          lonlat = long_lat,
                          pars  = ag_pars,
                          dates = c(start_date, end_date),
                          temporal_api = "hourly"
                      )
    daily_ag <- data.table(daily_ag)
    nasap <- rbind(nasap, daily_ag)
}

nasap_orig <- nasap
dim(nasap)
# 198192     15
summary(nasap)
# No NAs apart from CLOUD_AMT!

# Create timestamp from YR, MO, DY, HR
nasap$ds <- make_datetime(year = nasap$YEAR, month = nasap$MO, day = nasap$DY, hour = nasap$HR, tz='GMT')

# Drop unnecessary columns
sel_cols <- c("ds", "T2M", "T2MDEW", "RH2M", "PS", "WS2M", "WD2M", "PRECTOTCORR", "CLOUD_AMT", "TS")
nasap <- nasap[, sel_cols, with=FALSE]
dim(nasap)
# 198192     10
summary(nasap)


# Save data to CSV
fnCSV <- paste0("data/nasapower_unclean.", format(Sys.time(), "%Y.%m.%d"), ".csv.xz")
write.csv(nasap, xzfile(fnCSV), row.names=FALSE)


# NEXT Clean data
#      Calculate windowed correlations and/or distances with ISD, ASOS and Comp Lab data
#      Watch out for measurements at differing time points
#      Explore additional features listed above

