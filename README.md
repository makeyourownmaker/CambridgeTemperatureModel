# CambridgeTemperatureModel

![Lifecycle
](https://img.shields.io/badge/lifecycle-experimental-orange.svg?style=flat)
![R
%>%= 3.2.0](https://img.shields.io/badge/R->%3D3.2.0-blue.svg?style=flat)

Time series and other models for Cambridge UK temperature forecasts in R

If you like CambridgeTemperatureModel, give it a star, or fork it and contribute!


## Installation/Usage

Requires R version 3.2.0 and higher.

To install the required libraries in an R session:
```r
install.packages("caret", dependencies = c("Depends", "Suggests"))
install.packages("data.table")
install.packages("lubridate")
install.packages("forecast")
install.packages("prophet")
install.packages("suncalc")
install.packages("ggplot2")
```

Clone repository:
```r
git clone https://github.com/makeyourownmaker/CambridgeTemperatureModel
cd CambridgeTemperatureModel
```

The R files can be ran in sequence or the R session image can be loaded.

Run files in sequence in an R session:
```r
setwd("CambridgeTemperatureModel")
source("1-load.R", echo = TRUE)
source("2-clean.R", echo = TRUE)
```

Or load R session image:
```r
setwd("CambridgeTemperatureModel")
load("data/CambridgeTemperatureModel.RData")
```


## Details

The [Digital Technology Group](https://www.cl.cam.ac.uk/research/dtg/) in the Cambridge University
[Computer Laboratory](https://www.cl.cam.ac.uk/) maintain a [weather station](https://www.cl.cam.ac.uk/research/dtg/weather/).

I live close to this weather station.  When I started looking at this data the UK Met Office
were updating forecasts every 2 hours.  I thought I could produce a more frequent
[nowcast](https://en.wikipedia.org/wiki/Nowcasting_(meteorology)) (one step ahead forecast)
using time series or statistical learning methods.  Day long forecasts
are of secondary interest.  Temperature and rainfall are the primary variables of
interest.  Unfortunately, the rain sensor has issues.

I have no affiliation with Cambridge University, the Computer Laboratory or the Digital Technology Group.


### Variables

The weather measurements include the following variables.

| Variables         | Units                      |
|-------------------|----------------------------|
| Temperature       | Celsius (°C) * 10          |
| Dew Point         | Celsius (°C) * 10          |
| Humidity          | Percent                    |
| Pressure          | mBar                       |
| Wind Speed Mean   | Knots * 10                 |
| Wind Bearing Mean | Degrees                    |
| Timestamp         | Data Hours:Minutes:Seconds |

Dew point is the temperature at which air, at a level of constant pressure, can no longer hold all the
water it contains.  Dew point is defined [here](https://www.cl.cam.ac.uk/research/dtg/weather/dewpoint.html)
and in more detail [here](http://www.faqs.org/faqs/meteorology/temp-dewpoint/).

There are known issues with the sunlight and rain sensors.  These measurements are not included for now.

Measurements are recorded every 30 minutes.


### Cleaning

The data included start on 2008-08-01 when the weather station was moved to it's current
[location](https://www.cl.cam.ac.uk/research/dtg/weather/map.html).  Unrealistically high wind speed (> 60),
low humidity (< 25) and low temperature (< -20) values were removed.  The Digital Technology
Group list [inaccuracies](https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html) in the weather
data.  All measurements for the entire day or days was removed for each of the listed inaccuracies.
[Cook's distance](https://en.wikipedia.org/wiki/Cook%27s_distance)
was used to remove the remaining influential observations but some problems may remain in the data, such as
long series of repeated values.  The remaining measurements have no missing values.


### One step ahead baselines

The following table shows accuracy metrics for baseline nowcast methods:

| Method                         | RMSE     | MAE      | MAPE     |
| ------------------------------ | -------: | -------: | -------: |
| Mean temperature               | 64.46    | 52.63    | 249.91   |
| Persistent temperature         | 6.26     | 4.13     | **9.49** |
| Simple exponential smoothing   | 6.05     | 4.03     | 9.81     |
| Holt exponential smoothing     | **5.62** | **3.94** | 10.25    |

These metrics are calculated in the baselines file briefly
described in the Files subsection.  Numbers in **bold** indicate
the lowest value for each metric.

The three accuracy metrics:
 * RMSE - Root Mean Squared Error
 * MAE - Mean Absolute Error
 * MAPE - Mean Absolute Percent Error

The four baseline methods:
1. The mean temperature method simply uses the mean temperature across
the entire data set as the nowcast.
2. The persistent temperature method is a popular benchmark in the
meteorology literature.  It uses the previous temperature value for the
nowcast.  The
[forecast package](https://cran.r-project.org/web/packages/forecast/)
documentation refers to it as the naive method.
3. Simple exponential smoothing (ses) uses
["weighted averages, where the weights decrease exponentially as observations come from further in the past"](https://otexts.com/fpp2/ses.html).
Generally speaking, this method is surprisingly accurate given its low computational complexity.
4. [Holt](https://otexts.com/fpp2/holt.html) extended simple exponential
smoothing to include data with a trend.


### Daily forecast baselines

The following graph shows RMSE values for baseline daily forecast methods:

<img src="https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/figures/baseline.daily.accuracy.01.png" alt="baseline daily accuracy" width="50%" height="50%"/>

The ses and naive methods give almost identical results.

Two different Holt-Winters exponential smoothing implementations failed!
Sadly the double seasonal Holt-Winters exponential smoothing implementation in
the forecast package is not suitable when data contain zeros or negative numbers.
Vanilla ARIMA models are not suitable
for this temperature data due to multi-seasonality which is explained
next.


### Seasonality

In general, time series can be decomposed into seasonal and trend components.

The Cambridge temperature data contains two seasonal components:
1. Daily
2. Yearly

The next two figures show the daily and yearly components found using the
[prophet package](https://cran.r-project.org/web/packages/prophet/).  This
code is briefly described in the Files subsection.

1. Daily seasonal trend component

<img src="https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/figures/prophet.daily.component.01.png" alt="daily seasonal trend component" width="50%" height="50%"/>

2. Yearly seasonal trend component

<img src="https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/figures/prophet.yearly.component.01.png" alt="yearly seasonal trend component" width="50%" height="50%"/>

The daily and yearly components show smooth cyclic change as expected.  The
vertical axis shows percent change in temperature.


### Prophet package models

[Prophet](https://facebook.github.io/prophet/) models are robust to missing data,
shifts in the trend and typically handle outliers well.  Yearly, weekly,
and daily seasonality, plus holiday effects can be accomodated.  Seasonal
components are represented using Fourier terms.  Prophet models work
best with time series that have strong seasonal effects and several seasons
of historical data.  [Stan](http://mc-stan.org/) is used for fitting models.

Two prophet models were built:

1. Logistic growth with daily and annual components with automatic changepoint detection
2. Logistic growth with daily and annual components with 50 changepoints specified

In both cases a floor of -150 and a cap of 400 were used for
[logistic growth](https://facebook.github.io/prophet/docs/saturating_forecasts.html).

A changepoint is a specific timepoint where the statistical properties differ before and after
the timepoint.  The prophet package detects 25 changepoints automatically.

Additive seasonality is assumed for both models.

The accuracy results for one step ahead forecasts:

| Method                                  | RMSE     | MAE      | MAPE     |
| --------------------------------------- | -------: | -------: | -------: |
| Logistic growth, automatic changepoints | 28.82    | 25.88    | 50.25    |
| Logistic growth, 50 changepoints        | 28.66    | 25.80    | 50.13    |

Using more changepoints showed little to no improvement.

These results are substantially higher than most of the baseline one step
ahead forecasts.  It's possible that using more data would improve the yearly
seasonal component and in turn improve the nowcasts.
The prophet models may perform better for daily forecasts.  Unfortunately,
daily forecast cross-validation will be quite time-consuming to run.


### Forecast package model

The forecast package supports multi-seasonal models using the tbats() function.

This function uses a trigonometric representation of seasonality, instead of conventional
seasonal indices.  It also automatically performs Box-Cox transformation
of the time series, as required.  It can be very slow to estimate, especially with
multiple seasonal time series.  The tbats() function does not support including additional
regressors.

Unfortunately, cross-validation fails.  See the source code described in the Files
subsection for details and
[this unanswered stackoverflow question](https://stackoverflow.com/questions/45999524/for-loop-using-tscv-error-in-nextmethod-replacement-has-length-zero).

FWIW here are the training set accuracy metrics for one step ahead forecasts:

| Method                         | RMSE     | MAE      | MAPE     |
| ------------------------------ | -------: | -------: | -------: |
| TBATS                          | 5.4      | 3.7      | Inf      |

These results are **not** comparable with the baseline methods which are
calculated on a separate test data set.

The infinite MAPE value comes from the forecast package mape() function
implementation which permits division by zero.  Other implementations add
one to the denominator to avoid this behavior.


### Files

These files demonstrate how to build models for the Cambridge UK temperature data:

 * [1-load.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/1-load.R)
   * Download data, set variable types and adds some date and time related fields
 * [2-clean.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/2-clean.R)
   * Remove known [inaccuracies](https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html) and other unrealistic measurements
 * I'd usually do some exploratory data analysis but that is more or less covered in my
   [Cambridge University Computer Laboratory Weather Station R Shiny Web App](https://github.com/makeyourownmaker/ComLabWeatherShiny)
   repository
 * Some feature engineering will be required
   * transformations like the Box-Cox
   * dummy seasonal variables for certain models
   * possibly deseasonalisation
 * [4.01-baselines.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/4.01-baselines.R)
   * Build baseline models and calculate nowcast and daily accuracy using the [forecast package](https://cran.r-project.org/web/packages/forecast/).
     * This script will create a directory called figures if it doesn't already exist
 * [4.02-prophet.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/4.02-prophet.R)
   * Build multi-seasonal model using the [prophet package](https://cran.r-project.org/web/packages/prophet/).
     * This script will create a directory called figures if it doesn't already exist
 * [4.03-forecast.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/4.03-forecast.R)
   * Build multi-seasonal TBATS model using the [forecast package](https://cran.r-project.org/web/packages/forecast/).
     * Cross-validation fails - see source code for details


## Roadmap

* Enhance prophet model
  * Calculate daily accuracy for prophet models
  * Explore adding additional regressors
* Add more time series models
  * I have some [GAM](https://en.wikipedia.org/wiki/Generalized_additive_model)
    forecasts which are nearing completion
  * [TSA](https://cran.r-project.org/web/packages/TSA/index.html) supports multiple seasonalities and
    exogenous variables with the arimax() function
  * [bsts](https://cran.r-project.org/web/packages/bsts/index.html) *if* it supports multi-seasonality
    * spike-and-slab priors are quite appealing for adding regressors in a principled manner
* Add some statistical learning models
  * Support vector regression, modern neural networks etc may have some utility
* Improve documentation
  * Summarise cross-validation, models etc
  * Add a simple plot showing temperature over the years
    * Describe stationarity and trend


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## Alternatives

* [UK Met Office](https://metoffice.gov.uk/)
* [Cambridge University Computer Laboratory Weather Station R Shiny Web App](https://github.com/makeyourownmaker/ComLabWeatherShiny)
* [Forecasting surface temperature based on latitude, longitude, day of year and hour of day](https://github.com/makeyourownmaker/ParametricWeatherModel)


## License

[GPL-2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
