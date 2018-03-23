# Should be run from parent directory (traveldash)

library(openxlsx)
library(RPostgreSQL)
library(yaml)
library(pool)
library(lubridate)
library(magick)


# Define whether on Joe's computer (dev) or elsewhere (prod)
joe <- grepl('joebrew', getwd())

if(joe){
  dir <- getwd()
} else {
  dir <- paste0(dirname(path.expand("~")),"/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
  setwd(dir)
}

# Source helper files
functions <- dir('R')
for(i in 1:length(functions)) 
{
  if (functions[i] %in% c("util_populate_images_in_db.R","test_upload.R")) next 
  else source(paste0('R/', functions[i]), chdir = TRUE) 
  print(paste("Loading ",functions[i]))
  
}

populate_images_from_www <- function()
{
  headshots_path <- paste0(getwd(),"/www/headshots/circles")
  headshots <- list.files(path=headshots_path,pattern="*.png")
  head_names <- gsub(pattern = "(\\w+).png","\\1",headshots)
  name_string <- tolower(paste0(paste0("'",head_names,"'"),collapse=","))
  
  start_time <- Sys.time()
  
  pool <- create_pool(options_list = credentials_extract(),F)
  conn <- poolCheckout(pool)
  people <- dbGetQuery(conn,paste0("select person_id,short_name from pd_wbgtravel.people where lower(short_name) in (",name_string,");"))
  
  name_shots <- data.frame(short_name=head_names,image_file=headshots,path=paste0(headshots_path,"/",headshots),stringsAsFactors = F)
  
  images <- merge(x=people,y=name_shots,on="short_name",all.x=T)
  
  images[["files"]] <- lapply(images$path,file,open="rb")
  images[["binaries"]] <- lapply(images$files,readBin,what="raw",n=100000,size=1)
  images[["person_image"]] <- mapply(postgresqlEscapeBytea,raw_data=images$binaries,MoreArgs=list(con=conn))
  
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
  
  poolReturn(conn)
  
}

get_images <- function()
{
  pool <- create_pool(options_list = credentials_extract(),F)
  conn <- poolCheckout(pool)
  
  start_time <- Sys.time()
  
  images <- dbGetQuery(conn,paste0("select person_id,short_name,image_data from pd_wbgtravel.people where image_data is not null;"))

  images[["binaries"]] <- lapply(images$image_data,postgresqlUnescapeBytea)
  images[["person_image"]] <- lapply(images$binaries,image_read)

  end_time <- Sys.time()
  
  print(paste0("Database upload/download time: ", end_time - start_time))
  poolReturn(conn)
  return(images$person_image)
}