library(shiny)
library(shinydashboard)
library(sparkline)
library(jsonlite)
library(dplyr)

header <- dashboardHeader(title="Databrew app")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      text="Main",
      tabName="main",
      icon=icon("eye")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon"))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  tabItems(
    tabItem(
      tabName="main",
      fluidPage(
        fluidRow(
          a(href="http://databrew.cc",
            target="_blank", uiOutput("box1")),
          a(href="http://databrew.cc",
            target="_blank", uiOutput("box2"))
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
  
  output$box1 <- renderUI({
    valueBox(
      "12345", "Some information 1", icon = icon("bullseye"),
      color = 'blue'
    )})
  
  output$box2 <- renderUI({
    valueBox(
      5, "Some information 2", icon = icon("tachometer"),
      color = 'orange'
    )})
}

shinyApp(ui, server)