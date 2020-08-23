library(tidyverse)
library(data.table)
library(readxl)

# Make a directory called data
data_folder = "data"
dir.create(file.path(".", data_folder), showWarnings = T)

# Download data
urls <- c("https://www.eia.gov/electricity/data/eia860/xls/eia8602019ER.zip",
          "https://www.eia.gov/electricity/annual/xls/epa_04_02_a.xlsx",
          "https://www.eia.gov/electricity/annual/xls/epa_04_02_b.xlsx")

# Function to download and unzip
download_file <- function(url){
  fname <- file.path(data_folder, basename(url))
  if (!file.exists(fname)){
    download.file(url, fname)
  }
  # Unzip the eia 860 data only [hardcoded]
  if (str_detect(fname,'zip')){
    unzip(fname, exdir = data_folder)
    fname <- "data/3_5_Multifuel_Y2019_Early_Release.xlsx"
  }
  return(fname)
}

fnames <- urls %>%
  map(download_file)

operable <- read_excel("data/3_5_Multifuel_Y2019_Early_Release.xlsx",
                       sheet = "Operable",
                       col_types = c("numeric", "text", "numeric", "text", "text", "text", "text", "text", "text", "text", "text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "text", "numeric", "numeric", "numeric", "numeric", "text", "text", "text", "text", "text", "text"),
                       skip = 2)
retired <- read_excel("data/3_5_Multifuel_Y2019_Early_Release.xlsx",
                      sheet = "Retired and Canceled",
                      skip = 2)



