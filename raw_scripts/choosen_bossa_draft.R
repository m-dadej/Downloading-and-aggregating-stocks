library(lubridate)
library(tidyverse)

######## Downloading many choosen stocks from bossa.pl #############
# In most cases, better alternative is to use script choosen_stooq, because this script takes longer due to the need of 
# downloading full zip file of stocks and unpacking it anyway. It might be better if you hit the limit on stooq.pl
# this script will make a folder in your working directory called "exit_directory" where stock data will be stored

ptm <- proc.time() # timer begins now
tickers <- c("BLOOBER", "PEKAO")
ohlcv <- "Close"
from <- "1991-04-16"
to = Sys.Date()



ticker <- tickers[1]      # above matrix consists of choosen stocks to be downloaded
urlnc2 <- "newconnect"       
urlgpw2 <- "ciagle"
url1 <- "https://info.bossa.pl/pub/"
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp.nc <- tempfile()                 # making a temp file for newconnect
temp.gpw <- tempfile()                # and for GPW
temp_exit_dir <- tempdir()

bossa_list_gpw <- read.csv("https://info.bossa.pl/pub/ciagle/mstock/sesjacgl/sesjacgl.prn",
                           header = FALSE, stringsAsFactors=FALSE)%>%
  select(V1)%>%
  as.matrix()


if(any(tickers %in% bossa_list_gpw)){ # check if any ticker is from main platform of WSE
  download.file(paste(url1,             # putting both into temp.file
                      urlgpw2, 
                      urlgpw,
                      sep = ""),        
                temp.gpw)}

bossa_list_nc <- read.csv("https://info.bossa.pl/pub/newconnect/mstock/sesjancn/sesjancn.prn",
                          header = FALSE, stringsAsFactors=FALSE)%>%
  dplyr::select(V1)%>%
  as.matrix()

if (any(tickers %in% bossa_list_nc)) { # check if any ticker is from new connect
  download.file(paste(url1,
                      urlnc2, 
                      urlnc,
                      sep = ""),        
                temp.nc)}

if (!(any(tickers %in% c(bossa_list_nc, bossa_list_gpw)))) { # False if there is no tickers that are available
  stop("Provided tickers are wrong/not available in dataset")
}
# One of two commands below will give error. Its due to the first share being only from NC or GPW

options(show.error.messages = FALSE)
suppressWarnings(try(total <- read.csv(unzip(temp.gpw, paste(ticker, ".mst", sep = ""), exdir = temp_exit_dir))))
suppressWarnings(try(total <- read.csv(unzip(temp.nc, paste(ticker, ".mst", sep = ""), exdir = temp_exit_dir))))
options(show.error.messages = TRUE)

if (length(tickers) > 1) {
  
  ohlcv_translator <- data.frame(bossa = c("X.OPEN.", "X.HIGH.", "X.LOW.", "X.CLOSE.", "X.VOL."),
                                 stooq = c("Open", "High", "Low", "Close", "Volume"), stringsAsFactors = FALSE)
  
  ohlcv <- ohlcv_translator[ohlcv_translator$stooq == ohlcv,1] # translate ohlc of stooq to bossa
  
  total$X.DTYYYYMMDD. <- lubridate::ymd(total$X.DTYYYYMMDD.)                 # making YYYYMMDD format
  total <- dplyr::select(total, Date = X.DTYYYYMMDD., value = ohlcv)  # This time we only take 1 variable from every share
  colnames(total) <- c("Date", tickers[1])
  
  progress.bar <- winProgressBar("unzipping files - Done in %", "0% Done", 0, 1, 0)
  
  for(i in 2:length(tickers)) try({
    
    # This time we have to choose good market.
    if(tickers[i] %in% bossa_list_gpw){
      stock <- read.csv(unzip(temp.gpw, paste(tickers[i], ".mst", sep = ""), exdir = temp_exit_dir))
    } else {
      stock <- read.csv(unzip(temp.nc, paste(tickers[i], ".mst", sep = ""), exdir = temp_exit_dir))
    }
    
    
    stock$X.DTYYYYMMDD. <- lubridate::ymd(stock$X.DTYYYYMMDD.)                  
    stock <- dplyr::select(stock, Date = X.DTYYYYMMDD., value = ohlcv)
    colnames(stock) <- c("Date", tickers[i])
    total<-merge(total,stock,by="Date",all=TRUE)    
    
    # progress bar below
    percentage <- i / length(tickers)
    setWinProgressBar(progress.bar, percentage, "unzipping data - done in %",
                      sprintf("%d%% Done", round(100 * percentage)))
  })
  unlink(temp.nc)
  unlink(temp.gpw)
  
  close(progress.bar)
  proc.time()-ptm
  
}else{ 
  total <- total[,-1]
  colnames(total) <- c("Date", "Open", "High", "Low", "Close", "Volume")
  total$Date <- lubridate::ymd(total$Date)
}

total <- dplyr::filter(total, Date >= from & Date <= to)

rm(list = ls()[-which(ls() == "total")]) # remove everything beside "total"

