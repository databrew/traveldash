#' Geocode
#'
#' Geocode an "events" table
#' @param events_tbl An events table
#' @return An events table
#' @import tmap
#' @import tmaptools
#' @import dplyr
#' @export

geo_code <- function(events_tbl){
  
  # Check to see if any of the lat/long columns are empty
  which_empty <- 
    sort(unique(c(which(is.na(events_tbl$Lat)),
                  which(is.na(events_tbl$Long)),
                  which(events_tbl$Lat == ''),
                  which(events_tbl$Long == ''))))
  # If nothing is empty, just return the table as is (no need for further geocoding)
  if(length(which_empty) > 0){
    # If there are an empty elements, geocode them
    empties <- events_tbl[which_empty, c('City of visit', 'Country of visit')]
    empties <- paste0(empties$`City of visit`, ', ', empties$`Country of visit`)
    # Geocode them
    gc_list <- list()
    for(i in 1:length(empties)){
      message(i, ' of ', length(empties), ': geocoding ',
              empties[i])
      gc <- geocode_OSM(q = empties[i])$coords
      if(is.null(gc)){
        # If not geocodable, just use 0, 0
        gc <- data.frame(x = 0, y = 0)
      } else {
        gc <- data.frame(x = gc['x'], y = gc['y'])
      }
      gc_list[[i]] <- gc
    }
    gc <- bind_rows(gc_list)
    gc$y <- as.numeric(as.character(gc$y))
    gc$x <- as.numeric(as.character(gc$x))
    
    # Populate the events
    events_tbl$Lat <- as.numeric(events_tbl$Lat)
    events_tbl$Long <- as.numeric(events_tbl$Long)
    events_tbl$Lat[which_empty] <- gc$y
    events_tbl$Long[which_empty] <- gc$x  
  }
  return(events_tbl)
}
