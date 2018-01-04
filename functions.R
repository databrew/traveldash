
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

make_sank <- function(events){
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
                fontSize= 14, nodeWidth = 30)
}

# Define function for filtering events
filter_events <- function(events,
                          person = NULL,
                          organization = NULL,
                          city = NULL,
                          country = NULL,
                          counterpart = NULL,
                          visit_start = NULL,
                          visit_end = NULL,
                          month = NULL){
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
  # filter for month
  if(!is.null(month)){
    x <- x %>% filter(format(`Visit end`, '%B') %in% month |
                        format(`Visit start`, '%B') %in% month)
  }
  return(x)
}
