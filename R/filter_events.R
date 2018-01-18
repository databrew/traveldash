#' Filter events
#'
#' Filter the events table per various dimensions
#' @param events An events dataframe
#' @param person A character vector of any length; if NULL, ignored
#' @param organization A character vector of any length; if NULL, ignored
#' @param city A character vector of any length; if NULL, ignored
#' @param country A character vector of any length; if NULL, ignored
#' @param counterpart A character vector of any length; if NULL, ignored
#' @param visit_start A date
#' @param visit_end A date 
#' @param search A character vector of length 1; if NULL, ignored
#' @return A dataframe
#' @import dplyr
#' @export


filter_events <- function(events,
                          person = NULL,
                          organization = NULL,
                          city = NULL,
                          country = NULL,
                          counterpart = NULL,
                          visit_start = NULL,
                          visit_end = NULL,
                          search = NULL){
  x <- events
  
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
    keeps <- apply(mutate_all(.tbl = x, .funs = function(x){grepl(tolower(search), tolower(x))}),1, any)
    x <- x[keeps,]
  }
  return(x)
}
