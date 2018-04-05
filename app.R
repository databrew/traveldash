library(shiny)
library(shinydashboard)
source('global.R')
library(shinyjs)
library(knitr)
library(kableExtra)
the_width <- 280

# Header
header <- dashboardHeader(title="Travel dashboard",
                          
                          tags$li(class = 'dropdown',  
                                  tags$style(type='text/css', "#reset_date_range { width:100%; margin-top: 22px; margin-right: 10px; margin-left: 10px; font-size:80%}"),
                                  tags$style(type='text/css', "#search { width:70%; margin-right: 10px; margin-left: 10px; font-size:80%}"),
                                  tags$style(type='text/css', "#wbg_only {margin-right: 10px; margin-left: 10px; font-size:80%}"),
                                  tags$style(type='text/css', "#date_range_2 { width:80%; margin-top: 5px; margin-left: 10px; margin-right: 10px; font-size:80%}"),
                                  
                                  tags$li(class = 'dropdown',
                                          uiOutput('date_range_2_ui')),
                                  tags$li(class = 'dropdown',
                                          actionButton('reset_date_range', 'Reset', icon = icon('undo'))),
                                  tags$li(class = 'dropdown',
                                          img(src='blue.png', align = "center", width = '20px')),
                                  tags$li(class = 'dropdown',
                                          
                                          div(selectInput('wbg_only',
                                                          '',
                                                          choices = 
                                                            c('All affiliations' = 'Everyone', 
                                                              'WBG only' = 'WBG only', 
                                                              'Non-WBG only' = 'Non-WBG only'),
                                                          width = '150px'), 
                                              style='text-align: center;')
                                  ),
                                  tags$li(class = 'dropdown',
                                          textInput('search',
                                                    '',
                                                    placeholder = 'Search for people, places, events'))),
                          titleWidth = the_width)

