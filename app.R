library(shiny)
library(shinydashboard)
source('global.R')
the_width <- 270

# Header
header <- dashboardHeader(title="Travel event dashboard",
                          titleWidth = the_width)

# Sidebar
sidebar <- dashboardSidebar(
  width = the_width,
  sidebarMenu(
    menuItem(
      text="Dashboard",
      tabName="main",
      icon=icon("eye")),
    menuItem(
      text="Network analysis",
      tabName="network",
      icon=icon("eye")),
    menuItem(
      text="Timeline",
      tabName="timeline",
      icon=icon("calendar")),
    menuItem(
      text="Upload data",
      tabName="upload_data",
      icon=icon("upload")),
    # menuItem(
    #   text="Edit data",
    #   tabName="edit_data",
    #   icon=icon("edit")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon")),
    br(), br(), br(),br(), br(), br(),br(), br(), 
    fluidPage(
      h4('Details', align = 'center', style = 'text-align: center;'),
      h5('Built by:'),
      helpText('FIG Africa Digital Financial Services unit'),
      h5('With help from:'),
      helpText('The Partnership for Financial Inclusion'),
      helpText('The MasterCard Foundation'),
      br(),
      fluidRow(div(img(src='partnershiplogo.png', align = "center", width = '100px'), style="text-align: center;"),
               br()
      )
    )
    
    
  )
)

