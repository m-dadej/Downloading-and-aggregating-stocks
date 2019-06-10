library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

######## Downloading every stock from stooq.pl (not working) ################

# Code below does not work because:
# 1. stooq.pl limits number of daily downloads to around 150
# 2. there is something wrong with url i guess aslo.

setwd("C:/Users/HP/Documents/R/projekty/finansowe/akcje/kursy/akcje-gpw") 

tickery <- read_excel("~/R/projekty/finansowe/akcje/kursy/akcje-gpw/tickery.xlsx")%>%
  as.data.frame()%>%
  select(ticker)%>%
  apply(1, as.character)%>%
  as.matrix(ncol = 1, byrow = TRUE)%>%
  apply(1, tolower)%>%
  as.matrix(ncol = 1, byrow = TRUE)%>%
  .[sample(nrow(.)),]%>%                       
  as.matrix(ncol = 1, byrow = TRUE)             

colnames(tickery) <- c("s_stock")                     
# najpierw jedna spółka. tak jak w poprzednim przykładzie
url1 <- "https://stooq.com/q/d/l/?s="        
url2<-tickery[1,]
url3<-"&i=d"
url.caly<-paste(url1, url2, url3, sep = "")
total <- read.csv(url.caly,
                  header = TRUE,
                  sep = ",",
                  dec = ".",
                  stringsAsFactors = F)

total$Date <- ymd(total$Date)                    #  zmiana daty
total <- total[, c("Date", "Close")]             #  wybrane tylko 2 zmienne z pierwszego
colnames(total) <- c("Date", tickery[1,])        #  nazwa pierwszej spółki

ptm <- proc.time()
progress.bar <- winProgressBar(title = "Pobieranie notowań, postęp w %,
                               0% zrobione", 0, 100, 0)  # jaki progres (opcjonalnie)
for(i in 2:nrow(tickery)) try({
  url1 <- "https://stooq.com/q/d/l/?s="
  url2<- tickery[i,]
  url3<-"&i=d"
  url.caly<-paste(url1, url2, url3, sep = "") 
  stock <- read.csv(url.caly,
                    header = TRUE,
                    sep = ",",
                    dec = ".",
                    stringsAsFactors = F)  
  stock$Date <- ymd(stock$Date)                   # od tej linijki wybierasz co zrobić z danymi
  stock <- stock[, c("Date", "Close")]            # jakie zmienne wybierasz
  colnames(stock) <- c("Date", tickery[i,])       # nazwyanie zmiennych
  
  total<-merge(total,stock,by="Date",all=TRUE)    
  
  percentage <- i / nrow(tickery)
  setWinProgressBar(progress.bar, percentage, "Postep w %",
                    sprintf("%i%% zrobione - ticker: %tickery[i,]%%",
                            round(100 * percentage))) # ciagle progres bar
  
})
close(progress.bar)
proc.time() - ptm
# powyżej trzeba poprawić https czy cos


