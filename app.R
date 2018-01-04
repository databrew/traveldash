library(shiny)
library(shinydashboard)
library(sparkline)
library(jsonlite)
library(dplyr)
library(leaflet)
library(networkD3)
library(readxl)
library(tidyverse)

# Preparation
source('functions.R')
source('global.R')

# Header
header <- dashboardHeader(title="Travel event dashboard")

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
          
          column(3,
                 h3('Calendar filters'),
                 dateInput('date',
                           label = 'Date',
                           value = NULL),
                 selectInput('country',
                             label = 'Country',
                             choices = countries),
                 selectInput('person',
                             label = 'Person',
                             choices = people)),
          column(9,
                 leafletOutput('leafy')
                 )
        ),
        fluidRow(column(6,
                        sankeyNetworkOutput('sank')),
                        # tags$iframe(src='sankey_network.html', height=500, width=750)),
                 column(6,
                        h3('Detailed visit information',
                           align = 'center'),
                        dataTableOutput('visit_info_table')))
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

  output$leafy <- renderLeaflet({
    leaflet() %>% addTiles()
  })
  
  output$sank <- renderSankeyNetwork({
    make_sank()
  })
  
  output$visit_info_table <- renderDataTable({
    x <- data.frame(Person = letters[1:5],
                    Organization = letters[6:10],
                    Counterpart = letters[11:15],
                    Country = letters[16:20],
                    City = letters[21:25],
                    Date = as.Date(Sys.Date():(Sys.Date() +4), 
                                   origin = '1970-01-01'))
    DT::datatable(x,options = list(dom = 't',
                                   scrollY = '300px', 
                                   paging = FALSE,
                                   scrollX = TRUE), 
                  rownames = FALSE)
  })
}

shinyApp(ui, server)