library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

######## Downloading many choosen stocks from bossa.pl #############

ptm <- proc.time() # timer begins now
tickery <- matrix(c("PKOBP", "MILLENNIUM", "SANPL", "ROPCZYCE", "GINOROSSI", "ELEMENTAL",
                    "ASSECOPOL", "AUTOPARTN", "WADEX", "RAFAKO", "PGNIG", 
                    "MERLINGRP", "FARM51", "ATCCARGO", "MEXPOLSKA", "XTPL",
                    "DEKTRA"), ncol=1, byrow=TRUE)

ticker <- tickery[1]      # list of the shares provided just like before (example)
urlnc2 <- "newconnect"       
urlgpw2 <- "ciagle"
url1 <- "https://info.bossa.pl/pub/"
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp.nc <- tempfile()                 # making a temp file for newconnect
temp.gpw <- tempfile()                # and for GPW

download.file(paste(url1,
                    urlnc2, 
                    urlnc,
                    sep = ""),        # putting into temp.file
              temp.nc)
download.file(paste(url1,
                    urlgpw2, 
                    urlgpw,
                    sep = ""),        
              temp.gpw)

# One of two commands below will give error. Its due to the first share being only from NC or GPW
total <- read.csv(unzip(temp.gpw, paste(ticker, ".mst", sep = "")))
total <- read.csv(unzip(temp.nc, paste(ticker, ".mst", sep = "")))

total$X.DTYYYYMMDD. <- ymd(total$X.DTYYYYMMDD.)                 # making YYYYMMDD format
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.)  # This time we only take 1 variable from every share
colnames(total) <- c("Date", tickery[1])

progress.bar <- winProgressBar("unzipping files - Done in %", "0% Done", 0, 1, 0)

for(i in 2:nrow(tickery)) try({
  
  # This time we have to choose good market.
  if(paste(tickery[i],".mst", sep = "") %in% unzip(temp.gpw, list = TRUE)$Name){
    stock <- read.csv(unzip(temp.gpw, paste(tickery[i], ".mst", sep = "")))
  } else {
    stock <- read.csv(unzip(temp.nc, paste(tickery[i], ".mst", sep = "")))
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

tail(total)