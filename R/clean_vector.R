# Define function for sorting, removing NAs, and removing '' from vectors
clean_vector <- function(x){
  x <- x[!is.na(x)]
  x <- x[x != '']
  x <- sort(unique(x))
  return(x)
}