# UI body
body <- dashboardBody(
  useShinyjs(), # for hiding sidebar
  # useShinyalert(),
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "horizontal.css")
  # ),
  
  tabItems(
    tabItem(
      tabName="main",
      fluidPage(
        fluidRow(
          column(1),
          column(4,
                 fluidRow(
                   div(uiOutput('datey'),
                       uiOutput('dater'), style='text-align: center;'),
                   fluidRow(
                     fluidRow(column(1),
                              column(8,
                                     h6('Or click forward or back to move over time', align = 'center')),
                              column(3)),
                     div(column(1),
                         column(2,
                                actionButton("action_back", "Back", icon = icon('arrow-circle-left'))),
                         column(3),
                         column(2,
                                actionButton("action_forward", "Forward", icon=icon("arrow-circle-right"))),
                         column(4),
                         style='text-align: center;')
                   ),
                   br(),
                   div(
                   fluidRow(radioButtons('wbg_only',
                                         'Filter by affiliation',
                                         choices = c('Everyone', 'WBG only', 'Non-WBG only'),
                                         inline = TRUE)),
                   fluidRow(textInput('search',
                                      'Filter for people, events, places, organizations, etc. (separate items with a comma)')), style='text-align: center;')
                   # fluidRow(
                   #   fluidRow(
                   #     column(1),
                   #     column(8,
                   #            h6('Or click on any date below to jump around:',
                   #               align = 'center')),
                   #     column(3)
                   #   )#,
                   #   # fluidRow(
                   #   #   div(
                   #   #     # column(1),
                   #   #     column(12,
                   #   #            htmlOutput('g_calendar')),
                   #   #       style = 'text-align: center;')
                   #   # )
                   #   )
                 )
                 
                 
          ),
          column(1),
          column(6,
                 leafletOutput('leafy'))),
        fluidRow(
          column(6,
                 h4('Interactions during selected period:',
                    align = 'center'),
                 radioButtons('sankey_meeting',
                               'Show meetings only vs. any trip overlaps',choices = c('Meetings only', 'Trip overlaps'),
                              selected = 'Meetings only',
                              inline = TRUE),
                 sankeyNetworkOutput('sank')),
          column(6,
                 h4('Detailed visit information',
                    align = 'center'),
                 DT::dataTableOutput('visit_info_table'))
          # div(class = 'scroll',
          #     DT::dataTableOutput('visit_info_table')))
        )
      )
    ),
    tabItem(
      tabName = 'network',
      fluidPage(
        fluidRow(
          h3('Visualization of interaction between people and places during the selected period', align = 'center'),
          fluidRow(
            column(6,
                   dateRangeInput('date_range_network',
                                  'Filter for a specific date range:',
                                  start = min(date_dictionary$date, na.rm = TRUE),
                                  end = max(date_dictionary$date, na.rm = TRUE))),
            column(6,
                   textInput('search_network',
                             'Or filter for specific events, people, places, etc.:'))
          ),
          forceNetworkOutput('graph')
        )
      )
    ),
    tabItem(
      tabName = 'timeline',
      fluidPage(
        fluidRow(
          column(3,
                 dateRangeInput('date_range_timeline',
                                'Filter for a specific date range:',
                                start = min(date_dictionary$date),
                                max = max(date_dictionary$date))),
          column(3,
                 actionButton('timevis_clear',
                              'Clear selection')),
          column(3,
                 checkboxInput('show_meetings',
                               'Show meetings',
                               value = FALSE)),
          column(3,
                 textInput('search_timeline',
                           'Or filter for specific events, people, places, etc.:'))
        ),
        fluidRow(
          timevisOutput('timevis')
        )
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        fluidRow(h4("The dashboard was developed as a part of activities under the ", 
                    a(href = 'http://www.ifc.org/wps/wcm/connect/region__ext_content/ifc_external_corporate_site/sub-saharan+africa/priorities/financial+inclusion/za_ifc_partnership_financial_inclusion',
                      target='_blank',
                      "Partnership for Financial Inclusion"),
                    " (a $37.4 million joint initiative of the ",
                    a(href = "http://www.ifc.org/wps/wcm/connect/corp_ext_content/ifc_external_corporate_site/home",
                      target='_blank',
                      'IFC'),
                    " and the ",
                    a(href = "http://www.mastercardfdn.org/",
                      target='_blank',
                      'MasterCard Foundation'),
                    " to expand microfinance and advance digital financial services in Sub-Saharan Africa) by the FIG Africa Digital Financial Services unit (the MEL team).")),
        br(),
        fluidRow(div(img(src='partnershiplogo.png', 
                         align = "center",
                         height = '90'), style="text-align: center;"),
                 br(), 
                 style = 'text-align:center;'
        ),
        br(),
        fluidRow(
          shinydashboard::box(
            title = 'Soren Heitmann',
            fluidPage(
              fluidRow(
                div(a(img(src='about/Soren Heitmann.jpg', 
                          align = "center",
                          height = '80'),
                      href="mailto:sheitmann@ifc.org"), 
                    style="text-align: center;")
              ),
              fluidRow(h5('Project Lead'),
                       h5('Johannesburg, ', 
                          a(href = 'mailto:sheitmann@ifc.org',
                            'sheitmann@ifc.org'))),
              fluidRow(helpText("Soren has a background in database management, software engineering and web technology. He manages the applied research and integrated monitoring, evaluation and learning program for the IFC-MasterCard Foundation Partnership for Financial Inclusion. He works at the nexus of data-driven research and technology to help drive learning and innovation within IFC’s Digital Financial Services projects in Sub-Saharan Africa."))
            ),
            width = 4),
          shinydashboard::box(
            title = 'Oleksiy Anokhin',
            fluidPage(
              fluidRow(
                div(a(img(src='about/Oleksiy Anokhin.jpg', 
                          align = "center",
                          height = '80'),
                      href="mailto:oanokhin@ifc.org"), 
                    style="text-align: center;")
              ),
              fluidRow(h5('Project Specialist'),
                       h5('Washington, DC, ', 
                          a(href = 'mailto:oanokhin@ifc.org',
                            'oanokhin@ifc.org'))),
              fluidRow(helpText("Oleksiy focuses on data-driven visualization solutions for international development. He is passionate about using programmatic tools (such as interactive dashboards) for better planning and implementation of projects, as well as for effective communication of projects results to various stakeholders."))
            ),
            width = 4),
          shinydashboard::box(
            title = 'Joe Brew',
            fluidPage(
              fluidRow(
                div(a(img(src='about/Joe Brew.png', 
                          align = "center",
                          height = '80'),
                      href="mailto:jbrew1@worldbank.org"), 
                    style="text-align: center;")
              ),
              fluidRow(h5('Data Scientist'),
                       h5('Amsterdam, ', 
                          a(href = 'mailto:jbrew1@worldbank.org',
                            'jbrew1@worldbank.org'))),
              fluidRow(helpText("Joe is a data scientist with a background in epidemiology and development economics. He works in both industry as a consultant as well as academia. His research focuses on the economics of malaria elimination programs in Sub-Saharan Africa."))
            ),
            width = 4)
        ),
        fluidRow(br(),
                 div(a(actionButton(inputId = "email", label = "Contact", 
                                    icon = icon("envelope", lib = "font-awesome")),
                       href="mailto:sheitmann@ifc.org",
                       align = 'center')), 
                 style = 'text-align:center;'
        )
      )
    ),
    # tabItem(
    #   tabName = 'edit_data',
    #   uiOutput("MainBody")),
    tabItem(tabName = 'upload_data',
            fluidPage(
              fluidRow(
                column(12,
                       h3('Upload your own data to the dashboard'),
                       p('You can upload your own data, which will be geocoded, formatted, and then integrated into the dashboard. To do see, follow the instructions to the left. If you want a sample data set (with the format for upload), click one of the buttons to the right (the "short" format should be suitable for most users).')),
                column(6,
                       h4('Upload data'),
                       helpText('Upload a dataset from your computer. This should be either a .csv or .xls file.'),
                       fileInput('file1',
                                 '',
                                 accept=c('text/csv',
                                          'text/comma-separated-values,text/plain',
                                          '.csv'))),
                column(6,
                       h4('Download sample dataset'),
                       helpText('Click the "Download" button to get a sample dataset.'),
                       downloadButton("download_short", "Download short format"),
                       downloadButton("download_long", "Download long format"),
                       fluidRow(p('If in "long format" mode, you can enter the word "UPDATE" or "DELETE" in the "STATUS" column in order to change the database.')))),
              uiOutput('upload_ui'),
              fluidRow(
                h3(textOutput('your_data_text')),
                DT::dataTableOutput('uploaded_table')
              )
              
            ))
  ))
message('Done defining UI')
ui <- dashboardPage(header, sidebar, body, skin=skin)

