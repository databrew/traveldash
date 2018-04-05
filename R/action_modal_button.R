# function for closing action modal button
validateIcon <- function(icon) {
  if (is.null(icon) || identical(icon, character(0))) {
    return(icon)
  } else if (inherits(icon, "shiny.tag") && icon$name == "i") {
    return(icon)
  } else {
    stop("Invalid icon. Use Shiny's 'icon()' function to generate a valid icon")
  }
}
action_modal_button <-function (inputId, label, icon = NULL, width = NULL, ...) {
  value <- restoreInput(id = inputId, default = NULL)
  tags$button(id = inputId, style = if (!is.null(width)) 
    paste0("width: ", validateCssUnit(width), ";"), type = "button", 
    class = "btn btn-default action-button", `data-val` = value, 
    `data-dismiss` = "modal",
    list(validateIcon(icon), label),
    ...)
}