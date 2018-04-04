# Function for creating oleksiy-formatted date range
oleksiy_date <- function(date1, date2){
  if(date1 == date2){
    out <- format(date1, '%B %d')
  } else {
    the_dates <- c(date1, date2)
    the_dates <- sort(the_dates)
    the_months <- format(the_dates, '%B')
    the_days <- format(the_dates, '%d')
    the_years <- format(the_dates, '%Y')
    if(the_months[1] == the_months[2]){
      out <- paste0(the_months[1], 
                    ' ',
                    the_days[1], '-', the_days[2])
    } else {
      out <- paste0(format(the_dates[1], '%B %d'),
                    ' - ',
                    format(the_dates[2], '%B %d'))
    }
  }
  return(out)
}
oleksiy_date <- Vectorize(oleksiy_date)
