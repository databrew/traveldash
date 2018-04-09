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
library(XLConnect)

# Source all the functions in the R directory
functions <- dir('R')
message('Sourcing functions from the following files in the R/ directory:')
for(i in 1:length(functions)){
  message('---', functions[i])
  this_function <- functions[i]
  if(!grepl('test', this_function)){
    source(paste0('R/', this_function), chdir = TRUE)
  }
}

# Read in short and long format examples
suppressMessages(upload_format <- read_csv('upload_format.csv'))

# Detect which database
creds <- credentials_extract()
creds <- creds[names(creds) %in% c('dbname', 'host')]
creds <- paste0(paste0(#unlist(names(creds)), 
                       # ' : ', 
                       unlist(creds)), collapse = '\n')

# Get some tables shared between all users (and which don't ever require in-session refreshing)
conn <- db_get_connection()
# Load up venue types (since all sessions use it)
venue_types <- get_data(tab = 'venue_types',
                        schema = 'pd_wbgtravel',
                        connection_object = conn)

# Users table is also identical for all users
users <- get_data(tab = 'users',
                  schema = 'pd_wbgtravel',
                  connection_object = conn)
db_release_connection(conn)  

# Syncronize the www photo storage with the database
#populate_images_from_www(pool = GLOBAL_DB_POOL) # www to db
populate_images_to_www() # db to www
# images <- get_images()

# Image manipulation
resourcepath <- paste0(getwd(),"/www")
maskc <- image_read("www/mask-circle.png")
masks <- image_read("www/mask-square.png")
mask <- image_composite(maskc, masks, "out") 

message('############ Done with global.R')
