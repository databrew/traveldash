#' Load user data
#' 
#' Load data for a specific user into a list
#' @param return_list Boolean; return the objects as a list, rather than assignation to global environment
#' @param user_id Numeric; The id of the logged in user. If 0, this means that nobody is logged in, and no data will be returned
#' @param conn; A connection object. If NULL (the default) the function will create a connection to the database.
#' @return Objects assigned to global environment
#' @export

# This currently loads all data! It should instead load data only for the logged in user.

load_user_data <- function(return_list = TRUE, 
                           user_id = 0,
                           conn = NULL){
  if(user_id == 0){
    message('USER NOT LOGGED IN. Not loading data')
    return(NULL)
  } else {
    message('USER ID ', user_id, ' LOGGED IN. Loading data:')
    
    if(is.null(conn)){
      conn <- db_get_connection()
    }
    
    out_list <- list()
    
    # Read in all tables
    # tables <- unique(dbListTables(pool))
    tables <- get_table_names()
    
    for (i in 1:length(tables)){
      this_table <- tables[i]
      message(paste0('--- ', i, '. loading ', this_table))
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
        # Keep only those values for the relevant user id
        uid <- user_id
        x <- x %>% filter(user_id == uid)
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
}