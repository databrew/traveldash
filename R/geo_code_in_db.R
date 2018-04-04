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


get_geo <- function(city_id,q) 
{
  geo <- tmaptools::geocode_OSM(q,as.data.frame=F)
  if (is.null(geo)) df <- data.frame(city_id=city_id,query=q,latitude=NA,longitude=NA,stringsAsFactors=F)
  else df <- data.frame(city_id=city_id,query=q,latitude=geo$coords[["y"]],longitude=geo$coords[["x"]],stringsAsFactors=F)
  return (df)
}

geo_code_in_db <- function()
{
  #conn <- poolCheckout(pool)
  conn <- db_get_connection()
  cities <- dbGetQuery(conn,"select city_id,city_name,country_name from pd_wbgtravel.cities where latitude is null or longitude is null or ceiling(latitude*100) = floor(latitude*100) or ceiling(longitude*100)=floor(longitude*100)")
  
  geo_cities <- NULL
  
  if (!is.null(cities) && length(cities) > 0)
  {
    geo_cities <- plyr::ldply(mapply(get_geo,city_id=cities$city_id,q=paste0(cities$city_name,", ",cities$country_name),SIMPLIFY =F))
    
    geo_cities$error = F
    geo_cities$error[is.na(geo_cities$latitude) | is.na(geo_cities$longitude)] <- T

    geo_uploads <- subset(geo_cities,error==F)
    if (nrow(geo_uploads) > 0)
    {
      dbSendQuery(conn,"drop table if exists public._temp_city_uploads;") 
      
      dbWriteTable(conn,c("public","_temp_city_uploads"),geo_uploads,row.names=F,temporary=T)
      dbSendQuery(conn,"ALTER TABLE public._temp_city_uploads ADD PRIMARY KEY (city_id);") 
      dbSendQuery(conn,"update pd_wbgtravel.cities set latitude=public._temp_city_uploads.latitude,	  longitude =public._temp_city_uploads.longitude from public._temp_city_uploads where _temp_city_uploads.city_id = cities.city_id;") 
      dbSendQuery(conn,"drop table public._temp_city_uploads;") 
    }
  }
  
  #poolReturn(conn)
  db_release_connection(conn)
  return (geo_cities)
}
