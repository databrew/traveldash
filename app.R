library(shiny)
library(shinydashboard)
library(sparkline)
library(jsonlite)
library(dplyr)

# Header
header <- dashboardHeader(title="Databrew app")

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Dashboard",
      tabName="main",
      icon=icon("eye")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon"))
  )
)

# UI body
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  tabItems(
    tabItem(
      tabName="main",
      fluidPage(
        fluidRow(
          p('Some text'),
          column(3,
                 dateInput('date',
                           label = 'Date',
                           value = NULL)),
          column(9,
                 plotOutput('fake_plot'))
        )
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        fluidRow(
          div(img(src='logo_clear.png', align = "center"), style="text-align: center;"),
          h4('Built in partnership with ',
             a(href = 'http://databrew.cc',
               target='_blank', 'Databrew'),
             align = 'center'),
          p('Empowering research and analysis through collaborative data science.', align = 'center'),
          div(a(actionButton(inputId = "email", label = "info@databrew.cc", 
                             icon = icon("envelope", lib = "font-awesome")),
                href="mailto:info@databrew.cc",
                align = 'center')), 
          style = 'text-align:center;'
        )
      )
    )
  )
)

# UI
ui <- dashboardPage(header, sidebar, body, skin="blue")

# Server
server <- function(input, output) {

  output$fake_plot <- renderPlot({
    barplot(1:10)
  })
}

shinyApp(ui, server)