library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

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