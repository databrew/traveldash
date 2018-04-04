make_empty <- function(cn){
  d <- as.data.frame(x = t(rep(NA, length(cn))), stringsAsFactors = FALSE)
  names(d) <- cn
  d <- d[0,]
  return(d)
}