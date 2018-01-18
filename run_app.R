source('functions.R')
source('global.R')
source('server.R')
source('ui.R')
shiny::shinyApp(ui = ui,
              server = server)
