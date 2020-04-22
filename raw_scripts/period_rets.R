period_rets <- function(t, rets, freq){
  
  library(dplyr)
  library(lubridate)
  if (!freq %in% c("yearly", "quarterly", "monthly", "weekly")) {
    stop("freq argument have to be one of: c('yearly', 'quarterly', 'monthly', 'weekly')" )
  }
  
  df <- data.frame(t,rets)
  
  if (freq == "yearly") {
    
    df<- df%>%
      mutate(t = year(t))%>%
      group_by(t)%>%
      summarise(tot_ret = prod(rets+1, na.rm = TRUE))%>%
      as.data.frame()
    
    return(df)
    
  }
  
  if (freq == "monthly") {
    
    df <- df%>%
      mutate(year_ = year(t),
             month_ = month(t))%>%
      mutate(year_month = as.Date(with(., paste(.$year_, month_, 01,sep="-")), "%Y-%m-%d"))%>%
    group_by(year_month)%>%
      summarise(tot_ret = prod(rets+1, na.rm = TRUE))%>%
      as.data.frame()
    
    return(df)
  }
  
  if (freq == "quarterly") {
    
    df <-  df%>%
      mutate(year_ = year(t),
             quarter_ = quarter(t))%>%
      mutate(year_quarter = paste0(substring(year_,1,4),"/0",quarter_))%>%
      group_by(year_quarter)%>%
      summarise(t = t[1], tot_ret = prod(rets+1, na.rm = TRUE))%>%
      select(t, tot_ret)%>%
      as.data.frame()
    
    return(df)
    
  }
  
  if(freq == "weekly"){
    
    df <-  df%>%
      mutate(year_ = year(t),
             week_ = week(t))%>%
      mutate(year_week = paste(substr(year_,1,4), sprintf("%02d", week_), sep="/"))%>%
      group_by(year_week)%>%
      summarise(t = t[1], tot_ret = prod(rets+1, na.rm = TRUE))%>%
      select(t, tot_ret)%>%
      as.data.frame()
    
    return(df)
    
  }
  
}