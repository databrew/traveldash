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
                                  tags$style(type='text/css', "#reset_date_range {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: 10px; margin-bottom: -10px;}"),
                                  tags$style(type='text/css', "#search_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: -5px; width:70%; margin-bottom: -10px;}"),
                                  tags$style(type='text/css', "#wbg_only_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: -5px; margin-bottom: -10px;}"),
                                  tags$style(type='text/css', "#date_range_2_ui {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: -5px; margin-bottom: -10px;}"),
                                  
                                  tags$style(type='text/css', "#log_out {margin-right: 10px; margin-left: 10px; font-size:80%; margin-top: 10px; margin-bottom: -10px;}"),
                                  
                                  tags$li(class = 'dropdown',
                                          uiOutput('date_range_2_ui')),
                                  tags$li(class = 'dropdown',
                                          uiOutput('reset_date_range_ui')),
                                  tags$li(class = 'dropdown',
                                          img(src='blue.png', align = "center", width = '160px', height = '10px')),
                                  tags$li(class = 'dropdown',
                                          uiOutput('wbg_only_ui')
                                  ),
                                  tags$li(class = 'dropdown',
                                          uiOutput('search_ui')),
                                  # span(uiOutput('log_in_text'), class = "logo"),
                                  tags$li(class = 'dropdown',
                                          uiOutput('log_out_ui')),
                                  tags$li(class = 'dropdown',
                                          img(src='blue.png', align = "center", width = '160px', height = '10px'))),
                          titleWidth = the_width)

# Sidebar
sidebar <- dashboardSidebar(
  # tags$style(".left-side, .main-sidebar {padding-top: 70px}"),
  # tags$style(".main-header {max-height: 70px}"),
  # tags$style(".main-header .logo {height: 70px;}"),
  # tags$style(".sidebar-toggle {height: 70px; padding-top: 1px !important;}"),
  # tags$style(".navbar {min-height:70px !important}"),  
  
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
  sidebarMenuOutput("menu")
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
  
  uiOutput('any_data_ui'),
  tabItems(
    tabItem(tabName = 'log_in',
            fluidPage(
              fluidRow(column(12, align = 'center',
                              textInput(inputId = 'user_name',
                                        value = 'MEL',
                                        label = 'User name')),
                       column(12, align = 'center',
                              passwordInput(inputId = 'password', 
                                            value = 'FIGSSAMEL',
                                            label = 'Password'))),
              fluidRow(
                column(12, align = 'center',
                       h3(textOutput('failed_log_in_text')))
              ),
              fluidRow(
                column(12, align = 'center',
                       action_modal_button('log_in_submit', "Submit", icon = icon('check-circle')))
              )
            )),
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
          column(1),
          shinydashboard::box(
            title = 'Soren Heitmann',
            fluidPage(
              fluidRow(
                column(4,div(a(img(src='about/Soren Heitmann.jpg', 
                                   align = "center",
                                   height = '130'),
                               href="mailto:sheitmann@ifc.org"), 
                             style="text-align: center;")),
                column(8, h5('Project Lead'),
                       h5('Johannesburg | ', 
                          a(href = 'mailto:sheitmann@ifc.org',
                            'sheitmann@ifc.org')))),
              fluidRow(helpText("Soren has a background in database management, software engineering and web technology. He manages the applied research and integrated monitoring, evaluation and learning program for the IFC-MasterCard Foundation Partnership for Financial Inclusion. He works at the nexus of data-driven research and technology to help drive learning and innovation within IFC’s Digital Financial Services projects in Sub-Saharan Africa."))
            ),
            width = 4),
          column(2),
          shinydashboard::box(
            title = 'Oleksiy Anokhin',
            fluidPage(
              fluidRow(
                column(4,
                       div(a(img(src='about/Oleksiy Anokhin.jpg', 
                                 align = "center",
                                 height = '130'),
                             href="mailto:oanokhin@ifc.org"), 
                           style="text-align: center;")),
                column(8,
                       h5('Project Specialist'),
                       h5('Washington, DC | ', 
                          a(href = 'mailto:oanokhin@ifc.org',
                            'oanokhin@ifc.org')))
              ),
              fluidRow(helpText("Oleksiy focuses on data-driven visualization solutions for international development. He is passionate about using programmatic tools (such as interactive dashboards) for better planning and implementation of projects, as well as for effective communication of projects results to various stakeholders."))
            ),
            width = 4),
          column(1)
        ),
        fluidRow(div(helpText(creds),
                     style = 'text-align:right')),
        fluidRow(
          column(12,
                 align = 'right',
                 helpText(textOutput("url_text")))
        )
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
              
            )
    ),
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
                                                     uiOutput('photo_person_ui'))),
                                     fluidRow(
                                       column(6,
                                              fluidRow(column(12, align = 'center',
                                                              h3('Current information'),
                                                              actionButton('hot_people_submit',
                                                                           'Submit changes'),
                                                              uiOutput('hot_people_submit_check'))),
                                              br(),
                                              rHandsontableOutput("hot_people")),
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
                                                              # radioButtons('url_or_upload',
                                                              #              '',
                                                              #              choices = c('Upload from disk',
                                                              #                          'Get from web')),
                                                              uiOutput('upload_url_ui'),
                                                              helpText('Recommended size: 200x200 - 800x800 px')
                                              ))
                                       )))),
                          tabPanel("Venues & Events",
                                   fluidPage(
                                     fluidRow(
                                       column(12, align = 'center',
                                              h1('Events'))
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
                                     ),
                                     
                                     
                                     fluidRow(
                                       column(12, align = 'center',
                                              h1('Venues'))
                                     ),
                                     br(),
                                     fluidRow(
                                       column(12, align = 'center',
                                              actionButton('hot_venues_submit',
                                                           'Submit changes'),
                                              uiOutput('hot_venues_submit_check'))
                                     ),
                                     br(),
                                     fluidRow(
                                       rHandsontableOutput("hot_venues")
                                     )
                                   )))
            )
    )
    ),
  tags$style(type="text/css", "#add_table th {font-weight:bold;}"),
  tags$style(type="text/css", "#hot_trips th {font-weight:bold;}"),
  tags$style(type="text/css", "#hot_trips td {font-size: 10px;}"),
  tags$style(type="text/css", "#hot_people th {font-weight:bold;}"),
  tags$style(type="text/css", "#hot_venues th {font-weight:bold;}"),
  tags$style(type="text/css", "#hot_venue_events th {font-weight:bold;}")
  )


