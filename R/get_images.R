library(openxlsx)
library(RPostgreSQL)
library(yaml)
library(pool)
library(lubridate)
library(magick)


get_images <- function(pool){
  conn <- poolCheckout(pool)
  
  start_time <- Sys.time()
  
  images <- dbGetQuery(conn,paste0("select person_id,short_name,image_data from pd_wbgtravel.people where image_data is not null;"))
  
  images[["binaries"]] <- lapply(images$image_data,postgresqlUnescapeBytea)
  images[["person_image"]] <- lapply(images$binaries,image_read)
  
  end_time <- Sys.time()
  
  print(paste0("get_images(): Database upload/download time: ", end_time - start_time))
  poolReturn(conn)
  return(images)
}

