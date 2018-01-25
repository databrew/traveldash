#' Make a network graph chart
#'
#' Make an interactive network graph chart
#' @param events A dataframe in the form of the events table
#' @return An html widget
#' @import nd3
#' @export


make_graph <- function(events){
  
  events_filtered <- events %>%
    filter(!is.na(Person)) %>%
    filter(nchar(Person) > 1) %>%
    mutate(Place = paste0(`City of visit`,', ', `Country of visit`))
  
  if(nrow(events_filtered) == 0){
    return(NULL)
  } else {
    # Replacer
    replacer <- function(x){
      out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
      x <- data.frame(x = x)
      out <- left_join(x, out)
      return(out$y)
    }
    events_filtered <- 
      events_filtered %>%
      dplyr::select(Person, Place) %>%
      left_join(people %>% dplyr::select(short_name, is_wbg) %>%
                  mutate(is_wbg = as.logical(is_wbg)) %>%
                  dplyr::rename(Person = short_name),
                by = 'Person')
    
    nodes <- data.frame(name = 
                          c(sort(unique(events_filtered$Place)),
                            sort(unique(events_filtered$Person))))
    nodes$group <- replacer(nodes$name)
    nodes$size <- sample(1:3, nrow(nodes), replace = TRUE)
    

    links = bind_rows(
      # Person to place
      events_filtered %>% group_by(Person, Place) %>%
        tally %>%
        ungroup %>%
        mutate(Person = replacer(Person),
               Place = replacer(Place)) %>%
        rename(a = Person,
               b = Place)
    )
    # Assign color based on whether it's a place, wb person, or non wb person
    nodes <- nodes %>% left_join(people %>% dplyr::select(short_name, is_wbg) %>%
                         mutate(is_wbg = as.logical(is_wbg)) %>%
                         dplyr::rename(name = short_name))
    nodes <- nodes %>%
      mutate(color = ifelse(is.na(is_wbg), 'Location',
                            ifelse(is_wbg, 'WBG',
                                   'Non-WBG')))
    
    nodes$size <- ifelse(nodes$name %in% sort(unique(events_filtered$Place)),
                         10,
                         1)
    
    names(links) = c("source", "target", "value")
    # Plot
    forceNetwork(Links = links, 
                 Nodes = nodes,
                 Value = 'value',
                 NodeID = "name", 
                 Group = "color", # used to be group
                 Nodesize="size",                                                    # column names that gives the size of nodes
                 radiusCalculation = JS(" d.nodesize^6"),                         # How to use this column to calculate radius of nodes? (Java script expression)
                 
                 # radiusCalculation = JS(" d.nodesize^2+10"),                         # How to use this column to calculate radius of nodes? (Java script expression)
                 opacity = 1,                                                      # Opacity of nodes when you hover it
                 opacityNoHover = 0.8,                                               # Opacity of nodes you do not hover
                 colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),          # Javascript expression, schemeCategory10 and schemeCategory20 work
                 fontSize = 17,                                                      # Font size of labels
                 # fontFamily = "serif",                                               # Font family for labels
                 
                 # custom edges
                 # Value="my_width",
                 arrows = FALSE,                                                     # Add arrows?
                 # linkColour = c("grey","orange"),                                    # colour of edges
                 linkWidth = "function(d) { return (d.value^5)*0.4}",
                 
                 # layout
                 linkDistance = 250,                                                 # link size, if higher, more space between nodes
                 charge = -100,                                                       # if highly negative, more space betqeen nodes
                 
                 # -- general parameters
                 height = NULL,                                                      # height of frame area in pixels
                 width = NULL,
                 zoom = TRUE,                                                        # Can you zoom on the figure
                 legend = TRUE,                                                      # add a legend?
                 bounded = F, 
                 clickAction = NULL)
  }
}
