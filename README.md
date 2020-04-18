Downloading and aggregating stocks from Warsaw Stock Exchange
================
Mateusz Dadej

This repository contains of scripts that allow for user-friendly downloading of historical stock data listed on polish stock market (GPW / WSE). In near future it might be part of library for quantitative finance. Sources of the included functions, as of now, are [info.bossa.pl](https://info.bossa.pl/notowania/metastock/), website of polish brokerage house and [stooq.pl](https://stooq.com/), financial portal. Functions currently allows to download every stock from WSE (as of 18th April 2020, a dataset of 6,816 x 815 dimension, i.e. 814 stocks with prices for 6,816 trading sessions) and some choosen stocks similar to `getSymbols()` from [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) pacakge.

\

#### everyWSE()

Returns a `data.frame` object with downloaded daily prices of every stock listed on Warsaw Stock Exchange from main market or alternative one - newconnect. Data is currently downloaded from info.bossa.pl.

```R
everyWSE(market = "both",
         ohlcv = "Close",
         info = FALSE)
```
Arguments:

* `market` - One of `c("both", "gpw", "nc")`. Specify stocks from which market to download. Default to "both".

* `ohlcv` - One of `c("Open", "High", "Low", "Close", "Volume")`. Specify which part of the daily price or volume to donwload. Default to "Close"

* `info` - Boolean to choose if additional `data.frame` object to return. Downloaded data.frame have number of columns equal to the price data, for each stock indicate its IPO date, which market it is listed on and stock ticker.
If `info = TRUE` then returns a `list` object with 2 data frames described above.

to import this function download it from herein repository or run following script

```R
source("https://raw.githubusercontent.com/SquintRook/Downloading-and-aggregating-stocks/master/everyWSE.R")
```
\

#### getWSE() 

Returns historical data of prices or other financial metrics for a given vector of tickers, from a given timeframe. This function is similar to [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) getSymbol(). 

```R
getWSE(tickers, 
         ohlcv = "Close", 
         from = "1991-04-16", 
         to = Sys.Date(), 
         fin_metr = "p",         
         source = "stooq.pl")
```

Arguments:

* `tickers` - Vector or single character of tickers of desired stock, e.g. `c("ccc", "pko", "dkr")`. It is important that format of these tickers is different for every source argument. If source = "stooq.pl", then the proper way to specify tickers is an actual ticker in lowercase e.g, "cdr" for CD Project Red, "pko" for PKO Bank. If source = "bossa", then it is necessery to use capital letters with shortened version of name (technically not a ticker). E.g., "CDPROJEKT" for CD Project Red, "PKOBP" for PKO Bank. 
 
* `ohlcv` - Argument specyfing which part of the session should be returned as values. Available are `c("Open", "High", "Low", "Close", "Volume")`. It is possible to choose only one. 

* `from` and `to` - Specify timeframe of retunred data frame. On default, from the beginning of GPW

* `fin_metr` - Only for `source = "stooq.pl"`. One of the following, `c("p", "mv", "pb", "pe")`. Which are respectively, price, market capitalization (in PLN), price to earnings and to book value ratios.

* `source` - One of `c("stooq.pl", "bossa")`. Specify source of data. For less stocks it is faster to use "stooq.pl"

To download that function, firt you need to run following script:
```R
source("https://raw.githubusercontent.com/SquintRook/Downloading-and-aggregating-stocks/master/getWSE.R")
```

-----------------------------------------------------------------------------------------------------------------
Note, that using data from both of these sources without disclaiming it in final work is illegal.