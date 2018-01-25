#' DB to memory
#' 
#' Assign the data from the database to the global environment
#' @param pool A connection pool
#' @param return_list Return the objects as a list, rather than assignation to global environment
#' @return Objects assigned to global environment
#' @export

db_to_memory <- function(pool,
                         return_list = FALSE){
  
  # The database lay-out is as follows:
  #    Schema    |     Name      | Type  |  Owner  
  # --------------+---------------+-------+---------
  # pd_wbgtravel | cities        | table | joebrew
  # pd_wbgtravel | people        | table | joebrew
  # pd_wbgtravel | trip_meetings | table | joebrew
  # pd_wbgtravel | trips         | table | joebrew
  # There is also an "events" view 
  
  out_list <- list()
  
  # Read in all tables
  tables <- dbListTables(pool)
  # Add the views to the tables
  tables <- c(tables, 'view_trip_coincidences')
  for (i in 1:length(tables)){
    this_table <- tables[i]
    message(paste0('Reading in the ', this_table, ' from the database and assigning to global environment.'))
    x <- get_data(tab = this_table,
                  schema = 'pd_wbgtravel',
                  connection_object = pool,
                  use_sqlite = use_sqlite)
    if(return_list){
      out_list[[i]] <- x
      names(out_list)[i] <- this_table
    } else {
      assign(this_table,
             x,
             envir = .GlobalEnv)
    }
  }
  
  # Get the events view too (we do this separately since we modify its format)
  message(paste0('Reading in the events view from the database and assigning to global environment.'))
  events <- get_data(tab = 'events',
                     schema = 'pd_wbgtravel',
                     connection_object = pool,
                     use_sqlite = use_sqlite) %>%
    # Restructure like the events table
    dplyr::rename(Person = short_name,
                  Organization = organization,
                  `City of visit` = city_name,
                  `Country of visit` = country_name,
                  Counterpart = trip_reason,
                  `Visit start` = trip_start_date,
                  `Visit end` = trip_end_date,
                  Lat = latitude,
                  Long = longitude,
                  Event = meeting_topic) %>%
    dplyr::select(Person, Organization, `City of visit`, `Country of visit`,
                  Counterpart, `Visit start`, `Visit end`, Lat, Long, Event)
  if(return_list){
    i <- length(tables) + 1
    out_list[[i]] <- events
    names(out_list)[i] <- 'events'
  } else {
    assign('events',
           events,
           envir = .GlobalEnv)
  }
  if(return_list){
    return(out_list)
  }
}