server <- function(input, output, session) {
  
  # Create a reactive data frame from the user upload 
  uploaded <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    } else {
      if(grepl('csv', inFile$datapath)){
        x <- read_csv(inFile$datapath)
      } else if(grepl('xls', inFile$datapath)){
        x <- read_excel(inFile$datapath)
      }
      x
    }
  })
  
  # Column table
  output$column_table_short <- renderTable({
    short_format %>% sample_n(0)
  })
  output$column_table_long <- renderTable({
    long_format %>% sample_n(0)
  })
  
  output$uploaded_table <- DT::renderDataTable({
    ur <- vals$upload_results
    if(!is.null(ur)){
      prettify(ur, download_options = TRUE)
    } else {
      x <- uploaded()
      if(!is.null(x)){
        prettify(x)
      } else {
        NULL
      }
    }
  })
  
  
  output$your_data_text <- renderText({
    ur <- vals$upload_results
    x <- uploaded()
    if(!is.null(ur)){
      'Your uploaded data "results"'
    } else if(!is.null(x)){
      'Your data'
    } else {
      NULL
    }
  })
  
  output$conformity_text <- renderText({
    x <- uploaded()
    if(!is.null(x)){
      uploaded_names <- names(x)
      short_names <- names(head(short_format))
      long_names <- names(head(long_format))
      if(all(uploaded_names == short_names)){
        'Your data matches the short format. Click "Submit" to use it in the app and save it to the database.'
      } else if(all(uploaded_names == long_names)){
        'Your data matches the long format. Click "Submit" to use it in the app and save it to the database.'
      } else {
        paste0('Your data does not match either the short or long format. Please upload a different dataset.')
      }
    } else {
      NULL
    }
  })
  
  output$submit_text <-
    renderText({
      out <- submit_text()
      out
    })
  output$upload_ui <-
    renderUI({
      
      x <- uploaded()
      if(is.null(x)){
        fluidRow(
          column(8,
                 helpText(paste0('Your uploaded data can be in either "short" format or "long" format.')),
                 h4('Short format'),
                 tableOutput('column_table_short'),
                 h4('Long format'),
                 tableOutput('column_table_long')),
          column(4)
        )
      } else {
        fluidPage(
          fluidRow(h4(textOutput('conformity_text'))),
          fluidRow(actionButton('submit',
                                'Submit',
                                icon = icon('gears'))),
          fluidRow(
            textOutput('submit_text')
          )
        )
      }
    })
  
  output$download_short <- downloadHandler(
    filename = function() {
      'short_format.csv'
    },
    content = function(file) {
      write.csv(short_format, file, row.names = FALSE)
    }
  )
  output$download_long <- downloadHandler(
    filename = function() {
      'long_format.csv'
    },
    content = function(file) {
      write.csv(long_format, file, row.names = FALSE)
    }
  )
  
  # hide sidebar by default
  # addClass(selector = "body", class = "sidebar-collapse")
  
  starter <- reactiveVal(value = as.numeric(get_start_date(Sys.Date())))
  ender <- reactiveVal(value = as.numeric(get_end_date(Sys.Date())))
  the_dates <- reactive(
    c(starter(),
      ender())
  )
  
  date_width <- reactive({
    fd <- the_dates()
    if(is.null(fd)){
      14
    } else {
      as.numeric(fd[2] - fd[1])
    }
  })  
  observeEvent(input$dates, {
    starter(as.Date(input$dates[1]))
    ender(as.Date(input$dates[2]))
  })
  observeEvent(input$date_range, {
    starter(as.Date(input$date_range[1]))
    ender(as.Date(input$date_range[2]))
  })
  
  observeEvent(input$action_forward, {
    dw <- date_width()
    if(!is.null(dw)){
      starter(starter() + dw)
      ender(ender() + dw)
    } else {
      starter(starter() + 1)
      ender(ender() + 1)
    }
  })
  observeEvent(input$action_back, {
    dw <- date_width()
    if(!is.null(dw)){
      starter(starter() - dw)
      ender(ender() - dw)
    } else {
      starter(starter() - 1)
      ender(ender() - 1)
    }
  })
  
  # selected_date <- reactive({input$selected_date})
  
  seld <- reactive({
    x <- starter()
    x <- as.Date(x, 
                 origin = '1970-01-01')
    x <- as.character(x)
    x
  })
  
  output$datey <- renderUI({
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
    if(is.na(endy)){
      endy <- max(date_dictionary$date, na.rm = TRUE)
    }
    dateRangeInput('date_range',
                   'Set a date range for analysis of itineraries',
                   start = starty,
                   end = endy)
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
                "Or set the date range using the below slider:",
                min = min(date_dictionary$date, na.rm = TRUE), 
                max = max(date_dictionary$date, na.rm = TRUE), 
                value = c(starty, endy)
    )
    
  })
  
  
  
  
  
  # Reactive dataframe for the filtered table
  vals <- reactiveValues()
  vals$events<-filter_events(events = events,
                             visit_start = min(date_dictionary$date),
                             visit_end = max(date_dictionary$date))
  vals$cities <- cities
  vals$people <- people
  vals$trip_meetings <- trip_meetings
  vals$trips <- trips
  vals$view_trip_coincidences <- view_trip_coincidences
  vals$upload_results <- NULL
  
  # Replace data with uploaded data
  observeEvent(input$submit, {
    new_data <- uploaded()
    message('new data has ', nrow(new_data), ' rows')
    # Upload the new data to the database
    upload_results <- 
      upload_raw_data(pool = pool,
                      data = new_data,
                      return_upload_results = TRUE)
    message('Uploaded raw data')
    # Update the session
    updated_data <- db_to_memory(pool = pool, return_list = TRUE)
    vals$events <- updated_data$events
    vals$cities <- updated_data$cities
    vals$people <- updated_data$people
    vals$trip_meetings <- updated_data$trip_meetings
    vals$trips <- updated_data$trips
    vals$view_trip_coincidences <- updated_data$view_trip_coincidences
    vals$upload_results <- upload_results
  })
  
  # After modification is confirmed, update the data stores
  observeEvent(input$submit2, {
    # THIS NEEDS CHANGES
    message('Modification confirmed, geocoding and overwriting data.')
    new_data <- vals$events
    # Geocode if applicable
    new_data <- geo_code(new_data)
    # Update the underlying data 
    # Update the underlying data
    write_table(connection_object = pool,
                table = 'dev_events',
                schema = 'pd_wbgtravel',
                value = new_data,
                use_sqlite = use_sqlite)
    message('Ovewrote the database')
  })
  
  
  submit_text <- reactiveVal(value = '')
  observeEvent(input$submit, {
    submit_text('Data uploaded! Now click through other tabs to explore your data.')
  })
  observeEvent(input$Del_row_head, {
    vals$events <- vals$events
  })
  filtered_events <- reactive({
    # x <- vals$events
    fd <- the_dates()
    vd <- vals$events
    x <- filter_events(events = vd,
                       people = vals$people,
                       visit_start = fd[1],
                       visit_end = fd[2],
                       search = input$search,
                       wbg_only = input$wbg_only)
    # Jitter if necessary
    if(any(duplicated(x$Lat)) |
       any(duplicated(x$Long))){
      x <- x %>%
        mutate(Long = jitter(Long, factor = 0.5),
               Lat = jitter(Lat, factor = 0.5))
    }
    return(x)
    
  })
  
  filtered_events_timeline <- reactive({
    fd <- input$date_range_timeline
    vd <- vals$events
    x <- filter_events(events = vd,
                       visit_start = fd[1],
                       visit_end = fd[2],
                       search = input$search_timeline)
    return(x)
  })
  
  selected_timevis <- reactiveVal(value = NULL)
  observeEvent(input$timevis_selected,
               selected_timevis(input$timevis_selected))
  observeEvent(input$timevis_clear,
               selected_timevis(NULL))
  
  filtered_expanded_trips <- reactive({
    sm<- input$show_meetings
    fd <- input$date_range_timeline
    search_string <- input$search_timeline
    out <- expanded_trips %>%
      filter(end >= fd[1],
             start <= fd[2])
    keeps <- c()
    search_string <- trimws(unlist(strsplit(search_string, ',')), 'both')
    search_string <- tolower(search_string)
    if(!is.null(search_string)){
      if(length(search_string) > 0){
        for(i in 1:length(search_string)){
          search <- search_string[i]
          keep_this <- which(grepl(search, tolower(out$city_name)) |
                               grepl(search, tolower(out$title)) |
                               grepl(search, tolower(out$content)))
          keeps <- c(keeps, keep_this)
        }
        keeps <- sort(unique(keeps))
        out <- out[keeps,]
      }
    }
    
    if(nrow(out) > 0){
      # events only
      if(!sm){
        out <- out %>% filter(group == 1)
      }
      if(nrow(out) > 0){
        # Capture the selection if it exists
        selected <- selected_timevis()
        selected <- as.numeric(selected)
        if(!is.null(selected)){
          if(length(selected) > 0){
            # Get whether a meeting or event has been selected
            selected_row <- out %>% filter(id == selected)
            # Deal with bug in which a selected meeting gets disappeared
            if(nrow(selected_row) != 1){
              srei <- unique(expanded_trips$id)
            } else {
              # Get the selected row event id
              srei <- selected_row$event_id
            }

            # Keep everything with same event id
            out <- out %>%
              filter(event_id %in% srei)
          }
        }
      } else {
        out <- NULL
      }
      
      
    } else {
      out <- NULL
    }
    
    
    return(out)
  })
  
  
  
  # Create a filtered view_trip_coincidences
  filtered_view_trip_coincidences <- reactive({
    fd <- the_dates()
    vd <- vals$view_trip_coincidences
    x <- vd %>%
      dplyr::filter(fd[1] <= trip_end_date,
                    fd[2] >= trip_start_date)
    
    # Filter for search box too
    if(!is.null(input$search)){
      if(nchar(input$search) > 0){
        search <- input$search
        print(search)
        search_items <- unlist(strsplit(search, split = ','))
        search_items <- trimws(search_items, which = 'both')
        keeps <- c()
        for(i in 1:length(search_items)){
          these_keeps <- apply(mutate_all(.tbl = x, .funs = function(x){grepl(tolower(search_items[i]), tolower(x))}),1, any)
          these_keeps <- which(these_keeps)
          keeps <- c(keeps, these_keeps)
        }
        keeps <- sort(unique(keeps))
        x <- x[keeps,]
      }
    }
    
    return(x)
  })
  
  output$leafy <- renderLeaflet({
    
    # Get filtered place
    places <- filtered_events()
    
    # Get row selection (if applicable) from datatable
    s <- input$visit_info_table_rows_selected

    # Subset places if rows are selected
    if(!is.null(s)){
      if(length(s) > 0){
        places <- places[s,]
      }
    }

    # Get number of rows of places
    nrp <- nrow(places)
    
    # Get whether wbg or not
    places <- 
      left_join(places,
                people %>%
                  dplyr::select(short_name, is_wbg) %>%
                  dplyr::filter(!duplicated(short_name)),
                by = c('Person' = 'short_name'))
    places$is_wbg <- as.logical(places$is_wbg)
    
    # Overwrite event with the "counterpart" if event is NA
    places$Event <- ifelse(is.na(places$Event),
                           places$Counterpart,
                           places$Event)
    
    # Get a id
    places <- places %>% 
      mutate(id = paste0(Person, Organization, is_wbg, 
                         Event, 
                         `City of visit`, collapse = NULL)) %>%
      mutate(id = as.numeric(factor(id))) %>%
      dplyr::rename(City = `City of visit`) %>%
      dplyr::rename(Date = `Visit start`) %>%
      mutate(Date = format(Date, '%b %d, %Y'))
    
    
    # Make only one head per person/place
    full_places <- places %>% arrange(Date)
    places <- places %>%
      group_by(Person, Organization, City, `Country of visit`) %>%
      summarise(Date = paste0(Date, collapse = ';'),
                Lat = dplyr::first(Lat),
                Long = dplyr::first(Long),
                Event = paste0(Event, collapse = ';'),
                is_wbg = dplyr::first(is_wbg),
                id = paste0(id, collapse = ';')) %>% ungroup
    
    pops <- places %>%
      filter(!duplicated(id))
    
    popups = lapply(rownames(pops), function(row){ 
      this_id <- unlist(pops[row,'id'])
      # Get the original rows from full places for each of the ids
      ids <- unlist(lapply(strsplit(this_id, ';'), as.numeric))
      out_list <- list()
      for(i in 1:length(ids)){
        message(i)
        this_id <- ids[i]
        x <- full_places %>% dplyr::filter(id == this_id) %>%
          dplyr::select(Date, Person, City, Event, id)
        out_list[[i]] <- x
      }
      x <- bind_rows(out_list) 
      x <- x %>% distinct(Date, Person, City, Event, .keep_all = TRUE)
      # if(nrow(x) > 1){
      #   x$Person[2:nrow(x)] <- ''
      #   x$City[2:nrow(x)] <- ''
      # }
      y <- x %>%
        dplyr::select(-id, -Person, -City)
      htmlTable(y,
                rnames = FALSE,
                caption = paste0(x$Person[1], ' in ', x$City[1]),
                align = paste(rep("l", ncol(y)), collapse = ''))
    })
    
    
    # Get faces
    faces_dir <- paste0('www/headshots/circles/')
    faces <- dir(faces_dir)
    faces <- data_frame(joiner = gsub('.png', '', faces, fixed = TRUE),
                        file = paste0(faces_dir, faces))
    
    # Create a join column
    faces$joiner <- ifelse(is.na(faces$joiner) | faces$joiner == 'NA', 
                           'Unknown', 
                           faces$joiner)
    pops$joiner <- ifelse(pops$Person %in% faces$joiner, 
                          pops$Person,
                          'Unknown')
    
    # Join the files to the places data
    if(nrow(pops) > 0){
      pops <- 
        left_join(pops,
                  faces,
                  by = 'joiner')
      # Define colors
      cols <- ifelse(is.na(pops$is_wbg) | 
                       !pops$is_wbg,
                     'orange',
                     'blue')
    } else {
      pops <- events[0,]
    }
    face_icons <- icons(pops$file,
                        iconWidth = 25, iconHeight = 25)
    
    ## plot the subsetted ata
    # leafletProxy("leafy") %>%
    # clearMarkers() %>%
    # setView(lng = mean(pops$Long, na.rm = TRUE), lat = mean(pops$Lat, na.rm = TRUE)) %>%
    l <- leaflet() %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      # setView(lng = mean(events$Long, na.rm = TRUE) - 5, lat = mean(events$Lat, na.rm = TRUE), zoom = 1) %>%
      leaflet.extras::addFullscreenControl() %>%
      addLegend(position = 'topright', colors = c('orange', 'blue'), labels = c('Non-WBG', 'WBG')) %>%
      addCircleMarkers(data = pops, lng =~Long, lat = ~Lat,
                       # clusterOptions = markerClusterOptions(),
                       col = cols, radius = 14) %>%
      addMarkers(data = pops, lng =~Long, lat = ~Lat,
                 popup = popups,
                 # clusterOptions = markerClusterOptions(),
                 icon = face_icons) 
    
    # Zoom out a bit if only 1 city or person
    if(nrp == 1 | length(unique(places$City)) == 1){
      l <- l %>%
        setView(lng = mean(places$Long, na.rm = TRUE),
                lat = mean(places$Lat, na.rm = TRUE),
                zoom = 7)
    }
    
    # addDrawToolbar(
    #   targetGroup='draw',
    #   editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))  %>%
    # addLayersControl(overlayGroups = c('draw'), options =
    #                    layersControlOptions(collapsed=FALSE)) %>%
    # addStyleEditor()
    l
  })
  
  # # Leaflet proxy for the points
  # observeEvent(filtered_events(), {
  #   places <- filtered_events()
  #   
  #   # Get whether wbg or not
  #   places <- 
  #     left_join(places,
  #               people %>%
  #                 dplyr::select(short_name, is_wbg),
  #               by = c('Person' = 'short_name'))
  #   places$is_wbg <- as.logical(places$is_wbg)
  #   
  #   # Get a id
  #   places <- places %>% 
  #     mutate(id = paste0(Person, Organization, Lat, Long, is_wbg, 
  #              Counterpart, 
  #              `City of visit`, `Country of visit`, collapse = NULL)) %>%
  #     mutate(id = as.numeric(factor(id))) %>%
  #     dplyr::rename(City = `City of visit`) %>%
  #     dplyr::rename(Date = `Visit start`) %>%
  #     mutate(Date = format(Date, '%b %d, %Y'))
  #   
  #   pops <- places %>%
  #     filter(!duplicated(id))
  #   
  #   popups = lapply(rownames(pops), function(row){ 
  #     this_id <- pops[row,'id']
  #     x <- places %>% filter(id == this_id) %>%
  #       dplyr::select(Date, Person, City, Event)
  #     htmlTable(x,
  #               rnames = FALSE)
  #     })
  #   
  #   
  #   # Get faces
  #   faces_dir <- paste0('www/headshots/circles/')
  #   faces <- dir(faces_dir)
  #   faces <- data_frame(joiner = gsub('.png', '', faces, fixed = TRUE),
  #                       file = paste0(faces_dir, faces))
  #   
  #   # Create a join column
  #   faces$joiner <- ifelse(is.na(faces$joiner) | faces$joiner == 'NA', 
  #                          'Unknown', 
  #                          faces$joiner)
  #   pops$joiner <- ifelse(pops$Person %in% faces$joiner, 
  #                         pops$Person,
  #                           'Unknown')
  #   
  #   # Join the files to the places data
  #   if(nrow(pops) > 0){
  #     pops <- 
  #       left_join(pops,
  #                 faces,
  #                 by = 'joiner')
  #     # Define colors
  #     cols <- ifelse(is.na(pops$is_wbg) | 
  #                      !pops$is_wbg,
  #                    'orange',
  #                    'blue')
  #   } else {
  #     pops <- events[0,]
  #   }
  #   face_icons <- icons(pops$file,
  #                       iconWidth = 25, iconHeight = 25)
  #   
  #   ## plot the subsetted ata
  #   leafletProxy("leafy") %>%
  #     clearMarkers() %>%
  #     setView(lng = mean(pops$Long, na.rm = TRUE), lat = mean(pops$Lat, na.rm = TRUE)) %>%
  #     addCircleMarkers(data = pops, lng =~Long, lat = ~Lat,
  #                      col = cols, radius = 14) %>%
  #     addMarkers(data = pops, lng =~Long, lat = ~Lat,
  #                popup = popups,
  #                icon = face_icons) 
  # })
  
  output$sank <- renderSankeyNetwork({
    x <- filtered_view_trip_coincidences()
    show_sankey <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_sankey <- TRUE
      }
    }
    if(show_sankey){
      if(input$sankey_meeting == 'Meetings only'){
        meeting <- TRUE
      } else {
        meeting <- FALSE
      }
      
      make_sank(trip_coincidences = x,
                meeting = meeting)
    } else {
      return(NULL)
    }
  })
  
  
  # Create a separate filtered events for network
  filtered_view_trip_coincidences_network <- reactive({
    fd <- input$date_range_network
    vd <- vals$view_trip_coincidences
    # filter for dates
    x <- vd %>%
      dplyr::filter(fd[1] <= trip_end_date,
                    fd[2] >= trip_start_date)
    # Filter for search box too
    if(!is.null(input$search_network)){
      if(nchar(input$search_network) > 0){
        search <- input$search_network
        search_items <- unlist(strsplit(search, split = ','))
        search_items <- trimws(search_items, which = 'both')
        keeps <- c()
        for(i in 1:length(search_items)){
          these_keeps <- apply(mutate_all(.tbl = x, .funs = function(x){grepl(tolower(search_items[i]), tolower(x))}),1, any)
          these_keeps <- which(these_keeps)
          keeps <- c(keeps, these_keeps)
        }
        keeps <- sort(unique(keeps))
        x <- x[keeps,]
      }
    }
    
    return(x)
    
  })
  
  output$graph <- renderForceNetwork({
    x <- filtered_view_trip_coincidences_network()
    show_graph <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_graph <- TRUE
      }
    }
    if(show_graph){
      make_graph(trip_coincidences = x)
    } else {
      return(NULL)
    }
  })
  
  output$visit_info_table <- DT::renderDataTable({
    x <- filtered_events()
    x <- x %>%
      # arrange(`Visit start`) %>%
      mutate(Location = `City of visit`) %>%
      mutate(Dates = paste0(
        format(`Visit start`, '%b %d, %Y'), 
        ' - ', 
        format(`Visit end`, '%b %d, %Y'))) %>%
      dplyr::select(Person,
                    # Organization,
                    Location,
                    Event,
                    # Counterpart,
                    Dates)
    #               `Visit start`,
    #               `Visit end`) %>%
    # arrange(`Visit start`)
    prettify(x,
             download_options = TRUE) #%>%
    # DT::formatStyle(columns = colnames(.), fontSize = '50%')
  })
  
  output$timevis <-  renderTimevis({
    # fe <- filtered_events_timeline()
    # if(nrow(fe) > 0){
    #   fe$start <- fe$`Visit start`
    #   fe$content <- paste0(fe$Person, ' in ', fe$`City of visit`)
    #   fe$end <- fe$`Visit end`
    #   fe$id <- 1:nrow(fe)
    #   fe$type <- ifelse(as.numeric(fe$end - fe$start) == 0, 'box', 'range')
    #   fe$title <- paste0(fe$Person, ' in ', fe$`City of visit`, ' from',
    #                      fe$start, ' through ' , fe$end)
    #   x <- timevis(data = fe)
    #   return(x)
    # } else {
    #   return(NULL)
    # }
    fet <- filtered_expanded_trips()
    out <- NULL
    
    if(!is.null(fet)){
      if(nrow(fet) > 0){
        sm<- input$show_meetings
        if(!sm){
          out <- timevis(data = fet,
                         groups = data.frame(id = 1, content = c('Event'),
                                             title = c('Event'),
                                             style = paste0('color: ', c('blue'))),
                         showZoom = FALSE,
                         fit = TRUE)
        } else {
          out <- timevis(data = fet,
                         groups = data.frame(id = 1:2, content = c('Event', 'Meetings'),
                                             title = c('Event', 'Meeting'),
                                             style = paste0('color: ', c('blue', 'red'))))
        }
      }
    }
    
    return(out)
  })
  
  #   output$g_calendar <- renderGvis({
  #     
  #     fd <- the_dates()
  #     if(is.null(fd)){
  #       return(NULL)
  #     } else {
  #       fills <- ifelse(date_dictionary$date >= fd[1] &
  #                         date_dictionary$date <= fd[2],
  #                       1,
  #                       0)
  #       dd <- date_dictionary %>%
  #         mutate(num = fills)
  #       gvisCalendar(data = dd, 
  #                    datevar = 'date',
  #                    numvar = 'num',
  #                    options=list(
  #                      width=400,
  #                      height = 160,
  #                      # legendPosition = 'bottom',
  #                      # legendPosition = 'none',
  #                      # legend = "{position:'none'}",
  #                      calendar="{yearLabel: { fontName: 'Helvetica',
  #                      fontSize: 14, color: 'black', bold: false},
  #                      cellSize: 5,
  #                      cellColor: { stroke: 'black', strokeOpacity: 0.2 },
  #                      focusedCellColor: {stroke:'red'}}",
  #                      gvis.listener.jscode = "
  #                      var selected_date = data.getValue(chart.getSelection()[0].row,0);
  #                      var parsed_date = selected_date.getFullYear()+'-'+(selected_date.getMonth()+1)+'-'+selected_date.getDate();
  #                      Shiny.onInputChange('selected_date',parsed_date)"))
  #       
  #       
  # }
  # })
  
  output$MainBody<-renderUI({
    fluidPage(
      shinydashboard::box(width=12,
                          h3(strong("Create, modify, and delete travel events"),align="center"),
                          hr(),
                          column(12,#offset = 6,
                                 HTML('<div class="btn-group" role="group" aria-label="Basic example">'),
                                 actionButton(inputId = "Add_row_head",label = "Add a new row"),
                                 actionButton(inputId = "Del_row_head",label = "Delete selected rows"),
                                 actionButton(inputId = "submit2",label = "Save changes"),
                                 HTML('</div>')
                          ),
                          
                          column(12,dataTableOutput("Main_table")),
                          tags$script(HTML('$(document).on("click", "input", function () {
                                           var checkboxes = document.getElementsByName("row_selected");
                                           var checkboxesChecked = [];
                                           for (var i=0; i<checkboxes.length; i++) {
                                           
                                           if (checkboxes[i].checked) {
                                           checkboxesChecked.push(checkboxes[i].value);
                                           }
                                           }
                                           Shiny.onInputChange("checked_rows",checkboxesChecked);
  })')),
      tags$script("$(document).on('click', '#Main_table button', function () {
                  Shiny.onInputChange('lastClickId',this.id);
                  Shiny.onInputChange('lastClick', Math.random())
});")

      )
      )
    })
  
  output$Main_table<-renderDataTable({
    DT=vals$events
    DT[["Select"]]<-paste0('<input type="checkbox" name="row_selected" value="Row',1:nrow(vals$events),'"><br>')
    
    DT[["Actions"]]<-
      paste0('
             <div class="btn-group" role="group" aria-label="Basic example">
             <button type="button" class="btn btn-secondary delete" id=delete_',1:nrow(vals$events),'>Delete</button>
             <button type="button" class="btn btn-secondary modify"id=modify_',1:nrow(vals$events),'>Modify</button>
             </div>
             
             ')
    datatable(DT,
              escape=F,
              options = list(scrollX = TRUE))}
      )
  
  observeEvent(input$Add_row_head,{
    new_row=data_frame(
      Person = 'Jane Doe',
      Organization = 'Organization',
      `City of visit` = 'Bermuda Triangle',
      `Country of visit` = 'International Waters',
      Counterpart = 'Jack Sparrow',
      `Visit start` = Sys.Date() - 3,
      `Visit end` = Sys.Date())
    new_row <- new_row %>%
      mutate(Lat = 31,
             Long = -65)
    new_row$Event <- 'Some event'
    vals$events<-bind_rows(new_row,vals$events)
  })
  
  
  observeEvent(input$Del_row_head,{
    row_to_del=as.numeric(gsub("Row","",input$checked_rows))
    vals$events=vals$events[-row_to_del,]}
  )
  
  ##Managing in row deletion
  # modal_modify <- modalDialog(h3('Test'))
  modal_modify<-modalDialog(
    fluidPage(
      h3(strong("Row modification"),align="center"),
      hr(),
      dataTableOutput('row_modif'),
      actionButton("save_changes","Save changes"),
      
      tags$script(HTML("$(document).on('click', '#save_changes', function () {
                       var list_value=[]
                       for (i = 0; i < $( '.new_input' ).length; i++)
                       {
                       list_value.push($( '.new_input' )[i].value)
                       
                       
                       
                       }
                       
                       Shiny.onInputChange('newValue', list_value)
                       });"))
    ),
    size="l"
      )
  
  
  observeEvent(input$lastClick,
               {
                 if (input$lastClickId%like%"delete")
                 {
                   row_to_del=as.numeric(gsub("delete_","",input$lastClickId))
                   vals$events=vals$events[-row_to_del,]
                 }
                 else if (input$lastClickId%like%"modify")
                 {
                   showModal(modal_modify)
                 }
               }
  )
  
  output$row_modif<-renderDataTable({
    selected_row=as.numeric(gsub("modify_","",input$lastClickId))
    old_row=vals$events[selected_row,]
    the_dates <- the_nums <- rep(FALSE, ncol(old_row))
    for(j in 1:ncol(old_row)){
      if(class(data.frame(old_row)[,j]) == 'Date'){
        the_dates[j] <- TRUE
      } else if (class(data.frame(old_row)[,j]) %in% c('numeric', 'integer')){
        the_nums[j] <- TRUE
      }
    }
    copycat <- old_row
    for(j in which(the_dates)){
      copycat[,j] <- as.character(as.Date(copycat[,j] %>% as.numeric, origin = '1970-01-01'))
    }
    for(j in which(the_nums)){
      copycat[,j] <- as.character(copycat[,j])
    }
    
    row_change=list()
    for (i in 1:length(colnames(old_row))){
      message(i)
      cn <- names(old_row)[i]
      message(cn)
      if (is.numeric(vals$events[[cn]])){
        message('ok')
        row_change[[i]]<-paste0('<input class="new_input" value="',
                                copycat[1,cn],
                                '" type="number" id=new_',cn,'>')
      } else {
        row_change[[i]]<-paste0('<input class="new_input" value="',
                                copycat[1,cn],
                                '" type="text" id=new_',cn,'>')
      }
      
    }
    names(row_change) <- names(old_row)
    print(row_change)
    row_change = bind_rows(row_change)
    setnames(row_change,colnames(old_row))
    DT=bind_rows(copycat,row_change)
    DT <- t(DT)
    DT <- as.data.frame(DT)
    
    names(DT) <- c('Old', 'New')
    DT::datatable(DT,
                  escape=F,
                  options=list(dom='t',
                               ordering=F,
                               pageLength = nrow(DT)),
                  selection="none")
  }
  )
  
  
  observeEvent(input$newValue,
               {
                 newValue=lapply(input$newValue, function(col) {
                   if (suppressWarnings(all(!is.na(as.numeric(as.character(col)))))) {
                     as.numeric(as.character(col))
                   } else {
                     col
                   }
                 })
                 print(newValue)
                 values = unlist(newValue)
                 hh <- events %>% sample_n(0)
                 hh[1,] <- NA
                 classes <- unlist(lapply(hh, class))
                 for(j in 1:length(values)){
                   this_class <- classes[j]
                   if(this_class == 'Date'){
                     print(values[j])
                     hh[1,j] <- as.Date(values[j])
                   } else if(names(hh)[j] %in% c('Lat', 'Long')){
                     hh[1,j] <- as.numeric(values[j])
                   } else {
                     hh[1,j] <- values[j]
                   }
                 }
                 DF <- hh
                 # Give lat lon if not aa
                 if(is.na(DF$Lat)){
                   DF$Lat <- 0
                 }
                 if(is.na(DF$Long)){
                   DF$Long <- 0
                 }
                 new_classes <- lapply(vals$events, class)
                 vals$events[as.numeric(gsub("modify_","",input$lastClickId)),]<-DF
               })
  
  # On session end, close
  session$onSessionEnded(function() {
    message('Session ended. Closing the connection pool.')
    tryCatch(pool::poolClose(pool), error = function(e) {message('')})
  })
  
  }
message('Done defining server')

shinyApp(ui, server)