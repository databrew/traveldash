#' Geocode in DB
#' 
#' Geocode missing lat /lons in the database
#' @param pool The connection pool
#' @param use_sqlite Whether to use_sqlite (alternative is postgres)
#' @return the cities table in the database gets updated
#' @export
#' @import tmaptools
#' @import DBI
#' @import dplyr

geo_code_in_db <- function(pool,
                           use_sqlite = FALSE){
  
  # Get the cities table from the db
  cities <- get_data(tab = 'cities',
                     schema = 'pd_wbgtravel',
                     connection_object = pool,
                     use_sqlite = FALSE) 
  
  geo_code_cities_in_db <- FALSE
  if(any(is.na(cities$longitude))){
    geo_code_cities_in_db <- TRUE
  } else {
    message('No missing geocoordinates detected. No geocoding required. Not modifying the cities table.')
  }
  # Only geocode if necessary
  if(geo_code_cities_in_db){
    message('New cities detected. Geocoding')
    
    # Define locations
    locations <- 
      paste0(ifelse(!is.na(cities$city_name),
                    paste0(cities$city_name, ', ', collapse = NULL),
                    ''),
             ifelse(!is.na(cities$country_name),
                    cities$country_name, ''))
    # Define which ones need to be geocoded
    need_geo <- which(is.na(cities$latitude) | is.na(cities$longitude))
    message(length(need_geo), ' new locations needs geo-coding')
    gc_list <- list()
    for(i in 1:length(need_geo)){
      this_row <- need_geo[i]
      this_location <- locations[this_row]
      message('--- geocoding ', this_location)
      gc <- geocode_OSM(q = this_location)$coords
      if(is.null(gc)){
        message('------', this_location, ' is not geocodable. Setting lat = 0 and lon = 0.')
        # If not geocodable, just use 0, 0
        gc <- data.frame(x = 0, y = 0)
      } else {
        message('------', this_location, ' successfully geocoded!')
        gc <- data.frame(x = gc['x'], y = gc['y'])
      }
      gc_list[[i]] <- gc
    }
    gc <- bind_rows(gc_list)
    
    # Update the db
    message('Updating the database')
    city_ids <- cities$city_id[need_geo]
    for(i in 1:length(city_ids)){
      this_id <- city_ids[i]
      these_data <- gc[i,]
      longitude_statement <- paste0("UPDATE pd_wbgtravel.cities SET longitude = ",
                                    these_data$x,
                                    " WHERE city_id = ",
                                    this_id,
                                    ";")
      latitude_statement <- paste0("UPDATE pd_wbgtravel.cities SET latitude = ",
                                   these_data$y,
                                   " WHERE city_id = ",
                                   this_id,
                                   ";")
      conn <- poolCheckout(pool)
      dbSendQuery(conn = conn,
                  statement = longitude_statement)
      dbSendQuery(conn = conn,
                  statement = latitude_statement)
      poolReturn(conn)
    }
  }
}

