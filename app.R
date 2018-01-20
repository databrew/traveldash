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
      text="Upload data",
      tabName="upload_data",
      icon=icon("upload")),
    menuItem(
      text="Edit data",
      tabName="edit_data",
      icon=icon("edit")),
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
  #   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
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
                   fluidRow(
                     fluidRow(
                       column(1),
                       column(8,
                              h6('Or click on any date below to jump around:',
                                 align = 'center')),
                       column(3)
                     ),
                     fluidRow(
                       div(
                         # column(1),
                         column(12,
                                htmlOutput('g_calendar')),
                           style = 'text-align: center;')
                     )
                     )
                   )
                   
                   
          ),
          column(1),
          column(6,
                 leafletOutput('leafy'),
                 fluidRow(column(3),
                          column(9,
                                 textInput('search',
                                           'Filter for people, events, places, organizations, etc.'))))),
        fluidRow(
          column(6,
                 h4('Interactions during selected period:',
                    align = 'center'),
                 sankeyNetworkOutput('sank')),
          column(6,
                 h4('Detailed visit information',
                    align = 'center'),
                 DT::dataTableOutput('visit_info_table'))
        )
      )
    ),
    tabItem(
      tabName = 'network',
      fluidPage(
        fluidRow(
          h3('Visualization of interaction between people during the selected period', align = 'center'),
          forceNetworkOutput('graph')
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
            title = 'Lesley Sarah Denyes',
            fluidPage(
              fluidRow(
                div(a(img(src='about/Lesley Sarah Denyes.jpg', 
                          align = "center",
                          height = '80'),
                      href="mailto:LDenyes@ifc.org"), 
                    style="text-align: center;")
              ),
              fluidRow(h5('MCF Program Manager'),
                       h5('Johannesburg, ', 
                          a(href = 'mailto:LDenyes@ifc.org',
                            'LDenyes@ifc.org')))
            ),
            width = 4),
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
              fluidRow(h5('Research Manager'),
                       h5('Johannesburg, ', 
                          a(href = 'mailto:sheitmann@ifc.org',
                            'sheitmann@ifc.org')))
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
              fluidRow(h5('Dashboard Project Manager'),
                       h5('Washington, DC, ', 
                          a(href = 'mailto:oanokhin@ifc.org',
                            'oanokhin@ifc.org')))
            ),
            width = 4)
        ),
        fluidRow(
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
                            'jbrew1@worldbank.org')))
            ),
            width = 4),
          shinydashboard::box(
            title = 'Roman Zhukovskyi',
            fluidPage(
              fluidRow(
                div(a(img(src='about/Roman Zhukovskyi.jpg', 
                          align = "center",
                          height = '80'),
                      href="mailto:rzhukovskyi@worldbank.org"), 
                    style="text-align: center;")
              ),
              fluidRow(h5('Consultant'),
                       h5('Washington, DC, ', 
                          a(href = 'mailto:rzhukovskyi@worldbank.org',
                            'rzhukovskyi@worldbank.org')))
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
    tabItem(
      tabName = 'edit_data',
      uiOutput("MainBody")),
    tabItem(tabName = 'upload_data',
            fluidPage(
              fluidRow(
                column(6,
                       h4('Upload data'),
                       helpText('Upload a dataset from your computer'),
                       fileInput('file1', 
                                 '',
                                 accept=c('text/csv', 
                                          'text/comma-separated-values,text/plain', 
                                          '.csv'))),
                column(6,
                       h4('Download sample dataset'),
                       helpText('Click the "Download" button to get a sample dataset.'),
                       downloadButton("downloadData", "Download"))),
              uiOutput('upload_ui'),
              fluidRow(
                h3(textOutput('your_data_text')),
                DT::dataTableOutput('uploaded_table')
              )
              
            ))
  ))
message('Done defining UI')
ui <- dashboardPage(header, sidebar, body, skin="blue")

