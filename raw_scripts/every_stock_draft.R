# loading dependent libraries
list.of.packages <- c("lubridate", "dplyr", "readtext", "stringr", "xml2", "rvest")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(dplyr)
######## Downloading every stock from bossa.pl (the best way so far) ###########
# this script will make a folder in your working directory called "exit_directory" where stock data will be stored
# first we download a list of tickers from Nc and GPW 

ptm <- proc.time()

# webscraping name of every company listed on WSE in the same format as in bossa.pl
webs <- xml2::read_html("http://infostrefa.com/infostrefa/pl/spolki")
tickery<- rvest::html_table(webs)[[2]]%>%
              select(X2)%>%
              .[-which(.$X2 == ""),]%>%
              paste(".mst", sep = "")%>%
              .[-1]%>%
              as.matrix(ncol = 1, byrow = TRUE)
closeAllConnections()

# Downloading zip files of stocks from info.bossa.pl
ticker <- tickery[1]       
urlnc2 <- "newconnect"       
urlgpw2 <- "ciagle"
url1 <- "https://info.bossa.pl/pub/"
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp.nc <- tempfile()                
temp.gpw <- tempfile()        
temp.gpw2 <- tempfile()

# there are 2 files from bossa.pl. For NC and for main platform stocks.
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
download.file("https://info.bossa.pl/pub/jednolity/f2/mstock/mstf2.zip", temp.gpw2)

temp_exit_dir <- tempdir()

# one of those will give error. Thas is because its hard to know if the first stock is from NC or main platform
# so the script tries to read from both files.
options(show.error.messages = FALSE)
suppressWarnings(try(total <- read.csv(unzip(temp.gpw, paste(ticker), exdir = temp_exit_dir))))
suppressWarnings(try(total <- read.csv(unzip(temp.nc, paste(ticker), exdir = temp_exit_dir))))
suppressWarnings(try(total <- read.csv(unzip(temp.gpw2, paste(ticker), exdir = temp_exit_dir))))
options(show.error.messages = TRUE)

total$X.DTYYYYMMDD. <- lubridate::ymd(total$X.DTYYYYMMDD.)              
total <- select(total, Date = X.DTYYYYMMDD., Close = X.CLOSE.) 
colnames(total) <- c("Date", tickery[1])

progress.bar <- winProgressBar("Unzipping files - Done in %", "0% Done", 0, 1, 0)

# Unzipping data of desired stocks
options(show.error.messages = FALSE)
for(i in 2:nrow(tickery)) try({
  
  # suppressWarnings() is used because some stocks are not available in bossa.pl file. The file lacks several stocks
  if(paste(tickery[i]) %in% unzip(temp.gpw, list = TRUE)$Name){
    suppressWarnings(stock <- read.csv(unzip(temp.gpw, paste(tickery[i]), exdir = temp_exit_dir)))
  } else if(paste(tickery[i]) %in% unzip(temp.gpw2, list = TRUE)$Name) {
    
    suppressWarnings(stock <- read.csv(unzip(temp.gpw2, paste(tickery[i]), exdir = temp_exit_dir)))
    
  } else {
   suppressWarnings( stock <- read.csv(unzip(temp.nc, paste(tickery[i]), exdir = temp_exit_dir)))
  }
  
  stock$X.DTYYYYMMDD. <- lubridate::ymd(stock$X.DTYYYYMMDD.)                
  stock <- select(stock, Date = X.DTYYYYMMDD., Close = X.CLOSE.)
  colnames(stock) <- c("Date", tickery[i])
  total <- merge(total,stock,by="Date",all=TRUE)    
  
  percentage <- i / length(tickery)
  setWinProgressBar(progress.bar, percentage, "Unzipping files - Done in %",
                    sprintf("%d%% Done", round(100 * percentage)))
})
options(show.error.messages = TRUE)

stock.names <- stringr::str_split_fixed(colnames(total),n = 2, ".mst")[,1]
colnames(total) <- stock.names

unlink(c(temp.nc, temp.gpw, temp_exit_dir))

close(progress.bar) 
proc.time()-ptm # timer
rm(list = ls()[-which(ls() == "total")]) # remove everything beside "total"

# To check which stocks are not present in bossa.pl file, load whole script without last function rm(...) and run:
# stringr::str_split_fixed(tickery,n = 2, ".mst")[which(!(str_split_fixed(tickery,n = 2, ".mst")[,1] %in% colnames(total))),1]


