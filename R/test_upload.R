# Should be run from parent directory (traveldash)

library(openxlsx)
library(RPostgreSQL)
library(yaml)
library(DBI)
library(pool)
library(lubridate)


# Define whether on Joe's computer (dev) or elsewhere (prod)
joe <- grepl('joebrew', getwd())

if(joe){
  dir <- getwd()
} else {
  dir <- paste0(dirname(path.expand("~")),"/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
  setwd(dir)
}

# Source helper files
functions <- dir('R')
for(i in 1:length(functions)) 
{
  if (functions[i]=="test_upload.R") next 
  else source(paste0('R/', functions[i]), chdir = TRUE) 
}

pool <- create_pool(options_list = credentials_extract(),F)

file <- paste0(getwd(),"/dev_database/Travel_Event_Dashboard_DATA_06_Mar.xlsx")
##file <- paste0(getwd(),"/dev_database/Travel Event Dashboard_DATA_20 Feb.xlsx")

data <- read.xlsx(file,sheet=1,startRow=2,detectDates=F)

LOGGED_IN_USER_ID <- 1 

start_time <- Sys.time()
  upload_results <- upload_raw_data(pool=pool,data=data,logged_in_user_id=LOGGED_IN_USER_ID,return_upload_results = TRUE)
end_time <- Sys.time()

print(paste0("Database upload time: ", end_time - start_time))
     

template <- paste0(getwd(),"/dev_database/TEMPLATE_WBG_traveldash.xlsx")

conn <- poolCheckout(pool)

download_results <- dbGetQuery(conn,paste0('select short_name as "Person", organization as "Organization",
                                            city_name as "City", country_name as "Country", trip_start_date as "Start", trip_end_date as "End",
                                            trip_group as "Trip Group", coalesce(event_title,venue_name) as "Venue", meeting_person_short_names as "Meeting",
                                            agenda as "Agenda", null as "CMD", trip_uid as "ID"
                                            from pd_wbgtravel.view_all_trips_people_meetings_venues where user_id = ',LOGGED_IN_USER_ID,';')) 

poolReturn(conn)
Sys.setenv("R_ZIPCMD" = "C:/Program Files/R/Rtools/bin/zip.exe")
workbook <- openxlsx::loadWorkbook(file=template)
openxlsx::writeData(workbook,sheet="Travel Event Dashboard DATA",x=download_results,startCol=1,startRow=3,colNames=F,rowNames=F)
openxlsx::saveWorkbook(workbook,paste0("WBG Travel Event Dashboard DATA-",today(),".xlsx"),overwrite=T)
