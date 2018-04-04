#########################
### CONNECTION GROUPS ###
#########################


# This function is used in conjunction with credentials_extract() (above)
create_pool <- function(options_list)
{
  
  options_list$drv <- DBI::dbDriver("PostgreSQL")
  out <- do.call(dbPool, options_list)
  
  # Return the connection object
  return(out)
}

db_disconnect <- function()
{
  open_conns <- dbListConnections (PostgreSQL())
  if (length(open_conns) > 0) mapply(dbDisconnect,open_conns)
  if (exists("GLOBAL_DB_POOL",envir=globalenv()) && get("GLOBAL_DB_POOL",envir=globalenv())$valid) 
  {
    poolClose(get("GLOBAL_DB_POOL",envir=globalenv()))
    rm("GLOBAL_DB_POOL",envir=globalenv())
  }
}

db_get_pool <- function()
{
  if (!exists("GLOBAL_DB_POOL",envir=globalenv()) || get("GLOBAL_DB_POOL",envir=globalenv())$valid==FALSE)
  {
    print('Creating Global Pool Object')
    db_disconnect()
    assign("GLOBAL_DB_POOL",envi=globalenv(),value=create_pool(options_list = credentials_extract()))
  }
  get("GLOBAL_DB_POOL",envir=globalenv())
}

db_get_connection <- function() { poolCheckout(db_get_pool()) }
db_release_connection <- function(conn) { poolReturn(conn) }