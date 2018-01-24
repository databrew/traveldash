# Should be run from parent directory (traveldash)

library(openxlsx)
library(RPostgreSQL)
library(yaml)
library(DBI)

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
for(i in 1:length(functions)){
  source(paste0('R/', functions[i]), chdir = TRUE)
}

file <- paste0(getwd(),"/dev_database/travel_meeting_data.xlsx")
travels <- read.xlsx(xlsxFile=file,sheet=1)

travels[["Start"]] <- as.character(convertToDate(travels[["Start"]]))  
travels[["End"]] <- as.character(convertToDate(travels[["End"]]))  
travels$STATUS <- ''
travels <- cbind(up_id = rownames(travels), travels)

fields <- list(up_id="int4",Person="varchar(50)",Organization="varchar(50)",City="varchar(50)",Country="varchar(50)",Start="date",End="date",Reason="varchar(100)",
               Meeting="varchar(50)",Topic="varchar(50)",STATUS="varchar(50)",person_id="int4",city_id="int4",country_iso3="varchar(3)",trip_id="int4",meeting_person_id="int4")

##TESTING##
#dbSendQuery(c_ob,"delete from pd_wbgtravel.trips cascade;") 
###########

# Get credentials
credentials <- credentials_extract()
c_ob <- credentials_connect(options_list = credentials,
                            use_sqlite = FALSE)

start_time <- Sys.time()

dbSendQuery(c_ob,"drop table if exists public._temp_travel_uploads;") 
dbWriteTable(c_ob,c("public","_temp_travel_uploads"),travels,row.names=F,temporary=T,field.types=fields) #Note: temporary=T doesn't seem to work, although not important
dbSendQuery(c_ob,"ALTER TABLE public._temp_travel_uploads ADD PRIMARY KEY (up_id);") 

upload_results <- dbGetQuery(c_ob,'select msg."Person",msg."Organization",msg."City",msg."Country",msg."Start",msg."End",msg."Reason",msg."Meeting",msg."Topic",msg."STATUS" from pd_wbgtravel.travel_uploads() msg;') 

dbSendQuery(c_ob,"drop table if exists public._temp_travel_uploads;") 
dbDisconnect(c_ob)
end_time <- Sys.time()
print(paste0("Database upload time: ", end_time - start_time))
     
if(interactive()){
  View(upload_results)
} else {
  print(upload_results)
} 

