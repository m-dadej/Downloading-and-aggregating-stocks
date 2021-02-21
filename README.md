Downloading and aggregating financial data from Warsaw Stock Exchange
================
Mateusz Dadej

This repository contains of scripts that allow for user-friendly downloading of historical data of stocks listed on polish stock market (GPW / WSE). In future it might be part of library for quantitative finance. Sources of the included functions, as of now is [stooq.pl](https://stooq.com/), financial portal. Functions currently allows to download some choosen stock prices similar to `getSymbols()` from [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) package and financial data of those stocks.

There are following functions:

#### getWSE() 

Returns historical data of prices or other financial metrics for a given vector of tickers, from a given timeframe. This function is similar to [quantmod](https://cran.r-project.org/web/packages/quantmod/quantmod.pdf) getSymbol(). 

```R
getWSE(tickers, 
         ohlcv = "Close", 
         from = "1991-04-16", 
         to = Sys.Date())
```

Arguments:

* `tickers` - Vector or single character of tickers of desired stock, e.g. `c("ccc", "pko", "dkr")`.
 
* `ohlcv` - Argument specyfing which part of the session should be returned as values. Available are `c("Open", "High", "Low", "Close", "Volume")`. It is possible to choose only one. 

* `from` and `to` - Specify timeframe of returned data frame. On default, from the beginning of GPW. In yyyy-mm-dd format.

* `freq` -  Specifies frequency of time series. One of the following, `c("daily" "weekly", "monthly", "quarterly", "yearly")`.

* `corpo_action` - Which corporate actions to adjust. One of the following, `c("split", "div", "rights", "denomination")` or `"all"`.

stooq.pl have daily limits of downloading data.
 
To import this function to your environment, first you need to run following script:
```R
source("https://raw.githubusercontent.com/m-dadej/Downloading-and-aggregating-stocks/master/getWSE.R")
```

example:
```R
source("https://raw.githubusercontent.com/m-dadej/Downloading-and-aggregating-stocks/master/getWSE.R")

stock_data <- getWSE(tickers = c("dkr", "ccc", "peo"), 
                     ohlcv = "Close",
                     from = "2014-01-01",
                     to = "2016-01-01",
                     freq = "daily",
                     corpo_action = c("div", "split")) 

tibble::as_tibble(stock_data)

# A tibble: 24 x 4
   Date         dkr   ccc   peo
   <date>     <dbl> <dbl> <dbl>
 1 2014-01-31  7.46  119.  185.
 2 2014-02-28  8     132.  193.
 3 2014-03-31 10.0   131.  197.
 4 2014-04-30  9.76  127.  194.
 5 2014-05-31  9.00  120.  186.
 6 2014-06-30  8.00  113.  174.
 7 2014-07-31  5.80  110.  166.
 8 2014-08-31  8.00  119.  180.
 9 2014-09-30  7.70  128.  194.
10 2014-10-31  8.10  129.  176.
# ... with 14 more rows
```

#### getWSE_fin()

returns a financial data for specified companies listed on WSE main market and New Connect. Currently available variables are price to earnings ratio, price to book value and market capitalization. 

```R
getWSE_fin(tickers,
           fin_var,
           from = "1991-04-16",
           to = Sys.Date(),
           freq)
```
 Arguments:

* `tickers` - Tickers of chosen stocks, e.g. `c("peo", "dkr", "ccc")`.

* `fin_var` - Lower case acronym specifying financial data. One of `c("pe", "pb", "mv")`, respectively price to earnings ratio, price to book value ratio and market capitalization.

* `from` and `to` - Specify time frame of returned data frame. On default, from the beginning of GPW. yyyy-mm-dd format.

* `freq` -  Specifies frequency of time series. One of the following, `c("daily" "weekly", "monthly", "quarterly", "yearly")`.

 Details:

financial values from financial statement are the most recently published data at the moment, and is not corresponding to time frame during which it was generated. Values of market capitalization are denominated in million polish zloty (PLN). There is a daily limit of downloads.

To import function above, first you need to run following script:
```R
source("https://raw.githubusercontent.com/m-dadej/Downloading-and-aggregating-stocks/master/getWSE_fin.R")
```

example:

```R
source("https://raw.githubusercontent.com/m-dadej/Downloading-and-aggregating-stocks/master/getWSE_fin.R")

df <- getWSE_fin(tickers = c("dkr", "ccc", "peo", "clc"),
                       fin_var = "mv", 
                       from = "2015-01-01",
                       freq = "daily")
                       
tibble::as_tibble(df)
                       
# A tibble: 1,325 x 5
   Data       dkr_mv ccc_mv peo_mv clc_mv
   <date>      <dbl>  <dbl>  <dbl>  <dbl>
 1 2015-01-02   5.32  4820. 33931.   6.35
 2 2015-01-05   5.32  4809. 33131.   6.51
 3 2015-01-07   5.30  5083. 33416.   6.51
 4 2015-01-08   4.89  5398. 34083.   6.35
 5 2015-01-09   4.39  5301. 33626.   6.18
 6 2015-01-12   4.33  5319. 33340.   6.01
 7 2015-01-13   4.27  5192. 34064.   5.01
 8 2015-01-14   4.27  5166. 33912.   5.18
 9 2015-01-15   4.21  5155. 32978.   5.18
10 2015-01-16   4.21  5148. 32769.   4.68
# ... with 1,315 more rows
```


#### General notes on repository

When i find time, i will add another functions to download data as well as for portfolio and risk management. Feel free to suggest new features / functions.

The future access to info.bossa.pl is uncertain, to say the least. In case of limiting access of its data to customers of bossa brokerage house, the function `getWSE_every()` will be depreciated, as well as one of the source for `getWSE()`. There are also other very valuable data on info.bossa.pl (e.g financial statement data of every company on WSE/NC), but their future availability is uncertain as well. Thus, if anyone knows other valuable source of data, fell free to message me and i will add it or make another function.

fell free to contact me: mateuszdadej@gmail.com

-----------------------------------------------------------------------------------------------------------------
Note, that using data from both of these sources without disclaiming it in final work is illegal.

