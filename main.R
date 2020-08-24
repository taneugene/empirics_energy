library(tidyverse)
library(data.table)
library(readxl)

download_file <- function(url){
  #' Function to download and unzip.
  #' hardcoded filename for the eia 860 data
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

readin <- function(fname, skip=2){
  #' Function to read in an excel file as a dataframe
  as.data.table(read_excel(fname, skip = skip))
}



# Make a directory called data
data_folder = "data"
dir.create(file.path(".", data_folder), showWarnings = T)

# Download data
urls <- c("https://www.eia.gov/electricity/data/eia860/xls/eia8602019ER.zip", # Raw EIA860 data. nonexhaustive, but seems includes all operating capacity since data started being collected
          "https://www.eia.gov/electricity/annual/xls/epa_04_02_a.xlsx",# Summary capacity data for fossil energy back 10 years
          "https://www.eia.gov/electricity/annual/xls/epa_04_02_b.xlsx", # Summary capacity data for renewables back 10 years
          "https://www.eia.gov/electricity/data/state/emission_annual.xls", # Emissions only back to 1990
          "https://www.eia.gov/totalenergy/data/browser/csv.php?tbl=T11.06", # weird url but ok, emissions back to 1973)
          "https://www.eia.gov/electricity/data/water/xls/cooling_summary_2018.xlsx", # Water data 2018, only source
          "https://www.eia.gov/electricity/data/water/xls/cooling_summary_2017.xlsx", # 2017
          "https://www.eia.gov/electricity/data/water/archive/xls/cooling_summary_2016.xlsx", #2016
          "https://www.eia.gov/electricity/data/water/archive/xls/cooling_summary_2015.xlsx", #2015
          "https://www.eia.gov/electricity/data/water/archive/xls/cooling_summary_2014.xlsx" #2014
)
fnames <- map(urls, download_file)

# Get the currently operating generators and the retired ones and outer join on columns
# Guesses for data types don't work well, so reading in all as text and then convert to numeric later
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
## Set keys
setkey(add, year, Technology)
setkey(subtract, year, Technology)
## Make sure there's a key for each year-technology pair
## (this is the hardest part since it's easy to overlook a bug until you plot)
cap <- as.data.table(expand_grid('year' = min(add[,year]):max(add[,year]), 'Technology' = unique(add[,Technology])))
setkey(cap, year, Technology)
## now merge in the additions and subtractions
cap <-  merge(cap,merge(add, subtract, all = TRUE),all.x = TRUE)
## If there were no additions or subtractions in a year of a technology, set to 0.
cap[is.na(capacity_additions), capacity_additions:= 0]
cap[is.na(capacity_subtractions), capacity_subtractions:= 0]
# Calculate the net capacity change and the cumulative build of generating capacity
cap_final <- cap[,.(net_capacity_change = capacity_additions-capacity_subtractions), by = key(cap)]
cap_final[, capacity := cumsum(net_capacity_change), by = Technology]

# Set colors to use for plotting graphs
## Set high level groups
color_key = list('other' = 'coral',
                 "coal" = "brown4",
                 'petroleum' = 'grey8',
                 'gas' = 'dimgrey',
                 'combined cycle' = 'tan4',
                 'waste' = 'red4',
                 'nuclear' = 'lightgoldenrod',
                 'hydro' = 'cornflowerblue',
                 'wind' = 'aliceblue',
                 'solar' = 'gold',
                 'geothermal' = 'brown2'
                 )
## Get a list of technologies
techs <-  unique(cap_final$Technology)
## Make a hash lookup for the set of 27 techs
colors <-  rep('coral', length(techs))
colors <-  setNames(colors, techs)
## Aggregate by types
cap_final[, tech := "other"]
cap_final[, color := "coral"]
## loop through the big categories and search for them in the technologies.
for (fuel in names(color_key)){
  # Make a second key for the 27 techs
  colors[grep(fuel,techs,ignore.case = TRUE)] = color_key[fuel]
  # add a column with the 10 techs
  cap_final[grep(fuel,Technology,ignore.case = TRUE), tech:=fuel]
  # add a column for the color
  cap_final[grep(fuel,Technology,ignore.case = TRUE), color:=color_key[fuel]]
}

# change tech to a factor(categories)
cap_final[,tech:= as.factor(tech)]
# reorder in order of pollution levels
cap_final[,tech := factor(cap_final[,tech],levels = names(color_key))]
# Change tech also to a factor
cap_final[,Technology:= as.factor(Technology)]
# Make a lookup from tech group to technology
key <-  unique(cap_final[,.(tech,Technology)])
setkey(key, tech)
# Change data types to factors then reset key
cap_final[,Technology := factor(cap_final[,Technology],levels = key[,Technology])]
cap_final[,color:= as.factor(color)]
setkey(cap_final, tech, Technology, year)
# Aggregate on the Technologies to small techs
cap_agg = cap_final[,.(capacity = sum(capacity)), , .(tech,year, color)]

# Unaggregated Technology stacked area chart
ggplot(cap_final, aes(x = year, y= capacity, fill = Technology)) +
  geom_area(position = 'stack') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1)) +
  ylab("Nameplate Capacity (MW)") +
  ggtitle("United States Electricity Generation Capacity by Technology and Year", subtitle = "source: EIA-860 data")
  # scale_fill_manual(values = colors)
