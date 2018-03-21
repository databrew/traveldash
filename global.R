# events placeholder
events <- data.frame(a = 1:3,
                     b = 2:4)

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
library(Roxford)
library(png)
library(jpeg)


# Read in dropbox auth
library(rdrop2)
token <- readRDS("droptoken.rds")

message('############ Done with package loading')
#setwd("C:/Users/SHeitmann/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
# Source all the functions in the R directory
functions <- dir('R')
for(i in 1:length(functions)){
  this_function <- functions[i]
  if(!grepl('test', this_function)){
    source(paste0('R/', this_function), chdir = TRUE)
  }
}

# Define whether using postgresql or sqlite
use_sqlite <- FALSE

# Create a connection pool
pool <- create_pool(options_list = credentials_extract(),
                    use_sqlite = use_sqlite)

# Geocode the cities in the db if necessary 
# //SAH 2-22-2018: Called after upload or changes, should be unnecessary on app start-up and generate unnecessary db query each time
#geo_code_in_db(pool = pool,
#               use_sqlite = use_sqlite)


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
    dplyr::select(person_id, city_id, trip_group,
                  trip_start_date,
                  trip_end_date) %>%
    left_join(people %>% dplyr::select(person_id, 
                                       short_name),
              by = 'person_id') %>%
    dplyr::mutate(content = paste0(short_name, 
                                   ': ', trip_group)) %>%
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


make_empty <- function(cn){
  d <- as.data.frame(x = t(rep(NA, length(cn))), stringsAsFactors = FALSE)
  names(d) <- cn
  d <- d[0,]
  return(d)
}
if(nrow(cities) == 0){
  cn <- c("city_id", "city_name", "country_name", "latitude", "longitude")
  cities <- make_empty(cn)
}
if(nrow(people) == 0){
  cn <- c("person_id", "full_name", "short_name", "title", "organization", "sub_organization", "image_file", "is_wbg", "time_created")
  people <- make_empty(cn)
}
# if(nrow(trip_meetings) == 0){
#   cn <- c("meeting_person_id", "travelers_trip_id", "description", "meeting_venue_id", "agenda", "stag_flag")
#   trip_meetings <- make_empty(cn)
# }
if(nrow(trips) == 0){
  cn <- c("trip_id", "person_id", "city_id", "trip_start_date", "trip_end_date", "time_created", "created_by_user_id", "trip_group_id", "trip_group", "trip_uid")
  trips <- make_empty(cn)
}
if(nrow(view_trip_coincidences) == 0){
  cn <- c("created_by_user_id", "trip_id", "city_id", "person_id", "person_name", "is_wbg", "organization", "city_name", "country_name", "trip_start_date", "trip_end_date", "trip_group", "coincidence_trip_id", "coincidence_city_id", "coincidence_person_id", "coincidence_person_name", "coincidence_is_wbg", "coincidence_organization", "coincidence_city_name", "coincidence_country_name", "coincidence_trip_group", "has_coincidence", "is_colleague_coincidence", "has_meeting", "is_stag_meeting", "meeting_person_name", "meeting_venue", "meeting_venue_type", "meeting_agenda", "trip_meeting_agenda_id")
  view_trip_coincidences <- make_empty(cn)
}
if(nrow(view_trips_and_meetings) == 0){
  cn <- c("is_wbg", "short_name", "organization", "title", "sub_organization", "country_name", "city_name", "trip_group", "trip_start_date", "trip_end_date", "meeting_with", "meeting_agenda")
  view_trips_and_meetings <- make_empty(cn)
}

if(nrow(trips) > 0){
  expanded_trips = expand_trips(trips = trips,
                                cities = cities,
                                people = people)  
} else {
  expanded_trips <- data_frame(city_id = 1,
                               event_id = 1,
                               start = Sys.Date(),
                               end = Sys.Date(),
                               city_name = 'DC',
                               content = 'DC',
                               type = 'DC',
                               title = 'DC',
                               group = 1,
                               id = 1,
                               subgroup = 1,
                               style = 'DC') %>%
    sample_n(0)
}

# Detect which database
creds <- credentials_extract()
creds <- creds[names(creds) %in% c('dbname', 'host')]
creds <- paste0(paste0(#unlist(names(creds)), 
                       # ' : ', 
                       unlist(creds)), collapse = '\n')

message('Using the following credentials:')
message(creds)
message('############ Done with global.R')

# function for jittering
# Jitter
joe_jitter <- function(x, zoom = 2){
  z <- (0.1 / (zoom/ 20))^2
  return(x + rnorm(n = length(x),
                   mean = 0,
                   sd = z))
}

# Create a table of names / photos, conditional on what is available in dropbox
# and already stored locally
create_photos_df <- function(){
  photos <- data_frame(person = sort(unique(people$short_name))) %>%
    mutate(file_name = paste0(person, '.png'))
  drop_photos <- drop_dir(dtoken = token)
  photos <- left_join(photos,
                      drop_photos,
                      by = c('file_name' = 'name')) %>%
    mutate(file_name = ifelse(is.na(path_lower), 'NA.png', file_name)) %>%
    dplyr::select(person,
                  file_name)
  return(photos)
}
photos <- create_photos_df()
# populate the tmp folder with photos
populate_tmp <- function(photos){
  not_na <- which(photos$file_name != 'NA.png')
  lnn <- length(not_na)
  for (i in 1:lnn){
    message('--- downloading photo ', i, ' of ', lnn)
    this_index <- not_na[i]
    this_file <- photos$file_name[this_index]
    drop_download(this_file,
                  local_path = 'tmp',
                  overwrite = TRUE,
                  dtoken = token)
  }
}
populate_tmp(photos = photos)