server <- function(input, output, session) {
  
  # Create a reactive data frame from the user upload 
  uploaded <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    x <- read_csv(inFile$datapath)
    x
  })
  
  # Column table
  output$column_table <- renderTable({
    events %>% sample_n(0)
  })
  
  output$uploaded_table <- DT::renderDataTable({
    x <- uploaded()
    if(!is.null(x)){
      prettify(x)
    } else {
      NULL
    }
  })
  
  output$your_data_text <- renderText({
    x <- uploaded()
    if(!is.null(x)){
      'Your data'
    } else {
      NULL
    }
  })
  
  output$conformity_text <- renderText({
    x <- uploaded()
    if(!is.null(x)){
      uploaded_names <- names(x)[1:11]
      good_names <- names(events)[1:11]
      if(all(good_names %in% uploaded_names)){
        'Your data matches the required format. Click "Submit" to use it in the app and save it to the database.'
      } else {
        paste0('Your data does not match the required format. ',
               'Missing the following variables: ',
               paste0(good_names[which(!good_names %in% uploaded_names)], collapse = ', '))
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
                 helpText(paste0('Your uploaded data must include the below columns: ')),
                 tableOutput('column_table')),
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
  
  output$downloadData <- downloadHandler(
    filename = function() {
      'example-data.csv'
    },
    content = function(file) {
      write.csv(example_upload_data, file, row.names = FALSE)
    }
  )
  
  # hide sidebar by default
  # addClass(selector = "body", class = "sidebar-collapse")
  
  starter <- reactiveVal(value = as.numeric(Sys.Date() - 30))
  ender <- reactiveVal(value = as.numeric(Sys.Date()))
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
  observeEvent(input$selected_date, {
    dw <- date_width()
    starter(as.Date(selected_date()))
    ender(as.Date(starter() + dw))
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
  
  selected_date <- reactive({input$selected_date})
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
                min = date_dictionary$date[1], 
                max = date_dictionary$date[length(date_dictionary$date)], 
                value = c(starty, endy)
    )
    
  })
  
  # Reactive dataframe for the filtered table
  vals <- reactiveValues()
  vals$Data<-filter_events(events = events,
                           visit_start = min(date_dictionary$date),
                           visit_end = max(date_dictionary$date))
  # Add uploaded data
  observeEvent(input$submit, {
    new_data <- uploaded()
    message('new data has ', nrow(new_data), ' rows')
    # Geocode the new data if applicable
    new_data <- geo_code(new_data)
    message('done geocoding')
    # Update the session
    vals$Data <- bind_rows(vals$Data,
                           new_data)
    message('Added to the in-session data')
    
    # Pepare data for upload to database
    new_data <- new_data %>%
      mutate(state = 'new')
    
    # Update the underlying data
    write_table(pool = pool,
                table = 'dev_events',
                schema = 'pd_wbgtravel',
                value = new_data,
                use_sqlite = use_sqlite)
    message('Overwrote the database')
  })
  
  # After modification is confirmed, update the data stores
  observeEvent(input$submit2, {
    message('Modification confirmed, geocoding and overwriting data.')
    new_data <- vals$Data
    # Geocode if applicable
    new_data <- geo_code(new_data)
    # Update the underlying data 
    # Update the underlying data
    write_table(pool = pool,
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
    vals$Data <- vals$Data
  })
  filtered_events <- reactive({
    # x <- vals$Data
    fd <- the_dates()
    vd <- vals$Data
    x <- filter_events(events = vd,
                       visit_start = fd[1],
                       visit_end = fd[2],
                       search = input$search)
    # Jitter if necessary
    if(any(duplicated(x$Lat)) |
       any(duplicated(x$Long))){
      x <- x %>%
        mutate(Long = jitter(Long, factor = 0.5),
               Lat = jitter(Lat, factor = 0.5))
    }
    return(x)
    
  })
  
  output$leafy <- renderLeaflet({
    l <- leaflet() %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      setView(lng = mean(events$Long, na.rm = TRUE) - 5, lat = mean(events$Lat, na.rm = TRUE), zoom = 1) %>%
    leaflet.extras::addFullscreenControl() %>%
      addLegend(position = 'topright', colors = c('red', 'blue'), labels = c('Meeting', 'No meeting'))
    # addDrawToolbar(
    #   targetGroup='draw',
    #   editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))  %>%
      # addLayersControl(overlayGroups = c('draw'), options =
      #                    layersControlOptions(collapsed=FALSE)) %>%
      # addStyleEditor()
    l
  })
  
  # Leaflet proxy for the points
  observeEvent(filtered_events(), {
    places <- filtered_events()
    
    popups <- paste0(places$Person, ' of the ', places$Organization,
                     ifelse(!is.na(places$Counterpart) &
                              places$Counterpart != '',
                            paste0(' meeting with ', 
                                   places$Counterpart,
                                   collapse = ' '),
                            ''
                            ),
                      
                     ' in ',
                     places$`City of visit`, ' on ', format(places$`Visit start`, '%B %d, %Y'))
    
    # Get faces
    faces_dir <- paste0('www/headshots/circles/')
    faces <- dir(faces_dir)
    faces <- data_frame(joiner = gsub('.png', '', faces, fixed = TRUE),
                        file = paste0(faces_dir, faces))
    
    # Create a join column
    faces$joiner <- ifelse(is.na(faces$joiner) | faces$joiner == 'NA', 
                           'Unknown', 
                           faces$joiner)
    places$joiner <- ifelse(places$Person %in% faces$joiner, 
                            places$Person,
                            'Unknown')
    
    message('nrow places ', nrow(places))
    message('nrow faces ', nrow(faces))
    # Join the files to the places data
    if(nrow(places) > 0){
      places <- 
        left_join(places,
                  faces,
                  by = 'joiner')
    } else {
      places <- events[0,]
    }
    face_icons <- icons(places$file,
                        iconWidth = 25, iconHeight = 25)
    
    # Define which are "events" vs not
    cols <- ifelse(is.na(places$Event) | 
                   places$Event == '',
                   'blue',
                   'red')
    
    
    ## plot the subsetted ata
    leafletProxy("leafy") %>%
      clearMarkers() %>%
      addCircleMarkers(data = places, lng =~Long, lat = ~Lat,
                       col = cols, radius = 14) %>%
      addMarkers(data = places, lng =~Long, lat = ~Lat,
                 popup = popups,
                 icon = face_icons) 
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
  
  output$graph <- renderForceNetwork({
    x <- filtered_events()
    show_graph <- FALSE
    if(!is.null(x)){
      if(nrow(x) > 0){
        show_graph <- TRUE
      }
    }
    if(show_graph){
      make_graph(events = x)
    } else {
      return(NULL)
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
                    Event,
                    # `City of visit`,
                    # `Country of visit`,
                    Counterpart,
                    `Visit start`,
                    `Visit end`)
    prettify(x,
             download_options = TRUE) %>%
      DT::formatStyle(columns = colnames(.), fontSize = '50%')
  })
  
  output$g_calendar <- renderGvis({
    
    fd <- the_dates()
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
                     width=400,
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
#    DT=vals$Data[vals$Data$state != "delete",-(which(names(vals$Data) %in% c("state","event_id","file")))] #SAH Display only valid data rows where state>-2 (ie, not flagged for delete) and only relevant column names
    
    #Removed from display those set for deletion, but now added back in because msesses with indexing by row number below. 
    #indexing should be set to event_id rather than row number to avoid re-sorting issues or permutations that offset row value
    DT=vals$Data[,-(which(names(vals$Data) %in% c("state","event_id","file")))] #SAH Display only valid data rows where state>-2 (ie, not flagged for delete) and only relevant column names
    
    DT[["Select"]]<-paste0('<input type="checkbox" name="row_selected" value="Row',1:nrow(vals$Data),'"><br>')
    
    DT[["Actions"]]<-
      paste0('
             <div class="btn-group" role="group" aria-label="Basic example">
             <button type="button" class="btn btn-secondary delete" id=delete_',1:nrow(vals$Data),'>Delete</button>
             <button type="button" class="btn btn-secondary modify" id=modify_',1:nrow(vals$Data),'>Modify</button>
             </div>
             
             ')

    datatable(DT,
              escape=F,
              options = list(scrollX = TRUE)) 
    
  
  })
  
  observeEvent(input$Add_row_head,{
    # new_row <-
    #   events[1,]
    new_row=data_frame(
      Person = 'Jane Doe',
      Organization = 'Organization',
      `City of visit` = 'Bermuda Triangle',
      `Country of visit` = 'International Waters',
      Counterpart = 'Jack Sparrow',
      `Visit start` = Sys.Date() - 3,
      `Visit end` = Sys.Date(),
      state="new") #SAH state -1=new
    new_row <- new_row %>%
      mutate(Lat = 31,
             Long = -65)
    new_row$Event <- 'Some event'
    vals$Data<-bind_rows(new_row,vals$Data)
  })
  
  
  observeEvent(input$Del_row_head,{
    row_to_del=as.numeric(gsub("Row","",input$checked_rows))
    vals$Data[row_to_del,"state"] <- "delete" #SAH
  })
  
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
                   vals$Data$state[row_to_del] <- "delete" #SAH
                 }
                 else if (input$lastClickId%like%"modify")
                 {
                   showModal(modal_modify)
                 }
               }
  )
  
  output$row_modif<-renderDataTable({
    selected_row=as.numeric(gsub("modify_","",input$lastClickId))
    old_row=vals$Data[selected_row,]
    old_row$state <- "modified" #SAH modified row state
    
    print("Call: output$row_modif :: old_row") #SAH
    print(old_row) #SAH
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
    hidden <- c("event_id","state")
    for (i in 1:length(colnames(old_row))){
      cn <- names(old_row)[i]
      #message(i)
      #message(cn)
      if (cn %in% hidden) #SAH: ID and state values aren't editable 
      {
        row_change[[i]]<-paste0('<input class="new_input" value="',copycat[1,cn],'" type="hidden" id=new_',cn,'>')
      }
      else if (is.numeric(vals$Data[[cn]])){
        #message('ok')
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
    row_change = bind_rows(row_change)
    setnames(row_change,colnames(old_row))
    print("Call: output$row_modif :: row_change") #SAH
    print(row_change) #SAH
    
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
                 new_classes <- lapply(vals$Data, class)
                 vals$Data[as.numeric(gsub("modify_","",input$lastClickId)),]<-DF
               })
  
  # On session end, close
  session$onSessionEnded(function() {
    message('Session ended. Closing the connection pool.')
    tryCatch(pool::poolClose(pool), error = function(e) {message('')})
  })
  
  }
message('Done defining server')

shinyApp(ui, server)