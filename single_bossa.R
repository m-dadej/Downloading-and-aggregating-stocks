library(utils)

######## downloading historical data of a single stock #############
# In most cases, better alternative is to use script single_stooq, because this script takes longer due to the need of 
# downloading full zip file of stocks from a given market platform and unpacking it anyway. 
# It might be better if you hit the limit on stooq.pl
# this script will make a folder in your working directory called "exit_directory" where stock data will be stored

# downloaded data frame consists of OHLC, volume and date


ticker <- "XTPL"                     # Name of the company that will be recognized by bossa.pl (capital letters, no spaces)
rynek <- "newconnect"                # "newconnect" for newconnect and "ciagle" for GPW. !they have to match!
# these variables above are choosen by user

url1 <- "https://info.bossa.pl/pub/" # Some stock names lack or should not be in file with newconnect stocks. 99% are correct
urlnc <- "/mstock/mstncn.zip"
urlgpw <- "/mstock/mstcgl.zip"

temp <- tempfile()                   # making a temporary file
download.file(paste(url1,
                    rynek, 
                    ifelse(rynek == "newconnect", urlnc, urlgpw), # the link is different for nc and gpw
                    sep = ""),                                    # putting to temp file
              temp) 
df <- read.csv(unzip(temp, paste(ticker, ".mst", sep = ""), exdir = "exit_directory")) 
unlink(temp)
rm(rynek, temp, ticker, url1, urlgpw, urlnc)