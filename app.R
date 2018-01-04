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
          
          column(5,
                 dateRangeInput('date',
                           label = 'Date',
                           start = '2017-01-01',
                           end = '2017-12-31'),
                 selectInput('organization',
                             label = 'Organization',
                             choices = organizations,
                             multiple = TRUE),
                 selectInput('person',
                             label = 'Person',
                             choices = people,
                             multiple = TRUE),
                 selectInput('city',
                             label = 'City',
                             choices = cities,
                             multiple = TRUE),
                 selectInput('country',
                             label = 'Country',
                             choices = countries,
                             multiple = TRUE),
                 selectInput('counterpart',
                             label = 'Counterpart',
                             choices = counterparts,
                             multiple = TRUE)),
          column(7,
                 leafletOutput('leafy')
                 )
        ),
        fluidRow(column(6,
                        sankeyNetworkOutput('sank')),
                        # tags$iframe(src='sankey_network.html', height=500, width=750)),
                 column(6,
                        h3('Detailed visit information',
                           align = 'center'),
                        DT::dataTableOutput('visit_info_table')))
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
  
  # Reactive dataframe for the filtered table
  filtered_events <- reactive({
    x <- filter_events(events = events,
                       person = input$person,
                       organization = input$organization,
                       city = input$city,
                       country = input$country,
                       counterpart = input$counterpart,
                       visit_start = input$date[1],
                       visit_end = input$date[2])
  })

  output$leafy <- renderLeaflet({
    places <- filtered_events()
    # icons <- awesomeIcons(
    #   icon = 'ios-close',
    #   iconColor = 'black',
    #   library = 'ion',
    #   markerColor = getColor(df.20)
    # )
    icons <- icons(
      iconUrl = paste0('www/', places$file),
      iconWidth = 20, iconHeight = 28
    )
    popups <- places$Person
    
    leaflet() %>% 
      addProviderTiles("Esri.WorldGrayCanvas", options = tileOptions(
        minZoom=0, 
        maxZoom=16)) %>%
      addMarkers(data = places, lng =~Long, lat = ~Lat,
                       icon = icons,
                 popup = popups)
  })
  
  output$sank <- renderSankeyNetwork({
    make_sank(events = filtered_events())
  })
  
  output$visit_info_table <- DT::renderDataTable({
    x <- filtered_events()
    DT::datatable(x,options = list(dom = 't',
                                   scrollY = '300px',
                                   paging = FALSE,
                                   scrollX = TRUE),
                  rownames = FALSE)
  })
}

shinyApp(ui, server)