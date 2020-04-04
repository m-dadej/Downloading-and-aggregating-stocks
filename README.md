Downloading and aggregating stocks from Warsaw Stock Exchange
================
Mateusz Dadej

This repository contains of scripts that allow for user-friendly downloading of historical stock data listed on polish stock market (GPW/WSE). In near future it might be part of quantitative finance library. Sources of the included functions, as of now, are [info.bossa.pl](https://info.bossa.pl/notowania/metastock/), website of polish brokerage house and [stooq.pl](https://stooq.com/), financial portal.

#### Easiest way to download dataset of up to date historical share prices for every stock on GPW

Following script provide an easy way to download recent (last session) polish stock data. It allows to download several choosen stock data as well as to download a single dataset containing historical share prices of every company listed on NewConnect and main platform of Warsaw Stock Exchange (as of 1st April 2020, a dataset of 6805 x 783 dimension). One need only Rstudio with R itself and a more or less stable internet connection. 

Run following part of code in R:
```R
source("https://raw.githubusercontent.com/SquintRook/Downloading-and-aggregating-stocks/master/every_stock.R")
```
There ought ot be a few progress bars and in total the script will take aproximatelly 250 sec with good internet connection and without installing libraries. Essentially, the script downloads .zip packages from [info.bossa.pl](https://info.bossa.pl/notowania/metastock/) with historical data and unzips them, that is why it takes some time.

If you want to export it to csv file, run following command in R:
```R
write.csv(total, file = "total.csv")
```

#### getStock() 

This function is similar to [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) getSymbol(). It returns historical data of prices or other financial metrics for a given vector of tickers, from a given timeframe.

To have that function, firt you need to run following script:
```R

```
Then, the function will be in your environment. Here is an example how to use it:

```R
getStock(tickers, 
         ohlcv = "Close", 
         from = "1991-04-16", 
         to = Sys.Date(), 
         fin_metr = "p",         
         source = "stooq.pl")
```

Arguments:

* `tickers` - vector or single character of tickers of desired stock, e.g. c("ccc", "pko", "dkr"). It is important that format of these tickers is different for every source argument. If source = "stooq.pl", then the proper way to specify tickers is an actual ticker in lowercase e.g, "cdr" for CD Project Red, "pko" for PKO Bank. If source = "bossa", then it is necessery to use capital letters with shortened version of name (technically not a ticker). E.g., "CDPROJEKT" for CD Project Red, "PKOBP" for PKO Bank. 
 
* `ohlcv` - Argument specyfing which part of the session should be returned as values. Available are c("Open", "High", "Low", "Close", "Volume"). It is possible to choose only one. 

* `from` and `to` - Specify timeframe of retunred data frame. On default, from the beginning of GPW

* `fin_metr` - Only for `source = "stooq.pl"`. One of the following, c("p", "mv", "pb", "pe"). Which are respectively, price, market capitalization (in PLN), price to earnings and to book value ratios.

* `source` - One of c("stooq.pl", "bossa"). Specify source of data. For less stocks it is faster to use "stooq.pl"

