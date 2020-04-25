
######## Downloading every stock from bossa.pl ###########
# this script will make a folder in your working directory called "exit_directory" where stock data will be stored
# first we download a list of tickers from Nc and GPW 

everyWSE <- function(market = "both",
                      ohlcv = "Close",
                      info = FALSE){
  
  required_packages <- c("lubridate", "dplyr", "stringr", "xml2", "rvest", "magrittr")
  
  if(any(!(required_packages %in% installed.packages()[,"Package"]))){ 
    stop(paste("Required packages are not installed on local PC:", 
               required_packages[which(!(required_packages %in% installed.packages()[,"Package"]))]))
  }
  
  ptm <- proc.time()
  
  library(magrittr)
  # webscraping name of every company listed on WSE in the same format as in bossa.pl
  webs <- xml2::read_html("http://infostrefa.com/infostrefa/pl/spolki")
  tickery<- rvest::html_table(webs)[[2]]%>%
    dplyr::select(X2)%>%
    .[-which(.$X2 == ""),]%>%
    paste(".mst", sep = "")%>%
    .[-1]%>%
    as.matrix(ncol = 1, byrow = TRUE)
  
  closeAllConnections()
  
  gpw_tickers <- read.csv("https://info.bossa.pl/pub/ciagle/mstock/metacgl.lst", header = TRUE)%>%
    .[-c(1:2),]%>%
    stringr::str_split_fixed(" ", n = 10)%>%
    .[,9]%>%
    as.character()
  
  # delete from list tickers depending on desired market of stocks
  if(market == "nc"){ tickery <- tickery[-which(stringr::str_split_fixed(tickery, n = 2, ".mst")[,1] %in% gpw_tickers)]%>%
    as.matrix(ncol = 1, byrow = TRUE)} 
  if(market == "gpw"){ tickery <- tickery[which(stringr::str_split_fixed(tickery, n = 2, ".mst")[,1] %in% gpw_tickers)]%>%
    as.matrix(ncol = 1, byrow = TRUE)}
  
  # Downloading zip files of stocks from info.bossa.pl
  ticker <- tickery[1]       
  url1 <- "https://info.bossa.pl/pub/"
  
  if(market == "both" || market == "gpw"){
    
    urlgpw <- "/mstock/mstcgl.zip"
    urlgpw2 <- "ciagle"
    
    temp.gpw <- tempfile()  
    download.file(paste(url1,
                        urlgpw2, 
                        urlgpw,
                        sep = ""),
                  temp.gpw)
    
    temp.gpw2 <- tempfile()
    download.file("https://info.bossa.pl/pub/jednolity/f2/mstock/mstf2.zip", temp.gpw2)
  }
  
  if(market == "both" || market == "nc"){
    
    urlnc2 <- "newconnect" 
    urlnc <- "/mstock/mstncn.zip"
    
    temp.nc <- tempfile()    
    # there are 2 files from bossa.pl. For NC and for main platform stocks.
    download.file(paste(url1,
                        urlnc2, 
                        urlnc,
                        sep = ""),  # putting into temp file
                  temp.nc)}
  
  temp_exit_dir <- tempdir()
  
  # one of those will give error. Thas is because its hard to know if the first stock is from NC or main platform
  # so the script tries to read from both files.
  options(show.error.messages = FALSE)
  suppressWarnings(try(total <- read.csv(unzip(temp.gpw, paste(ticker), exdir = temp_exit_dir))))
  suppressWarnings(try(total <- read.csv(unzip(temp.gpw2, paste(ticker), exdir = temp_exit_dir))))
  suppressWarnings(try(total <- read.csv(unzip(temp.nc, paste(ticker), exdir = temp_exit_dir))))
  options(show.error.messages = TRUE)
  
  ohlcv_translator <- data.frame(bossa = c("X.OPEN.", "X.HIGH.", "X.LOW.", "X.CLOSE.", "X.VOL."),
                                 stooq = c("Open", "High", "Low", "Close", "Volume"), stringsAsFactors = FALSE)
  
  ohlcv <- ohlcv_translator[ohlcv_translator$stooq == ohlcv,1] # translate ohlc of stooq to bossa
  
  total$X.DTYYYYMMDD. <- lubridate::ymd(total$X.DTYYYYMMDD.)              
  total <- dplyr::select(total, Date = X.DTYYYYMMDD., value = ohlcv) 
  colnames(total) <- c("Date", tickery[1])
  
  progress.bar <- winProgressBar("Unzipping files - Done in %", "0% Done", 0, 1, 0)
  
  # Unzipping data of desired stocks
  options(show.error.messages = FALSE)
  for(i in 2:nrow(tickery)) try({
    
    if(market == "both"){ # suppressWarnings() is used because some stocks are not available in bossa.pl file. The file lacks several stocks
      if(paste(tickery[i]) %in% unzip(temp.gpw, list = TRUE)$Name){
        
        suppressWarnings(stock <- read.csv(unzip(temp.gpw, paste(tickery[i]), exdir = temp_exit_dir)))
        
      } else if(paste(tickery[i]) %in% unzip(temp.gpw2, list = TRUE)$Name){
        
        suppressWarnings(stock <- read.csv(unzip(temp.gpw2, paste(tickery[i]), exdir = temp_exit_dir)))
        
      } else {
        
        suppressWarnings(stock <- read.csv(unzip(temp.nc, paste(tickery[i]), exdir = temp_exit_dir)))
        
      }}
    
    if(market == "gpw"){ if(paste(tickery[i]) %in% unzip(temp.gpw, list = TRUE)$Name){
      suppressWarnings(stock <- read.csv(unzip(temp.gpw, paste(tickery[i]), exdir = temp_exit_dir)))
    } else {suppressWarnings(stock <- read.csv(unzip(temp.gpw2, paste(tickery[i]), exdir = temp_exit_dir)))}} 
    
    if(market == "nc"){suppressWarnings(stock <- read.csv(unzip(temp.nc, paste(tickery[i]), exdir = temp_exit_dir)))}
    
    stock$X.DTYYYYMMDD. <- lubridate::ymd(stock$X.DTYYYYMMDD.)                
    stock <- dplyr::select(stock, Date = X.DTYYYYMMDD., value = ohlcv)
    colnames(stock) <- c("Date", tickery[i])
    total <- merge(total,stock,by="Date",all=TRUE)    
    
    percentage <- i / length(tickery)
    setWinProgressBar(progress.bar, percentage, "Unzipping files - Done in %",
                      sprintf("%d%% Done", round(100 * percentage)))
  })
  
  
  close(progress.bar) 
  options(show.error.messages = TRUE)
  
  stock.names <- stringr::str_split_fixed(colnames(total),n = 2, ".mst")[,1]
  colnames(total) <- stock.names
  
  if(info == TRUE){
    info.df <- data.frame(ticker = stock.names, market = NA, ipo_date = NA)
    info.df[which(info.df$ticker %in% gpw_tickers),"market"] <- "gpw"
    info.df[-which(info.df$ticker %in% gpw_tickers),"market"] <- "nc"
    info.df$ipo_date <- apply(total, 2, function(x){which(!(is.na(x)))[1]})%>%
      as.numeric()
    info.df$ipo_date <- total$Date[info.df$ipo_date]
    
    total <- list(info = info.df, stock_prices = total)
  }
  
  rm(list = ls()[-which(ls() == "total")])
  
  return(total)
  unlink(c(temp.nc, temp.gpw, temp_exit_dir))
  
}

# To check which stocks are not present in bossa.pl file, load whole script without last function rm(...) and run:
# str_split_fixed(tickery,n = 2, ".mst")[which(!(str_split_fixed(tickery,n = 2, ".mst")[,1] %in% colnames(total))),1]

