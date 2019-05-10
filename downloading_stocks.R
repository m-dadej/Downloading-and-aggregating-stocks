library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

# You may not find everything useful. Some parts of the scripts are designed rather for me
# But still, after modyfing script, one can make it quite insightful for him, i believe.
# The most interesting and versatile script is entitled:
# "Downloading every stock from bossa.pl"

######## downloading historical data of a single share #############
# downloaded data frame consists of OHLC volume and date

ticker <- "XTPL"                     # Name of the company that will be recognized by bossa.pl (capital letters, no spaces)
                                     # the list of shares is on the bossa.pl or later in the script
rynek <- "newconnect"                # "newconnect" for newconnect and "ciagle" for GPW. !they have to match!
url1 <- "https://info.bossa.pl/pub/" # Some company names are wrong on the side of the bossa's API
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp <- tempfile()                   #making a temporary file
download.file(paste(url1,
                    rynek, 
                    ifelse( rynek == "newconnect",urlnc,urlgpw), # the link is different for nc and gpw
                    sep = ""),                                   # putting to temp file
              temp) 
df <- read.csv(unzip(temp, paste(ticker, ".mst", sep = "")))
unlink(temp)

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

######## Downloading every stock from bossa.pl (the best way so far) ###########
# first we download a list of tickers from Nc and GPW separately

ptm <- proc.time()

tickery.nc <- read.csv("https://info.bossa.pl/pub/newconnect/mstock/sesjancn/sesjancn.prn",
                       header = FALSE,
                       sep = ",",
                       dec = ".",
                       stringsAsFactors = F)%>%
  select(V1)
tickery.nc <- tickery.nc[-length(tickery.nc),] # bez ncindex


tickery.gpw <- read.csv("https://info.bossa.pl/pub/ciagle/mstock/sesjacgl/sesjacgl.prn",
                        header = FALSE,
                        sep = ",",
                        dec = ".",
                        stringsAsFactors = F)%>%
  select(V1)%>%
  mutate(n.char = nchar(V1))

# archive from bossa also contains data of futures and other unwanted stuff
# these unwanted securities have many letters usually
# we searched for securities below given threshold of letters to cut unwanted ones
# these shares below are exceptions (their names are also long)
# dont change it if you are 100% sure i missed some or if there was IPO.

exception <- c("SILVAIR-REGS","GRUPAAZOTY","MDIENERGIA","MILLENNIUM","INVESTORMS","4FUNMEDIA",
             "ACAUTOGAZ", "APSENERGY","ASSECOPOL","ASSECOSEE","AUTOPARTN","BAHOLDING",
             "BIOMEDLUB", "CDPROJEKT", "CLNPHARMA", "CYFRPLSAT","EKOEXPORT","ELEKTROTI",
             "ELEMENTAL", "ENERGOINS","GETINOBLE","GINOROSSI","HOLLYWOOD","IMCOMPANY",
             "INSTALKRK","INTERAOLT", "INTERCARS", "INTERSPPL", "JWWINVEST", "K2INTERNT",
             "KOMPUTRON", "KONSSTALI", "KRUSZWICA", "KRVITAMIN", "LABOPRINT", "MAKARONPL",
             "MASTERPHA", "MEXPOLSKA", "MIRACULUM", "MOSTALPLC", "MOSTALWAR", "NORTCOAST",
             "NTTSYSTEM", "OPONEO.PL", "PCCROKITA", "PEMANAGER", "PLATYNINW", "PLAZACNTR",
             "POLIMEXMS", "PRAGMAINK", "PRIMETECH", "PROJPRZEM", "PROVIDENT", "RANKPROGR",
             "SANTANDER", "STALPROFI", "STARHEDGE", "UNICREDIT", "VENTUREIN", "WIRTUALNA",
             "IDMSA")
# we dont want these because these are indexes
without <- c("SANPL2", "WIGDIV","WIG30","SWIG80", "MWIG40","WIG30TR", "WIG20TR", "WIG-CEE",
         "RESPECT")

any(!(without %in% tickery.gpw$V1)) #looking if anything is included 
any(!(exception %in% tickery.gpw$V1))

tickery.gpw <- filter(tickery.gpw, n.char<8)%>% # number of characters higher than 8
  select(-n.char)%>%
  apply(1, as.character)

bez.index <- matrix()
for (q in 1:length(without)) {bez.index[q] <-  match(without[q], tickery.gpw)

}

tickery <- tickery.gpw[-bez.index]%>%
  append(exception)%>%
  append(tickery.nc)%>%
  unique(tickery.gpw)%>%
  as.matrix(ncol = 1, byrow = TRUE)

# We have every name 
# script below goes in analogous way to the one before 

ticker <- tickery[1]       
urlnc2 <- "newconnect"       
urlgpw2 <- "ciagle"
url1 <- "https://info.bossa.pl/pub/"
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp.nc <- tempfile()                
temp.gpw <- tempfile()               

download.file(paste(url1,
                    urlnc2, 
                    urlnc,
                    sep = ""),  # putting into temp file
              temp.nc)
download.file(paste(url1,
                    urlgpw2, 
                    urlgpw,
                    sep = ""),
              temp.gpw)

total <- read.csv(unzip(temp.gpw, paste(ticker, ".mst", sep = "")))
total <- read.csv(unzip(temp.nc, paste(ticker, ".mst", sep = "")))

total$X.DTYYYYMMDD. <- ymd(total$X.DTYYYYMMDD.)              
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.) 
colnames(total) <- c("Date", tickery[1])

