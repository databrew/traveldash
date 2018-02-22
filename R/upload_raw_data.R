#' Upload raw data
#' 
#' Upload raw data to the databse, following a submission from the app
#' @param pool A connection pool
#' @param data A dataframe in either short or long format
#' @param return_upload_results Whether to return the upload results
#' @return Database is uploaded
#' @import pool
#' @import DBI
#' @import RPosgreSQL
#' @export

upload_raw_data <- function(pool,
                            data,
                            return_upload_results = TRUE){
  
  # Define function for fixing date issues
  # necessary since people's spreadsheet programs may do some inconsistent formatting
  fix_date <- function(x){
    if(!is.Date(x)){
      if(any(grepl('/', x, fixed = TRUE))){
        out <- as.Date(x, format = '%m/%d/%Y')
      } else if(any(grepl('-', x, fixed = TRUE))){
        out <- as.Date(x)
      } else {
        out <- as.Date(x, origin = '1970-01-01')
      }
    } else {
      out <- x
    }
    return(out)
  }
  data$Start <- fix_date(data$Start)
  data$End <- fix_date(data$End)
  
# Create fields
  new_fields <- c('person_id', 'city_id', 'country_iso3', 'trip_id', 'meeting_person_id')
  data$STATUS <- ''
  for (new_field in new_fields){
    if(!new_field %in% names(data)){
      data[,new_field] <- as.integer(NA)
    }
  }

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
                 Reason="varchar(100)",
                 Meeting="varchar(50)",
                 Topic="varchar(50)",
                 STATUS="varchar(50)",
                 person_id="int4",
                 city_id="int4",
                 country_iso3="varchar(3)",
                 trip_id="int4",
                 meeting_person_id="int4")
  
    # Create the connection
  conn <- poolCheckout(pool)

  # # DELETE or UPDATE fields if applicable
  # (this method has not yet been created)

  # Drop a previous temporary table if it's around
  dbSendQuery(conn,"drop table if exists public._temp_travel_uploads;") 
  
  # Write a new temporary table
  dbWriteTable(conn,c("public","_temp_travel_uploads"),data,row.names=F,temporary=T,field.types=fields) 
  
  # Define primary key
  dbSendQuery(conn,"ALTER TABLE public._temp_travel_uploads ADD PRIMARY KEY (up_id);") 
  
  # Get the results of the upload
  upload_results <- dbGetQuery(conn,'select msg."Person",msg."Organization",msg."City",msg."Country",msg."Start",msg."End",msg."Reason",msg."Meeting",msg."Topic",msg."STATUS" from pd_wbgtravel.travel_uploads() msg;') 
  
  # Drop the temporary table
  dbSendQuery(conn,"drop table if exists public._temp_travel_uploads;") 
  
  # Geocode the cities table if it has been changed
  geo_code_in_db(pool = pool, 
                 use_sqlite = FALSE)

  # Return the connection pool
  poolReturn(conn)
  
  # Spit back upload_results
  if(return_upload_results){
    return(upload_results)
  }
}
