#' Make a sankey chart
#'
#' Make an interactive sankey chart
#' @param trip_coincidences A dataframe in the form of the trip_coincidences view
#' @param meeting Use explicit meetings rather than just trip coincidences
#' @return An html widget
#' @import nd3
#' @export

make_sank <- function(trip_coincidences,
                      meeting = TRUE){
  if(meeting){
    tc <- trip_coincidences %>%
      dplyr::select(person_name, 
                    is_wbg,
                    city_name,
                    country_name,
                    trip_start_date,
                    trip_end_date,
                    meeting_person_name,
                    coincidence_is_wbg) %>%
      dplyr::rename(Person = person_name,
                    Counterpart = meeting_person_name) 
  } else {
    tc <- trip_coincidences %>%
      dplyr::select(person_name, 
                    is_wbg,
                    city_name,
                    country_name,
                    trip_start_date,
                    trip_end_date,
                    coincidence_person_name,
                    coincidence_is_wbg) %>%
      dplyr::rename(Person = person_name,
                    Counterpart = coincidence_person_name) 
  }
  tc <- tc %>%
    # remove those where the person and counterpart are the same
    dplyr::filter(Counterpart != Person) %>%
    # Rename the counterpart to avoid loop-arounds
    mutate(Counterpart = paste0(Counterpart, ' '))

  if(nrow(tc) == 0){
    return(NULL)
  } else {
    nodes = data.frame("name" = 
                         c(sort(unique(tc$Person)),
                           sort(unique(tc$Counterpart))))
    
    # Replacer
    replacer <- function(x){
      out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
      x <- data.frame(x = x)
      out <- left_join(x, out)
      return(out$y)
    }
    links = bind_rows(
      # Person to counterpart
      tc %>% group_by(Person, Counterpart) %>%
        tally %>%
        ungroup %>%
        mutate(Person = replacer(Person),
               Counterpart = replacer(Counterpart)) %>%
        rename(a = Person,
               b = Counterpart)
    )
    
    
    # Each row represents a link. 
    # The first number represents the node being connected from. 
    # The second number represents the node connected to.
    # The third number is the value of the node
    names(links) = c("source", "target", "value")
    nd3::sankeyNetwork(Links = links, Nodes = nodes,
                       Source = "source", Target = "target",
                       Value = "value", NodeID = "name",
                       fontSize= 12, nodeWidth = 20)
  }
}
