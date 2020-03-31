library(lubridate)
library(tidyverse)

######## Downloading many choosen stocks from bossa.pl #############
# In most cases, better alternative is to use script choosen_stooq, because this script takes longer due to the need of 
# downloading full zip file of stocks and unpacking it anyway. It might be better if you hit the limit on stooq.pl
# this script will make a folder in your working directory called "exit_directory" where stock data will be stored

ptm <- proc.time() # timer begins now
tickery <- matrix(c("PKOBP", "MILLENNIUM", "SANPL", "ROPCZYCE", "GINOROSSI", "ELEMENTAL",
                    "DEKTRA", "GETIN", "XTB", "MEXPOLSKA"), ncol=1, byrow=TRUE)

ticker <- tickery[1]      # above matrix consists of choosen stocks to be downloaded
urlnc2 <- "newconnect"       
urlgpw2 <- "ciagle"
url1 <- "https://info.bossa.pl/pub/"
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp.nc <- tempfile()                 # making a temp file for newconnect
temp.gpw <- tempfile()                # and for GPW

download.file(paste(url1,             # putting both into temp.file
                    urlnc2, 
                    urlnc,
                    sep = ""),        
              temp.nc)
download.file(paste(url1,
                    urlgpw2, 
                    urlgpw,
                    sep = ""),        
              temp.gpw)

# One of two commands below will give error. Its due to the first share being only from NC or GPW

options(show.error.messages = FALSE)
suppressWarnings(try(total <- read.csv(unzip(temp.gpw, paste(ticker, ".mst", sep = ""), exdir = "exit_directory"))))
suppressWarnings(try(total <- read.csv(unzip(temp.nc, paste(ticker, ".mst", sep = ""), exdir = "exit_directory"))))
options(show.error.messages = TRUE)

total$X.DTYYYYMMDD. <- ymd(total$X.DTYYYYMMDD.)                 # making YYYYMMDD format
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.)  # This time we only take 1 variable from every share
colnames(total) <- c("Date", tickery[1])

progress.bar <- winProgressBar("unzipping files - Done in %", "0% Done", 0, 1, 0)

for(i in 2:nrow(tickery)) try({
  
  # This time we have to choose good market.
  if(paste(tickery[i],".mst", sep = "") %in% unzip(temp.gpw, list = TRUE)$Name){
    stock <- read.csv(unzip(temp.gpw, paste(tickery[i], ".mst", sep = ""), exdir = "exit_directory"))
  } else {
    stock <- read.csv(unzip(temp.nc, paste(tickery[i], ".mst", sep = ""), exdir = "exit_directory"))
  }
  
  
  stock$X.DTYYYYMMDD. <- ymd(stock$X.DTYYYYMMDD.)                  
  stock <- select(stock, Date = X.DTYYYYMMDD., Close = X.CLOSE.)
  colnames(stock) <- c("Date", tickery[i])
  total<-merge(total,stock,by="Date",all=TRUE)    
  
  # progress bar below
  percentage <- i / length(tickery)
  setWinProgressBar(progress.bar, percentage, "unzipping data - done in %",
                    sprintf("%d%% Done", round(100 * percentage)))
})
unlink(temp.nc)
unlink(temp.gpw)
close(progress.bar)
proc.time()-ptm
rm(progress.bar, stock, tickery, i, percentage, ptm, temp.gpw, temp.nc, ticker, url1, urlgpw, urlgpw2, urlnc, urlnc2)

