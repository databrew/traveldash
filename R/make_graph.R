#' Make a network graph chart
#'
#' Make an interactive network graph chart
#' @param events A dataframe in the form of the events table
#' @return An html widget
#' @import nd3
#' @export


make_graph <- function(events){
  
  events <- events %>%
    filter(!is.na(Person),
           !is.na(Counterpart)) %>%
    filter(nchar(Person) > 1,
           nchar(Counterpart) > 2)
  if(nrow(events) == 0){
    return(NULL)
  } else {
    # Replacer
    replacer <- function(x){
      out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
      x <- data.frame(x = x)
      out <- left_join(x, out)
      return(out$y)
    }
    x <- events %>% group_by(Person, Counterpart) %>%
      tally %>%
      ungroup %>%
      mutate(Person = as.numeric(factor(Person)),
             Counterpart = as.numeric(factor(Counterpart)))
    nodes = data.frame("name" = 
                         c(sort(unique(events$Person)),
                           sort(unique(events$Counterpart))))
    nodes$group <-replacer(nodes$name)
    noder <- events %>% group_by(x = Person) %>% tally
    noderb <- events %>% group_by(x = Counterpart) %>% tally
    noder<- bind_rows(noder, noderb) %>%
      group_by(name = x) %>% summarise(size = sum(n))
    nodes <- left_join(nodes, noder, by = 'name')
    links = bind_rows(
      # Person to counterpart
      events %>% group_by(Person, Counterpart) %>%
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
}
