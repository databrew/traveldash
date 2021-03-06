#' DB to memory
#' 
#' Assign the data from the database to the global environment
#' @param return_list Return the objects as a list, rather than assignation to global environment
#' @return Objects assigned to global environment
#' @export

db_to_memory <- function(return_list = FALSE){
  
  out_list <- list()
  
  # Read in all tables
  # tables <- unique(dbListTables(pool))
  tables <- c('cities', 
              'people',
              'trip_meetings',
              'trips',
              'user_action_log',
              'venue_events',
              'venue_types',
              'view_all_trips_people_meetings_venues',
              'users')#,
              # 'venue_events',
              # 'venue_types'
              # )
  # Add the views to the tables
  conn <- db_get_connection()
  tables <- c(tables, 'view_trip_coincidences',  
              # 'events',
              'view_trips_and_meetings')
  for (i in 1:length(tables)){
    this_table <- tables[i]
    message(paste0('Reading in the ', this_table, ' from the database and assigning to global environment.'))
    x <- get_data(tab = this_table,
                  schema = 'pd_wbgtravel',
                  connection_object = conn)
    # Re-shape events before assigning to global environment
    if(this_table == 'events'){
      message(paste0('Restructuring events table'))
      x <- x %>%
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
                      Counterpart, `Visit start`, `Visit end`, Lat, Long, Event) %>%
        distinct(Person, Organization, `City of visit`, `Country of visit`,
                 Counterpart, `Visit start`, `Visit end`,Event, .keep_all = TRUE)
    }
    if(return_list){
      out_list[[i]] <- x
      names(out_list)[i] <- this_table
    } else {
      assign(this_table,
             x,
             envir = .GlobalEnv)
    }
  }
  db_release_connection(conn)
  if(return_list){
    return(out_list)
  }
}