# Sidebar
sidebar <- dashboardSidebar(
  tags$style(".left-side, .main-sidebar {padding-top: 70px}"),
  tags$style(".main-header {max-height: 70px}"),
  tags$style(".main-header .logo {height: 70px;}"),
  tags$style(".sidebar-toggle {height: 70px; padding-top: 1px !important;}"),
  tags$style(".navbar {min-height:70px !important}"),  
  
  tags$script(type="text/javascript", "function dragend(event) 
              {
              var crop = document.getElementById('crop')
              document.is_drag=false;  
              Shiny.onInputChange('cropX',Number(crop.style.backgroundPositionX.replace('px','')));
              Shiny.onInputChange('cropY',Number(crop.style.backgroundPositionY.replace('px','')));
              }"), 

  tags$script(type="text/javascript", "function dragstart(event) 
              {
              var crop = document.getElementById('crop')
              
              var cropX = Number(crop.style.backgroundPositionX.replace('px',''))
              var cropY = Number(crop.style.backgroundPositionY.replace('px',''))
              
              crop.ondragstart = function() { return false; }
              document.is_drag=true; 
              document.dragorigin = [ Number(event.clientX) , Number(event.clientY) ];
              document.croporigin = [ cropX , cropY ];
              }"),
  tags$script(type="text/javascript", "function dodrag(event) 
              {
              if (typeof document.is_drag=='undefined') return;
              if (document.is_drag)
              {
              var x = Number(event.clientX);
              var y = Number(event.clientY);
              var dragorigin = document.dragorigin;
              var croporigin = document.croporigin;
              var crop = document.getElementById('crop')
              
              //                  console.log(croporigin[0]+'+'+x+'-'+dragorigin[0]+' & '+croporigin[1]+'+'+y+'-'+dragorigin[1])
              crop.style.backgroundPositionX =  croporigin[0] + (x-dragorigin[0]) + 'px';
              crop.style.backgroundPositionY =  croporigin[1] + (y-dragorigin[1]) + 'px';
              }
              }"),
  
  width = the_width,
  sidebarMenu(
    id="tabs",
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
      text="Upload trips",
      tabName="upload_data",
      icon=icon("upload")),
    menuItem(
      text="Edit trips",
      tabName="edit_data",
      icon=icon("pencil")),
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

body <- dashboardBody(
  useShinyjs(),
  
  # jquery daterange picker: # Using https://longbill.github.io/jquery-date-range-picker/
  tags$head(tags$style(HTML('
                            
                            .modal-lg {
                            width: 90%;
                            }
                            '))),
  tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css')),
  tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'dist/daterangepicker.min.css')),
  # Commenting out the below, since jquery is already included in shinydashboard
  # tags$head(tags$script(src = 'https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js', type = 'text/javascript')),
  tags$head(tags$script(src = 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.16.0/moment.min.js', type = 'text/javascript')),
  tags$head(tags$script(src = 'demo.js')),
  tags$head(tags$script(src = 'src/jquery.daterangepicker.js')),
  
  # tags$head(tags$style(HTML("
  # 
  #                           #daterange12container
  #                           {
  #                           width:60px;
  #                           margin:0 auto;
  #                           color:#333;
  #                           font-family:Tahoma,Verdana,sans-serif;
  #                           line-height:1.5;
  #                           font-size:10px;
  #                           }
  #                           .demo { margin:0px 0;}
  #                           .date-picker-wrapper .month-wrapper table .day.lalala { background-color:red; }
  #                           .options { display:none; border-left:0px solid #8ae; padding:2px; font-size:0px; line-height:1.4; background-color:#eee; border-radius:0px;}
  # 
  #                           "))),
  
  tabItems(
    tabItem(tabName = 'main',
            
            fluidPage(
              fluidRow(
                column(5,
                       align = 'center',
                       div(uiOutput('date_ui'),
                           style = 'text-align:center;'),
                       checkboxInput('play', 'Day-by-day map',
                                     value = FALSE),
                       radioButtons('sankey_meeting',
                                    '',choices = c('Meetings only', 'Trip overlaps'),
                                    selected = 'Meetings only',
                                    inline = TRUE),
                       sankeyNetworkOutput('sank',
                                           height = '400px')),
                column(7,
                       div(
                         uiOutput('leaf_ui'),
                         style = 'text-align:right;'),
                       DT::dataTableOutput('visit_info_table')))
            )
            
    ),
    tabItem(
      tabName = 'network',
      fluidPage(
        fluidRow(
          fluidRow(forceNetworkOutput('graph'),
                   fluidRow(
                     column(12,
                            align = 'center',
                            radioButtons('network_meeting',
                                         'Show meetings only or any trip overlaps',choices = c('Meetings only', 'Trip overlaps'),
                                         selected = 'Meetings only',
                                         inline = TRUE),
                            DT::dataTableOutput('click_table'))
                   ))
        )
      )
    ),
    tabItem(
      tabName = 'timeline',
      fluidPage(
        fluidRow(
          timevisOutput('timevis')
        ),
        fluidRow(
          column(6,
                 align = 'center'),
          column(6,
                 align = 'center',
                 actionButton('timevis_clear',
                              'Clear selection'),
                 checkboxInput('show_meetings',
                               'Show meetings',
                               value = FALSE))
        )
      )
    ),
    tabItem(
      tabName = 'about',
      fluidPage(
        fluidRow(
          tags$div(HTML('
                        
                        <h4>
                        <img src="partnershiplogo.png" alt="logo" hspace="20" height=90 style="float: right;">
                        The dashboard was originally developed as a part of activities under the <a href="http://www.ifc.org/wps/wcm/connect/region__ext_content/ifc_external_corporate_site/sub-saharan+africa/priorities/financial+inclusion/za_ifc_partnership_financial_inclusion">Partnership for Financial Inclusion</a>, a $37.4 million joint initiative of the <a href="http://www.ifc.org/wps/wcm/connect/corp_ext_content/ifc_external_corporate_site/home">IFC</a> and the <a href="http://www.mastercardfdn.org/">Mastercard Foundation</a> to expand microfinance and advance digital financial services in Sub-Saharan Africa) by the FIG Africa Digital Financial Services unit (the MEL team).
                        </h4>
                        '))
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
              fluidRow(helpText("Joe is a data scientist for", a(href = 'http://databrew.cc/', 'DataBrew.'), "He has a background in epidemiology and development economics. He works in both industry as a consultant as well as academia. His research focuses on the economics of malaria elimination programs in Sub-Saharan Africa."))
            ),
            width = 4)
        ),
        fluidRow(div(helpText(creds),
                     style = 'text-align:right'))
          )
        ),
    tabItem(tabName = 'upload_data',
            fluidPage(
              fluidRow(
                column(12, align = 'center',
                       p('You can upload your own data, which will be geocoded, formatted, and then integrated into the dashboard. You can manually enter data (left), bulk upload from a spreadsheet (center), or download your data set in the bulk format (right).')),
                column(4, align = 'center',
                       h3('Manually add data'),
                       helpText('Create a trip.'),
                       actionButton('action_add', 'Create trip',
                                    icon = icon('plus'))),
                column(4, align = 'center',
                       h3('Upload trips'),
                       helpText('Upload a dataset from your computer. This should be either a .csv or .xls file.'),
                       fileInput('file1',
                                 '',
                                 accept=c('text/csv',
                                          'text/comma-separated-values,text/plain',
                                          '.csv'))),
                column(4, align = 'center',
                       h3('Download dataset'),
                       helpText('Click the "Download" button to get your dataset in the correct bulk upload format.'),
                       downloadButton("download_correct", "Download your data"))),
              uiOutput('upload_ui'),
              # Results from most recent upload (bulk or manual)
              fluidRow(
                column(12, align = 'center',
                       h3(textOutput('your_data_text')),
                       DT::dataTableOutput('uploaded_table'))
              )
              
            )),
    tabItem(tabName = 'edit_data',
            fluidPage(
              tabsetPanel(type = "tabs",
                          tabPanel("Trips",
                                   fluidPage(
                                     fluidRow(
                                       column(12, align = 'center',
                                              h1('Trips'))
                                     ),
                                     fluidRow(column(12, align = 'center',
                                                     textInput('trips_filter',
                                                               'Filter',
                                                               placeholder = 'filter by name, title, location, etc.'))),
                                     br(),
                                     fluidRow(
                                       column(12, align = 'center',
                                              actionButton('hot_trips_submit',
                                                           'Submit changes'),
                                              uiOutput('hot_trips_submit_check'))
                                     ),
                                     br(),
                                     
                                     fluidRow(
                                       rHandsontableOutput("hot_trips")
                                     )
                                   )),
                          tabPanel("People",
                                   fluidPage(
                                     fluidRow(
                                       column(12, align = 'center',
                                              h1('People'))
                                     ),
                                     fluidRow(column(12, align = 'center',
                                                     selectInput('photo_person',
                                                                 'Person',
                                                                 choices = sort(unique(view_all_trips_people_meetings_venues$person_name))))),
                                     fluidRow(
                                       column(6, 
                                              fluidRow(column(12, align = 'center',
                                                              h3('Current information'),
                                                              actionButton('hot_people_submit',
                                                                           'Submit changes'),
                                                              uiOutput('hot_people_submit_check'))),
                                              br(),
                                              fluidRow(rHandsontableOutput("hot_people"))),
                                       column(6, align = 'center',
                                              fluidRow(column(12,
                                                              align = 'center',
                                                              h3('Current photo'),
                                                              uiOutput('photo_confirmation_ui'),
                                                              imageOutput('current_photo_output', height = '200px'),
                                                              align = 'center',
                                                              h3('New photo'),
                                                              # imageOutput('new_photo_output'),
                                                              uiOutput('new_photo_ui'),
                                                              radioButtons('url_or_upload',
                                                                           '',
                                                                           choices = c('Upload from disk',
                                                                                       'Get from web')),
                                                              uiOutput('upload_url_ui'),
                                                              helpText('Recommended size: 200x200 - 800x800 px')
                                              ))
                                       )))),
                          tabPanel("Venues & Events",
                                   fluidPage(
                                     fluidRow(
                                       column(12, align = 'center',
                                              h1('Venues & Events'))
                                     ),
                                     br(),
                                     fluidRow(
                                       column(12, align = 'center',
                                              actionButton('hot_venue_events_submit',
                                                           'Submit changes'),
                                              uiOutput('hot_venue_events_submit_check'))
                                     ),
                                     br(),
                                     fluidRow(
                                       rHandsontableOutput("hot_venue_events")
                                     )
                                   )))
            )
    )
    )
  )


ui <- dashboardPage(header, sidebar, body)

# Define server
server <- function(input, output, session) {
  
  # Create a reactive dataframe of photos
  photos_reactive <- reactiveValues()
  photos_reactive$images <- images
  
  date_range <- reactiveVal(c(Sys.Date() - 7,
                              Sys.Date() + 14 ))
  observeEvent(input$daterange12,{
    date_input <- input$daterange12
    message('Dates changed. They are: ')
    new_dates <- unlist(strsplit(date_input, split = ' to '))
    new_dates <- as.Date(new_dates)
    date_range(new_dates)
  })
  
  observeEvent(input$date_range_2,{
    date_input <- input$date_range_2
    message('Dates changed. They are: ')
    print(input$date_range_2)
    new_dates <- as.Date(date_input)
    date_range(new_dates)
  })
  
  observeEvent(input$reset_date_range, {
    # reset
    date_range(c(Sys.Date() - 7,
                 Sys.Date() + 14))
  })
  
  output$date_ui <- renderUI({
    dr <- date_range()
    dr <- paste0(as.character(dr[1]), ' to ', as.character(dr[2]))
    fluidPage(
      tags$div(HTML("<div id='daterange12container' style=\"width:156px;\">
                    <input id=\"daterange12\" name=\"joe\" type=\"hidden\" class=\"form-control\" value=\"",dr, "\"/>
                    
                    </div>
                    <script type=\"text/javascript\">
                    $(function() {
                    $('#daterange12').dateRangePicker({
                    inline: true,
                    container: '#daterange12container',
                    alwaysOpen: true,
                    showTopbar: false
                    });
                    
                    // Observe changes and update:
                    
                    $('#daterange12').on('datepicker-change', function(event, changeObject) {
                    // changeObject has properties value, date1 and date2.
                    Shiny.onInputChange('daterange12', changeObject.value);
                    });
                    });
                    </script>
                    
                    "))
      )
})
  
  
  
  ################################
  # Create a reactive data frame from the user upload
  uploaded <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    } else {
      if(grepl('csv', inFile$datapath)){
        x <- read_csv(inFile$datapath,
                      skip = 0)
        # If it appears that the header row was included, skip it.
        if(names(x)[1] != 'Person'){
          x <- read_csv(inFile$datapath,
                        skip = 1)
        }
      } else if(grepl('xls', tolower(inFile$datapath))){
        x <- read_excel(inFile$datapath,
                        skip = 0)
        # If it appears that the header row was included, skip it.
        if(names(x)[1] != 'Person'){
          x <- read_excel(inFile$datapath,
                          skip = 1)
        }
      }
      x
    }
  })
  
  
  
  uploaded_photo_path <- reactive({
    inFile <- input$photo_upload
    
    message('upload photo path is:------------------------ ')
    print(inFile)
    
    if (is.null(inFile)){
      return(NULL)
    } else {
      inFile$datapath
    }
  })
  
  # Column table
  output$column_table_correct <- renderTable({
    upload_format %>% sample_n(0)
  })
  
  output$uploaded_table <- DT::renderDataTable({
    ur <- vals$upload_results
    if(!is.null(ur)){
      if(all(is.na(names(ur)))){
        prettify(data.frame(x = ur[,ncol(ur)]))
      } else {
        prettify(ur, download_options = FALSE)
      }
      
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
      'Your uploaded data'
    } else {
      NULL
    }
  })
  
  output$conformity_text <- renderText({
    x <- uploaded()
    if(!is.null(x)){
      uploaded_names <- names(x)
      correct_names <- names(head(upload_format))
      if(all(correct_names %in% uploaded_names)){
        'Your data matches the correct upload format. Click "Submit" to use it in the app and save it to the database.'
      } else {
        paste0('Your data does not match either the upload format. Please upload a different dataset.')
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
          column(12, align = 'center',
                 helpText(paste0('Your uploaded data should be in the following format')),
                 h4('Correct format'),
                 tableOutput('column_table_correct'))
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
  
  output$download_correct <- downloadHandler(
    filename = function() {
      'data_download.csv'
    },
    content = function(file){
      x <- view_all_trips_people_meetings_venues %>%
        dplyr::select(short_name,
                      organization,
                      title,
                      city_name,
                      country_name,
                      trip_start_date,
                      trip_end_date,
                      trip_group,
                      venue_name, 
                      meeting_with,
                      agenda) %>%
        dplyr::rename(Person = short_name,
                      Organization = organization,
                      Title = title,
                      City= city_name,
                      Country = country_name,
                      Start = trip_start_date,
                      End = trip_end_date,
                      `Trip Group` = trip_group,
                      Venue = venue_name,
                      Meeting = meeting_with,
                      Agenda = agenda)
      write_csv(x, file)
    }
  )
  
  # Reactive dataframe for the filtered table
  vals <- reactiveValues()
  # vals$events<-filter_events(events = events,
  #                            visit_start = min(date_dictionary$date),
  #                            visit_end = max(date_dictionary$date))
  vals$events <- events
  vals$cities <- cities
  vals$people <- people
  # vals$trip_meetings <- trip_meetings
  vals$trips <- trips
  vals$view_trip_coincidences <- view_trip_coincidences
  # vals$venue_events <- venue_events
  # vals$venue_types <- venue_types
  vals$view_trips_and_meetings <- view_trips_and_meetings
  vals$upload_results <- NULL
  vals$view_all_trips_people_meetings_venues <- view_all_trips_people_meetings_venues
  
  # Replace data with uploaded data
  observeEvent(input$submit, {
    new_data <- uploaded()
    message('new data has ', nrow(new_data), ' rows')
    # Upload the new data to the database
    upload_results <-
      upload_raw_data(data = new_data,
                      logged_in_user_id = 1,
                      return_upload_results = TRUE)
    message('Uploaded raw data')
    # Update the session
    warning('need to depricate db_to_memory: Line 673 in app.R')
    updated_data <- db_to_memory(return_list = TRUE)
    vals$events <- updated_data$events
    vals$cities <- updated_data$cities
    vals$people <- updated_data$people
    # vals$trip_meetings <- updated_data$trip_meetings
    vals$trips <- updated_data$trips
    # vals$venue_events <- updated_data$venue_events
    # vals$venue_types <- updated_data$venue_types
    vals$view_trips_and_meetings <- updated_data$view_trips_and_meetings
    vals$view_trip_coincidences <- updated_data$view_trip_coincidences
    vals$view_all_trips_people_meetings_venues <- updated_data$view_all_trips_people_meetings_venues
    vals$upload_results <- upload_results
  })
  
  # # After modification is confirmed, update the data stores
  # observeEvent(input$submit2, {
  #   # THIS NEEDS CHANGES
  #   message('Modification confirmed, geocoding and overwriting data.')
  #   new_data <- vals$events
  #   # Geocode if applicable
  #   new_data <- geo_code(new_data)
  #   # Update the underlying data
  #   # Update the underlying data
  #   write_table(connection_object = GLOBAL_DB_POOL,
  #               table = 'dev_events',
  #               schema = 'pd_wbgtravel',
  #               value = new_data,
  #               use_sqlite = use_sqlite)
  #   message('Ovewrote the database')
  # })
  
  
  submit_text <- reactiveVal(value = '')
  observeEvent(input$submit, {
    submit_text('Data uploaded! Now click through other tabs to explore your data.')
  })
  observeEvent(input$Del_row_head, {
    vals$events <- vals$events
  })
  
  selected_timevis <- reactiveVal(value = NULL)
  observeEvent(input$timevis_selected,
               selected_timevis(input$timevis_selected))
  observeEvent(input$timevis_clear,
               selected_timevis(NULL))
  
  filtered_expanded_trips <- reactive({
    sm<- input$show_meetings
    fd <- date_range()
    search_string <- input$search
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
  view_all_trips_people_meetings_venues_filtered <- reactive({
    fd <- date_range()
    vd <- vals$view_all_trips_people_meetings_venues
    x <- vd %>%
      dplyr::filter(fd[1] <= trip_end_date,
                    fd[2] >= trip_start_date)
    
    x <- search_df(data = x,
                   input$search)
    return(x)
  })
  
  output$leafy <- renderLeaflet({
    
    # Get trips and meetings, filtered for date range    
    df <- view_all_trips_people_meetings_venues_filtered()
    
    
    # Filter for wbg only if relevant
    if(input$wbg_only == 'WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 1)
    } else if(input$wbg_only == 'Non-WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 0)
    }
    
    # Get row selection (if applicable) from datatable
    s <- input$visit_info_table_rows_selected
    
    # Subset df if rows are selected
    if(!is.null(s)){
      if(length(s) > 0){
        df <- df[s,]
      }
    }
    
    # Get number of rows of df
    nrp <- nrow(df)
    
    # Get whether wbg or not
    df$is_wbg <- as.logical(df$is_wbg)
    
    
    # Select down
    df <- df %>%
      dplyr::select(is_wbg,
                    short_name,
                    title,
                    city_name,
                    country_name,
                    trip_start_date,
                    trip_end_date,
                    meeting_with,
                    venue_name,
                    agenda)
    
    # Get city id
    df <- df %>%
      left_join(cities %>%
                  dplyr::select(city_name, country_name, city_id),
                by = c('city_name', 'country_name'))
    
    # Create an id
    df <- df %>%
      mutate(id = paste0(short_name, is_wbg, city_id)) %>%
      mutate(id = as.numeric(factor(id))) %>%
      arrange(trip_start_date)
    
    # Create some more columns
    df <- df %>%
      mutate(dates = oleksiy_date(trip_start_date, trip_end_date)) %>%
      mutate(event = paste0(ifelse(!is.na(meeting_with) & short_name != meeting_with, ' With ', ''),
                            ifelse(!is.na(meeting_with) & short_name != meeting_with, meeting_with, ''))) %>%
      mutate(event = Hmisc::capitalize(event)) 
    
    
    # Keep a "full" df with one row per trip
    full_df <- df
    
    # Make only one head per person/place
    df <- df %>%
      group_by(id, short_name, title, is_wbg, city_id, venue_name) %>%
      summarise(date = paste0(dates, collapse = ';'),
                event = paste0(event, collapse = ';')) %>% ungroup
    
    # Join to city names
    df <- df %>%
      left_join(cities %>%
                  dplyr::select(city_name, country_name, city_id,
                                latitude, longitude),
                by = 'city_id') 
    
    
    popups = lapply(rownames(df), function(row){
      this_id <- unlist(df[row,'id'])
      # Get the original rows from full df for each of the ids
      x <- full_df %>%
        filter(id == this_id)
      x$short_name <- oleksiy_name(x$short_name)
      if(!is.na(x$title[1])){
        caption <- paste0(x$short_name[1], '<br>(', x$title[1], ') in ', x$city_name[1])
      } else {
        caption <- paste0(x$short_name[1], '<br>in ', x$city_name[1])
      }
      # vn <- paste0(unique(x$venue_name[!is.na(x$venue_name)]), collapse = ', ')
      # if(!is.na(vn)){
      #   if(nchar(vn) > 0){
      #     caption <- paste0(caption, ' at ', vn)
      #   }
      # }
      # ag <- paste0(unique(x$agenda[!is.na(x$agenda)]), collapse = ', ')
      # if(!is.na(ag)){
      #   if(nchar(ag) > 0){
      #     caption <- paste0(caption, ' for ', ag)
      #   }
      # }
      
      x <- x %>%
        mutate(event = ifelse(!is.na(venue_name) & venue_name != '' & !is.na(event) & event != '', paste0(event, ' at ', venue_name),
                              event)) %>%
        dplyr::select(dates, event, agenda)
      names(x) <- Hmisc::capitalize(names(x))
      knitr::kable(x,
                   rnames = FALSE,
                   caption = caption,
                   align = paste(rep("l", ncol(x)), collapse = ''),
                   format = 'html') %>%
        kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = FALSE,
                      font_size = 9) %>%
        scroll_box(height = '200px', width = '300px')
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
    df$joiner <- ifelse(df$short_name %in% faces$joiner,
                        df$short_name,
                        'Unknown')
    
    # Join the files to the df data
    if(nrow(df) > 0){
      df <-
        left_join(df,
                  faces,
                  by = 'joiner')
      # Define colors
      cols <- ifelse(is.na(df$is_wbg) |
                       !df$is_wbg,
                     'orange',
                     'blue')
    } else {
      df <- df[0,]
    }
    face_icons <- icons(df$file,
                        iconWidth = 25, iconHeight = 25)
    
    
    zoom_level <- 2
    
    df <- df %>%
      mutate(longitude = joe_jitter(longitude, zoom = zoom_level),
             latitude = joe_jitter(latitude, zoom = zoom_level))
    
    l <- leaflet(#options = leafletOptions(zoomControl = FALSE)
    ) %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      leaflet.extras::addFullscreenControl(position = 'topright') %>%
      addLegend(position = 'bottomright', colors = c('orange', 'blue'), labels = c('Non-WBG', 'WBG')) %>%
      addCircleMarkers(data = df, lng =~longitude, lat = ~latitude,
                       # clusterOptions = markerClusterOptions(),
                       col = cols, radius = 14) %>%
      addMarkers(data = df, lng =~longitude, lat = ~latitude,
                 popup = popups,
                 # clusterOptions = markerClusterOptions(),
                 icon = face_icons)
    
    # Zoom out a bit if only 1 city or person
    if(nrp == 1 | length(unique(df$city_id)) == 1){
      l <- l %>%
        setView(lng = mean(df$longitude, na.rm = TRUE),
                lat = mean(df$latitude, na.rm = TRUE),
                zoom = 7)
    }
    
    shinyjs::enable("action_forward")
    shinyjs::hide("text1")
    shinyjs::enable("action_back")
    shinyjs::hide("text2")
    l
  })
  
  # Obseve changes to zoom
  observeEvent(input$leafy_zoom, {
    
    # Much of this is a copy of the above map code
    # Could be cleaned up a bit to not duplicate.
    
    # Get trips and meetings, filtered for date range    
    df <- view_all_trips_people_meetings_venues_filtered()
    
    
    # Filter for wbg only if relevant
    if(input$wbg_only == 'WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 1)
    } else if(input$wbg_only == 'Non-WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 0)
    }
    
    # Get row selection (if applicable) from datatable
    s <- input$visit_info_table_rows_selected
    
    # Subset df if rows are selected
    if(!is.null(s)){
      if(length(s) > 0){
        df <- df[s,]
      }
    }
    
    # Get number of rows of df
    nrp <- nrow(df)
    
    # Get whether wbg or not
    df$is_wbg <- as.logical(df$is_wbg)
    
    
    # Select down
    df <- df %>%
      dplyr::select(is_wbg,
                    short_name,
                    title,
                    city_name,
                    country_name,
                    trip_start_date,
                    trip_end_date,
                    meeting_with,
                    venue_name,
                    agenda)
    
    # Get city id
    df <- df %>%
      left_join(cities %>%
                  dplyr::select(city_name, country_name, city_id),
                by = c('city_name', 'country_name'))
    
    # Create an id
    df <- df %>%
      mutate(id = paste0(short_name, is_wbg, city_id)) %>%
      mutate(id = as.numeric(factor(id))) %>%
      arrange(trip_start_date)
    
    # Create some more columns
    df <- df %>%
      mutate(dates = oleksiy_date(trip_start_date, trip_end_date)) %>%
      mutate(short_name = ifelse(is.na(short_name), '', short_name)) %>%
      mutate(meeting_with = ifelse(is.na(meeting_with), '', meeting_with)) %>%
      mutate(event = ifelse(short_name != meeting_with &
                              meeting_with != '' &
                              short_name != '',
                            paste0(short_name, ' with ', meeting_with),
                            '')) %>%
      mutate(event = Hmisc::capitalize(event)) %>%
      mutate(event = ifelse(trimws(event) == 'With', '', event))
    
    
    # Keep a "full" df with one row per trip
    full_df <- df
    
    
    # Make only one head per person/place
    df <- df %>%
      group_by(id, short_name, title, is_wbg, city_id, venue_name) %>%
      summarise(date = paste0(dates, collapse = ';'),
                event = paste0(event, collapse = ';')) %>% ungroup
    
    # Join to city names
    df <- df %>%
      left_join(cities %>%
                  dplyr::select(city_name, country_name, city_id,
                                latitude, longitude),
                by = 'city_id') 
    
    popups = lapply(rownames(df), function(row){
      this_id <- unlist(df[row,'id'])
      # Get the original rows from full df for each of the ids
      x <- full_df %>%
        filter(id == this_id)
      x$short_name <- oleksiy_name(x$short_name)
      if(!is.na(x$title[1])){
        caption <- paste0(x$short_name[1], '<br>(', x$title[1], ') in ', x$city_name[1])
      } else {
        caption <- paste0(x$short_name[1], '<br>in ', x$city_name[1])
      }
      
      x <- x %>%
        mutate(event = ifelse(!is.na(venue_name) & venue_name != '' & !is.na(event) & event != '', paste0(event, ' at ', venue_name),
                              event)) %>%
        dplyr::select(dates, event, agenda)
      names(x) <- Hmisc::capitalize(names(x))
      knitr::kable(x,
                   rnames = FALSE,
                   caption = caption,
                   align = paste(rep("l", ncol(x)), collapse = ''),
                   format = 'html') %>%
        kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = FALSE,
                      font_size = 9) %>%
        scroll_box(height = '200px', width = '300px')
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
    df$joiner <- ifelse(df$short_name %in% faces$joiner,
                        df$short_name,
                        'Unknown')
    
    # Join the files to the df data
    if(nrow(df) > 0){
      df <-
        left_join(df,
                  faces,
                  by = 'joiner')
      # Define colors
      cols <- ifelse(is.na(df$is_wbg) |
                       !df$is_wbg,
                     'orange',
                     'blue')
    } else {
      df <- df[0,]
    }
    face_icons <- icons(df$file,
                        iconWidth = 25, iconHeight = 25)
    
    
    zoom_level <- input$leafy_zoom
    if(is.null(zoom_level)){
      zoom_level <- 2
    }
    message('zoom is ', zoom_level)
    
    df <- df %>%
      mutate(longitude = joe_jitter(longitude, zoom = zoom_level),
             latitude = joe_jitter(latitude, zoom = zoom_level))
    
    
    l <- leafletProxy('leafy') %>%
      clearMarkers() %>%
      # clearControls() %>%
      addCircleMarkers(data = df, lng =~longitude, lat = ~latitude,
                       # clusterOptions = markerClusterOptions(),
                       col = cols, radius = 14) %>%
      addMarkers(data = df, lng =~longitude, lat = ~latitude,
                 popup = popups,
                 # clusterOptions = markerClusterOptions(),
                 icon = face_icons)
    l
    
  })
  
  
  
  output$sank <- renderSankeyNetwork({
    x <- view_all_trips_people_meetings_venues_filtered()
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
  view_all_trips_people_meetings_venues_filtered_network <- reactive({
    # fd <- input$date_range_network
    fd <- date_range()
    vd <- vals$view_all_trips_people_meetings_venues
    # filter for dates
    x <- vd %>%
      dplyr::filter(fd[1] <= trip_end_date,
                    fd[2] >= trip_start_date)
    x <- search_df(data = x,
                   input$search)

    return(x)
    
  })
  
  output$graph <- renderForceNetwork({
    x <- view_all_trips_people_meetings_venues_filtered_network()
    show_graph <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_graph <- TRUE
      }
    }
    if(input$network_meeting == 'Meetings only'){
      meeting <- TRUE
    } else {
      meeting <- FALSE
    }
    
    if(show_graph){
      make_graph(trip_coincidences = x,
                 meeting = meeting)
    } else {
      return(NULL)
    }
  })
  
  output$visit_info_table <- DT::renderDataTable({
    
    x <- view_all_trips_people_meetings_venues_filtered()
    # Filter for wbg only if relevant
    if(input$wbg_only == 'WBG only'){
      x <- x %>% dplyr::filter(is_wbg == 1)
    } else if(input$wbg_only == 'Non-WBG only'){
      x <- x %>% dplyr::filter(is_wbg == 0)
    }
    x <- x %>%
      mutate(location = city_name) %>%
      mutate(name = short_name) %>%
      arrange(trip_start_date) %>%
      mutate(date = oleksiy_date(trip_start_date, trip_end_date)) %>%
      mutate(event = paste0(ifelse(!is.na(meeting_with) & short_name != meeting_with, ' With ', ''),
                            ifelse(!is.na(meeting_with) & short_name != meeting_with, meeting_with, ''))) %>%
      mutate(event = Hmisc::capitalize(event)) %>%
      mutate(event = ifelse(!is.na(venue_name),
                            paste0(event, ' At ', venue_name),
                            event)) %>%
      dplyr::select(name, date, location, event) %>%
      
      mutate(event = ifelse(trimws(event) == 'With', '', event))
    names(x) <- Hmisc::capitalize(names(x))
    x$Date <- factor(x$Date, levels = sort(unique(x$Date)))
    
    # prettify(x,
    #          download_options = FALSE) #%>%
    DT::datatable(x,
                  # escape=FALSE,
                  rownames = FALSE,
                  autoHideNavigation = TRUE,
                  options=list(#dom='t',
                    filter = FALSE,
                    ordering=F,
                    lengthMenu = c(5, 20, 50),
                    pageLength = 10#nrow(x)
                  ))
  })
  
  output$timevis <-  renderTimevis({
    
    fet <- filtered_expanded_trips()
    out <- NULL
    
    if(!is.null(fet)){
      if(nrow(fet) > 0){
        # Decide whether to show meetings or not
        sm <- input$show_meetings
        
        if(!sm){
          out <- timevis(data = fet,
                         groups = data.frame(id = 1, 
                                             content = c('Event'),
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
  #     fd <- date_range()
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
  
  # output$MainBody<-renderUI({
  #   fluidPage(
  #     shinydashboard::box(width=12,
  #                         h3(strong("Create, modify, and delete travel events"),align="center"),
  #                         hr(),
  #                         column(12,#offset = 6,
  #                                HTML('<div class="btn-group" role="group" aria-label="Basic example">'),
  #                                actionButton(inputId = "Add_row_head",label = "Add a new row"),
  #                                actionButton(inputId = "Del_row_head",label = "Delete selected rows"),
  #                                actionButton(inputId = "submit2",label = "Save changes"),
  #                                HTML('</div>')
  #                         ),
  #                         
  #                         column(12,dataTableOutput("Main_table")),
  #                         tags$script(HTML('$(document).on("click", "input", function () {
  #                                          var checkboxes = document.getElementsByName("row_selected");
  #                                          var checkboxesChecked = [];
  #                                          for (var i=0; i<checkboxes.length; i++) {
  #                                          
  #                                          if (checkboxes[i].checked) {
  #                                          checkboxesChecked.push(checkboxes[i].value);
  #                                          }
  #                                          }
  #                                          Shiny.onInputChange("checked_rows",checkboxesChecked);
  # })')),
  #     tags$script("$(document).on('click', '#Main_table button', function () {
  #                 Shiny.onInputChange('lastClickId',this.id);
  #                 Shiny.onInputChange('lastClick', Math.random())
  #                 });")
  # 
  #     )
  #     )
  #   })
  # 
  # output$Main_table<-renderDataTable({
  #   DT=vals$events
  #   DT[["Select"]]<-paste0('<input type="checkbox" name="row_selected" value="Row',1:nrow(vals$events),'"><br>')
  #   
  #   DT[["Actions"]]<-
  #     paste0('
  #            <div class="btn-group" role="group" aria-label="Basic example">
  #            <button type="button" class="btn btn-secondary delete" id=delete_',1:nrow(vals$events),'>Delete</button>
  #            <button type="button" class="btn btn-secondary modify"id=modify_',1:nrow(vals$events),'>Modify</button>
  #            </div>
  #            
  #            ')
  #   datatable(DT,
  #             escape=F,
  #             options = list(scrollX = TRUE))}
  #     )
  # 
  # observeEvent(input$Add_row_head,{
  #   new_row=data_frame(
  #     Person = 'Jane Doe',
  #     Organization = 'Organization',
  #     `City of visit` = 'Bermuda Triangle',
  #     `Country of visit` = 'International Waters',
  #     Counterpart = 'Jack Sparrow',
  #     `Visit start` = Sys.Date() - 3,
  #     `Visit end` = Sys.Date())
  #   new_row <- new_row %>%
  #     mutate(Lat = 31,
  #            Long = -65)
  #   new_row$Event <- 'Some event'
  #   vals$events<-bind_rows(new_row,vals$events)
  # })
  # 
  # 
  # observeEvent(input$Del_row_head,{
  #   row_to_del=as.numeric(gsub("Row","",input$checked_rows))
  #   vals$events=vals$events[-row_to_del,]}
  # )
  # 
  # ##Managing in row deletion
  # # modal_modify <- modalDialog(h3('Test'))
  # modal_modify<-modalDialog(
  #   fluidPage(
  #     h3(strong("Row modification"),align="center"),
  #     hr(),
  #     dataTableOutput('row_modif'),
  #     actionButton("save_changes","Save changes"),
  #     
  #     tags$script(HTML("$(document).on('click', '#save_changes', function () {
  #                      var list_value=[]
  #                      for (i = 0; i < $( '.new_input' ).length; i++)
  #                      {
  #                      list_value.push($( '.new_input' )[i].value)
  #                      
  #                      
  #                      
  #                      }
  #                      
  #                      Shiny.onInputChange('newValue', list_value)
  #                      });"))
  #   ),
  #   size="l"
  #     )
  # 
  # 
  # observeEvent(input$lastClick,
  #              {
  #                if (input$lastClickId%like%"delete")
  #                {
  #                  row_to_del=as.numeric(gsub("delete_","",input$lastClickId))
  #                  vals$events=vals$events[-row_to_del,]
  #                }
  #                else if (input$lastClickId%like%"modify")
  #                {
  #                  showModal(modal_modify)
  #                }
  #              }
  # )
  # 
  # output$row_modif<-renderDataTable({
  #   selected_row=as.numeric(gsub("modify_","",input$lastClickId))
  #   old_row=vals$events[selected_row,]
  #   the_dates <- the_nums <- rep(FALSE, ncol(old_row))
  #   for(j in 1:ncol(old_row)){
  #     if(class(data.frame(old_row)[,j]) == 'Date'){
  #       the_dates[j] <- TRUE
  #     } else if (class(data.frame(old_row)[,j]) %in% c('numeric', 'integer')){
  #       the_nums[j] <- TRUE
  #     }
  #   }
  #   copycat <- old_row
  #   for(j in which(the_dates)){
  #     copycat[,j] <- as.character(as.Date(copycat[,j] %>% as.numeric, origin = '1970-01-01'))
  #   }
  #   for(j in which(the_nums)){
  #     copycat[,j] <- as.character(copycat[,j])
  #   }
  #   
  #   row_change=list()
  #   for (i in 1:length(colnames(old_row))){
  #     message(i)
  #     cn <- names(old_row)[i]
  #     message(cn)
  #     if (is.numeric(vals$events[[cn]])){
  #       message('ok')
  #       row_change[[i]]<-paste0('<input class="new_input" value="',
  #                               copycat[1,cn],
  #                               '" type="number" id=new_',cn,'>')
  #     } else {
  #       row_change[[i]]<-paste0('<input class="new_input" value="',
  #                               copycat[1,cn],
  #                               '" type="text" id=new_',cn,'>')
  #     }
  #     
  #   }
  #   names(row_change) <- names(old_row)
  #   print(row_change)
  #   row_change = bind_rows(row_change)
  #   setnames(row_change,colnames(old_row))
  #   DT=bind_rows(copycat,row_change)
  #   DT <- t(DT)
  #   DT <- as.data.frame(DT)
  #   
  #   names(DT) <- c('Old', 'New')
  #   DT::datatable(DT,
  #                 escape=F,
  #                 options=list(dom='t',
  #                              ordering=F,
  #                              pageLength = nrow(DT)),
  #                 selection="none")
  # }
  # )
  # 
  # 
  # observeEvent(input$newValue,
  #              {
  #                newValue=lapply(input$newValue, function(col) {
  #                  if (suppressWarnings(all(!is.na(as.numeric(as.character(col)))))) {
  #                    as.numeric(as.character(col))
  #                  } else {
  #                    col
  #                  }
  #                })
  #                print(newValue)
  #                values = unlist(newValue)
  #                hh <- events %>% sample_n(0)
  #                hh[1,] <- NA
  #                classes <- unlist(lapply(hh, class))
  #                for(j in 1:length(values)){
  #                  this_class <- classes[j]
  #                  if(this_class == 'Date'){
  #                    print(values[j])
  #                    hh[1,j] <- as.Date(values[j])
  #                  } else if(names(hh)[j] %in% c('Lat', 'Long')){
  #                    hh[1,j] <- as.numeric(values[j])
  #                  } else {
  #                    hh[1,j] <- values[j]
  #                  }
  #                }
  #                DF <- hh
  #                # Give lat lon if not aa
  #                if(is.na(DF$Lat)){
  #                  DF$Lat <- 0
  #                }
  #                if(is.na(DF$Long)){
  #                  DF$Long <- 0
  #                }
  #                new_classes <- lapply(vals$events, class)
  #                vals$events[as.numeric(gsub("modify_","",input$lastClickId)),]<-DF
  #              })
  # 
  # plotReady <- reactiveValues(ok = FALSE)
  # 
  # observeEvent(input$action_back, {
  #   shinyjs::disable("action_back")
  #   shinyjs::show("text1")
  #   plotReady$ok <- FALSE
  #   Sys.sleep(0.1)
  #   plotReady$ok <- TRUE
  # })
  # observeEvent(input$action_forward, {
  #   shinyjs::disable("action_forward")
  #   shinyjs::show("text2")
  #   plotReady$ok <- FALSE
  #   Sys.sleep(0.1)
  #   plotReady$ok <- TRUE
  # })
  
  # Test table for graph
  output$click_table <- DT::renderDataTable({
    
    # Data used for network
    x <- view_all_trips_people_meetings_venues_filtered_network()
    show_graph <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_graph <- TRUE
      }
    }
    if(input$network_meeting == 'Meetings only'){
      meeting <- TRUE
    } else {
      meeting <- FALSE
    }
    
    if(show_graph){
      
      if(meeting){
        tc <- x %>%
          dplyr::select(person_name,
                        is_wbg,
                        city_name,
                        country_name,
                        trip_start_date,
                        trip_end_date,
                        meeting_person_name,
                        coincidence_is_wbg,
                        venue_name) %>%
          dplyr::rename(Person = person_name,
                        Counterpart = meeting_person_name)  %>%
          filter(!is.na(Counterpart))
      } else {
        tc <- x %>%
          dplyr::select(person_name,
                        is_wbg,
                        city_name,
                        country_name,
                        trip_start_date,
                        trip_end_date,
                        coincidence_person_name,
                        coincidence_is_wbg,
                        venue_name) %>%
          dplyr::rename(Person = person_name,
                        Counterpart = coincidence_person_name)
      }
      tc <- tc %>% dplyr::filter(!is.na(Counterpart))
      
      if(nrow(tc) > 0){
        
        # Get the title of the counterpart
        tc <- tc %>%
          left_join(people %>%
                      dplyr::select(short_name, title) %>%
                      dplyr::rename(Counterpart = short_name,
                                    Counterpart_title = title),
                    by = 'Counterpart')
        
        
        
        # Extract the clicked id
        ii <- input$id
        if(!is.null(ii)){
          tc <- tc %>% filter(Person == ii | Counterpart == ii)
          # Keep only one of each
          tc <- tc %>%
            dplyr::distinct(Person, city_name, trip_start_date, trip_end_date, Counterpart, .keep_all = TRUE)
          # Arrange by date
          tc <- tc %>% 
            arrange(trip_start_date)
          tc <- tc %>%
            mutate(date = oleksiy_date(trip_start_date, trip_end_date)) 
          
          tc <- tc %>%
            dplyr::select(-is_wbg, -coincidence_is_wbg, -country_name, -trip_start_date, -trip_end_date) 
          # Reorder columns
          tc <- tc %>%
            dplyr::select(Person, city_name, venue_name, Counterpart_title, Counterpart, date)
          names(tc) <- Hmisc::capitalize(gsub('_', ' ', names(tc)))
          DT::datatable(tc,
                        escape=F,
                        options=list(dom='t',
                                     ordering=F,
                                     pageLength = nrow(tc)),
                        selection="none",
                        rownames = FALSE)
        } else {
          NULL
        }
      } else {
        return(NULL)
      }
    } else {
      return(NULL)
    }
  })
  
  output$date_range_2_ui <- renderUI({
    dr <- date_range()
    the_tab <- input$tabs
    message('the tab is ', the_tab)
    if(the_tab != 'main'){
      div(
        dateRangeInput('date_range_2',
                       '  ',
                       start = dr[1],
                       end = dr[2]),
        style='text-align: center;')
    } else {
      NULL
    }
    
  })
  
  timer <- reactiveTimer(4000)
  
  # Create a date for looping through
  this_date <- reactiveVal(value = NULL)
  observeEvent(date_range(), {
    dr <- date_range()
    this_date(dr[1])
  })
  
  
  # Play    
  observeEvent(timer(),{
    td <- this_date()
    dr <- date_range()
    if(td >= max(dr)){
      this_date(dr[1])
    } else {
      this_date(td + 1)
    }
  })
  observeEvent(input$play,{
    # Reset the this_date object to beginning of date range
    td <- this_date()
    dr <- date_range()
    this_date(dr[1])
    
    # Re-initialize the base canvas for the map
    output$leafy_play <- renderLeaflet({
      leaflet() %>%
        leaflet.extras::addFullscreenControl(position = 'topright') %>%
        addLegend(position = 'bottomright', colors = c('orange', 'blue'), labels = c('Non-WBG', 'WBG')) %>%
        addProviderTiles(providers$Esri.WorldStreetMap) %>%
        setView(lng = 0, lat = 20, zoom = 2) 
    })
    
    if(!input$play){
      leafletProxy('leaflet_play') %>%
        clearMarkers() %>%
        clearControls()
    }
    
    
  })
  
  observeEvent(this_date(),{
    if(input$play){
      td <- this_date()
      
      # Get trips and meetings, filtered for date range
      df <- view_all_trips_people_meetings_venues_filtered()
      
      # Filter for this date only
      df <- df %>% filter(trip_start_date <= td,
                          trip_end_date >= td)
      
      # Filter for wbg only if relevant
      if(input$wbg_only == 'WBG only'){
        df <- df %>% dplyr::filter(is_wbg == 1)
      } else if(input$wbg_only == 'Non-WBG only'){
        df <- df %>% dplyr::filter(is_wbg == 0)
      }
      
      # Get number of rows of df
      nrp <- nrow(df)
      
      # Get whether wbg or not
      df$is_wbg <- as.logical(df$is_wbg)
      
      # Select down
      df <- df %>%
        dplyr::select(is_wbg,
                      short_name,
                      city_name,
                      country_name,
                      trip_start_date,
                      trip_end_date,
                      meeting_with)
      
      # Get city id
      df <- df %>%
        left_join(cities %>%
                    dplyr::select(city_name, country_name, city_id),
                  by = c('city_name', 'country_name'))
      
      # Create an id
      df <- df %>%
        mutate(id = paste0(short_name, is_wbg, city_id)) %>%
        mutate(id = as.numeric(factor(id))) %>%
        arrange(trip_start_date)
      
      # Create some more columns
      
      
      # Join the files to the df data
      if(nrow(df) > 0){
        
        df <- df %>%
          mutate(dates = oleksiy_date(trip_start_date, trip_end_date)) %>%
          mutate(short_name = ifelse(is.na(short_name), '', short_name)) %>%
          mutate(meeting_with = ifelse(is.na(meeting_with), '', meeting_with)) %>%
          mutate(event = ifelse(short_name != meeting_with &
                                  meeting_with != '' &
                                  short_name != '',
                                paste0(short_name, ' with ', meeting_with),
                                '')) %>%
          mutate(event = Hmisc::capitalize(event)) %>%
          mutate(event = ifelse(trimws(event) == 'With', '', event))
        
        
        # Keep a "full" df with one row per trip
        full_df <- df
        
        # Make only one head per person/place
        df <- df %>%
          group_by(id, short_name, is_wbg, city_id) %>%
          summarise(date = paste0(dates, collapse = ';'),
                    event = paste0(event, collapse = ';')) %>% ungroup
        
        # Join to city names
        df <- df %>%
          left_join(cities %>%
                      dplyr::select(city_name, country_name, city_id,
                                    latitude, longitude),
                    by = 'city_id')
        
        # Get faces
        faces_dir <- paste0('www/headshots/circles/')
        faces <- dir(faces_dir)
        faces <- data_frame(joiner = gsub('.png', '', faces, fixed = TRUE),
                            file = paste0(faces_dir, faces))
        
        # Create a join column
        faces$joiner <- ifelse(is.na(faces$joiner) | faces$joiner == 'NA',
                               'Unknown',
                               faces$joiner)
        df$joiner <- ifelse(df$short_name %in% faces$joiner,
                            df$short_name,
                            'Unknown')
        
        df <-
          left_join(df,
                    faces,
                    by = 'joiner')
        # Define colors
        cols <- ifelse(is.na(df$is_wbg) |
                         !df$is_wbg,
                       'orange',
                       'blue')
        zoom_level <- input$leafy_zoom
        
        df <- df %>%
          mutate(longitude = joe_jitter(longitude, zoom = zoom_level),
                 latitude = joe_jitter(latitude, zoom = zoom_level))
      } else {
        df <- df[0,]
      }
      
      
      
      
      rr <- tags$div(
        h2(format(td, '%B %d, %Y'), align = 'center'),
        style = 'text-align: center; padding-bottom: 20px;'
      )
      
      l <- leafletProxy('leafy_play') %>%
        clearMarkers() %>%
        clearControls() %>%
        addControl(rr, position = "bottomleft")
      
      if(nrow(df) > 0){
        face_icons <- icons(df$file,
                            iconWidth = 25, iconHeight = 25)
        l <- l %>%
          addCircleMarkers(data = df, lng =~longitude, lat = ~latitude,
                           # clusterOptions = markerClusterOptions(),
                           col = cols, radius = 14) %>%
          addMarkers(data = df, lng =~longitude, lat = ~latitude,
                     # popup = popups,
                     # clusterOptions = markerClusterOptions(),
                     icon = face_icons) 
      }
      l
      
    }
  })
  
  output$leaf_ui <- renderUI({
    
    if(input$play){
      leafletOutput('leafy_play')
    } else {
      leafletOutput('leafy')
    }
  })
  
  # Current photo output
  output$current_photo_output <- renderImage({
    # image <- photos_reactive$images
    # image <- image$person_image[image$short_name == person]
    
    # Also observe confirmation and refresh
    x <- input$button_crop
    person <- input$photo_person
    
    file_name <- paste0('www/headshots/circles/', person, '.png')
    if(!file.exists(file_name)){
      message('No photo file on disk for ', person, '. Using the NA placeholder photo.')
      file_name <- 'www/headshots/circles/NA.png'
    }
    list(src = file_name,
         # width = width,
         # height = height,
         alt = person)
    
  },
  deleteFile = FALSE)
  
  # Define a switch for showing the old photo or not
  switcher <- reactiveVal(TRUE)
  
  observeEvent(input$photo_person,{
    message('Setting switcher to FALSE')
    # Upon change of person, set the switcher to FALSE
    switcher(FALSE)
  })
  observeEvent(uploaded_photo_path(),{
    message('Setting switcher to TRUE')
    # Upon change of the photo path, set switcher back to TRUE
    switcher(TRUE)
  })
  
  # Current photo output
  # output$new_photo_output <- 
  #   renderImage({
  #     ss <- switcher()
  #     the_person <- input$photo_person
  #     x <- uploaded_photo_path()
  #     
  #     if(is.null(x) | !ss){
  #       the_file <- 'www/headshots/circles/NA.png'
  #     } else {
  #       the_file <- x
  #     }
  #     list(src = the_file,
  #          # width = width,
  #          # height = height,
  #          alt = the_person)
  #     
  #   }, deleteFile = FALSE)
  
  # Observe the confirmation of the photo upload and send to dropbox
  output$photo_confirmation_ui <-
    renderUI({
      ok <- FALSE
      upl <- input$url_or_upload
      x <- uploaded_photo_path()
      if(upl == 'Get from web'){
        ok <- TRUE
      }
      if(!is.null(x)){
        ok <- TRUE
      }
      
      if(ok){
        fluidPage(
          fluidRow(
            column(12, 
                   align = 'center',
                   actionButton("button_crop", "Crop & Save",
                                icon = icon('calendar')))
          ),

          br()
        )
      }
    })
  observeEvent(input$button_crop,{
    message('Photo upload confirmed---')
    person <- input$photo_person
    destination_file <- paste0('www/headshots/circles/', person, '.png')
    
    upl <- input$url_or_upload
    if(upl == 'Upload from disk'){
      upp <- uploaded_photo_path()
      img_url <- upp
      external_url <- FALSE
    } else {
      upp <- input$img_url
      img_url <- gsub("\\s","",
                      upp)
      external_url <- TRUE
    }
    
    
    # Update the www folder
    if (is.null(img_url) || img_url=="") return(NULL)
    
    scale = as.numeric(input$scale)
    cropX = as.numeric(input$cropX)
    cropY = as.numeric(input$cropY)
    
    size <- min(image_info(mask)$width,image_info(mask)$height)
    
    img_ob <- image_read(path=img_url)
    xscale <- ceiling(image_info(img_ob)$width * (as.numeric(scale))/100)
    yscale <- ceiling(image_info(img_ob)$height * (as.numeric(scale))/100)
    
    img_ob_r <- image_resize(img_ob,geometry=geometry_size_pixels(width=xscale,height=NULL,preserve_aspect = TRUE))
    img_ob_c <- image_crop(img_ob_r,geometry=geometry_area(x_off=cropX,y_off=cropY))
    
    
    circle_img <- image_composite(mask, img_ob_c, "out") 
    image_write(circle_img,path="www/circle_img.png")
    person <- input$photo_person
    destination_file <- paste0('www/headshots/circles/', person, '.png')
    file.copy(from = 'www/circle_img.png',
              to = destination_file,
              overwrite = TRUE)
    message('Just copied the cropped image to ', destination_file)
    
    
    # Having updated the www folder, we can now uppdate the database
    message('--- updating the database')
    Sys.sleep(0.2)
    populate_image_from_www(name=person)
    # # Update the reactive object
    # message('--- updating the reactive in-session object')
    # images <- get_images(pool = pool)
    # photos_reactive$images <- images
    
    
  })
  
  #UI for editing new photo
  output$new_photo_ui <- renderUI({
    ok <- FALSE
    upl <- input$url_or_upload
    x <- uploaded_photo_path()
    if(upl == 'Get from web'){
      ok <- TRUE
    }
    if(!is.null(x)){
      ok <- TRUE
    }
    if(ok){
      fluidPage(
        fluidRow(
          column(12,
                 uiOutput('photo_editor'),
                 sliderInput(inputId="scale",label="Resize",min=1,max=200,step=1,value=100),
                 hidden(textInput(inputId="cropX","Crop X",value="0"),
                        textInput(inputId="cropY","Crop Y",value="0")))
        )
      ) 
    }
  })
  addResourcePath("www", resourcepath)
  
  output$photo_editor <- renderUI({
    
    temp_name <- paste0('www/temp', Sys.time(), '.png')
    temp_name <- gsub(' ', '', temp_name)
    temp_name <- gsub(':', '', temp_name, fixed = TRUE)
    temp_name <- gsub('-', '', temp_name, fixed = TRUE)
    
    # Refresh
    uploaded_photo_path()
    
    delete_old_ones <- dir('www')[grepl('temp', dir('www')) & grepl('png', dir('www'))]
    if(length(delete_old_ones) > 0){
      for(i in 1:length(delete_old_ones)){
        file.remove(paste0('www/', delete_old_ones[i]))
      }
    }
    
    this_time <- as.numeric(Sys.time())
    zz <- -1# *(20000000000 - this_time - app_start_time)
    
    scale <- input$scale
    print(paste("Scale: ",scale))
    # upp <- uploaded_photo_path()
    upl <- input$url_or_upload
    if(upl == 'Upload from disk'){
      upp <- uploaded_photo_path()
      img_url <- upp
      external_url <- FALSE
    } else {
      upp <- input$img_url
      img_url <- gsub("\\s","",
                      upp)
      external_url <- TRUE
    }
    
    
    print(paste('Rendering image [ ',img_url,' ]'))
    go <- FALSE
    if(!is.null(img_url)){
      if(length(img_url) > 0){
        if(img_url != ''){
          go <- TRUE
        }
      }
    }
    ss <- switcher()
    # if(!ss){
    #   go <- FALSE
    # }
    if(!go){
      return(NULL)
    }
    img_ob <- image_read(path=img_url)
    xscale <- ceiling(image_info(img_ob)$width * (as.numeric(scale))/100)
    yscale <- ceiling(image_info(img_ob)$height * (as.numeric(scale))/100)
    
    
    if(!external_url){
      file.copy(img_url,
                to = temp_name,
                overwrite = TRUE)
      img_url <- temp_name
      url_text <- paste0("'", img_url, "'")
    }
    url_text <- paste0('url(', img_url, ')')
    html<- list(
      HTML(paste0("<img src='www/mask.png'
                  id='crop' name='crop' 
                  onmousedown=\"dragstart(event);\" 
                  onmouseup=\"dragend(event);\" 
                  onmousemove=\"dodrag(event);\" 
                  style=\"z-index:", zz, ";background-image:", url_text, ";
                  background-repeat: no-repeat;background-size:",xscale,"px ",yscale,"px;\" width='200px';>"))
    )
    
    print(html)
    return (html)
  })
  
  output$upload_url_ui <- renderUI({
    
    upl <- input$url_or_upload
    if(upl == 'Upload from disk'){
      fileInput('photo_upload',
                'Upload here:',
                accept=c('.png'))
    } else {
      textInput(inputId='img_url', 'Image Url',value='https://petapixel.com/assets/uploads/2017/11/Donald_Trump_official_portraitt-640x800.jpg')
    }
  })
  
  # Create hidden ids associated with the hands on tables
  hidden_ids <- reactiveValues()
  hidden_ids$person_id <- NA
  hidden_ids$trip_uid <- NA
  hidden_ids$venue_id <- NA
  
  # People edit table
  output$hot_people <- renderRHandsontable({
    df <- make_hot_people(people = people, person = input$photo_person) 
    if(!is.null(df)){
      if(nrow(df) > 0){
        hidden_ids$person_id <- df$person_id
        rhandsontable(df, #useTypes = TRUE,
                      stretchH = 'all',
                      # width = 1000, height = 100,
                      rowHeaders = NULL,
                      colHeaders = c('Name', 'Title', 'Organization', 'World Bank Group')) %>%
          hot_col(col = "World Bank Group", type = "checkbox") %>%
          hot_cols(manualColumnResize = TRUE, columnSorting = TRUE)
      }
    }
  })
  
  # Trips edit table
  output$hot_trips <- renderRHandsontable({
    
    print('view_all IS ..............................')
    print(head(vals$view_all_trips_people_meetings_venues))
    df <- make_hot_trips(data = vals$view_all_trips_people_meetings_venues,
                         filter = input$trips_filter) 
    
    if(!is.null(df)){
      if(nrow(df) > 0){
        
        df <- df %>%
          mutate(Delete = FALSE)
        
        hidden_ids$trip_uid <- df$trip_uid
        
        # Update the hidden ids
        df <- df %>% dplyr::select(-trip_uid)
        rhandsontable(df, 
                      stretchH = 'all',
                      # width = 1000, height = 300,
                      rowHeaders = NULL) %>%
          hot_col(col = "Person", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$short_name), strict = FALSE)  %>%
          hot_col(col = "Organization", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$organization), strict = FALSE)  %>%
          hot_col(col = "Title", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$title), strict = FALSE)  %>%
          hot_col(col = "City", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$city_name), strict = FALSE)  %>%
          hot_col(col = "Country", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$country_name), strict = FALSE)  %>%
          hot_col(col = "Trip Group", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$trip_group), strict = FALSE)  %>%
          hot_col(col = "Venue", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$venue_name), strict = FALSE)  %>%
          hot_col(col = "Meeting", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$meeting_with), strict = FALSE)  %>%
          hot_col(col = "Agenda", type = "autocomplete", source = clean_vector(view_all_trips_people_meetings_venues$agenda), strict = FALSE) %>%
          hot_col(col = 'Delete', type = 'checkbox') %>%
          hot_cols(manualColumnResize=TRUE, columnSorting = TRUE, colWidths = 70)
      }
    }
  })
  
  # Events edit table
  output$hot_venue_events <- renderRHandsontable({
    
    df <- make_hot_venue_events(data = venue_events)
    if(!is.null(df)){
      if(nrow(df) > 0){
        hidden_ids$venue_id <- df$venue_id
        df <- df %>% dplyr::select(-venue_id)
        rhandsontable(df, 
                      stretchH = 'all',
                      # width = 1000, height = 300,
                      rowHeaders = NULL,
                      colHeaders = c('Event', 'Start', 'End', 'Display on timeline', 'Type', 'City')) %>%
          hot_col(col = "Type", type = "autocomplete", source = clean_vector(venue_types$type_name), strict = FALSE)  %>%
          hot_col(col = "City", type = "autocomplete", source = clean_vector(cities$city_name), strict = FALSE)  %>%
          hot_col(col = "Event", type = "autocomplete", source = clean_vector(venue_events$event_title), strict = FALSE)  %>%
          hot_col(col = "Display on timeline", type = "checkbox") %>%
          hot_cols(manualColumnResize=TRUE, columnSorting = TRUE)
      }
    }
  })
  
  # Define reactive values for checking diff between the last saved hot table and current one
  last_save <- reactiveValues()
  last_save$hot_people <- make_hot_people(people = people,
                                          person = sort(unique(view_all_trips_people_meetings_venues$person_name))[1])
  last_save$hot_trips <- make_hot_trips(data = view_all_trips_people_meetings_venues,
                                        filter = NULL) %>% dplyr::select(-trip_uid) %>% mutate(Delete = FALSE)
  last_save$hot_venue_events <- make_hot_venue_events(data = venue_events) %>% dplyr::select(-venue_id)
  
  # # Observe the trips filter and update accordingly
  # observeEvent(input$trips_filter, {
  #   the_filter <- input$trips_filter
  #   if(!is.null(the_filter)){
  #     if(length(the_filter) > 0){
  #       if(nchar(the_filter) >= 1){
  #         last_save$hot_trips <- make_hot_trips(data = view_all_trips_people_meetings_venues,
  #                                               filter = the_filter) %>% dplyr::select(-trip_uid)
  #       }
  #     }
  #   }
  # })
  
  
  # Observe the submissions of the hands on tables and send info to database
  observeEvent(input$hot_people_submit, {
    message('Edits to the people hands-on-table were submitted.')
    # Get the data
    last_save$hot_people <- df <- hot_to_r(input$hot_people)
    # Convert the boolean back to 0/1
    df$is_wbg <- ifelse(df$is_wbg, 1, 0)
    # Get the person id
    df$person_id <- hidden_ids$person_id
    # For now, not doing anything with the data
    message('--- Nothing actually being changed in the database. Waiting on function from Soren.')
    upload_edited_people_data(data = df)

    # Update the session
    updated_data <- db_to_memory(return_list = TRUE)
    vals$events <- updated_data$events
    vals$cities <- updated_data$cities
    vals$people <- updated_data$people
    vals$trips <- updated_data$trips
    vals$view_trips_and_meetings <- updated_data$view_trips_and_meetings
    vals$view_trip_coincidences <- updated_data$view_trip_coincidences
    vals$view_all_trips_people_meetings_venues <- updated_data$view_all_trips_people_meetings_venues
    
  })
  
  output$hot_people_submit_check <- 
    renderUI({
      go <- FALSE
      x <- last_save$hot_people
      if(nrow(x) > 0){
        y <- input$hot_people
        if(!is.null(y)){
          y <- hot_to_r(y)
          if(identical(x,y)){
            go <- TRUE
          }
        }
      }
      if(go){
        fluidPage(fluidRow(column(12, align = 'center', icon('check'))))
      } else {
        fluidPage(fluidRow(column(12, align = 'center', helpText('Changes detected. Click above to save.'))))
      }
    })
  
  observeEvent(input$hot_trips_submit, {
    message('Edits to the trips hands-on-table were submitted.')
    # Get the data
    last_save$hot_trips <- df <- hot_to_r(input$hot_trips)
    # Get the trip id (though I don't think we're doing anything with it)
    df$ID <- hidden_ids$trip_uid
    # Create a command column
    df$CMD <- ifelse(df$Delete, 'DELETE', 'UPDATE')
    df$Delete <- NULL
    # For now, not doing anything with the data
    message('--- Uploading new trips data ')
    upload_results <- 
      upload_raw_data(data = df,
                      logged_in_user_id = 1,
                      return_upload_results = TRUE)
    
    # Update the session
    updated_data <- db_to_memory(return_list = TRUE)
    vals$events <- updated_data$events
    vals$cities <- updated_data$cities
    vals$people <- updated_data$people
    vals$trips <- updated_data$trips
    vals$view_trips_and_meetings <- updated_data$view_trips_and_meetings
    vals$view_trip_coincidences <- updated_data$view_trip_coincidences
    # vals$upload_results <- upload_results
    vals$view_all_trips_people_meetings_venues <- updated_data$view_all_trips_people_meetings_venues
    message('--- Done uploading new trips data.')
  })
  
  output$hot_trips_submit_check <- 
    renderUI({
      go <- FALSE
      nothing <- FALSE
      x <- last_save$hot_trips
      if(nrow(x) > 0){
        y <- input$hot_trips
        if(!is.null(y)){
          y <- hot_to_r(y)
          if(identical(x,y)){
            go <- TRUE
          } 
        }
      }
      if(!is.null(input$trips_filter)){
        if(length(input$trips_filter) > 0){
          if(nchar(input$trips_filter) > 0){
            nothing <- TRUE
          }
        }
      }
      if(nothing){
        fluidPage('')
      } else {
        if(go){
          fluidPage(fluidRow(column(12, align = 'center', icon('check'))))
        } else {
          fluidPage(fluidRow(column(12, align = 'center', helpText('Changes detected. Click above to save.'))))
        }
      }
      
    })
  
  
  observeEvent(input$hot_venue_events_submit, {
    message('Edits to the venue_events hands-on-table were submitted.')
    # Get the data
    last_save$hot_venue_events <- df <- hot_to_r(input$hot_venue_events)
    # Get the hidden ids
    df$venue_id <- hidden_ids$venue_id
    message('Venue ids are ')
    print(df$venue_id)
    # Convert venue type name to venue type id
    df <- left_join(x = df,
                    y = venue_types %>% dplyr::select(-is_temporal_venue),
                    by = 'type_name') %>%
      dplyr::select(-type_name)
    # For now, not doing anything with the data
    message('--- Nothing actually being changed in the database. Waiting on function from Soren.')
    upload_edited_venue_events_data(data = df)
    
    # Update the session
    updated_data <- db_to_memory(return_list = TRUE)
    vals$events <- updated_data$events
    vals$cities <- updated_data$cities
    vals$people <- updated_data$people
    vals$trips <- updated_data$trips
    vals$view_trips_and_meetings <- updated_data$view_trips_and_meetings
    vals$view_trip_coincidences <- updated_data$view_trip_coincidences
    vals$view_all_trips_people_meetings_venues <- updated_data$view_all_trips_people_meetings_venues
  })
  
  output$hot_venue_events_submit_check <- 
    renderUI({
      go <- FALSE
      x <- last_save$hot_venue_events
      if(nrow(x) > 0){
        y <- input$hot_venue_events
        if(!is.null(y)){
          y <- hot_to_r(y)
          if(identical(x,y)){
            go <- TRUE
          }
        }
      }
      if(go){
        fluidPage(fluidRow(column(12, align = 'center', icon('check'))))
      } else {
        fluidPage(fluidRow(column(12, align = 'center', helpText('Changes detected. Click above to save.'))))
      }
    })
  
  
  
  # Add data table
  output$add_table <- renderRHandsontable({
    df <- data.frame(Person = as.character(NA),
                     Organization = as.character(NA),
                     Title = as.character(NA),
                     City = as.character(NA),
                     Country = as.character(NA),
                     Start = as.Date(NA),
                     End = as.Date(NA),
                     `Trip Group` = as.character(NA),
                     Venue = as.character(NA),
                     Meeting = as.character(NA),
                     Agenda = as.character(NA))
    names(df) <- gsub('.', ' ', names(df), fixed = TRUE)
    
    
    if(!is.null(df)){
      rhandsontable(df, rowHeaders = NULL, width = 1000, height = 200) %>%
        hot_col(col = "Person", type = "autocomplete", source = clean_vector(people$short_name), strict = FALSE) %>%
        hot_col(col = "Organization", type = "autocomplete", source = clean_vector(people$organization), strict = FALSE) %>%
        hot_col(col = 'Title', type = 'autocomplete', source = clean_vector(people$title), strict = FALSE) %>%
        hot_col(col = 'City', type = 'autocomplete', source = clean_vector(cities$city_name), strict = FALSE) %>%
        hot_col(col = 'Country', type = 'autocomplete', source = clean_vector(cities$country_name), strict = FALSE) %>%
        hot_col(col = 'Trip Group', type = 'autocomplete', source = clean_vector(trips$trip_group), strict = FALSE) %>%
        hot_col(col = 'Venue', type = 'autocomplete', source = clean_vector(venue_events$venue_name), strict = FALSE) %>%
        hot_col(col = 'Meeting', type = 'autocomplete', source = clean_vector(people$short_name), strict = FALSE) %>%
        hot_col(col = 'Agenda', type = 'autocomplete', source = clean_vector(trip_meetings$agenda), strict = FALSE) %>%
        hot_cols(colWidths = 90, manualColumnResize = TRUE, columnSorting = TRUE)
    }
  })
  
  # Observe the confirmation of an add and process it
  observeEvent(input$add_table_submit, {
    message('A manual addition to the database was submitted.')
    # Get the data
    df <- hot_to_r(input$add_table)
    upload_results <- 
      upload_raw_data(data = df,
                    logged_in_user_id = 1,
                    return_upload_results = TRUE)
    message('Results from manual data upload:')
    print(upload_results)

  })
  
  
  
  # Observe the add table action button and give a menu
  observeEvent(input$action_add, {
    showModal(
      modalDialog(
        title = 'Manually add data',
        size = 'l',
        easyClose = TRUE,
        fade = TRUE,
        fluidPage(
          fluidRow(
            rHandsontableOutput('add_table')
          ),
          fluidRow(
            column(12, align = 'center',
                   action_modal_button('add_table_submit',
                                'Submit new data',
                                icon = icon('check')))
          )
        )
      )
    )
    
  })
  
  # On session end, close
  session$onSessionEnded(function() {
    message('Session ended. Closing the connection pool.')
    #tryCatch(pool::poolClose(GLOBAL_DB_POOL), error = function(e) {message('')})
    tryCatch(db_disconnect(), error = function(e) {message('')})
    if(file.exists('www/temp.png')){
      file.remove('www/temp.png')
    }
  })
  
  
  }

# Run the application 
shinyApp(ui = ui, server = server)
