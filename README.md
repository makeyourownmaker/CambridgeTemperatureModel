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

I have no affiliation with Cambridge University, the Computer Laboratory or the Digital Technology Group.

I live close to this weather station.  When I started looking at this data the UK Met Office
were updating forecasts every 2 hours.  I thought I could produce a more frequent
[nowcast](https://en.wikipedia.org/wiki/Nowcasting_(meteorology)) using time series or
machine learning methods.


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


### Cleaning

The data included in the app start on 2008-08-01 when the weather station was moved to it's current
[location](https://www.cl.cam.ac.uk/research/dtg/weather/map.html).  Unrealistically high wind speed (> 60),
low humidity (< 25) and low temperature (< -20) values were removed.  The Digital Technology
Group list [inaccuracies](https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html) in the weather
data.  All measurements for the entire day or days was removed for each of the listed inaccuracies.
[Cook's distance](https://en.wikipedia.org/wiki/Cook%27s_distance)
was used to remove the remaining influential observations but some problems may remain in the data, such as
long series of repeated values.  The remaining measurements have no missing values.


### Seasonality

In general, time series can be decomposed into seasonal and trend components.

The Cambridge temperature data contains two seasonal components:
1. daily
2. yearly

The two figures below show the daily and yearly components found using the
[prophet package](https://cran.r-project.org/web/packages/prophet/).  This
code is briefly described in the Files sub-section.

1. daily seasonal trend component
![daily seasonal trend component
](https://github.com/makeyourownmaker/CambridgeTemperatureModel/figures/prophet.daily.componet.01.png "daily seasonal trend component")

2. yearly seasonal trend component
![yearly seasonal trend component
](https://github.com/makeyourownmaker/CambridgeTemperatureModel/figures/prophet.yearly.componet.01.png "yearly seasonal trend component")

The daily component shows a smooth change throughout the period.
The less smooth yearly component may indicate more data is required and/or
additional/improved cleaning.


### Files

These files demonstrate how to build models for the Cambridge UK temperature data:

 * [1-load.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/1-load.R)
   * Download data, set variable types and adds some date and time related fields
 * [2-clean.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/2-clean.R)
   * Remove known [inaccuracies](https://www.cl.cam.ac.uk/research/dtg/weather/inaccuracies.html) and other unrealistic measurements
 * [3-prophet.R](https://github.com/makeyourownmaker/CambridgeTemperatureModel/blob/master/3-prophet.R)
   * Build multi-seasonal model using [prophet package](https://cran.r-project.org/web/packages/prophet/).


## Roadmap

* Improve documentation
  * Summarise models and results
* Add more models
  * forecast, prophet ...
* Lint scripts with [goodpractice](https://cran.r-project.org/web/packages/goodpractice/index.html)


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## Alternatives

* [UK Met Office](https://metoffice.gov.uk/)
* [Cambridge University Computer Laboratory Weather Station R Shiny Web App](https://github.com/makeyourownmaker/ComLabWeatherShiny)
* [Forecasting surface temperature based on latitude, longitude, day of year and hour of day](https://github.com/makeyourownmaker/ParametricWeatherModel)


## License

[GPL-2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
