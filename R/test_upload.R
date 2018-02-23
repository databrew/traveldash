# Should be run from parent directory (traveldash)

# library(openxlsx)
library(readxl)
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

file <- paste0(getwd(),"/dev_database/Travel Event Dashboard_DATA Feb-15.xlsx")
# file <- paste0(getwd(),"/dev_database/Travel_Event_Dashboard_DATA_20_Feb.xlsx")

data <- read_excel(file,sheet=1,skip = 1)

LOGGED_IN_USER_ID <- 1 

start_time <- Sys.time()
  upload_results <- upload_raw_data(pool=pool,data=data,logged_in_user_id=LOGGED_IN_USER_ID,return_upload_results = TRUE)
end_time <- Sys.time()

print(paste0("Database upload time: ", end_time - start_time))
     
