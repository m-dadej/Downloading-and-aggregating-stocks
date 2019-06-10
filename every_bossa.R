library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

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
without <- c("WIGDIV","WIG30","SWIG80", "MWIG40","WIG30TR", "WIG20TR", "WIG-CEE",
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
