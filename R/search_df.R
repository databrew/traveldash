search_df <- function(data, search_string){
  if(!is.null(search_string)){
    if(length(search_string) > 0){
      if(nchar(search_string) > 0){
        keeps <- c()
        search_string <- trimws(unlist(strsplit(search_string, ',')), 'both')
        search_string <- tolower(search_string)
        
        search <- search_string
        search_items <- unlist(strsplit(search, split = ','))
        search_items <- trimws(search_items, which = 'both')
        keeps <- c()
        for(i in 1:length(search_items)){
          these_keeps <- apply(mutate_all(.tbl = data, .funs = function(x){grepl(tolower(search_items[i]), tolower(x))}),1, any)
          these_keeps <- which(these_keeps)
          keeps <- c(keeps, these_keeps)
        }
        keeps <- sort(unique(keeps))
        data <- data[keeps,]
      }
    }
  }
  return(data)
}
