library(maps)
library(tidyverse)
library(sp)
library(shinyjs)
library(shiny)
library(shinydashboard)
library(dplyr)
library(nd3) # devtools::install_github('databrew/nd3)
# use dev version: christophergandrud/networkD3 due to this issue: https://stackoverflow.com/questions/46252133/shiny-app-showmodal-does-not-pop-up-with-rendersankeynetwork
library(leaflet)
library(tidyverse)
library(googleVis)
library(DT)
library(data.table)
#library(googlesheets)
library(DBI)
library(yaml)
library(httr)
library(tmaptools)
library(RPostgreSQL)
library(pool) # devtools::install_github("rstudio/pool")
library(leaflet.extras)
library(RSQLite)
library(timevis)
library(lubridate)

message('############ Done with package loading')
#setwd("C:/Users/SHeitmann/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
# Source all the functions in the R directory
functions <- dir('R')
for(i in 1:length(functions)){
  source(paste0('R/', functions[i]), chdir = TRUE)
}

# Define whether using postgresql or sqlite
use_sqlite <- FALSE
if(use_sqlite){
  message('In "sqlite mode"')
} else {
  message('In "Postgres mode"')
}

# Create a connection pool
pool <- create_pool(options_list = credentials_extract(),
                    use_sqlite = use_sqlite)

# The database lay-out is as follows:
#    Schema    |     Name      | Type  |  Owner  
# --------------+---------------+-------+---------
# pd_wbgtravel | cities        | table | joebrew
# pd_wbgtravel | people        | table | joebrew
# pd_wbgtravel | trip_meetings | table | joebrew
# pd_wbgtravel | trips         | table | joebrew

# Read in all tables
tables <- dbListTables(pool)
for (i in 1:length(tables)){
  this_table <- tables[i]
  message(paste0('Reading in the ', this_table, ' from the database and assigning to global environment.'))
  x <- get_data(tab = this_table,
                schema = 'pd_wbgtravel',
                connection_object = pool,
                use_sqlite = use_sqlite)
  assign(this_table,
         x,
         envir = .GlobalEnv)
}

# Get the events view too
events <- get_data(tab = 'events',
                   schema = 'pd_wbgtravel',
                   connection_object = pool,
                   use_sqlite = use_sqlite)

# Restructure like the events table
events <- events %>%
  dplyr::rename(Person = short_name,
                Organization = organization,
                `City of visit` = city_name,
                `Country of visit` = country_name,
                Counterpart = trip_reason,
                `Visit start` = trip_start_date,
                `Visit end` = trip_end_date,
                Lat = latitude,
                Long = longitude,
                Event = topic) %>%
  dplyr::select(Person, Organization, `City of visit`, `Country of visit`,
                Counterpart, `Visit start`, `Visit end`, Lat, Long, Event)

# Create an events table from the db tables
# Person, Organization, City of visit, Country of visit, Counterpart, Visit start, Visit end, Lat, Long, Event

# Create an events view
# events <- trip_meetings %>%
#   left_join(trips  %>% dplyr::select(-time_created),
#             by = c('travelers_trip_id' = 'trip_id')) %>%
#   left_join(people %>% dplyr::select(-time_created),
#                by = 'person_id') %>%
#   # Get into on cities
#   left_join(cities, by = 'city_id') %>%
#   dplyr::rename(Person = short_name,
#                 Organization = organization,
#                 `City of visit` = city_name,
#                 `Country of visit` = country_name,
#                 Counterpart = trip_reason,
#                 `Visit start` = trip_start_date,
#                 `Visit end` = trip_end_date,
#                 Lat = latitude,
#                 Long = longitude,
#                 Event = topic) %>%
#   dplyr::select(Person, Organization, `City of visit`, `Country of visit`, 
#                 Counterpart, `Visit start`, `Visit end`, Lat, Long, Event)
#   

## Define static objects for selection
# people <- sort(unique(events$Person))
# organizations <- sort(unique(events$Organization))
# cities <- sort(unique(events$`City of visit`))
# counterparts <- sort(unique(events$Counterpart))
# countries <- sort(unique(events$`Country of visit`))

# # Create a dataframe for dicting day numbers to dates
# date_dictionary <-
#   data_frame(date = seq(as.Date('2017-01-01'),
#                         as.Date('2018-12-31'),
#                         1)) 
# date_dictionary <- date_dictionary %>%
#   mutate(day_number = 1:nrow(date_dictionary))

# Define functions for getting start and end date (appropriate range)
get_start_date <- function(x){
  day <- as.numeric(format(x, '%d'))
  month <- as.numeric(format(x, '%m'))
  year <- as.numeric(format(x, '%Y'))
  if(day > 15){
    out <- floor_date(x, unit = 'month')
  } else {
    out <- floor_date(x - months(1), unit = 'month')
  }
  return(out)
}
get_end_date <- function(x){
  day <- as.numeric(format(x, '%d'))
  month <- as.numeric(format(x, '%m'))
  year <- as.numeric(format(x, '%Y'))
  if(day > 15){
    out <- ceiling_date(x + months(1), unit = 'month') - 1
  } else {
    out <- ceiling_date(x, unit = 'month')
  }
  return(out)
}


# Example data
example_upload_data <- read_csv('example-upload-data.csv')

message('############ Done with global.R')

skin <- ifelse(use_sqlite, 'red', 'blue')
