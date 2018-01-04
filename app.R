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
                 uiOutput("choose.date"),
                 fluidRow(
                          column(6, uiOutput("pre.week.btn")),
                          column(6, uiOutput("next.week.btn"))),
                 helpText(textOutput('date_text'))
          ),
          column(7,
                 leafletOutput('leafy'))),
        fluidRow(
          column(5,
                 # tags$iframe(src='sankey_network.html', height=500, width=750)
                 sankeyNetworkOutput('sank')
                 ),
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
                       visit_start = input$dates[1],
                       visit_end = input$dates[2])
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
    if(is.null(input$dates)){
      return(NULL)
    } else {
      visit_start <- input$dates[1]
      visit_end <- input$dates[2]
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
  
  
  # ------- Date Range Input + previous/next week buttons---------------
  output$choose.date <- renderUI({
    dateRangeInput("dates", 
                   label = h3(HTML("<i class='glyphicon glyphicon-calendar'></i> Date Range")), 
                   start = "2017-01-01", end='2017-01-07', 
                   min = date.range[1], max = date.range[2])
  }) 
  
  output$pre.week.btn <- renderUI({
    actionButton("pre.week", 
                 label = HTML("<span class='small'><i class='glyphicon glyphicon-arrow-left'></i> Back</span>"))
  })
  output$next.week.btn <- renderUI({
    actionButton("next.week", 
                 label = HTML("<span class='small'>Next <i class='glyphicon glyphicon-arrow-right'></i></span>"))
  })
  
  date.gap <- reactive({input$dates[2]-input$dates[1]+1})
  observeEvent(input$pre.week, {
    if(input$dates[1]-date.gap() < date.range[1]){
      if(input$dates[2]-date.gap() < date.range[1]){
        updateDateRangeInput(session, "dates", start = date.range[1], end = date.range[1])
      }else{updateDateRangeInput(session, "dates", start = date.range[1], end = input$dates[2]-date.gap())}
      #if those two dates inputs equal to each other, use 7 as the gap by default
    }else{if(input$dates[1] == input$dates[2]){updateDateRangeInput(session, "dates", start = input$dates[1]-7, end = input$dates[2])
    }else{updateDateRangeInput(session, "dates", start = input$dates[1]-date.gap(), end = input$dates[2]-date.gap())}
    }})
  observeEvent(input$next.week, {
    if(input$dates[2]+date.gap() > date.range[2]){
      if(input$dates[1]+date.gap() > date.range[2]){
        updateDateRangeInput(session, "dates", start = date.range[2], end = date.range[2])
      }else{updateDateRangeInput(session, "dates", start = input$dates[1]+date.gap(), end = date.range[2])}
    }else{if(input$dates[1] == input$dates[2]){updateDateRangeInput(session, "dates", start = input$dates[1], end = input$dates[2]+7)
    }else{updateDateRangeInput(session, "dates", start = input$dates[1]+date.gap(), end = input$dates[2]+date.gap())}
    }})
  
  output$dates.input <- renderPrint({input$dates})
}

shinyApp(ui, server)