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
library(ggcal) #devtools::install_github('jayjacobs/ggcal')
library(googleVis)

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
          column(4,
                 sliderInput("dates",
                             "Date range",
                             min = date_dictionary$date[1], 
                             max = date_dictionary$date[length(date_dictionary$date)], 
                             value = date_dictionary$date[c(1,7)],
                             animate = TRUE),
                 htmlOutput('g_calendar'),
                 # plotOutput('calendar_plot',
                 #            height = '200px'),
                 # uiOutput('date_mirror') # currently only using for display
                 textInput('search',
                           'Filter for people, places, organizations, etc.')
          ),
          column(8,
                 leafletOutput('leafy'))),
        fluidRow(
          column(4,
                 # tags$iframe(src='sankey_network.html', height=500, width=750)
                 sankeyNetworkOutput('sank')
                 ),
          column(8,
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
    # x <- filter_events(events = events)
    fd <- filter_dates()
    x <- filter_events(events = events,
                       visit_start = fd[1],
                       visit_end = fd[2],
                       search = input$search)
    # Jitter if necessary
    if(any(duplicated(events$Lat)) |
       any(duplicated(events$Long))){
      x <- x %>%
        mutate(Long = jitter(Long, factor = 0.5),
               Lat = jitter(Lat, factor = 0.5))
    }
    return(x)
    
  })

  output$leafy <- renderLeaflet({
    l <- leaflet() %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      setView(lng = mean(events$Long) - 5, lat = mean(events$Lat), zoom = 1)
    l
  })
  
  # Leaflet proxy for the points
  observeEvent(filtered_events(), {
    places <- filtered_events()
    icons <- icons(
      iconUrl = paste0('www/', places$file),
      iconWidth = 28, iconHeight = 28
    )
    popups <- places$Person
    
    ## plot the subsetted ata
    leafletProxy("leafy") %>%
      clearMarkers() %>%
      addMarkers(data = places, lng =~Long, lat = ~Lat,
                 icon = icons,
                 popup = popups)
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
  
  filter_dates <- reactive({
    good_input <- FALSE
    if(!is.null(input$dates)){
      if(!any(is.na(input$dates))){
        # if(!any(grepl('null|na', tolower(input$dates)))){
          good_input <- TRUE
        # }
      }
    }
    if(!good_input){
      return(NULL)
      # as.Date(c('2017-01-01',
      #           '2017-01-07'))
    } else {
      out <- as.Date(input$dates)
      return(out)
    }
    
    # as.Date(paste("01", unlist(strsplit(input$dates, ";")), sep="-"), format="%d-%B-%Y")
  })
  
  output$visit_info_table <- DT::renderDataTable({
    x <- filtered_events()
    # DT::datatable(x,options = list(dom = 't',
    #                                scrollY = '300px',
    #                                paging = FALSE,
    #                                scrollX = TRUE),
    #               rownames = FALSE)
    x <- x %>%
      mutate(Location = paste0(`City of visit`,
                               ', ',
                               toupper(substr(`Country of visit`, 1, 3)))) %>%
      dplyr::select(Person,
                    Organization,
                    Location,
                    # `City of visit`,
                    # `Country of visit`,
                    Counterpart,
                    `Visit start`,
                    `Visit end`)
    prettify(x,
             download_options = TRUE) %>%
      DT::formatStyle(columns = colnames(.), fontSize = '50%')
  })
  
  # output$res <- renderPrint({
  #   print(input$dates) # you have to split manually the result by ";"
  #   print(filter_dates())
  # })
  

  output$date_mirror <- renderUI({
    fd <- filter_dates()
    ok <- FALSE
    if(!is.null(fd)){
      if(length(fd) == 2){
        ok <- TRUE
      }
    }
    if(ok){
      dateRangeInput('date_mirror',
                     label = '',
                     start = fd[1],
                     end = fd[2])
    } else {
      return(NULL)
    }
  })
  
  output$calendar_plot <-
    renderPlot({
      fd <- filter_dates()
      if(is.null(fd)){
        return(NULL)
      } else {
        fills <- ifelse(date_dictionary$date >= fd[1] &
                          date_dictionary$date <= fd[2],
                        'Selected',
                        'Not selected')
          date_dictionary$date[date_dictionary$date >= fd[1] &
                                      date_dictionary$date <= fd[2]]
          col_vec <- c('darkorange', 'lightblue')
        gg_cal(date_dictionary$date, fills) +
          scale_fill_manual(name = '',
                             values = col_vec) +
          theme(legend.position = 'none')
      }
    })
  
  output$g_calendar <- renderGvis({
    
    fd <- filter_dates()
    if(is.null(fd)){
      return(NULL)
    } else {
      fills <- ifelse(date_dictionary$date >= fd[1] &
                        date_dictionary$date <= fd[2],
                      1,
                      0)
      dd <- date_dictionary %>%
        mutate(num = fills)
      gvisCalendar(data = dd, 
                   datevar = 'date',
                   numvar = 'num',
                   options=list(
                     width=300,
                     height = 100,
                     calendar="{yearLabel: { fontName: 'Helvetica',
                               fontSize: 20, color: '#1A8763', bold: false},
                               cellSize: 5,
                               cellColor: { stroke: 'black', strokeOpacity: 0.2 },
                               focusedCellColor: {stroke:'red'}}"))


    }
  })
}

shinyApp(ui, server)