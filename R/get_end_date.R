get_end_date <- function(x){
  day <- as.numeric(format(x, '%d'))
  month <- as.numeric(format(x, '%m'))
  year <- as.numeric(format(x, '%Y'))
  if(day > 15){
    out <- ceiling_date(x %m+% months(1), unit = 'month') - 1
  } else {
    out <- ceiling_date(x, unit = 'month') -1 
  }
  return(out)
}