ggsave('stacked_capacity_all.pdf', width = 16, height = 9)

# Unaggregated Technology stacked area chart as a proportion of total capacity
ggplot(cap_final, aes(x = year, y= capacity, fill = Technology)) +
  geom_area(position = 'fill') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1)) +
  ylab("Nameplate Capacity (% of total)") +
  ggtitle("United States Electricity Generation Capacity by Technology and Year", subtitle = "source: EIA-860 data")
  # scale_fill_manual(values = colors) +
ggsave('proportion_capacity_all.pdf', width = 16, height = 9)

# Aggregated Technology - color codedd
ggplot(cap_agg, aes(x = year, y= capacity, fill = tech)) +
  geom_area(position = 'stack') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1)) +
  ylab("Nameplate Capacity (MW)") +
  ggtitle("United States Electricity Generation Capacity by Technology and Year", subtitle = "source: EIA-860 data") +
  scale_fill_manual(values = color_key)
ggsave('stacked_capacity_agg.pdf', width = 16, height = 9)

# Aggregated Technology as % - color coded
ggplot(cap_agg, aes(x = year, y= capacity, fill = tech)) +
  geom_area(position = 'fill') +
  theme(legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 1)) +
  scale_fill_manual(values = color_key) +
  ylab("Nameplate Capacity (% of total)") +
  ggtitle("United States Electricity Generation Capacity by Technology and Year", subtitle = "source: EIA-860 data")
ggsave('proportion_capacity_agg.pdf', width = 16, height = 9)

##################
# Emissions by year
em = fread(fnames[[5]])
# Get the year and month by getting the quotient and remainder after dividing by 100
em[, `:=`(year = YYYYMM%/%100, month =  YYYYMM%%100)]
# Get the annual data which is coded as the 13th month in this dataset
em = em[!grepl('total',Description, ignore.case = TRUE) & month==13]
# Check everything is in the same units, convert to factor
em[,c('Unit', 'Description','Value'):= list(as.factor(Unit),as.factor(Description),as.numeric(Value))]
# Make missing values 0
em[is.na(Value), Value := 0]

# Make a color lookup (to make it look similar to above plot based on technology)
colors_co2 = c()
"%notin%" <- Negate("%in%")
for (des in unique(em$Description)){
  for (fuel in names(color_key)){
    if (grepl(fuel,des, ignore.case = T)){
      colors_co2[des] <- color_key[fuel]
    }
  }
  if (des %notin% names(colors_co2)){
    colors_co2[des] <-  'tomato4'
  }
}

# Plot emissions over time by technology of generator
ggplot(em, aes(x= year, y = Value, fill = Description))+
  geom_area(position = 'stack') +
  ggtitle("United States CO2 Emissions from Power Plants by Technology and Year", subtitle = "source: EIA-860 data") +
  ylab("Million Metric Tons of CO2") +
  scale_fill_manual(values = colors_co2)
ggsave('emissions.pdf', width = 16, height = 9)

#################
# Water consumption

# 5 data frames, one for each year from 2014-2018
h2ofnames = fnames[6:length(fnames)]
# Columns match up exactly so we can do this
h2o = rbindlist(map(h2ofnames, readin))
# Change data types
h2o[,`:=`(Year = as.integer(Year),
          Month = as.integer(Month),
          `Generator Primary Technology` = as.factor(`Generator Primary Technology`))]
# Set key
setkey(h2o,Year,`Generator Primary Technology`)
# Select the columns with the relevant data
cols = grep('Water.+Million', names(h2o), value = T)

# This command works for one column but not the other... one column is bound but not other.
# unsure how to fix this, so...
# h2o[, cols := lapply(.SD,nafill(.SD,fill = 0)), .SDcols = cols]

# Looks like hardcoding will be easier
# shorten the names of columns to make them easy to type
h2o[,"withdrawals":= get(cols[1])]
h2o[,"consumption":= get(cols[2])]
# Set nas to 0
h2o[is.na(withdrawals),withdrawals:=0]
h2o[is.na(consumption),consumption:=0]
# sum by the technology-year key
h2o_summary = h2o[,.(withdrawals = sum(withdrawals), consumption = sum(consumption)), by = key(h2o)]

# Plot water withdrawals over time by technology
ggplot(h2o_summary, aes(x = Year, y = withdrawals, fill = `Generator Primary Technology`)) +
  geom_area(position = 'stack') +
  ylab('Water Withdrawal Volume (Million Gallons)')  +
  ggtitle('Water withdrawal volume (Million Gallons)', subtitle = 'source: EIA Thermoelectric Cooling data')
ggsave('water_withdrawal.pdf')

# Plot water consumption over time by technology
ggplot(h2o_summary, aes(x = Year, y = consumption, fill = `Generator Primary Technology`)) +
  geom_area(position = 'stack') +
  ylab('Water Consumption Volume (Million Gallons)')  +
  ggtitle('Water Consumption volume (Million Gallons)', subtitle = 'source: EIA Thermoelectric Cooling data')
ggsave('water_consumption.pdf')


