#' Make a network graph chart
#'
#' Make an interactive network graph chart
#' @param trip_coincidences A dataframe in the form of the trip_coincidences view
#' @return An html widget
#' @import nd3
#' @export


make_graph <- function(trip_coincidences){
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
                  Counterpart = coincidence_person_name) %>%
    # remove those where the person and counterpart are the same
    dplyr::filter(Counterpart != Person) %>%
    # Rename the counterpart to avoid loop-arounds
    mutate(Counterpart = paste0(Counterpart, ' '))
  # Replacer
  replacer <- function(x){
    out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
    x <- data.frame(x = x)
    out <- left_join(x, out)
    return(out$y)
  }
  x <- tc %>% group_by(Person, Counterpart) %>%
    tally %>%
    ungroup %>%
    mutate(Person = as.numeric(factor(Person)),
           Counterpart = as.numeric(factor(Counterpart)))
  nodes = data.frame("name" = 
                       c(sort(unique(tc$Person)),
                         sort(unique(tc$Counterpart))))
  nodes$group <-replacer(nodes$name)
  noder <- tc %>% group_by(x = Person) %>% tally
  noderb <- tc %>% group_by(x = Counterpart) %>% tally
  noder<- bind_rows(noder, noderb) %>%
    group_by(name = x) %>% summarise(size = sum(n))
  nodes <- left_join(nodes, noder, by = 'name')
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
  
  nodes$size <- 1
  names(links) = c("source", "target", "value")
  # Plot
  forceNetwork(Links = links, 
               Nodes = nodes,
               Value = 'value',
               NodeID = "name", Group = "group",
               Nodesize="size",                                                    # column names that gives the size of nodes
               radiusCalculation = JS(" d.nodesize^2+10"),                         # How to use this column to calculate radius of nodes? (Java script expression)
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
               # legend = TRUE,                                                      # add a legend?
               bounded = F, 
               clickAction = NULL)
}