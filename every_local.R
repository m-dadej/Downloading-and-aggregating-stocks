library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

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