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

# Create a dataframe for dicting day numbers to dates
date_dictionary <-
  data_frame(date = seq(as.Date('2017-01-01'),
                        as.Date('2018-12-31'),
                        1))
date_dictionary <- date_dictionary %>%
  mutate(day_number = 1:nrow(date_dictionary))

# Read in short and long format examples
upload_format <- read_csv('upload_format.csv')

# Skin of header
skin <- 'blue'

# Detect which database
creds <- credentials_extract()
creds <- creds[names(creds) %in% c('dbname', 'host')]
creds <- paste0(paste0(#unlist(names(creds)), 
                       # ' : ', 
                       unlist(creds)), collapse = '\n')

message('Using the following credentials:')
message(creds)

# Load up venue types (since all sessions use it)
venue_types <- get_data(tab = 'venue_types',
                        schema = 'pd_wbgtravel')

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




message('############ Done with global.R')
