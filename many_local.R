library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

######## Downloading many files from local pc ################

ptm <- proc.time()
tickery <- matrix(c("PKOBP", "MILLENNIUM", "SANPL", "ROPCZYCE", "GINOROSSI", "ELEMENTAL",
                    "ASSECOPOL", "AUTOPARTN", "WADEX", "RAFAKO", "PGNIG", 
                    "MERLINGRP", "FARM51", "ATCCARGO", "MEXPOLSKA", "XTPL",
                    "DEKTRA"),ncol=1,byrow=TRUE)

colnames(tickery) <- c("s_stock")                     

# first we download first company, just like in other examples
file1 <- "~/R/projekty/finansowe/akcje/kursy/akcje-gpw/"        
file2 <-tickery[1,]
file3 <-".mst"
url.caly<-paste(file1, file2, file3, sep = "")
total <- read.csv(url.caly,
                  sep = ",",
                  dec = ".",
                  stringsAsFactors = F)

total$X.DTYYYYMMDD. <- ymd(total$X.DTYYYYMMDD.)                  
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.)           
colnames(total) <- c("Date", tickery[1,])     


progress.bar <- winProgressBar(title = "Downloading files, Done in %,
                               0% Done", 0, 100, 0)  
for(i in 2:nrow(tickery)){
  file1 <- "~/R/projekty/finansowe/akcje/kursy/akcje-gpw/"
  file2 <- tickery[i,]
  file3 <-".mst"
  url.caly<-paste(file1, file2, file3, sep = "") 
  stock <- read.csv(url.caly,
                    sep = ",",
                    dec = ".",
                    stringsAsFactors = F)  
  stock$X.DTYYYYMMDD. <- ymd(stock$X.DTYYYYMMDD.)                 
  stock <- select(stock, Date = X.DTYYYYMMDD., Close = X.CLOSE.) 
  colnames(stock) <- c("Date", tickery[i,])      
  
  total<-merge(total,stock,by="Date",all=TRUE)    
  
  percentage <- i / nrow(tickery)
  setWinProgressBar(progress.bar, percentage, "Done in %",
                    sprintf("%i%% Done", round(100 * percentage))) 
  
}

close(progress.bar)
proc.time()-ptm

tail(total)

