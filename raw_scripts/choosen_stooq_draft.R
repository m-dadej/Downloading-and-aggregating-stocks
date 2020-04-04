library(lubridate)
library(dplyr)

######## Downloading many stocks from a list.##########


tickers <- c("ccc", "dkr")
ohlcv <-  "Close"
from <-  "1991-04-16"
to <-  Sys.Date()
fin_metr <-  "p"

# arguments info:

# tickers - vector of one or more tickers of desired stocks. Limit is 150 per day. E.g c("pko", "ccc", "dkr")
# ohlcv - For more than 1 ticker. One of the following c("Open", "High", "Low", "Close", "Volume")
# 'from' and 'to' - what is the timeframe of dataset? On default from "1991-04-16" to Sys.Date()
# fin_metr - which metric of stocks to get. one of the c("p", "pe", "pb", "mv") 
# "p" - price; "pe" - Price to earnings ratio (P/E); "pb" = Price to book value ratio (P/BV); "mv" - market capitalization

if (!(fin_metr == "p")) {paste(tickers, fin_metr, sep = "_")}

url1 <- "https://stooq.com/q/d/l/?s="        
url2 <- tickers[1]
url3 <- "&i=d"
url.caly <- paste(url1, url2, url3, sep = "")
total <- read.csv(url.caly,
                  header = TRUE,
                  sep = ",",
                  dec = ".",
                  stringsAsFactors = F)

total$Date <- ymd(total$Date)    

# if there is only one ticker to download, then retunred data frame consists of OHLC and vloume also
if(length(tickers)  > 1){ 
  
  total <- total[, c("Date", ohlcv)]           
  colnames(total) <- c("Date", tickers[1])   
  
  progress.bar <- winProgressBar(title = "Downloading data, Done in %,
                                 0% Done", 0, 100, 0) 
  for(i in 2:length(tickers)){
    url1 <- "http://stooq.com/q/d/l/?s="
    url2 <- tickers[i]
    url3 <-"&i=d"
    url.caly <-paste(url1, url2, url3, sep = "") 
    stock <- read.csv(url.caly,
                      header = TRUE,
                      sep = ",",
                      dec = ".",
                      stringsAsFactors = F)  
    stock$Date <- ymd(stock$Date)                  
    stock <- stock[, c("Date", ohlcv)]         
    colnames(stock) <- c("Date", tickers[i])      
    
    total <- merge(total,stock,by="Date",all=TRUE)    
    
    percentage <- i / length(tickers)
    setWinProgressBar(progress.bar, percentage, "Downloading stocks - Done in %",
                      sprintf("%i%% Done", round(100 * percentage))) 
    
  }
  close(progress.bar)}

total <- filter(total, Date >= from & Date <= to)

rm(list = ls()[-which(ls() == "total")]) # remove everything beside "total"