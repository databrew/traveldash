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
                 fluidRow(
                   h4('Date range'),
                   column(1,
                          actionButton("action_back", "Back", icon = icon('arrow-circle-left'))),
                   column(4, NULL),
                   column(1,
                          actionButton("action_forward", "Forward", icon=icon("arrow-circle-right")))
                 ),
                 uiOutput('dater'),
                 htmlOutput('g_calendar'),
                 textInput('search',
                           'Filter for people, places, organizations, etc.')
          ),
          column(8,
                 leafletOutput('leafy'))),
        fluidRow(
          column(4,
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
  
  starter <- reactiveVal(value = as.numeric(Sys.Date()))
  observeEvent(input$dates, {
    starter(as.Date(input$dates[1]))
  })
  observeEvent(input$selected_date, {
    starter(as.Date(selected_date()))
  })
  observeEvent(input$action_forward, {
    dw <- date_width()
    if(!is.null(dw)){
      starter(starter() + dw)
    } else {
      starter(starter() + 1)
    }
  })
  observeEvent(input$action_back, {
    dw <- date_width()
    if(!is.null(dw)){
      starter(starter() - dw)
    } else {
      starter(starter() - 1)
    }
  })
  seld <- reactive({
    x <- starter()
    x <- as.Date(x, 
                 origin = '1970-01-01')
    x <- as.character(x)
    x
  })
  output$starter_text <- renderText({
    x <- seld()
    x
  })
  
  # Date input
  output$dater <- renderUI({
    seldy <- seld()
    have_selection <- FALSE
    if(exists('seldy')){
      if(!is.null(seldy)){
        have_selection <- TRUE
      }
    }
    if(!have_selection){
      x <- input$date
      if(is.null(x)){
        starty <- date_dictionary$date[1]
      } else {
        starty <- x[1]
      }
      
    } else {
      starty <- as.Date(seldy)
    }
    
    dw <- date_width()
    if(is.null(dw)){
      endy <- starty + 14
    } else {
      endy <- starty + dw
    }
    
    sliderInput("dates",
                "",
                min = date_dictionary$date[1], 
                max = date_dictionary$date[length(date_dictionary$date)], 
                value = c(starty, endy)
    )
    
  })
  
  # Reactive dataframe for the filtered table
  filtered_events <- reactive({
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
    popups <- paste0(places$Person, ' of the ', places$Organization, ' meeting with ', places$Counterpart, ' in ',
                     places$`City of visit`, ' on ', format(places$`Visit start`, '%B %d, %Y'))
    
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
        good_input <- TRUE
      }
    }
    if(!good_input){
      return(NULL)
    } else {
      out <- as.Date(input$dates)
      return(out)
    }
    
  })
  
  output$visit_info_table <- DT::renderDataTable({
    x <- filtered_events()
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
  
  # output$calendar_plot <-
  #   renderPlot({
  #     fd <- filter_dates()
  #     if(is.null(fd)){
  #       return(NULL)
  #     } else {
  #       fills <- ifelse(date_dictionary$date >= fd[1] &
  #                         date_dictionary$date <= fd[2],
  #                       'Selected',
  #                       'Not selected')
  #         date_dictionary$date[date_dictionary$date >= fd[1] &
  #                                     date_dictionary$date <= fd[2]]
  #         col_vec <- c('darkorange', 'lightblue')
  #       gg_cal(date_dictionary$date, fills) +
  #         scale_fill_manual(name = '',
  #                            values = col_vec) +
  #         theme(legend.position = 'none')
  #     }
  #   })
  
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
                     height = 160,
                     # legendPosition = 'bottom',
                     # legendPosition = 'none',
                     # legend = "{position:'none'}",
                     calendar="{yearLabel: { fontName: 'Helvetica',
                     fontSize: 14, color: 'black', bold: false},
                     cellSize: 5,
                     cellColor: { stroke: 'black', strokeOpacity: 0.2 },
                     focusedCellColor: {stroke:'red'}}",
                     gvis.listener.jscode = "
                     var selected_date = data.getValue(chart.getSelection()[0].row,0);
                     var parsed_date = selected_date.getFullYear()+'-'+(selected_date.getMonth()+1)+'-'+selected_date.getDate();
                     Shiny.onInputChange('selected_date',parsed_date)"))
      
      
      }
  })
  
  # Create reactive object for width of dates
  date_width <- reactive({
    fd <- filter_dates()
    if(is.null(fd)){
      14
    } else {
      as.numeric(fd[2] - fd[1])
    }
  })
  
  selected_date <- reactive({input$selected_date})
  
  }

shinyApp(ui, server)