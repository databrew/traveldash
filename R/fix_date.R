# Define function for fixing date issues
# necessary since people's spreadsheet programs may do some inconsistent formatting

fix_date <- function(x){
  if(!is.Date(x)){
    if(any(grepl('/', x, fixed = TRUE))){
      out <- as.Date(x, format = '%m/%d/%Y')
    } else if(any(grepl('-', x, fixed = TRUE))){
      out <- as.Date(x)
    } else {
      out <- openxlsx::convertToDate(x)
    }
  } else {
    out <- x
  }
  return(out)
}