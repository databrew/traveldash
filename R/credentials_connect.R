#' Create a connection to database
#'
#' Use a list of options (usually created through running \code{credentials_extract})
#' to create a connection to the psql database.
#' @param options_list A list of options for connecting to a database, usually generated by calling \code{credentials_extract()}
#' @import dplyr
#' @export

# This function is used in conjunction with credentials_extract() (above)
# and fetch_db() (below)
credentials_connect <- function(options_list){
  
  # Establish connection with database
  options_list$drv <- DBI::dbDriver("PostgreSQL")
  connection_object <- do.call(dbConnect, options_list)
  
  # Return the connection object
  return(connection_object)
}
