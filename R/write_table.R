#' Write table
#'
#' Write a table in the database
#' @param connection_object An open connection to adatabase (as created through \code{credentials_extract} and \code{credentials_connect} or \code{credentials_now}); if \code{NULL}, the function will try to create a \code{connection_object} by retrieving user information from the \code{credentials/credentials.yaml}
#' in or somewhere upwards of the working directory.
#' @param table The name of the table in the database to be written
#' @param schema The schema of the table in the database to be written
#' @return A table will be written or overwritten
#' @import DBI
#' @import RPostgreSQL
#' @export

write_table <- function(connection_object = NULL,
                        table = 'dev_events',
                        schema = 'pd_wbgtravel',
                        value){
  
  # If not connection object, try to find one
  if(is.null(connection_object)){
    message(paste0('No connection_object provided. Will try ',
                   'to find a credentials file.'))
    # Get credentials
    the_credentials <- credentials_extract()
    
    # Establish the connection
    connection_object <- credentials_connect(the_credentials)
  }
  
  # Define table name
    table_name <- c(schema, table)
  
  # Write
  dbWriteTable(connection_object, 
               table_name, 
               value = value, 
               overwrite = TRUE, 
               row.names = FALSE)

}
