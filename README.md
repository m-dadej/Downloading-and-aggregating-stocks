# Downloading-and-aggregating-stocks
This script provide an easy way to download recent (last session) polish stock data. It allows to download several choosen stock data as well as to download a single dataset containing historical share prices of every company listed on NewConnect and main platform of Warsaw Stock Exchange (as of 1st April 2020, a dataset of 6805 x 783 dimension).

### Easiest way to download dataset of up to date historical share prices for every stock on GPW

One need only Rstudio with R itself and a more or less stable internet connection. 

Then run following part of code:
```R
source("https://raw.githubusercontent.com/SquintRook/Downloading-and-aggregating-stocks/master/every_stock.R")
```
There ought ot be a few progress bars and in total the script will take aproximatelly 250 sec with good internet connection and without installing libraries. Essentially, the script downloads .zip packages from bossa.info.pl with historical data and unzips them, that is why it takes some time. The script also creates `"exit_directory_stocks"` file in current working directory (if not set, then most likely in documents). It is not important after downloading stock, so one can delete it afterwards. 

If you want to export it to csv file, run following command in R:
```R
write.csv(total, file = "total.csv")
```