ui <- dashboardPage(header, sidebar, body)

# Define server
server <- function(input, output, session) {
  
  # Reactive list of dataframes for user-specific data
  vals <- reactiveValues()
  
  # Whether the user has any data at all
  any_data <- reactiveVal(value = FALSE)
  
  # Reactive value for whether logged in or not
  logged_in <- reactiveVal(value = FALSE)
  user_id <- reactiveVal(value = 0)
  
  # Observe the submission and log in
  observeEvent(input$log_in_submit, {
    # Check password and username
    log_in_result <- 
      check_user_name_and_password(user_name = input$user_name,
                                   password = input$password,
                                   users = users)
    if(log_in_result > 0){
      logged_in(TRUE)
      user_id(log_in_result)
      # Update the "last_login" field
      update_last_login_field(user_id = log_in_result)
    } else {
      # Failed log in
      fli <- failed_log_in()
      failed_log_in(fli + 1)
    }
  })
  
  # Observe the log out button
  observeEvent(input$log_out, {
    logged_in(FALSE)
    user_id(0)
    failed_log_in_text('')
    failed_log_in(0)
    any_data(FALSE)
  })
  
  # Observe changes to the user id and update the vals
  observeEvent(user_id(), {
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
    x <- vals$view_all_trips_people_meetings_venues
    if(!is.null(x)){
      if(nrow(x) > 0){
        any_data(TRUE)
      }
    }
  })
  
  # Log in text
  output$log_in_text <- renderText({
    l <- logged_in()
    if(!l){
      return(NULL)
    }
    u <- user_id()
    out <- 'Not logged in'
    if(!is.null(u)){
      if(u != ''){
        out <- paste0('Logged in as ', u)
      }
    }
    return(out)
  })
  
  
  # Text to warn if no data
  output$any_data_ui <- renderUI({
    li <- logged_in()
    if(!li){
      return(NULL)
    }
    ad <- any_data()
    if(ad){
      return(NULL)
    } else {
      fluidPage(fluidRow(column(12, align = 'center',
                                h3(paste0('No data on record. Go to "Upload trips" to add data.')))))
    }
  })
  
  # Failed log in text
  failed_log_in <- reactiveVal(value = 0)
  failed_log_in_text <- reactiveVal(value = '')
  observeEvent(c(failed_log_in()), {
    fli <- failed_log_in()
    if(fli > 0){
      message('Failed log in attempt. Re-prompting the log-in.')
      failed_log_in_text('Incorrect user name / password combination.')
    }
  })
  output$failed_log_in_text <-
    renderText({
      ok <- FALSE
      x <- failed_log_in_text()
      if(!is.null(x)){
        if(length(x) > 0){
          if(x != ''){
            ok <- TRUE
          }
        }
      }
      if(ok){
        return(x)
      }
    })
  
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
  
  
  output$reset_date_range_ui <- renderUI({
    li <- logged_in()
    if(!li){
      return(NULL)
    } else {
      actionButton('reset_date_range', 'Reset', icon = icon('undo'))
    }
  })
  
  output$log_out_ui <- renderUI({
    li <- logged_in()
    if(li){
      tags$li(class = 'dropdown',
              actionButton('log_out', label = 'Log out', icon = icon('times')))
    } else {
      NULL
    }
  })
  
  output$wbg_only_ui <- renderUI({
    li <- logged_in()
    if(!li){
      return(NULL)
    } else {
      selectInput('wbg_only',
                  '',
                  choices = 
                    c('All affiliations' = 'Everyone', 
                      'WBG only' = 'WBG only', 
                      'Non-WBG only' = 'Non-WBG only'),
                  width = '150px')
    }
  })
  
  output$search_ui <- renderUI({
    li <- logged_in()
    if(!li){
      return(NULL)
    } else {
      textInput('search',
                '',
                placeholder = 'Search for people, places, events')
    }
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
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
    inFile <- input$photo_upload

    if (is.null(inFile)){
      return(NULL)
    } else {
      inFile$datapath
    }
  })
  
  # Column table
  output$column_table_correct <- renderTable({
    li <- logged_in(); if(!li){return(NULL)}
    data_frame(Person = 'John Doe',
               Organization = 'Acme Inc.',
               Title = 'CEO',
               City = 'New York',
               Country = 'USA',
               Start = format(Sys.Date(), '%m/%d/%Y'),
               End = format(Sys.Date() + 3, '%m/%d/%Y'),
               `Trip Group` = NA,
               Venue = 'Acme Hotel',
               Agenda = 'Meeting with stakeholders')
  })
  
  output$uploaded_table <- DT::renderDataTable({
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
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
      li <- logged_in(); if(!li){return(NULL)}
      out <- submit_text()
      out
    })
  output$upload_ui <-
    renderUI({
      li <- logged_in(); if(!li){return(NULL)}
      
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
            textOutput('submit_text'),
            uiOutput('submit_icon')
          )
        )
      }
    })
  
  output$download_correct <- downloadHandler(
    filename = function() {
      'data_download.csv'
    },
    content = function(file){
      x <- vals$view_all_trips_people_meetings_venues %>%
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
  
  # Replace data with uploaded data
  observeEvent(input$submit, {
    new_data <- uploaded()
    message('new data has ', nrow(new_data), ' rows')
    # Upload the new data to the database
    upload_results <-
      upload_raw_data(data = new_data,
                      logged_in_user_id = user_id(),
                      return_upload_results = TRUE)
    message('Uploaded raw data')
    # Update the session
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
    vals$upload_results <- upload_results
  })
  
  submit_text <- reactiveVal(value = '')
  output$submit_icon <- renderUI({
    li <- logged_in(); if(!li){return(NULL)}
    if(input$submit > 0){
      fluidPage(
        fluidRow(
          column(12, align = 'center',
                 icon('check', 'fa-3x'))
        )
      )
    } else {
      NULL
    }
  })
  observeEvent(input$submit, {
    submit_text('Data uploaded! Now click through other tabs to explore your data.')
  })
  
  
  selected_timevis <- reactiveVal(value = NULL)
  observeEvent(input$timevis_selected,
               selected_timevis(input$timevis_selected))
  observeEvent(input$timevis_clear,{
    selected_timevis(NULL)
    updateCheckboxInput(session = session,
                        inputId = 'show_meetings',
                        value = FALSE)
  })
  
  filtered_expanded_trips <- reactive({
    li <- logged_in(); if(!li){return(NULL)}
    sm<- input$show_meetings
    fd <- date_range()
    search_string <- input$search

    out <- NULL
    if(nrow(vals$view_all_trips_people_meetings_venues) > 0){
      expanded_trips <- 
        expand_trips(view_all_trips_people_meetings_venues = vals$view_all_trips_people_meetings_venues,
                     venue_types = venue_types, 
                     venue_events = vals$venue_events, 
                     cities = vals$cities)
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
              
              updateCheckboxInput(session = session,
                                  inputId = 'show_meetings',
                                  value = TRUE)
            }
          }
        } else {
          out <- NULL
        }
        
        
      } else {
        out <- NULL
      }
    }
    
    
    
    return(out)
  })
  
  
  
  # Create a filtered view_all_trips_people_meetings_venues_filtered
  view_all_trips_people_meetings_venues_filtered <- reactive({
    li <- logged_in(); if(!li){return(NULL)}
    fd <- date_range()
    vd <- vals$view_all_trips_people_meetings_venues
    if(!is.null(vd)){
      x <- vd %>%
        dplyr::filter(fd[1] <= trip_end_date,
                      fd[2] >= trip_start_date)
      
      x <- search_df(data = x,
                     input$search)
      return(x)
    }
  })
  
  output$leafy <- renderLeaflet({
    li <- logged_in(); if(!li){return(NULL)}
    
    # Get trips and meetings, filtered for date range    
    df <- view_all_trips_people_meetings_venues_filtered()
    
    # Filter for wbg only if relevant
    if(input$wbg_only == 'WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 1)
    } else if(input$wbg_only == 'Non-WBG only'){
      df <- df %>% dplyr::filter(is_wbg == 0)
    }
    
    if(!is.null(df)){
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
        left_join(vals$cities %>%
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
        left_join(vals$cities %>%
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
    } else {
      return(leaflet())
    }
    
  })
  
  # Obseve changes to zoom
  observeEvent(input$leafy_zoom, {
    li <- logged_in()
    # Much of this is a copy of the above map code
    # Could be cleaned up a bit to not duplicate.
    
    if(li){
      # Get trips and meetings, filtered for date range    
      df <- view_all_trips_people_meetings_venues_filtered()
      
      if(!is.null(df)){
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
        if(nrp > 0){
          
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
            left_join(vals$cities %>%
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
            left_join(vals$cities %>%
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
        }
      }
    }
  })
  
  
  
  output$sank <- renderSankeyNetwork({
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
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
    li <- logged_in(); if(!li){return(NULL)}
    
    x <- view_all_trips_people_meetings_venues_filtered()
    if(!is.null(x)){
      # Filter for wbg only if relevant
      if(input$wbg_only == 'WBG only'){
        x <- x %>% dplyr::filter(is_wbg == 1)
      } else if(input$wbg_only == 'Non-WBG only'){
        x <- x %>% dplyr::filter(is_wbg == 0)
      }
      
      # Clean up
      x <- x %>%
        dplyr::select(short_name, organization, city_name, trip_start_date, trip_end_date,
                      meeting_person_name, agenda, venue_name, event_title)
      
      x <- x %>%
        mutate(a = paste0(short_name,
                          ifelse(!is.na(organization),
                                 paste0(' (', organization),
                                 ''),
                          ifelse(!is.na(organization),
                                 ')',
                                 '')),
               b = oleksiy_date(trip_start_date, trip_end_date),
               c = city_name,
               d = ifelse(!is.na(agenda) & agenda != '',
                          agenda,
                          ifelse(!is.na(meeting_person_name) & meeting_person_name != '',
                                 paste0('Meeting with ', meeting_person_name),
                                 ifelse(!is.na(event_title) & event_title != '',
                                        event_title,
                                        NA)))) %>%
        dplyr::select(a, b, c, d)
      names(x) <- c('Person', 'Date', 'Location', 'Event')
      
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
      
    }
  })
  
  output$timevis <-  renderTimevis({
    li <- logged_in(); if(!li){return(NULL)}
    
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
  
  
  # Test table for graph
  output$click_table <- DT::renderDataTable({
    li <- logged_in(); if(!li){return(NULL)}
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
          left_join(vals$people %>%
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
    li <- logged_in(); if(!li){return(NULL)}
    dr <- date_range()
    the_tab <- input$tabs
    message('the tab is ', the_tab)
    if(!is.null(the_tab)){
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
      li <- logged_in(); if(!li){return(NULL)}
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
        left_join(vals$cities %>%
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
          left_join(vals$cities %>%
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
    li <- logged_in(); if(!li){return(NULL)}
    
    if(input$play){
      leafletOutput('leafy_play')
    } else {
      leafletOutput('leafy')
    }
  })
  
  # Current photo output
  output$current_photo_output <- renderImage({
    li <- logged_in(); if(!li){return(NULL)}
    # Also observe confirmation and refresh
    x <- input$button_crop
    person <- input$photo_person
    
    file_name <- paste0('www/headshots/circles/', person, '.png')
    if(!file.exists(file_name)){
      message('No photo file on disk for ', person, '. Using the NA placeholder photo.')
      file_name <- 'www/headshots/circles/NA.png'
    }
    height = 200
    list(src = file_name,
         # width = width,
         height = height,
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
      li <- logged_in(); if(!li){return(NULL)}
      ok <- FALSE
      # upl <- input$url_or_upload
      upl <- 'Upload from disk' # temporarily disabling upload from web due to firewall
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
    
    # upl <- input$url_or_upload
    upl <- 'Upload from disk' # temporarily disabling upload from web due to firewall
    
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

  })
  
  #UI for editing new photo
  output$new_photo_ui <- renderUI({
    li <- logged_in(); if(!li){return(NULL)}
    ok <- FALSE
    # upl <- input$url_or_upload
    upl <- 'Upload from disk' # temporarily disabling upload from web due to firewall
    
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
    li <- logged_in(); if(!li){return(NULL)}
    
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
    # upl <- input$url_or_upload
    upl <- 'Upload from disk' # temporarily disabling upload from web due to firewall
    
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
    li <- logged_in(); if(!li){return(NULL)}
    
    # upl <- input$url_or_upload
    upl <- 'Upload from disk' # temporarily disabling upload from web due to firewall
    
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
  hidden_ids$venue_venue_id <- NA
  
  # People edit table
  output$hot_people <- renderRHandsontable({
    li <- logged_in(); if(!li){return(NULL)}
    df <- make_hot_people(people = vals$people, person = input$photo_person) 
    if(!is.null(df)){
      if(nrow(df) > 0){
        hidden_ids$person_id <- df$person_id
        rhandsontable(df, #useTypes = TRUE,
                      # stretchH = 'all',
                      width = 350, 
                      # height = 100,
                      rowHeaders = NULL,
                      colHeaders = c('Name', 'Title', 'Organization', 'World Bank Group')) %>%
          hot_col(col = "World Bank Group", type = "checkbox") %>%
          hot_cols(manualColumnResize = TRUE, columnSorting = TRUE, halign = 'htCenter',
                   colWidths = c(rep(100, ncol(df) - 1), 50))
      }
    }
  })
  
  # Trips edit table
  output$hot_trips <- renderRHandsontable({
    li <- logged_in(); if(!li){return(NULL)}

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
          hot_col(col = "Person", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$short_name), strict = FALSE)  %>%
          hot_col(col = "Organization", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$organization), strict = FALSE)  %>%
          hot_col(col = "Title", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$title), strict = FALSE)  %>%
          hot_col(col = "City", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$city_name), strict = FALSE)  %>%
          hot_col(col = "Country", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$country_name), strict = FALSE)  %>%
          hot_col(col = "Trip Group", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$trip_group), strict = FALSE)  %>%
          hot_col(col = "Venue", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$venue_name), strict = FALSE)  %>%
          hot_col(col = "Meeting", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$meeting_with), strict = FALSE)  %>%
          hot_col(col = "Agenda", type = "autocomplete", source = clean_vector(vals$view_all_trips_people_meetings_venues$agenda), strict = FALSE) %>%
          hot_col(col = 'Delete', type = 'checkbox') %>%
          hot_cols(manualColumnResize=TRUE, columnSorting = TRUE, colWidths = c(rep(50, ncol(df) - 1), 35), halign = 'htCenter')
      }
    }
  })
  
  # Events edit table
  output$hot_venue_events <- renderRHandsontable({
    li <- logged_in(); if(!li){return(NULL)}
    df <- make_hot_venue_events(data = vals$venue_events, cities = vals$cities)
    if(!is.null(df)){
      if(nrow(df) > 0){
        hidden_ids$venue_id <- df$venue_id
        df <- df %>% dplyr::select(-venue_id)
        rhandsontable(df, 
                      stretchH = 'all',
                      # width = 1000, height = 300,
                      rowHeaders = NULL,
                      colHeaders = c('Type', 'Event', 'City', 'Start', 'End', 'Display on timeline')) %>%
          hot_col(col = "Type", type = "autocomplete", source = clean_vector(venue_types$type_name[venue_types$is_temporal_venue]), strict = FALSE)  %>%
          hot_col(col = "City", type = "autocomplete", source = clean_vector(vals$cities$city_name), strict = FALSE)  %>%
          hot_col(col = "Event", type = "autocomplete", source = clean_vector(vals$venue_events$event_title), strict = FALSE)  %>%
          hot_col(col = "Display on timeline", type = "checkbox") %>%
          hot_cols(manualColumnResize=TRUE, columnSorting = TRUE, halign = 'htCenter')
      }
    }
  })
  
  
  # Events edit table
  output$hot_venues <- renderRHandsontable({
    li <- logged_in(); if(!li){return(NULL)}
    df <- make_hot_venues(data = vals$venue_events, cities = vals$cities)
    if(!is.null(df)){
      if(nrow(df) > 0){
        hidden_ids$venue_venue_id <- df$venue_id
        df <- df %>% dplyr::select(-venue_id)
        rhandsontable(df, 
                      stretchH = 'all',
                      # width = 1000, height = 300,
                      rowHeaders = NULL,
                      colHeaders = c('Type', 'Venue', 'City', 'Display on timeline')) %>%
          hot_col(col = "Type", type = "autocomplete", source = clean_vector(venue_types$type_name[!venue_types$is_temporal_venue]), strict = FALSE)  %>%
          hot_col(col = "City", type = "autocomplete", source = clean_vector(vals$cities$city_name), strict = FALSE)  %>%
          hot_col(col = "Venue", type = "autocomplete", source = clean_vector(vals$venue_events$event_title), strict = FALSE)  %>%
          hot_col(col = "Display on timeline", type = "checkbox") %>%
          hot_cols(manualColumnResize=TRUE, columnSorting = TRUE, halign = 'htCenter')
      }
    }
  })
  
  
  # Define reactive values for checking diff between the last saved hot table and current one
  last_save <- reactiveValues()
  observeEvent(input$tabs, {
    it <- input$tabs
    if(it == 'edit_data'){
      last_save$hot_people <- make_hot_people(people = vals$people,
                                              person = sort(unique(vals$view_all_trips_people_meetings_venues$person_name))[1])
      last_save$hot_trips <- make_hot_trips(data = vals$view_all_trips_people_meetings_venues,
                                            filter = NULL) %>% dplyr::select(-trip_uid) %>% mutate(Delete = FALSE)
      last_save$hot_venue_events <- make_hot_venue_events(data = vals$venue_events, cities = vals$cities) %>% dplyr::select(-venue_id)
      last_save$hot_venues <- make_hot_venues(data = vals$venue_events, cities = vals$cities) %>% dplyr::select(-venue_id)
      
    }
  })
  
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
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
  })
  
  output$hot_people_submit_check <- 
    renderUI({
      li <- logged_in(); if(!li){return(NULL)}
      go <- FALSE
      x <- last_save$hot_people
      if(!is.null(x)){
        if(nrow(x) > 0){
          y <- input$hot_people
          if(!is.null(y)){
            y <- hot_to_r(y)
            if(identical(x,y)){
              go <- TRUE
            }
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
                      logged_in_user_id = user_id(),
                      return_upload_results = TRUE)
    
    # Update the session
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
    vals$upload_results <- upload_results
    message('--- Done uploading new trips data.')
  })
  
  output$hot_trips_submit_check <- 
    renderUI({
      li <- logged_in(); if(!li){return(NULL)}
      go <- FALSE
      nothing <- FALSE
      x <- last_save$hot_trips
      if(!is.null(x)){
        if(nrow(x) > 0){
          y <- input$hot_trips
          if(!is.null(y)){
            y <- hot_to_r(y)
            if(identical(x,y)){
              go <- TRUE
            } 
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
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
  })
  
  output$hot_venue_events_submit_check <- 
    renderUI({
      li <- logged_in(); if(!li){return(NULL)}
      go <- FALSE
      x <- last_save$hot_venue_events
      if(!is.null(x)){
        if(nrow(x) > 0){
          y <- input$hot_venue_events
          if(!is.null(y)){
            y <- hot_to_r(y)
            if(identical(x,y)){
              go <- TRUE
            }
          }
        }
      }
      
      if(go){
        fluidPage(fluidRow(column(12, align = 'center', icon('check'))))
      } else {
        fluidPage(fluidRow(column(12, align = 'center', helpText('Changes detected. Click above to save.'))))
      }
    })
  
  observeEvent(input$hot_venues_submit, {
    message('Edits to the hot venues hands-on-table were submitted.')
    # Get the data
    last_save$hot_venues <- df <- hot_to_r(input$hot_venues)
    # Get the hidden ids
    df$venue_id <- hidden_ids$venue_venue_id
    message('Venue ids are ')
    print(df$venue_id)
    # Convert venue type name to venue type id
    df <- left_join(x = df,
                    y = venue_types %>% dplyr::select(-is_temporal_venue),
                    by = 'type_name') %>%
      dplyr::select(-type_name)
    # For now, not doing anything with the data
    message('--- Nothing actually being changed in the database. Waiting on function from Soren.')
    upload_edited_venues_data(data = df)
    
    # Update the session
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
  })
  
  output$hot_venues_submit_check <- 
    renderUI({
      li <- logged_in(); if(!li){return(NULL)}
      go <- FALSE
      x <- last_save$hot_venues
      if(!is.null(x)){
        if(nrow(x) > 0){
          y <- input$hot_venues
          if(!is.null(y)){
            y <- hot_to_r(y)
            if(identical(x,y)){
              go <- TRUE
            }
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
    li <- logged_in(); if(!li){return(NULL)}
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
        hot_col(col = "Person", type = "autocomplete", source = clean_vector(vals$people$short_name), strict = FALSE) %>%
        hot_col(col = "Organization", type = "autocomplete", source = clean_vector(vals$people$organization), strict = FALSE) %>%
        hot_col(col = 'Title', type = 'autocomplete', source = clean_vector(vals$people$title), strict = FALSE) %>%
        hot_col(col = 'City', type = 'autocomplete', source = clean_vector(vals$cities$city_name), strict = FALSE) %>%
        hot_col(col = 'Country', type = 'autocomplete', source = clean_vector(vals$cities$country_name), strict = FALSE) %>%
        hot_col(col = 'Trip Group', type = 'autocomplete', source = clean_vector(vals$trips$trip_group), strict = FALSE) %>%
        hot_col(col = 'Venue', type = 'autocomplete', source = clean_vector(vals$venue_events$venue_name), strict = FALSE) %>%
        hot_col(col = 'Meeting', type = 'autocomplete', source = clean_vector(vals$people$short_name), strict = FALSE) %>%
        hot_col(col = 'Agenda', type = 'autocomplete', source = clean_vector(vals$view_all_trips_people_meetings_venues$agenda), strict = FALSE) %>%
        hot_cols(colWidths = 90, manualColumnResize = TRUE, columnSorting = TRUE, halign = 'htCenter')
    }
  })
  
  # Observe the confirmation of an add and process it
  observeEvent(input$add_table_submit, {
    message('A manual addition to the database was submitted.')
    # Get the data
    df <- hot_to_r(input$add_table)
    upload_results <- 
      upload_raw_data(data = df,
                      logged_in_user_id = user_id(),
                      return_upload_results = TRUE)
    message('Results from manual data upload:')
    print(upload_results)
    # Update the session
    liui <- user_id()
    new_vals <- load_user_data(return_list = TRUE, user_id = liui)
    tables <- get_table_names()
    for(i in 1:length(tables)){
      vals[[tables[i]]] <- new_vals[[tables[i]]]
    }
    vals$upload_results <- upload_results
    
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
  
  # Return the components of the URL in a string:
  output$url_text <- renderText({
    
    the_search <- session$clientData$url_search
    search_ok <- FALSE
    if(!is.null(the_search)){
      if(length(the_search) > 0){
        if(the_search != ''){
          search_ok <- TRUE
        }
      }
    }
    if(!search_ok){
      the_search <- paste0('Add something like /?foo=123&bar=somestring to the end of the url (and then load the modified url) to see how it is captured here.')
    }
    paste(sep = "",
          # "protocol: ", session$clientData$url_protocol, "\n",
          # "hostname: ", session$clientData$url_hostname, "\n",
          # "pathname: ", session$clientData$url_pathname, "\n",
          # "port: ",     session$clientData$url_port,     "\n",
          "search: ",   the_search,   "\n"
    )
  })
  
  # Parse the GET query string
  output$queryText <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    
    # Return a string with key-value pairs
    paste(names(query), query, sep = "=", collapse=", ")
  })
  
  # On session end, close
  session$onSessionEnded(function() {
    message('Session ended. Closing the connection pool.')
    #tryCatch(pool::poolClose(GLOBAL_DB_POOL), error = function(e) {message('')})
    tryCatch(db_disconnect(), error = function(e) {message('')})
    # Removing extra images
    if(file.exists('www/temp.png')){
      file.remove('www/temp.png')
    }
    if(file.exists('www/headshots/circle_img.png')){
      file.remove('www/headshots/circle_img.png')
    }if(file.exists('www/circle_img.png')){
      file.remove('www/circle_img.png')
    }
  })
  
  
  
  # Reactive sidebar menu
  output$menu <-
    renderMenu({
      
      # Logged in or not?
      li <- logged_in()
      
      if(!li){
        sidebarMenu(
          id = 'tabs',
          menuItem(
            text = 'Log-in',
            tabName = 'log_in',
            icon = icon('eye')
          ),
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
      } else {
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
            text="Edit data",
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
      }
    })
  
  # Reactive choices for people (ie, only those to whom the user has access)
  output$photo_person_ui <- renderUI({
    li <- logged_in(); if(!li){return(NULL)}
    # Choices for photo
    vv <- vals$view_all_trips_people_meetings_venues
    the_choices <- sort(unique(vv$person_name))
    selectInput('photo_person',
                'Person',
                choices = the_choices)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
