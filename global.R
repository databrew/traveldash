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

message('############ Done with package loading')
#setwd("C:/Users/SHeitmann/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
# Source all the functions in the R directory
functions <- dir('R')
message('Sourcing functions:')
for(i in 1:length(functions)){
  message('---', functions[i])
  this_function <- functions[i]
  if(!grepl('test', this_function)){
    source(paste0('R/', this_function), chdir = TRUE)
  }
}

# Define whether using postgresql or sqlite
use_sqlite <- FALSE

# Create a connection pool
GLOBAL_DB_POOL <- db_get_pool()

# Geocode the cities in the db if necessary 
# //SAH 2-22-2018: Called after upload or changes, should be unnecessary on app start-up and generate unnecessary db query each time
#geo_code_in_db(pool = pool,
#               use_sqlite = use_sqlite)


# Get the data from the db into memory
db_to_memory(pool = GLOBAL_DB_POOL)

# Bring the is_wbg field from people into view_all_trips_people_meetings_venues
view_all_trips_people_meetings_venues <- 
  view_all_trips_people_meetings_venues %>%
  # Create a "meeting with" column
  mutate(meeting_with = meeting_person_short_names,
         meeting_person_name = meeting_person_short_names,
         coincidence_person_name = meeting_person_short_names) %>%
  # Create a "person_name" column
  mutate(person_name = short_name) %>%
  # get whether the coincidence person is wbg too
  left_join(people %>%
              dplyr::select(person_id, is_wbg) %>%
              dplyr::rename(meeting_person_ids = person_id,
                            coincidence_is_wbg = is_wbg) %>%
              mutate(meeting_person_ids = as.character(meeting_person_ids)),
            by = 'meeting_person_ids')
  

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
expand_trips <- function(trips, cities, people, view_all_trips_people_meetings_venues){
  out <- list()
  for(i in 1:nrow(trips)){
    dates <- seq(trips$trip_start_date[i],
                 trips$trip_end_date[i],
                 by = 1)
    df <- trips[i,] %>% dplyr::select(trip_id, person_id, city_id, trip_uid)
    df1 <- df
    while(length(dates) > nrow(df)){
      df <- bind_rows(df, df1)
    }
    df$date <- dates
    out[[i]] <- df
  }
  df <- bind_rows(out)
  # Bring in venue
  df <- left_join(df,
                  view_all_trips_people_meetings_venues %>%
                    group_by(trip_uid) %>%
                    summarise(venue_name = dplyr::first(venue_name)) %>%
                    ungroup,
                  by = 'trip_uid')
  
  # Get rid of dulicates
  df <- df %>% dplyr::distinct(city_id, date,
                               venue_name) %>%
    arrange(city_id, date)
  # Get gap between previous days
  df <- df %>%
    group_by(city_id,venue_name) %>%
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
  old_df <- df
  df <- df %>%
    group_by(city_id, event_id) %>%
    summarise(start = min(date),
              end = max(date)) %>%
    ungroup
  # Get the cities (events)
  df <- left_join(df,
                  cities %>% 
                    dplyr::select(city_id, city_name),
                  by = 'city_id')
  # Get the event into
  df <- left_join(df, old_df, by = c('city_id', 'event_id'))
  
  # Remove non-event stuff
  df <- df %>% dplyr::filter(!is.na(venue_name) & venue_name != '' & venue_name != 'Unspecified Venue')
  
  # Make a content variale
  df <- df %>%
    mutate(content = ifelse(!is.na(venue_name) & venue_name != '',
                            venue_name,
                            city_name)) %>%
    mutate(content = ifelse(content == 'Unspecified Venue',
                            paste0('Unspecified event in ', city_name),
                            content))

  
  
  # Keep only one observation for each event
  df <- df %>%
    dplyr::distinct(city_id, event_id, start, end, city_name, content, .keep_all = TRUE)
  # Remove those with nothing
  df <- df %>%
    mutate(type = 'range',
           title = content) %>%
    mutate(group = 1)
  # Get the meetings in each event
  meetings <- view_all_trips_people_meetings_venues %>%
    dplyr::select(person_id, city_id, trip_group,
                  trip_start_date,
                  trip_end_date,
                  short_name,
                  agenda) %>%
    dplyr::mutate(content = paste0(short_name, 
                                   ifelse(!is.na(agenda) & agenda != '',
                                          ': ',
                                          ''), agenda)) %>%
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
                                people = people,
                                view_all_trips_people_meetings_venues = view_all_trips_people_meetings_venues)  
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

# function for jittering
# Jitter
joe_jitter <- function(x, zoom = 2){
  z <- (0.1 / (zoom/ 20))^2
  return(x + rnorm(n = length(x),
                   mean = 0,
                   sd = z))
}

# Syncronize the www photo storage with the database
populate_images_from_www(pool = GLOBAL_DB_POOL) # www to db
populate_images_to_www(pool = GLOBAL_DB_POOL) # db to www
images <- get_images(pool = GLOBAL_DB_POOL)

# Image manipulation
resourcepath <- paste0(getwd(),"/www")
maskc <- image_read("www/mask-circle.png")
masks <- image_read("www/mask-square.png")
mask <- image_composite(maskc, masks, "out") 

# Get app start time
app_start_time <- Sys.time()
app_start_time <- as.numeric(app_start_time)

# Overwrite "unsepcified venue"
view_all_trips_people_meetings_venues$venue_name[view_all_trips_people_meetings_venues$venue_name == 'Unspecified Venue'] <- NA

# Function for creating oleksiy-formatted date range
oleksiy_date <- function(date1, date2){
  if(date1 == date2){
    out <- format(date1, '%B %d, %Y')
  } else {
    the_dates <- c(date1, date2)
    the_dates <- sort(the_dates)
    the_months <- format(the_dates, '%B')
    the_days <- format(the_dates, '%d')
    the_years <- format(the_dates, '%Y')
    if(the_months[1] == the_months[2]){
      out <- paste0(the_months[1], 
                    ' ',
                    the_days[1], '-', the_days[2],
                    ', ',
                    the_years[1])
    } else {
      out <- paste0(format(the_dates[1], '%B %d, %Y'),
                    ' - ',
                    format(the_dates[2], '%B %d, %Y'))
    }
  }
  return(out)
}
oleksiy_date <- Vectorize(oleksiy_date)

message('############ Done with global.R')
