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
library(rhandsontable)

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


# Read in short and long format examples
upload_format <- read_csv('upload_format.csv')

# Conditionally color the skin based on mode
skin <- ifelse(use_sqlite, 'red', 'blue')

# Timevis data prep



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


message('############ Done with global.R')
