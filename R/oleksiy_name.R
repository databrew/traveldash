# Function for formatting names per oleksiy's request (Donald Trump > D. Trump)
# oleksiy_name <- function(name){
#   name_split <- unlist(strsplit(name, ' '))
#   if(length(name_split) == 1){
#     return(name)
#   } else {
#     last_name <- name_split[length(name_split)]
#     first_names <- name_split[1:(length(name_split) - 1)]
#     first_names <- 
#       paste0(unlist(lapply(first_names, function(x){
#       substr(x, 1, 1)
#     })), collapse = '.')
#   }
#   return(paste0(first_names, '. ', last_name))
# }
oleksiy_name <- function(name){return(name)}
oleksiy_name <- Vectorize(oleksiy_name)