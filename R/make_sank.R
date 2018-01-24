#' Make a sankey chart
#'
#' Make an interactive sankey chart
#' @param events A dataframe in the form of the events table
#' @return An html widget
#' @import nd3
#' @export

make_sank <- function(events){
  events_filtered <- events %>%
    filter(!is.na(Person),
           !is.na(Counterpart)) %>%
    filter(nchar(Person) > 1,
           nchar(Counterpart) > 2) %>%
    mutate(Place = paste(`City of visit`,', ', `Country of visit`))
  if(nrow(events) == 0){
    return(NULL)
  } else {
    x <- events_filtered %>%
      group_by(Person, Place) %>%
      tally %>%
      ungroup %>%
      mutate(Person = as.numeric(factor(Person)),
             Place = as.numeric(factor(Place)))
    
    # x <- events_filtered %>%
    #   group_by(Person, Counterpart) %>%
    #   tally %>%
    #   ungroup %>%
    #   mutate(Person = as.numeric(factor(Person)),
    #          Counterpart = as.numeric(factor(Counterpart)))
    # 

    nodes = data.frame("name" = 
                         c(sort(unique(events_filtered$Person)),
                           sort(unique(events_filtered$Place))))
    
    # Replacer
    replacer <- function(x){
      out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
      x <- data.frame(x = x)
      out <- left_join(x, out)
      return(out$y)
    }
    links = bind_rows(
      # Person to counterpart
      events_filtered %>% group_by(Person, Place) %>%
        tally %>%
        ungroup %>%
        mutate(Person = replacer(Person),
               Place = replacer(Place)) %>%
        rename(a = Person,
               b = Place)
    )
    
    
    # Each row represents a link. 
    # The first number represents the node being connected from. 
    # The second number represents the node connected to.
    # The third number is the value of the node
    names(links) = c("source", "target", "value")
    nd3::sankeyNetwork(Links = links, Nodes = nodes,
                       Source = "source", Target = "target",
                       Value = "value", NodeID = "name",
                       fontSize= 12, nodeWidth = 30)
  }
}

