
# simple function to scrap list of all stocks from WSE and their sector. Sector names are in polish.

getWSE_list <- function(){

  # checking dependencies and loading libraries
  required_packages <- c("rvest", "dplyr", "xml2")
  
  if(any(!(required_packages %in% installed.packages()[,"Package"]))){ 
    stop(paste("Required packages are not installed on local PC:", 
               required_packages[which(!(required_packages %in% installed.packages()[,"Package"]))]))
  }
  
  library(dplyr)

  webs <- xml2::read_html("http://infostrefa.com/infostrefa/pl/spolki")
  stock_list<- rvest::html_table(webs)[[2]]%>%
    dplyr::select(X2, X3, X5)%>%
    .[-which(.$X2 == ""),]%>%
    .[-1,]

  colnames(stock_list) <- c("stock_name", "ticker", "sector")
  closeAllConnections()
  
return(stock_list)
}

