library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

######## Downloading historical data of one given share from stooq.pl ##############

# link constructed below should look like : "https://stooq.pl/q/d/l/?s=ccc&i=d" (dla CCC)

ticker <- "11bit"                          #choosen ticker different than previous examples
url1 <- "https://stooq.pl/q/d/l/?s="           
url2 <- "&i=d" # url kończący
url.caly <- paste(url1, ticker, url2, sep = "")
read.csv(url.caly,
         header = FALSE,
         sep = ",",
         dec = ".",
         stringsAsFactors = F)
