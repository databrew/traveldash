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
# There is also an "events" view 

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

# Geocode the cities in the db on first time
geo_code_cities_in_db <- FALSE
if(any(is.na(cities$longitude))){
  geo_code_cities_in_db <- TRUE
}
if(geo_code_cities_in_db){
  locations <- 
    paste0(ifelse(!is.na(cities$city_name),
                  paste0(cities$city_name, ', ', collapse = NULL),
                  ''),
           ifelse(!is.na(cities$country_name),
                  cities$country_name, ''))
  # Define which ones need to be geocoded
  need_geo <- which(is.na(cities$latitude))
  gc_list <- list()
  for(i in 1:length(need_geo)){
    message('geocoding')
    this_row <- need_geo[i]
    gc <- geocode_OSM(q = locations[this_row])$coords
    if(is.null(gc)){
      # If not geocodable, just use 0, 0
      gc <- data.frame(x = 0, y = 0)
    } else {
      gc <- data.frame(x = gc['x'], y = gc['y'])
    }
    gc_list[[i]] <- gc
  }
  gc <- bind_rows(gc_list)
  
  # Update the db
  city_ids <- cities$city_id[need_geo]
  conn <- poolCheckout(pool)
  for(i in 1:length(city_ids)){
    message(i)
    this_id <- city_ids[i]
    these_data <- gc[i,]
    longitude_statement <- paste0("UPDATE pd_wbgtravel.cities SET longitude = ",
                        these_data$x,
                        " WHERE city_id = ",
                        this_id,
                        ";")
    latitude_statement <- paste0("UPDATE pd_wbgtravel.cities SET latitude = ",
                                  these_data$y,
                                  " WHERE city_id = ",
                                  this_id,
                                  ";")
    dbSendQuery(conn = conn,
                statement = longitude_statement)
    dbSendQuery(conn = conn,
                statement = latitude_statement)
  }
  poolReturn(conn)
  # Get the newly updated cities into memory
  cities <- get_data(tab = 'cities',
                     schema = 'pd_wbgtravel',
                     connection_object = pool,
                     use_sqlite = use_sqlite) 
}

# Get the events view too
events <- get_data(tab = 'events',
                   schema = 'pd_wbgtravel',
                   connection_object = pool,
                   use_sqlite = use_sqlite) %>%
# Restructure like the events table
  dplyr::rename(Person = short_name,
                Organization = organization,
                `City of visit` = city_name,
                `Country of visit` = country_name,
                Counterpart = trip_reason,
                `Visit start` = trip_start_date,
                `Visit end` = trip_end_date,
                Lat = latitude,
                Long = longitude,
                Event = meeting_topic) %>%
  dplyr::select(Person, Organization, `City of visit`, `Country of visit`,
                Counterpart, `Visit start`, `Visit end`, Lat, Long, Event)

# Create a dataframe for dicting day numbers to dates
date_dictionary <-
  data_frame(date = seq(as.Date('2017-01-01'),
                        as.Date('2018-12-31'),
                        1))
date_dictionary <- date_dictionary %>%
  mutate(day_number = 1:nrow(date_dictionary))

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

# Read in short and long format examples
short_format <- read_csv('short_format.csv')
long_format <- read_csv('long_format.csv')

# Conditionally color the skin based on mode
skin <- ifelse(use_sqlite, 'red', 'blue')

message('############ Done with global.R')

