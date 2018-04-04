# function for jittering
# Jitter
joe_jitter <- function(x, zoom = 2){
  z <- (0.1 / (zoom/ 20))^2
  return(x + rnorm(n = length(x),
                   mean = 0,
                   sd = z))
}