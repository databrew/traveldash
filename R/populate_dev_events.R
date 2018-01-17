#' Populate dev events
#'
#' Populate the dev_events table for the first time
#' @param connection_object An open connection to adatabase (as created through \code{credentials_extract} and \code{credentials_connect} or \code{credentials_now}); if \code{NULL}, the function will try to create a \code{connection_object} by retrieving user information from the \code{credentials/credentials.yaml}
#' in or somewhere upwards of the working directory.
#' @return The dev_events table will be populated
#' @import DBI
#' @import dplyr
#' @import googlesheets
#' @export

populate_dev_events <- function(connection_object = NULL){
  
  # If not connection object, try to find one
  if(is.null(connection_object)){
    message(paste0('No connection_object provided. Will try ',
                   'to find a credentials file.'))
    # Get credentials
    the_credentials <- credentials_extract()
    
    # Establish the connection
    connection_object <- credentials_connect(the_credentials)
  }
  
  # Read in the events data from google sheets
  data_url <- gs_url('https://docs.google.com/spreadsheets/d/13m0gMUQ2cQOoxPQgO2A7EESm4pG3eftTCGOdiH-0W6Y/edit#gid=0')
  events <- gs_read_csv(data_url)
  
  # Upload
  copy_to(connection_object, 
          events, 
          "dev_events",
          temporary = FALSE,
          overwrite = TRUE)
}