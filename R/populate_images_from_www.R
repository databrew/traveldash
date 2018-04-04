#library calls should be in global.R
# library(openxlsx)
# library(RPostgreSQL)
# library(yaml)
# library(pool)
# library(lubridate)
# library(magick)

populate_image_from_www <- function(name)
{
  headshots_path <- "www/headshots/circles"
  headshots <- list.files(path=headshots_path,pattern=paste0(name,".png"))
  #head_names <- gsub(pattern = "(\\w+).png","\\1",headshots)
  #name_string <- tolower(paste0(paste0("'",head_names,"'"),collapse=","))
  name_string <- tolower(paste0("'",name,"'"))

  start_time <- Sys.time()
  #conn <- poolCheckout(pool)
  conn <- db_get_connection()
  people <- dbGetQuery(conn,paste0("select person_id,short_name from pd_wbgtravel.people where lower(short_name) in (",name_string,");"))

  name_shots <- data.frame(short_name=name,image_file=headshots,path=paste0(headshots_path,"/",headshots),stringsAsFactors = F)

  images <- merge(x=people,y=name_shots,on="short_name",all.x=T)

  images[["files"]] <- lapply(images$path,file,open="rb")
  images[["binaries"]] <- lapply(images$files,readBin,what="raw",n=1000000,size=1)
  images[["person_image"]] <- mapply(postgresqlEscapeBytea,raw_data=images$binaries,MoreArgs=list(con=conn))
  # Close the connections
  #closeAllConnections()

  people_upload <- images[,c("person_id","person_image")]
  dbSendQuery(conn,"drop table if exists public._temp_headshots_upload;")
  dbWriteTable(conn,name=c("public","_temp_headshots_upload"),value=people_upload,row.names=F,field.types=list(person_id="int4",person_image="bytea"))
  dbSendQuery(conn,"update pd_wbgtravel.people
              set image_data = up.person_image
              from public._temp_headshots_upload up
              where people.person_id = up.person_id;")
  dbSendQuery(conn,"drop table if exists public._temp_headshots_upload;")
  end_time <- Sys.time()
  print(paste0("Database upload/download time: ", end_time - start_time))
<<<<<<< HEAD:R/util_populate_images_in_db.R
  #poolReturn(conn)
  db_release_connection(conn)
}

get_images <- function(pool){
  #conn <- poolCheckout(pool)
  conn <- db_get_connection()
  
  start_time <- Sys.time()
  
  images <- dbGetQuery(conn,paste0("select person_id,short_name,image_data from pd_wbgtravel.people where image_data is not null;"))

  images[["binaries"]] <- lapply(images$image_data,postgresqlUnescapeBytea)
  images[["person_image"]] <- lapply(images$binaries,image_read)

  end_time <- Sys.time()
  
  print(paste0("get_images(): Database upload/download time: ", end_time - start_time))
  #poolReturn(conn)
  db_release_connection(conn)
  
  return(images)
}

=======
  poolReturn(conn)
}
>>>>>>> 8122e694b20876a8c12cd631091c02de060f8041:R/populate_images_from_www.R
