library(openxlsx)
library(RPostgreSQL)

setwd("C:/Users/SHeitmann/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")

file <- paste0(getwd(),"/travel_meeting_data.xlsx")
travels <- read.xlsx(xlsxFile=file,sheet=1)

travels[["Start"]] <- as.character(convertToDate(travels[["Start"]]))  
travels[["End"]] <- as.character(convertToDate(travels[["End"]]))  
travels[["STATUS"]] <- ''
travels <- cbind(up_id = rownames(travels), travels)
c_ob <- dbConnect(RPostgreSQL::PostgreSQL(), dbname = "dev", host = "w0lxsfigssa01", port = 5432, user = "rscript", password = "rscript")

fields <- list(up_id="int4",Person="varchar(50)",Organization="varchar(50)",City="varchar(50)",Country="varchar(50)",Start="date",End="date",Reason="varchar(100)",
               Meeting="varchar(50)",Topic="varchar(50)",STATUS="varchar(50)",person_id="int4",city_id="int4",country_iso3="varchar(3)",trip_id="int4",meeting_person_id="int4")

##TESTING##
dbSendQuery(c_ob,"delete from pd_wbgtravel.trips cascade;") 
###########

dbSendQuery(c_ob,"drop table if exists public._temp_travel_uploads;") 
dbWriteTable(c_ob,c("public","_temp_travel_uploads"),travels,row.names=F,temporary=T,field.types=fields) #Note: temporary=T doesn't seem to work, although not important
dbSendQuery(c_ob,"ALTER TABLE public._temp_travel_uploads ADD PRIMARY KEY (up_id);") 

upload_results <- dbGetQuery(c_ob,'select msg."Person",msg."Organization",msg."City",msg."Country",msg."Start",msg."End",msg."Reason",msg."Meeting",msg."Topic",msg."STATUS"
                                  from pd_wbgtravel.travel_uploads() msg;') 

View(upload_results)
dbSendQuery(c_ob,"drop table if exists public._temp_travel_uploads;") 
dbDisconnect(c_ob)