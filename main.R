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
    fname <- "data/3_1_Generator_Y2019_Early_Release.xlsx"
  }
  return(fname)
}

# Get the currently operating generators and the retired ones and outer join on columns
# Guesses for data types don't work well, read in all as text and then convert to numeric later
operable = as.data.table(read_excel(fnames[[1]], sheet = "Operable", skip = 2,col_types = 'text'))
retired = as.data.table(read_excel(fnames[[1]], sheet = "Retired and Canceled", skip = 2,col_types = 'text'))
df = rbindlist(list(operable, retired), use.names = T, fill =  T, idcol = T)
rm(operable,retired)

# Convert all columns which are labelled with 'Plant Code', has 'MW', 'Year', or 'Month' to numeric data type,
df
