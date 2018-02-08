# Implementation of the qdap replace number function, but without having to get whole package
replace_number <- function (text.var, num.paste = TRUE, remove = FALSE) {
  text.var <- as.character(text.var)
  if (remove) 
    return(gsub("[0-9]", "", text.var))
  ones <- c("zero", "one", "two", "three", "four", "five", 
            "six", "seven", "eight", "nine")
  num.paste <- ifelse(num.paste, "separate", "combine")
  unlist(lapply(lapply(gsub(",([0-9])", "\\1", text.var), function(x) {
    if (!is.na(x) & length(unlist(strsplit(x, "([0-9])", 
                                           perl = TRUE))) > 1) {
      num_sub(x, num.paste = num.paste)
    }
    else {
      x
    }
  }), function(x) mgsub(0:9, ones, x)))
}

mgsub <-function (pattern, replacement, text.var, leadspace = FALSE, 
                  trailspace = FALSE, fixed = TRUE, trim = TRUE, order.pattern = fixed, 
                  ...) {
  if (leadspace | trailspace) 
    replacement <- spaste(replacement, trailing = trailspace, 
                          leading = leadspace)
  if (fixed && order.pattern) {
    ord <- rev(order(nchar(pattern)))
    pattern <- pattern[ord]
    if (length(replacement) != 1) 
      replacement <- replacement[ord]
  }
  if (length(replacement) == 1) 
    replacement <- rep(replacement, length(pattern))
  for (i in seq_along(pattern)) {
    text.var <- gsub(pattern[i], replacement[i], text.var, 
                     fixed = fixed, ...)
  }
  if (trim) 
    text.var <- gsub("\\s+", " ", gsub("^\\s+|\\s+$", "", 
                                       text.var, perl = TRUE), perl = TRUE)
  text.var
}