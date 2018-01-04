
# Define function for printing nice html tables
prettify <- function (the_table, remove_underscores_columns = TRUE, cap_columns = TRUE,
                      cap_characters = TRUE, comma_numbers = TRUE, date_format = "%B %d, %Y",
                      round_digits = 2, remove_row_names = TRUE, remove_line_breaks = TRUE,
                      data_table = TRUE, nrows = 5, download_options = FALSE, no_scroll = TRUE){
  column_names <- names(the_table)
  the_table <- data.frame(the_table)
  names(the_table) <- column_names
  classes <- lapply(the_table, function(x) {
    unlist(class(x))[1]
  })
  if (cap_columns) {
    names(the_table) <- Hmisc::capitalize(names(the_table))
  }
  if (remove_underscores_columns) {
    names(the_table) <- gsub("_", " ", names(the_table))
  }
  for (j in 1:ncol(the_table)) {
    the_column <- the_table[, j]
    the_class <- classes[j][1]
    if (the_class %in% c("character", "factor")) {
      if (cap_characters) {
        the_column <- as.character(the_column)
        the_column <- Hmisc::capitalize(the_column)
      }
      if (remove_line_breaks) {
        the_column <- gsub("\n", " ", the_column)
      }
    }
    else if (the_class %in% c("POSIXct", "Date")) {
      the_column <- format(the_column, format = date_format)
    }
    else if (the_class %in% c("numeric", "integer")) {
      the_column <- round(the_column, digits = round_digits)
      if (comma_numbers) {
        if(!grepl('year', tolower(names(the_table)[j]))){
          the_column <- scales::comma(the_column)
        }
      }
    }
    the_table[, j] <- the_column
  }
  if (remove_row_names) {
    row.names(the_table) <- NULL
  }
  if (data_table) {
    if (download_options) {
      if(no_scroll){
        the_table <- DT::datatable(the_table, options = list(#pageLength = nrows,
          scrollY = '300px', paging = FALSE,
          dom = "Bfrtip", buttons = list("copy", "print",
                                         list(extend = "collection", buttons = "csv",
                                              text = "Download"))), rownames = FALSE, extensions = "Buttons")
      } else {
        the_table <- DT::datatable(the_table, options = list(pageLength = nrows,
                                                             # scrollY = '300px', paging = FALSE,
                                                             dom = "Bfrtip", buttons = list("copy", "print",
                                                                                            list(extend = "collection", buttons = "csv",
                                                                                                 text = "Download"))), rownames = FALSE, extensions = "Buttons")
      }
      
    }
    else {
      if(no_scroll){
        the_table <- DT::datatable(the_table, options = list(#pageLength = nrows,
          scrollY = '300px', paging = FALSE,
          columnDefs = list(list(className = "dt-right",
                                 targets = 0:(ncol(the_table) - 1)))), rownames = FALSE)
      } else {
        the_table <- DT::datatable(the_table, options = list(pageLength = nrows,
                                                             columnDefs = list(list(className = "dt-right",
                                                                                    targets = 0:(ncol(the_table) - 1)))), rownames = FALSE)
      }
    }
  }
  return(the_table)
}

make_sank <- function(){
  olek <- read_excel('data/Random Sankey Data.xlsx') %>%
    arrange(Country,
            Client,
            Actors,
            Study)
  olek$Client <- gsub('Cleint', 'Client', olek$Client)
  
  x <- olek %>% group_by(Country, Client) %>%
    tally %>%
    ungroup %>%
    mutate(Country = as.numeric(factor(Country)),
           Client = as.numeric(factor(Client)))
  nodes = data.frame("name" = 
                       c(sort(unique(olek$Country)),
                         sort(unique(olek$Client)),
                         sort(unique(olek$Actors)),
                         sort(unique(olek$Study))))# Node 3
  # Replacer
  replacer <- function(x){
    out <- data.frame(x = nodes$name, y = (1:nrow(nodes))-1)
    x <- data.frame(x = x)
    out <- left_join(x, out)
    return(out$y)
  }
  links = bind_rows(
    # Country to client
    olek %>% group_by(Country, Client) %>%
      tally %>%
      ungroup %>%
      mutate(Country = replacer(Country),
             Client = replacer(Client)) %>%
      rename(a = Country,
             b = Client),
    # Client to actors
    olek %>% group_by(Client, Actors) %>%
      tally %>%
      ungroup %>%
      mutate(Client = replacer(Client),
             Actors = replacer(Actors)) %>%
      rename(a = Client,
             b = Actors),
    # Actors to study
    olek %>% group_by(Actors, Study) %>%
      tally %>%
      ungroup %>%
      mutate(Actors = replacer(Actors),
             Study = replacer(Study)) %>%
      rename(a = Actors,
             b = Study)
  )
  
  # Each row represents a link. The first number represents the node being conntected from. 
  # the second number represents the node connected to.
  # The third number is the value of the node
  names(links) = c("source", "target", "value")
  sankeyNetwork(Links = links, Nodes = nodes,
                Source = "source", Target = "target",
                Value = "value", NodeID = "name",
                fontSize= 8, nodeWidth = 30)
}