progress.bar <- winProgressBar("Unzipping files - Done in %", "0% Done", 0, 1, 0)

for(i in 2:nrow(tickery)) try({
  
  if(paste(tickery[i],".mst", sep = "") %in% unzip(temp.gpw, list = TRUE)$Name){
    stock <- read.csv(unzip(temp.gpw, paste(tickery[i], ".mst", sep = "")))
  } else {
    stock <- read.csv(unzip(temp.nc, paste(tickery[i], ".mst", sep = "")))
  }
  
  stock$X.DTYYYYMMDD. <- ymd(stock$X.DTYYYYMMDD.)                
  stock <- select(stock, Date = X.DTYYYYMMDD., Close = X.CLOSE.)
  colnames(stock) <- c("Date", tickery[i])
  total<-merge(total,stock,by="Date",all=TRUE)    
  
  # progres bar niżej tylko
  percentage <- i / length(tickery)
  setWinProgressBar(progress.bar, percentage, "Unzipping files - Done in %",
                    sprintf("%d%% Done", round(100 * percentage)))
})
unlink(temp.nc)
unlink(temp.gpw)
close(progress.bar)
proc.time()-ptm

tail(total)

######## Downloading data from local pc ##########

# path to folder to your folder with unzipped files 
setwd("C:/Users/HP/Documents/R/projekty/finansowe/akcje/kursy/akcje-gpw") 


ticker <- "DEKTRA"                                           

file1 <-  "~/R/projekty/finansowe/akcje/kursy/akcje-gpw/"     
file2 <- ".mst"                                                
url.caly <- paste(file1, ticker, file2, sep = "")
read.csv(url.caly,
         sep = ",",
         dec = ".",
         stringsAsFactors = F)

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


######## Downloading every historical data of shares from GPW and NC from local memory ######

# downloading list of names just like before
setwd("C:/Users/HP/Documents/R/projekty/finansowe/akcje/kursy/akcje-gpw") 

ptm <- proc.time()
tickery.nc <- read.csv("https://info.bossa.pl/pub/newconnect/mstock/sesjancn/sesjancn.prn",
                       header = FALSE,
                       sep = ",",
                       dec = ".",
                       stringsAsFactors = F)%>%
  select(V1)
tickery.nc <- tickery.nc[-length(tickery.nc),]


tickery.gpw <- read.csv("https://info.bossa.pl/pub/ciagle/mstock/sesjacgl/sesjacgl.prn",
                        header = FALSE,
                        sep = ",",
                        dec = ".",
                        stringsAsFactors = F)%>%
  select(V1)%>%
  mutate(n.char = nchar(V1))


wyjątki <- c("SILVAIR-REGS","GRUPAAZOTY","MDIENERGIA","MILLENNIUM","INVESTORMS","4FUNMEDIA",
             "ACAUTOGAZ", "APSENERGY","ASSECOPOL","ASSECOSEE","AUTOPARTN","BAHOLDING",
             "BIOMEDLUB", "CDPROJEKT", "CLNPHARMA", "CYFRPLSAT","EKOEXPORT","ELEKTROTI",
             "ELEMENTAL", "ENERGOINS","GETINOBLE","GINOROSSI","HOLLYWOOD","IMCOMPANY",
             "INSTALKRK","INTERAOLT", "INTERCARS", "INTERSPPL", "JWWINVEST", "K2INTERNT",
             "KOMPUTRON", "KONSSTALI", "KRUSZWICA", "KRVITAMIN", "LABOPRINT", "MAKARONPL",
             "MASTERPHA", "MEXPOLSKA", "MIRACULUM", "MOSTALPLC", "MOSTALWAR", "NORTCOAST",
             "NTTSYSTEM", "OPONEO.PL", "PCCROKITA", "PEMANAGER", "PLATYNINW", "PLAZACNTR",
             "POLIMEXMS", "PRAGMAINK", "PRIMETECH", "PROJPRZEM", "PROVIDENT", "RANKPROGR",
             "SANTANDER", "STALPROFI", "STARHEDGE", "UNICREDIT", "VENTUREIN", "WIRTUALNA",
             "IDMSA")

bez <- c("SANPL2", "WIGDIV","WIG30","SWIG80", "MWIG40","WIG30TR", "WIG20TR", "WIG-CEE",
         "RESPECT")

any(!(bez %in% tickery.gpw$V1)) 
any(!(wyjątki %in% tickery.gpw$V1))

tickery.gpw <- filter(tickery.gpw, n.char<8)%>%
  select(-n.char)%>%
  apply(1, as.character)

bez.index <- matrix()
for (q in 1:length(bez)) {bez.index[q] <-  match(bez[q], tickery.gpw)

}

tickery <- tickery.gpw[-bez.index]%>%
  append(wyjątki)%>%
  append(tickery.nc)%>%
  unique(tickery.gpw)%>%
  as.matrix(ncol = 1, byrow = TRUE)

# We have list of names and we download them just like before

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
for(i in 2:nrow(tickery)) try({
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
  setWinProgressBar(progress.bar, percentage, "Postep w %",
                    sprintf("%i%% zrobione", round(100 * percentage))) # ciagle progres bar
  
})
close(progress.bar)
proc.time()-ptm

tail(total)
sum(is.na(total))
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
  setWinProgressBar(progress.bar, percentage, "Done in %",
                    sprintf("%i%% Done", round(100 * percentage))) 
  
}
close(progress.bar)



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



