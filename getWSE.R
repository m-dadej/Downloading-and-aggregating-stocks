

getWSE <- function(tickers, 
                     ohlcv = "Close", 
                     from = "1991-04-16", 
                     to = Sys.Date(),
                     source = "stooq.pl",       # source of the data. "stooq.pl" or "bossa"
                     freq = "daily",
                     corpo_action = c()) {        
                    
  
  required_packages <- c("lubridate", "dplyr", "stringr")
  
  if(any(!(required_packages %in% installed.packages()[,"Package"]))){ 
    stop(paste("Required packages are not installed on local PC:", 
               required_packages[which(!(required_packages %in% installed.packages()[,"Package"]))]))
    }
  
  library(dplyr)
  
  if(source == "stooq.pl"){
    
    # dictionary to translate english ohlcv to pl ohlcv
    translate_ohlcv <- data.frame(pl_ohlcv = c("Data", "Otwarcie", "Najwyzszy", "Najnizszy", "Zamkniecie", "Wolumen"),
                                  en_ohlcv = c("Date", "Open", "High", "Low", "Close", "Volume"), stringsAsFactors = FALSE)
    # trasnalte ohlcv
    ohlcv <- translate_ohlcv[which(translate_ohlcv$en_ohlcv == ohlcv),1]
    
    # change date format to character yyyymmdd
    from_d <- as.character(from)%>%
      stringr::str_remove_all("-")
    to_d <- as.character(to)%>%
      stringr::str_remove_all("-")
    
    # frequency
    if(freq == "daily")     fr <- "d"
    if(freq == "weekly")    fr <- "w"
    if(freq == "monthly")   fr <- "m"
    if(freq == "quarterly") fr <- "q"
    if(freq == "yearly")    fr <- "y"
    
    # adjust for some corporate action
    full_corpo_action <- c("split", "div", "rights", "denomination")
    
    spl <- ifelse(any(corpo_action %in% full_corpo_action[1]), 0, 1)
    div <- ifelse(any(corpo_action %in% full_corpo_action[2]), 0, 1)
    right <- ifelse(any(corpo_action %in% full_corpo_action[3]), "000", "111")
    denom <- ifelse(any(corpo_action %in% full_corpo_action[4]), 0, 1)
    
    # full corporate actions binary code
    if("all" %in% corpo_action){
      corpo_adj <- "0000000"
    }else{
      corpo_adj <- paste(spl, div, right, denom, 0, sep = "")
      }
    
    # full url to download data
    url_ <- paste("https://stooq.pl/q/d/l/?s=", tickers[1],
                      "&d1=", from_d,
                      "&d2=", to_d,
                      "&i=", fr,
                      "&o=", corpo_adj,
                      sep = "")
    
    total <- read.csv(url_,
                      header = TRUE,
                      sep = ",",
                      dec = ".",
                      stringsAsFactors = F)
    
    total$Data <- lubridate::ymd(total$Data)    
    
    # if there is only one ticker to download, then retunred data frame consists of OHLC and vloume
    if(length(tickers)  > 1){ 
      
      total <- total[, c("Data", ohlcv)]           
      colnames(total) <- c("Data", tickers[1])   
      
      progress.bar <- winProgressBar(title = "Downloading data, Done in %,
                                 0% Done", 0, 100, 0) 
      
      for(i in 2:length(tickers)){
        
        url_ <- paste("https://stooq.pl/q/d/l/?s=", tickers[i],
                          "&d1=", from_d,
                          "&d2=", to_d,
                          "&i=", fr,
                          "&o=", corpo_adj,
                          sep = "")
        
        stock <- read.csv(url_,
                          header = TRUE,
                          sep = ",",
                          dec = ".",
                          stringsAsFactors = F)  
        
        stock$Data <- lubridate::ymd(stock$Data)                  
        stock <- stock[, c("Data", ohlcv)]         
        colnames(stock) <- c("Data", tickers[i])      
        
        total <- merge(total,stock,by="Data",all=TRUE)    
        
        percentage <- i / length(tickers)
        setWinProgressBar(progress.bar, percentage, "Downloading stocks - Done in %",
                          sprintf("%i%% Done", round(100 * percentage))) 
        
      }
      close(progress.bar)
      }
    
    return(total)
    
  }
  else
    {
      
    ticker <- tickers[1]      # above matrix consists of choosen stocks to be downloaded
    urlnc2 <- "newconnect"       
    urlgpw2 <- "ciagle"
    url1 <- "https://info.bossa.pl/pub/"
    urlnc <- "/mstock/mstncn.zip"
    urlgpw <- "/mstock/mstcgl.zip"
    
    temp.nc <- tempfile()                 # making a temp file for newconnect
    temp.gpw <- tempfile()                # and for GPW
    temp.gpw2 <- tempfile()
    temp_exit_dir <- tempdir()
    
    bossa_list_gpw <- read.csv("https://info.bossa.pl/pub/ciagle/mstock/metacgl.lst", header = TRUE)%>%
      .[-c(1:2),]%>%
      stringr::str_split_fixed(" ", n = 10)%>%
      .[,9]%>%
      as.character()%>%
      as.matrix(ncol = 1)
    
    bossa_list_gpw2 <- read.csv("https://info.bossa.pl/pub/jednolity/f2/mstock/mstf2.lst", header = TRUE)%>%
      .[-c(1:2),]%>%
      stringr::str_split_fixed(" ", n = 16)%>%
      .[,c(14:15)]%>%
      as.character()%>%
      as.matrix(ncol = 1)%>%
      .[-nrow(.),]%>%
      .[!. == ""]%>%
      stringr::str_split_fixed(".mst", n = 2)%>%
      .[,1]
    
    if(any(tickers %in% bossa_list_gpw)){ # check if any ticker is from main platform of WSE
      download.file(paste(url1,             # putting both into temp.file
                          urlgpw2, 
                          urlgpw,
                          sep = ""),        
                    temp.gpw)
      
      download.file("https://info.bossa.pl/pub/jednolity/f2/mstock/mstf2.zip", temp.gpw2)}
    
    bossa_list_nc <- read.csv("https://info.bossa.pl/pub/newconnect/mstock/sesjancn/sesjancn.prn",
                              header = FALSE, stringsAsFactors=FALSE)%>%
                              dplyr::select(V1)%>%
                              as.matrix()
    
    if (any(tickers %in% bossa_list_nc)) { # check if any ticker is from new connect
      download.file(paste(url1,
                          urlnc2, 
                          urlnc,
                          sep = ""),        
                    temp.nc)}
    
    if (!(any(tickers %in% c(bossa_list_nc, bossa_list_gpw)))) { # False if there is no tickers that are available
      stop("Provided tickers are wrong/not available in database")
    }
    # One of two commands below will give error. Its due to the first share being only from NC or GPW
    
    options(show.error.messages = FALSE)
    suppressWarnings(try(total <- read.csv(unzip(temp.gpw, paste(ticker, ".mst", sep = ""), exdir = temp_exit_dir))))
    suppressWarnings(try(total <- read.csv(unzip(temp.nc, paste(ticker, ".mst", sep = ""), exdir = temp_exit_dir))))
    suppressWarnings(try(total <- read.csv(unzip(temp.gpw2, paste(ticker, ".mst", sep = ""), exdir = temp_exit_dir))))
    options(show.error.messages = TRUE)
    
    if (length(tickers) > 1) {
      
      ohlcv_translator <- data.frame(bossa = c("X.OPEN.", "X.HIGH.", "X.LOW.", "X.CLOSE.", "X.VOL."),
                                     stooq = c("Open", "High", "Low", "Close", "Volume"), stringsAsFactors = FALSE)
      
      ohlcv <- ohlcv_translator[ohlcv_translator$stooq == ohlcv,1] # translate ohlc of stooq to bossa
      
      total$X.DTYYYYMMDD. <- lubridate::ymd(total$X.DTYYYYMMDD.)                 # making YYYYMMDD format
      total <- dplyr::select(total, Date = X.DTYYYYMMDD., value = ohlcv)  # This time we only take 1 variable from every share
      colnames(total) <- c("Date", tickers[1])
      
      progress.bar <- winProgressBar("unzipping files - Done in %", "0% Done", 0, 1, 0)
      
      for(i in 2:length(tickers)) try({
        
        # This time we have to choose good market.
        if(tickers[i] %in% bossa_list_gpw){
          
          stock <- read.csv(unzip(temp.gpw, paste(tickers[i], ".mst", sep = ""), exdir = temp_exit_dir))
          
        } else if(tickers[i] %in% bossa_list_gpw2){
          
          stock <- read.csv(unzip(temp.gpw2, paste(tickers[i], ".mst", sep = ""), exdir = temp_exit_dir))
          
        } else {
          
          stock <- read.csv(unzip(temp.nc, paste(tickers[i], ".mst", sep = ""), exdir = temp_exit_dir))
          
        }
        
        stock$X.DTYYYYMMDD. <- lubridate::ymd(stock$X.DTYYYYMMDD.)                  
        stock <- dplyr::select(stock, Date = X.DTYYYYMMDD., value = ohlcv)
        colnames(stock) <- c("Date", tickers[i])
        total<- merge(total,stock,by="Date",all=TRUE)    
        
        # progress bar below
        percentage <- i / length(tickers)
        setWinProgressBar(progress.bar, percentage, "unzipping data - done in %",
                          sprintf("%d%% Done", round(100 * percentage)))
      })
      unlink(temp.nc)
      unlink(temp.gpw)
      
      close(progress.bar)
      
    }else{ 
      total <- total[,-1]
      colnames(total) <- c("Date", "Open", "High", "Low", "Close", "Volume")
      total$Date <- lubridate::ymd(total$Date)
    }
    
    total <- dplyr::filter(total, Date >= from & Date <= to)
  
    return(total)
    }
  
}

#example:
#stock_data <- getWSE(tickers = c("DROP","DEKTRA", "PEKAO", "PKOBP", "GETIN", "DROP", "MOSTALZAB"), 
#                        ohlcv = "Close",
#                       from = "1999-01-01",
#                       to = "2015-01-01"
#                       source = "bossa")
