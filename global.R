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

# Get the data from the db into memory
#SAH: Let's please depricate this.  Pulls in a lot of unncessary data and is time consuming to do it.
db_to_memory()

# Bring the fields from people into view_all_trips_people_meetings_venues
view_all_trips_people_meetings_venues <- expand_view_all(view_all_trips_people_meetings_venues = view_all_trips_people_meetings_venues)

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
skin <- 'blue'

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
#This should already be happening, see commented note in populate_images_from_www
#populate_images_from_www(pool = GLOBAL_DB_POOL) # www to db
populate_images_to_www() # db to www
images <- get_images()

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
