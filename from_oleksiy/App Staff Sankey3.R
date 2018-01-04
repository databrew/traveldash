# Oleksiy Anokhin
# January 2, 2018

# Travel Event Dashboard (Sankey Diagram Draft)

# Packages
library(networkD3)
library(readxl)
library(tidyverse)

# Set working directory
setwd("C:/DC/IFC/My Shiny apps/App Travel Map")

events <- read_excel("Fake events data1.xlsx") %>%
  arrange(Person,
          Counterpart)

x <- events %>% group_by(Person, Counterpart) %>%
  tally %>%
  ungroup %>%
  mutate(Person = as.numeric(factor(Person)),
         Counterpart = as.numeric(factor(Counterpart)))
nodes = data.frame("name" = 
                     c(sort(unique(events$Person)),
                       sort(unique(events$Counterpart))))

# Replacer
replacer <- function(x){
  out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
  x <- data.frame(x = x)
  out <- left_join(x, out)
  return(out$y)
}
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

# Each row represents a link. The first number represents the node being conntected from. 
# The second number represents the node connected to.
# The third number is the value of the node
names(links) = c("source", "target", "value")
sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 8, nodeWidth = 30)
