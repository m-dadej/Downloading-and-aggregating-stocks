library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)
library(readtext)

######## Downloading every stock from bossa.pl (the best way so far) ###########
# first we download a list of tickers from Nc and GPW 

ptm <- proc.time()

tickery.gpw <- list.files("for_tickers_only_gpw")
n.char <- nchar(tickery.gpw)
tickery.gpw <- as.data.frame(tickery.gpw)%>%
  cbind(n.char)

filter(tickery.gpw, n.char==12)%>%
  select(-n.char)%>%
  as.matrix()%>%
  c()
  

tickery.nc <- list.files("for_tickers_only_nc")
# tickers are from folder "for_tickers_only" and should be updated after every ipo

# archive from bossa also contains data of futures and other unwanted stuff
# these unwanted securities have many letters usually
# we searched for securities below given threshold of letters to cut unwanted ones
# these shares below are exceptions (their names are also long)
# dont change it if you are 100% sure i missed some or if there was IPO.

exception <- read.csv("exceptions")%>%
  select("exceptions" = x)%>%
  as.matrix()
# some of the stocks above are not from main platform but the error is on the data provider side
# we dont want these because these are indexes
without <- c("WIGDIV.mst","WIG30.mst","SWIG80.mst", "MWIG40.mst","WIG30TR.mst", "WIG20TR.mst", "WIG-CEE.mst",
             "RESPECT.mst", "RCTLBEI.mst", "RCFL4RI.mst", "LMESFIZ.mst", "LMDSFIZ.mst", "LMCSFIZ.mst",
             "LMBSFIZ.mst", "LMASFIZ.mst")

any(!(without %in% tickery.gpw$tickery.gpw)) #looking if anything is included 
any(!(exception %in% tickery.gpw$tickery.gpw))

tickery.gpw <- filter(tickery.gpw, n.char < 12)%>% # number of characters higher than 8
  select(-n.char)%>%
  apply(1, as.character)

bez.index <- matrix()
for (q in 1:length(without)) {bez.index[q] <-  match(without[q], tickery.gpw)

}

tickery <- tickery.gpw[-bez.index]%>%
  append(exception)%>%
  append(tickery.nc)%>%
  unique(tickery.gpw)%>%
  as.matrix(ncol = 1, byrow = TRUE)%>%
  unique()


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

total <- read.csv(unzip(temp.gpw, paste(ticker), exdir = "exit_directory"))
total <- read.csv(unzip(temp.nc, paste(ticker), exdir = "exit_directory"))

total$X.DTYYYYMMDD. <- ymd(total$X.DTYYYYMMDD.)              
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.) 
colnames(total) <- c("Date", tickery[1])

progress.bar <- winProgressBar("Unzipping files - Done in %", "0% Done", 0, 1, 0)

for(i in 2:nrow(tickery)) try({
  
  if(paste(tickery[i]) %in% unzip(temp.gpw, list = TRUE)$Name){
    stock <- read.csv(unzip(temp.gpw, paste(tickery[i]), exdir = "exit_directory"))
  } else {
    stock <- read.csv(unzip(temp.nc, paste(tickery[i]), exdir = "exit_directory"))
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

stock.names <- str_split_fixed(colnames(total),n = 2, ".mst")[,1] # moze cos takiego
colnames(total) <- stock.names

unlink(temp.nc)
unlink(temp.gpw)
close(progress.bar)
proc.time()-ptm




