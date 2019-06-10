library(lubridate)
library(dplyr)
library(readtext)
library(stringr)
library(readr)
library(readxl)

######## Downloading data from local pc ##########

# path to folder to your folder with unzipped files 
setwd("C:/Users/HP/Documents/R/projekty/finansowe/akcje/kursy/akcje-gpw") 


ticker <- "DEKTRA"                                           

file1 <-  "~/R/projekty/finansowe/akcje/kursy/akcje-gpw/"     
file2 <- ".mst"                                                
url.caly <- paste(file1, ticker, file2, sep = "")
read.csv(url.caly,
         sep = ",",
         dec = ".",
         stringsAsFactors = F)
