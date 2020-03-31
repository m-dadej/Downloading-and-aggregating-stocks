library(utils)

######## Downloading historical data of one given share from stooq.pl ##############

# link constructed below should look like : "https://stooq.pl/q/d/l/?s=ccc&i=d" (dla CCC)

ticker <- "11b"                          #choosen ticker different than previous examples      
url2 <- "&i=d" # url kończący
url.caly <- paste("https://stooq.pl/q/d/l/?s=", ticker, url2, sep = "")
df <- read.csv(url.caly,
         header = FALSE,
         sep = ",",
         dec = ".",
         stringsAsFactors = F)
rm(ticker, url.caly, url2)
