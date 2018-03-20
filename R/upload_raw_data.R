#' Upload raw data
#' 
#' Upload raw data to the databse, following a submission from the app
#' @param pool A connection pool
#' @param data A dataframe in either short or long format
#' @param logged_in_user_id A user id, system is 0  
#' @param return_upload_results Whether to return the upload results
#' @return Database is uploaded
#' @import pool
#' @import DBI
#' @import RPosgreSQL
#' @export

#logged_in_user_id=0 is SYSTEM account -- this should not be left as default
upload_raw_data <- function(pool,
                            data,
                            logged_in_user_id,
                            return_upload_results = TRUE){
  print('Debug Start: in upload_raw_data()')
  
  names(data) <- gsub("\\."," ",names(data)) #read.xlsx replaces " " with "." eg, "Trip Group" to "Trip.Group"
  
  data_cols <- names(data)
  valid_cols <- c("Person","Title","Organization","City","Country","Start","End","Trip Group","Venue","Meeting","Agenda","CMD","ID")
  
  if (!any(length(data_cols) %in% c(10,12))) stop("Data upload row mismatch")
  if (!(all(data_cols==valid_cols) || all(data_cols[1:10]==valid_cols))) stop(paste0("Data upload columns mismatch: ",paste0(data_cols, collapse=",")))
      
  # Define function for fixing date issues
  # necessary since people's spreadsheet programs may do some inconsistent formatting

   fix_date <- function(x){
   if(!is.Date(x)){
     if(any(grepl('/', x, fixed = TRUE))){
       out <- as.Date(x, format = '%m/%d/%Y')
     } else if(any(grepl('-', x, fixed = TRUE))){
       out <- as.Date(x)
     } else {
       out <- openxlsx::convertToDate(x)
     }
   } else {
     out <- x
   }
   return(out)
 }
  
  data$Start <- fix_date(data$Start)
  data$End <- fix_date(data$End)
  
  data$bad_date <- is.null(data$Start) | is.null(data$End) | is.na(data$Start) | is.na(data$End) |  !is.Date(data$Start) | !is.Date(data$End) 
  data$good_date <- FALSE
  
  if (length(data$bad_date[!data$bad_date])>0)
  {
    data$good_date[!data$bad_date] <- with(data[!data$bad_date,],year(Start) < year(now())+10 & year(Start) > year(now())-10 &
                                                               year(End) < year(now())+10 & year(Start) > year(now())-10 )
  }
  
  data_bad_dates <- subset(data,data$good_date==FALSE)  
  data <- subset(data,data$good_date==TRUE,select=data_cols)

  
  # Create an id field
  data <- cbind(up_id = rownames(data), data)
  
  # Define field types
  fields <- list(up_id="int4",
                 Person="varchar(50)",
                 Organization="varchar(50)",
                 City="varchar(50)",
                 Country="varchar(50)",
                 Start="date",
                 End="date",
                 `Trip Group`="varchar(100)",
                 Venue="varchar(100)",
                 Meeting="varchar(50)",
                 Agenda="varchar(100)",
                 CMD="varchar(50)",
                 ID="varchar(50)")
  
    # Create the connection
  print(paste('Debug: Pool1 '))
  conn <- poolCheckout(pool)
  print(paste('Debug: Pool2 '))
  
  # Drop a previous temporary table if it's around
  dbSendQuery(conn,"drop table if exists public._temp_travel_uploads;") 
  
  # Write a new temporary table
  dbWriteTable(conn,c("public","_temp_travel_uploads"),data,row.names=F,temporary=T,field.types=fields) 
  
  # Define primary key
  dbSendQuery(conn,"ALTER TABLE public._temp_travel_uploads ADD PRIMARY KEY (up_id);") 
  
  upload_results <- dbGetQuery(conn,paste0('select msg."Person",msg."Organization", msg."City", msg."Country",msg."Start",msg."End",msg."Trip Group", msg."Venue",msg."Meeting",msg."Agenda", msg."STATUS" from pd_wbgtravel.travel_uploads(',logged_in_user_id,') msg;')) 
  # Drop the temporary table
  #dbSendQuery(conn,"drop table if exists public._temp_travel_uploads;") 
  
  poolReturn(conn)
  
  # Geocode the cities table if it has been changed
  geo_results <- geo_code_in_db(pool = pool)
  if (!is.null(geo_results) && sum(geo_results$error)>0)
  {
    STATUS <- paste0(">ERROR< No geo-coordinates for: ",geo_results$query[geo_results$error==T])
    city_results <- data.frame(Person=NA,Organization=NA,City=NA,Country=NA,Start=NA,End=NA,`Trip Group`=NA,Venue=NA,Meeting=NA,Agenda=NA,STATUS=STATUS)
    names(city_results) <- names(upload_results)
    upload_results <- rbind(upload_results,city_results)
  }
  
  if (nrow(data_bad_dates)>0)
  {
    date_results <- data_bad_dates[,c("Person","Organization","City","Country","Start","End","Trip Group","Venue","Meeting","Agenda")]
    date_results$STATUS <- paste0(">ERROR< Travel date missing or more than 10 years away: ",date_results$Start," - ",date_results$End)
    upload_results <- rbind(upload_results,date_results)
  }
  # Spit back upload_results
  print('Debug End: exit in upload_raw_data()')
  
  if(return_upload_results)
  {
    names(upload_results) <- gsub("\\."," ",names(upload_results)) #read.xlsx replaces " " with "." eg, "Trip Group" to "Trip.Group 
    return(upload_results)
  }
}
