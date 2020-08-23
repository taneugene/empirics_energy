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
operable <-  as.data.table(read_excel(fnames[[1]], sheet = "Operable", skip = 2,col_types = 'text', na = 'NA'))
retired <-  as.data.table(read_excel(fnames[[1]], sheet = "Retired and Canceled", skip = 2,col_types = 'text', na = 'NA'))
df <-  rbindlist(list(operable, retired), use.names = T, fill =  T, idcol = T)
rm(operable,retired)

# Convert all columns which are labelled with 'Plant Code', has 'MW', 'Year', or 'Month' to numeric data type.
num_cols <-  colnames(df)[grep("MW|Plant Code|Year|Month|Factor|Buoys", colnames(df), ignore.case=T)]
df[, (num_cols):= lapply(.SD, as.numeric), .SDcols = num_cols]

# Get a sum of new and retiring capacity year on year (new variable) by technology
setkey(df, "Operating Year", Technology)
add <- df[!is.na(`Operating Year`),.(year = `Operating Year`,capacity_additions = sum(`Nameplate Capacity (MW)`,na.rm = T)), by = .(`Operating Year`, Technology)]
subtract <-  df[!is.na(`Retirement Year`),.(year = `Retirement Year`,capacity_subtractions = sum(`Nameplate Capacity (MW)`,na.rm = T)), by = .(`Retirement Year`, Technology)]

# Join the additions and subtractions
setkey(add, year, Technology)
setkey(subtract, year, Technology)
# Make sure there's an entry for each year-technology pair
# (this is the hardest part since you don't know there's a bug until you plot)
cap <- as.data.table(expand_grid('year' = min(add[,year]):max(add[,year]), 'Technology' = unique(add[,Technology])))
setkey(cap, year, Technology)
cap <-  merge(cap,merge(add, subtract, all = TRUE),all.x = TRUE)

# If there were no additions or subtractions in a year of a technology, set to 0.
cap[is.na(capacity_additions), capacity_additions:= 0]
cap[is.na(capacity_subtractions), capacity_subtractions:= 0]
# Add the additions and retirements and cancellations
cap_final <- cap[,.(net_capacity_change = capacity_additions-capacity_subtractions), by = key(cap)]
cap_final[, capacity := cumsum(net_capacity_change), by = Technology]

# Plot the data

ggplot(cap_final, aes(x = year, y= capacity, fill = Technology)) +
  geom_area(position = 'stack') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1))
ggsave('stacked_capacity_all.pdf', width = 16, height = 9)

ggplot(cap_final, aes(x = year, y= capacity, fill = Technology)) +
  geom_area(position = 'fill') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1))
ggsave('proportion_capacity_all.pdf', width = 16, height = 9)




