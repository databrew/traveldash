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
library(googlesheets)
library(DBI)
library(yaml)
library(httr)
library(tmap)
library(tmaptools)
message('############ Done with package loading')

# Source all the functions in the R directory
functions <- dir('R')
for(i in 1:length(functions)){
  source(paste0('R/', functions[i]), chdir = TRUE)
}

# Define whether using database or google
use_google <- FALSE

# Read in data (either from google or database, depending on above)
if(use_google){
  # Read in data from google sheets
  data_url <- gs_url('https://docs.google.com/spreadsheets/d/13m0gMUQ2cQOoxPQgO2A7EESm4pG3eftTCGOdiH-0W6Y/edit#gid=0')
  events <- gs_read_csv(data_url)  
} else {
  # Read in data from the database
  events <- get_data(tab = 'dev_events')
}

# Define static objects for selection
people <- sort(unique(events$Person))
organizations <- sort(unique(events$Organization))
cities <- sort(unique(events$`City of visit`))
counterparts <- sort(unique(events$Counterpart))
countries <- sort(unique(events$`Country of visit`))


# Create a dataframe for dicting day numbers to dates
date_dictionary <-
  data_frame(date = seq(as.Date('2017-01-01'),
                        as.Date('2018-12-31'),
                        1)) 
date_dictionary <- date_dictionary %>%
  mutate(day_number = 1:nrow(date_dictionary))

# Example data
example_upload_data <- read_csv('example-upload-data.csv')

message('############ Done with global.R')
