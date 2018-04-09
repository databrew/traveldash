#populate_images_to_www <- function(){
populate_images_to_www <- function()
{
  #conn <- poolCheckout(pool)
  conn <- db_get_connection()
  
  start_time <- Sys.time()
  
  headshots_path <- "www/headshots/circles"
  images_on_disk <- list.files(path=headshots_path,pattern="*.png")
  sql_names <- ""
  
  if (length(images_on_disk)>0)
  {
    image_names_in_db <- tolower(images_on_disk)
    image_names_in_db <- gsub(".png","",image_names_in_db)
    image_names_in_db <- paste0(paste0("'",image_names_in_db,"'"),collapse=",")
    sql_names <- paste0(" and lower(short_name) not in (",image_names_in_db,") ")
  }
  
  images <- dbGetQuery(conn,paste0("select person_id,short_name,image_data from pd_wbgtravel.people where image_data is not null ",sql_names,";"))
  
  images[["binaries"]] <- lapply(images$image_data,postgresqlUnescapeBytea)
  images[["person_image"]] <- lapply(images$binaries,function(x){
    image_read(as.raw(unlist(x)))
  })

  if(nrow(images) > 0){
    images$file_name <- paste0(images$short_name, '.png')
    
    # If an image is in db and not on disk, put on disk
    for (i in 1:nrow(images)){
      this_db_image <- images$file_name[i]
      already_on_disk <- this_db_image %in% images_on_disk
      if(!already_on_disk){
        message('.....', this_db_image, ' is in the database but not on disk. Copying to disk.')
        this_image <- unlist(images$person_image[i])[[1]]
        disk_name <- paste0('www/headshots/circles/', this_db_image)
        image_write(this_image, 
                    path = disk_name, 
                    format = "png")
        message('....... Wrote ', disk_name, ' to disk successfully.')
      } else {
        message('.....', this_db_image, ' is already on disk. Not copying from database.')
      }
    }
    
    end_time <- Sys.time()
    
    message(paste0("populate_images_to_www(): Database upload/download time: ", end_time - start_time))
  } else {
    message('No image_data in the people table. Skipping.')
  }
  
  #poolReturn(conn)
  db_release_connection(conn)
}