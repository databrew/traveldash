update_last_login_field <- function(user_id = 0){
  if(user_id > 0){
    the_time <- Sys.time()
    query <- paste0("UPDATE pd_wbgtravel.users SET last_login = '", the_time,
                    "' WHERE user_id = ", 
                    user_id, ';')
    conn <- db_get_connection()
    # Drop a previous temporary table if it's around
    dbSendQuery(conn, query) 
    db_release_connection(conn)
  }
}