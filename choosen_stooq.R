library(lubridate)
library(dplyr)

######## Downloading many stocks from a list.##########

tickery <- matrix(c("pko", "pkn", "pzu", "peo",       #As earlier
                    "ing", "lpp", "pgn",
                    "eat", "ccc", "car",
                    "bhw" ),ncol=1,byrow=TRUE)
colnames(tickery) <- c("s_stock")                     

url1 <- "https://stooq.com/q/d/l/?s="        
url2<-tickery[1,]
url3<-"&i=d"
url.caly<-paste(url1, url2, url3, sep = "")
total <- read.csv(url.caly,
                  header = TRUE,
                  sep = ",",
                  dec = ".",
                  stringsAsFactors = F)

total$Date <- ymd(total$Date)                 
total <- total[, c("Date", "Close")]           
colnames(total) <- c("Date", tickery[1,])       

progress.bar <- winProgressBar(title = "Downloading data, Done in %,
                               0% Done", 0, 100, 0) 
for(i in 2:nrow(tickery)){
  url1 <- "http://stooq.com/q/d/l/?s="
  url2<- tickery[i,]
  url3<-"&i=d"
  url.caly<-paste(url1, url2, url3, sep = "") 
  stock <- read.csv(url.caly,
                    header = TRUE,
                    sep = ",",
                    dec = ".",
                    stringsAsFactors = F)  
  stock$Date <- ymd(stock$Date)                  
  stock <- stock[, c("Date", "Close")]         
  colnames(stock) <- c("Date", tickery[i,])      
  
  total<-merge(total,stock,by="Date",all=TRUE)    
  
  percentage <- i / nrow(tickery)
  setWinProgressBar(progress.bar, percentage, "Downloading stocks - Done in %",
                    sprintf("%i%% Done", round(100 * percentage))) 
  
}
close(progress.bar)
rm(progress.bar, stock, tickery, i, percentage, url.caly, url1, url2, url3)

