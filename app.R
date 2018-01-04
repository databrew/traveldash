library(shinyjs)
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
      icon=icon("eye"))
  )
)

# UI body
body <- dashboardBody(
  useShinyjs(), # for hiding sidebar
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  # ),
  tabItems(
    tabItem(
      tabName="main",
      fluidPage(
        fluidRow(
          column(5,
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
                             multiple = TRUE),
                 shiny::dateInput('date',
                           label = 'Date',
                           min = as.Date('2017-01-01'),
                           max(as.Date('2017-12-31')),
                           # value = Sys.Date(),
                           startview = 'month'
                 ),
                 sliderInput('date_cushion',
                             label = 'Date cushion',
                             min = 0,
                             max = 185,
                             value = 185),
                 helpText('Examining travel for the period from ', textOutput('date_text'))
          ),
          column(7,
                 leafletOutput('leafy'))),
        fluidRow(
          column(5,
                 sankeyNetworkOutput('sank')),
          column(7,
                 h3('Detailed visit information',
                    align = 'center'),
                 DT::dataTableOutput('visit_info_table')))
      )
    )
    
  ))
# UI
ui <- dashboardPage(header, sidebar, body, skin="blue")

# Server
server <- function(input, output, session) {
  
  # hide sidebar by default
  addClass(selector = "body", class = "sidebar-collapse")
  
  # Reactive dataframe for the filtered table
  filtered_events <- reactive({
    x <- filter_events(events = events,
                       person = input$person,
                       organization = input$organization,
                       city = input$city,
                       country = input$country,
                       counterpart = input$counterpart,
                       visit_start = input$date - input$date_cushion,
                       visit_end = input$date + input$date_cushion)
    # Jitter if necessary
    if(any(duplicated(events$Lat)) |
       any(duplicated(events$Long))){
      x <- x %>%
        mutate(Long = jitter(Long, factor = 0.5),
               Lat = jitter(Lat, factor = 0.5))
    }
    return(x)
    
  })
  
  output$date_text <- renderText({
    if(is.null(input$date)){
      return(NULL)
    } else {
      visit_start <- input$date - input$date_cushion
      visit_end <- input$date + input$date_cushion
      ff <- function(x){format(x, '%B %d, %Y')}
      paste0(ff(visit_start), ' through ', ff(visit_end))
    }
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
      iconWidth = 28, iconHeight = 28
    )
    popups <- places$Person
    
    l <- leaflet() %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      addMarkers(data = places, lng =~Long, lat = ~Lat,
                 icon = icons,
                 popup = popups)
    
    if(length(unique(places$Lat)) == 1){
      l <- l %>%
        setView(lng = places$Long[1], lat = places$Lat[1], zoom = 3)
    } 
    l
  })
  
  output$sank <- renderSankeyNetwork({
    x <- filtered_events()
    show_sankey <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_sankey <- TRUE
      }
    }
    # return(NULL)
    if(show_sankey){
      make_sank(events = x)
    } else {
      return(NULL)
    }
  })
  
  output$visit_info_table <- DT::renderDataTable({
    x <- filtered_events()
    # DT::datatable(x,options = list(dom = 't',
    #                                scrollY = '300px',
    #                                paging = FALSE,
    #                                scrollX = TRUE),
    #               rownames = FALSE)
    x <- x %>%
      dplyr::select(Person,
                    Organization,
                    `City of visit`,
                    `Country of visit`,
                    Counterpart,
                    `Visit start`,
                    `Visit end`)
    prettify(x,
             download_options = TRUE)
  })
}

shinyApp(ui, server)