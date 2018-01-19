#' Write table
#'
#' Write a table in the database
#' @param connection_object An open connection to adatabase (as created through \code{credentials_extract} and \code{credentials_connect} or \code{credentials_now}); if \code{NULL}, the function will try to create a \code{connection_object} by retrieving user information from the \code{credentials/credentials.yaml}
#' in or somewhere upwards of the working directory.
#' @param table The name of the table in the database to be written
#' @param schema The schema of the table in the database to be written
#' @param use_sqlite Whether to use SQLite; alternative is PostgreSQL
#' @return A table will be written or overwritten
#' @import DBI
#' @import RPostgreSQL
#' @import RSQLite
#' @export

write_table <- function(pool = NULL,
                        table = 'dev_events',
                        schema = 'pd_wbgtravel',
                        value,
                        use_sqlite = FALSE){

  connection_object<-poolCheckout(pool)
  
  stmt <- 'CREATE TABLE if not exists public.temp_dev_events (
    "Person" varchar(255),
    "Organization" varchar(255),
    "City of visit" varchar(255),
    "Country of visit" varchar(255),
    "Counterpart" varchar(255),
    "Visit start" date,
    "Visit end" date,
    "Visit month" varchar(255),
    "Lat" numeric,
    "Long" numeric,
    "Event" varchar(255),
    "file" varchar(255),
    "event_id" int2 NOT NULL,
    "state" varchar(15) NOT NULL);'
  
  dbSendQuery(connection_object,stmt)
  
  stmt <- ' COPY public.temp_dev_events("Person","Organization","City of visit","Country of visit","Counterpart","Visit start","Visit end","Visit month","Lat","Long","Event","file","event_id","state") FROM STDIN;'
  
  dbSendQuery(connection_object,stmt)
  
  skip_rows <- which(value$state=="static")
  if (length(skip_rows) > 0) { events <- value[-skip_rows,c("Person","Organization","City of visit","Country of visit","Counterpart","Visit start","Visit end","Visit month","Lat","Long","Event","file","event_id","state")] 
  } else { events <- value[,c("Person","Organization","City of visit","Country of visit","Counterpart","Visit start","Visit end","Visit month","Lat","Long","Event","file","event_id","state")] }

  events[["Visit start"]] <- as.character(format.Date(events[["Visit start"]],"%Y-%m-%d")) 
  events[["Visit end"]] <- as.character(format.Date(events[["Visit end"]],"%Y-%m-%d")) 
  
  postgresqlCopyInDataframe(connection_object, events)
  
  stmt <- '
            delete from pd_wbgtravel.dev_events
            where exists(select * from temp_dev_events where temp_dev_events.state = \'delete\' and temp_dev_events.event_id = dev_events.event_id);
           '
  dbSendQuery(connection_object,stmt)
  
  stmt <- '
            insert into pd_wbgtravel.dev_events("Person","Organization","City of visit","Country of visit","Counterpart","Visit start","Visit end","Visit month","Lat","Long","Event","file")
            select "Person","Organization","City of visit","Country of visit","Counterpart","Visit start","Visit end","Visit month","Lat","Long","Event","file"
            from temp_dev_events
            where state=\'new\';
          '
  dbSendQuery(connection_object,stmt)
  
  stmt <- '
            update pd_wbgtravel.dev_events de SET
            "Person"=tde."Person",
            "Organization"=tde."Organization",
            "City of visit"=tde."City of visit",
            "Country of visit"=tde."Country of visit",
            "Counterpart"=tde."Counterpart",
            "Visit start"=tde."Visit start",
            "Visit end"=tde."Visit end",
            "Visit month"=tde."Visit month",
            "Lat"=tde."Lat",
            "Long"=tde."Long",
            "Event"=tde."Event",
            "file"=tde."file"
            FROM temp_dev_events tde
            WHERE tde.state = \'modified\' AND de.event_id=tde.event_id;
          '
  dbSendQuery(connection_object,stmt)
  
  dbSendQuery(connection_object,"DROP TABLE temp_dev_events")
  poolReturn(connection_object)
  # Write
  #dbWriteTable(connection_object, 
  #             table_name, 
  #             value = value, 
  #             overwrite = TRUE, 
  #             row.names = FALSE)

}
