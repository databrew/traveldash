#' Load user data
#' 
#' Load data for a specific user into a list
#' @param return_list Return the objects as a list, rather than assignation to global environment
#' @return Objects assigned to global environment
#' @export


load_user_data <- function(return_list = TRUE, 
                           user_id = 0,
                           conn = NULL){
  
  if(is.null(conn)){
    conn <- db_get_connection()
  }
  
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
              'users')

  for (i in 1:length(tables)){
    this_table <- tables[i]
    message(paste0('Reading in the ', this_table, ' from the database and assigning to global environment.'))
    x <- get_data(tab = this_table,
                  schema = 'pd_wbgtravel',
                  connection_object = conn)
    
    # If this is the "view_all", expand it to include some more useful columns
    if(tables[i] == 'view_all_trips_people_meetings_venues'){
      if(return_list){
        the_people <- out_list[['people']]
      } else {
        the_people <- get('people', envir = .GlobalEnv)
      }
      x <- expand_view_all(view_all_trips_people_meetings_venues = x,
                           people = the_people)
      # Overwrite "unsepcified venue"
      x$venue_name[x$venue_name == 'Unspecified Venue'] <- NA
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
  # Get the events view too (we do this separately since we modify its format)
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