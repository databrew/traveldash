#' Filter events
#'
#' Filter the events table per various dimensions
#' @param events An events dataframe
#' @param people A people dataframe
#' @param person A character vector of any length; if NULL, ignored
#' @param organization A character vector of any length; if NULL, ignored
#' @param city A character vector of any length; if NULL, ignored
#' @param country A character vector of any length; if NULL, ignored
#' @param counterpart A character vector of any length; if NULL, ignored
#' @param visit_start A date
#' @param visit_end A date 
#' @param search A character vector of length 1; if NULL, ignored
#' @param wbg_only Whether only wbg employs should be included
#' @return A dataframe
#' @import dplyr
#' @export


filter_events <- function(events,
                          people = NULL,
                          person = NULL,
                          organization = NULL,
                          city = NULL,
                          country = NULL,
                          counterpart = NULL,
                          visit_start = NULL,
                          visit_end = NULL,
                          search = NULL,
                          wbg_only = FALSE){
  x <- events
  
  # Filter for wbg only
  if(wbg_only){
    if(is.null(people)){
      stop('You must provided a "people" table if filtering for wbg_only')
    }
    x <- left_join(x,
                        people %>%
                          dplyr::select(short_name, is_wbg),
                        by = c('Person' = 'short_name'))
    x$is_wbg <- as.logical(x$is_wbg)
    x <- x %>% filter(is_wbg) %>%
      dplyr::select(-is_wbg)
  }
  
  # filter for person
  if(!is.null(person)){
    x <- x %>% filter(Person %in% person)
  }
  # filter for organization
  if(!is.null(organization)){
    x <- x %>% filter(Organization %in% organization)
  }
  # filter for city
  if(!is.null(city)){
    x <- x %>% filter(`City of visit` %in% city)
  }
  # filter for country
  if(!is.null(country)){
    x <- x %>% filter(`Country of visit` %in% country)
  }
  # filter for counterpart
  if(!is.null(counterpart)){
    x <- x %>% filter(Counterpart %in% counterpart)
  }
  # filter for visit start
  if(!is.null(visit_start)){
    x <- x %>% filter(`Visit start` >= visit_start)
  }
  # filter for visit end
  if(!is.null(visit_end)){
    x <- x %>% filter(`Visit end`<= visit_end)
  }
  
  # filter for search
  if(!is.null(search)){
    if(nchar(search) > 0){
      # Get all the search items (seperated by commas, which function as "or" statements)
      search_items <- unlist(strsplit(search, split = ','))
      search_items <- trimws(search_items, which = 'both')
      keeps <- c()
      for(i in 1:length(search_items)){
        these_keeps <- apply(mutate_all(.tbl = x, .funs = function(x){grepl(tolower(search_items[i]), tolower(x))}),1, any)
        these_keeps <- which(these_keeps)
        keeps <- c(keeps, these_keeps)
      }
      keeps <- sort(unique(keeps))
      x <- x[keeps,]
    }
  }
  return(x)
}
