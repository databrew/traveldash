library(RColorBrewer)
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
library(readxl)
library(htmlTable)

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

# Geocode the cities in the db if necessary 
geo_code_in_db(pool = pool,
               use_sqlite = use_sqlite)

# Get the data from the db into memory
db_to_memory(pool = pool)

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
    out <- floor_date(x %m-% months(1), unit = 'month')
  }
  return(out)
}
get_end_date <- function(x){
  day <- as.numeric(format(x, '%d'))
  month <- as.numeric(format(x, '%m'))
  year <- as.numeric(format(x, '%Y'))
  if(day > 15){
    out <- ceiling_date(x %m+% months(1), unit = 'month') - 1
  } else {
    out <- ceiling_date(x, unit = 'month') -1 
  }
  return(out)
}

# Read in short and long format examples
upload_format <- read_csv('upload_format.csv')

# Conditionally color the skin based on mode
skin <- ifelse(use_sqlite, 'red', 'blue')

# Timevis data prep
# Get all "events" - which are any period in which someone is at a place continuously
expand_trips <- function(trips, cities, people){
  out <- list()
  for(i in 1:nrow(trips)){
    dates <- seq(trips$trip_start_date[i],
                 trips$trip_end_date[i],
                 by = 1)
    df <- trips[i,] %>% dplyr::select(trip_id, person_id, city_id)
    df1 <- df
    while(length(dates) > nrow(df)){
      df <- bind_rows(df, df1)
    }
    df$date <- dates
    out[[i]] <- df
  }
  df <- bind_rows(out)
  # Get rid of dulicates
  df <- df %>% dplyr::distinct(city_id, date) %>%
    arrange(city_id, date)
  # Get gap between previous days
  df <- df %>%
    group_by(city_id) %>%
    mutate(date_dif = date - dplyr::lag(date, 1)) %>% ungroup
  # Get a "event_id"
  df$event_id <- NA
  df$event_id[1] <- 1
  for(i in 2:nrow(df)){
    df$event_id[i] <- 
      ifelse(any(is.na(df$date_dif[i]), df$date_dif[i] > 1),
             df$event_id[i-1] + 1,
             df$event_id[i-1])
  }
  # Group by event id and get start / end
  df <- df %>%
    group_by(city_id, event_id) %>%
    summarise(start = min(date),
              end = max(date)) %>%
    ungroup
  # Get the cities (events)
  df <- left_join(df,
                  cities %>% 
                    dplyr::select(city_id, city_name),
                  by = 'city_id') %>%
    dplyr::mutate(content = city_name) %>%
    mutate(type = 'range',
           title = city_name) %>%
    mutate(group = 1)
  # Get the meetings in each event
  meetings <- trips %>%
    dplyr::select(person_id, city_id, #trip_group,
                  trip_start_date,
                  trip_end_date) %>%
    left_join(people %>% dplyr::select(person_id, 
                                       short_name),
              by = 'person_id') %>%
    dplyr::mutate(content = paste0(short_name, 
                                   ': ')) %>% #, 
                                   # trip_group)) %>%
    left_join(df %>% dplyr::select(-content,
                                   -type)) %>%
    # Keep only those dates which fall in the range
    filter(trip_start_date >= start,
           trip_end_date <= end) %>%
    mutate(group = 2) %>%
    mutate(type = 'point')
  meetings <- meetings[,names(df)]
  # Combine everything
  df <- bind_rows(df, meetings)
  df$id <- 1:nrow(df)
  df$subgroup <- df $event_id
  cols <- colorRampPalette(brewer.pal(8, 'Dark2'))(length(unique(df$subgroup)))
  df$style <- paste0('color: ', cols[df$subgroup], ';')
  df <- df %>% arrange(start, city_name)
  # Make 23 hour event for those which are events
  df$start <- as.POSIXct(df$start)
  df$end <- as.POSIXct(df$end)
  df$end[df$group == 1] <- df$end[df$group == 1] + hours(23)
  return(df)
}
expanded_trips = expand_trips(trips = trips,
                              cities = cities,
                              people = people)


message('############ Done with global.R')

