#' Get data from database
#'
#' Fetch a table or a specific query of a table from the database.
#' @param query A SQL query as a chracter string of length 1
#' @param tab As an alternative to query, the name of an entire table to return
#' @param schema The schema of the table in the connected database. If \code{NULL}, then will follow the default search_path
#' @param dbname The name of the database from which you are getting data.
#' Example: portfolio. If \code{NULL}
#' the function will try to use the \code{dbname} in your \code{connection_object}; if the \code{connection_object} is \code{NULL}, the function will
#' try to create a \code{connection_object} as described below.
#' @param host The name of the host from which you are getting data.
#' If \code{NULL} the function will try to use the \code{host} in your \code{connection_object}; if the \code{connection_object} is \code{NULL}, the function will
#' try to create a \code{connection_object} as described below.
#' @param port The name of the port from which you are getting data.
#'  If \code{NULL}
#' the function will try to use the \code{port} in your \code{connection_object}; if the \code{connection_object} is \code{NULL}, the function will
#' try to create a \code{connection_object} as described below.
#' @param user The user. If \code{NULL}
#' the function will try to use the \code{user} in your \code{connection_object}; if the \code{connection_object} is \code{NULL}, the function will
#' try to create a \code{connection_object} as described below.
#' @param password The password If \code{NULL}
#' the function will try to use the \code{pqssword} in your \code{connection_object}; if the \code{connection_object} is \code{NULL}, the function will
#' try to create a \code{connection_object} as described below.
#' @param connection_object An open connection to adatabase (as created through \code{credentials_extract} and \code{credentials_connect}); if \code{NULL}, the function will try to create a \code{connection_object} by retrieving user information from the \code{credentials/credentials.yaml}
#' in or somewhere upwards of the working directory.
#' @param use_sqlite Whether to use SQLite; alternative is PostgreSQL
#' @return A dataframe matching the results of either the \code{query} or \code{tab} arguments
#' @import DBI
#' @import RPostgreSQL
#' @export

get_data <- function(query = NULL,
                     tab = NULL,
                     schema = NULL,
                     dbname = NULL,
                     host = NULL,
                     port = NULL,
                     user = NULL,
                     password = NULL,
                     connection_object = NULL,
                     use_sqlite = FALSE){

  # If not connection object, try to find one
  if(is.null(connection_object)){
    message(paste0('No connection_object provided. Will try ',
                   'to find a credentials file.'))
    # Get credentials
    the_credentials <- credentials_extract()

    # Replace dbname if necessary
    if(!is.null(dbname)){
      the_credentials$dbname <- dbname
    }
    # Replace host if necessary
    if(!is.null(host)){
      the_credentials$host <- host
    }
    # Replace port if necessary
    if(!is.null(port)){
      the_credentials$port <- port
    }
    # Replace user if necessary
    if(!is.null(user)){
      the_credentials$user <- user
    }
    # Replace dbname if necessary
    if(!is.null(password)){
      the_credentials$password <- password
    }

    # Establish the connection
    connection_object <- credentials_connect(the_credentials)
  }


  # Conformity of input
  if((!is.null(tab) & !is.null(query)) |
     is.null(tab) & is.null(query)){
    stop('You must provide at least a query OR a tab argument (an entire table you want), but not both or neither.')
  }
  if(is.null(connection_object)){
    stop('You must supply a connection object (use credentials_extract and credentials_connect, or simply credentials_now).')
  }
  
  # Configure a query if not provided
  if(is.null(query)){
    if(is.null(schema)){
      schema <- ''
    } else {
      schema <- paste0(schema, '.')
    }
    tab <- paste0(schema, tab)
    
    # sqlite requires quotations around the entire schema.table string in order to work
    if(use_sqlite){
      tab <- paste0("'", tab, "'")
    }
    
    # Construct a query
    query <- paste0('select * from ', tab)
  }
  
  return_object <- dbGetQuery(connection_object, 
                                query)

  # SQLite doesn't handle dates, so we have to convert from characters
  # This is a hard-coded hack
  if("Visit start" %in% names(return_object)){
    if(is.numeric(return_object$`Visit start`)){
      return_object$`Visit start` <- as.Date(return_object$`Visit start`,
                                             origin = '1970-01-01')
      return_object$`Visit end` <- as.Date(return_object$`Visit end`,
                                           origin = '1970-01-01')
    } else {
      return_object$`Visit start` <- as.Date(return_object$`Visit start`)
      return_object$`Visit end` <- as.Date(return_object$`Visit end`)
    }
  }

  # # Disconnect
  # pool::poolClose(connection_object)

  # Spit back
  return(return_object)
}
