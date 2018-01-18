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
                   '',
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
                "",
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
  # Replace data with uploaded data
  observeEvent(input$submit, {
    new_data <- uploaded()
    message('new data has ', nrow(new_data), ' rows')
    # Geocode the new data if applicable
    new_data <- geo_code(new_data)
    message('done geocoding')
    # Update the session
    vals$Data <- new_data
    message('overwrote vals$Data')
    print(nrow(vals$Data))
    # Update the underlying data (google sheets or database)
    if(use_google){
      # Write to a temp csv
      tf <- tempfile(fileext = '.csv')
      write_csv(new_data, tf)
      message('Writing new data to google')
      gs_upload(file = tf,
                sheet_title = 'Travel dashboard events - do not modify name or duplicate',
                verbose = TRUE,
                overwrite = TRUE)
    } else {
      message('Overwriting the database')
      # Overwrite the data
      dbWriteTable(pool, c("pd_wbgtravel", "events"), value = new_data, overwrite = TRUE, row.names = FALSE)
      message('Overwrote the database')
    }
  })
  
  # After modification is confirmed, update the data stores
  # (db or google)
  observeEvent(input$submit2, {
    message('Modification confirmed, geocoding and overwriting data.')
    new_data <- vals$Data
    # Geocode if applicable
    new_data <- geo_code(new_data)
    # Update the underlying data (google sheets or database)
    if(use_google){
      # Write to a temp csv
      tf <- tempfile(fileext = '.csv')
      write_csv(new_data, tf)
      message('Writing new data to google')
      gs_upload(file = tf,
                sheet_title = 'Travel dashboard events - do not modify name or duplicate',
                verbose = TRUE,
                overwrite = TRUE)
    } else {
      message('Overwriting the database')
      # Overwrite the data
      dbWriteTable(pool, c("pd_wbgtravel", "events"), value = new_data, overwrite = TRUE, row.names = FALSE)
      message('Overwrote the database')
    }
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
      setView(lng = mean(events$Long) - 5, lat = mean(events$Lat), zoom = 1)
    l
  })
  
  # Leaflet proxy for the points
  observeEvent(filtered_events(), {
    places <- filtered_events()
    
    popups <- paste0(places$Person, ' of the ', places$Organization, ' meeting with ', places$Counterpart, ' in ',
                     places$`City of visit`, ' on ', format(places$`Visit start`, '%B %d, %Y'))
    
    ## plot the subsetted ata
    leafletProxy("leafy") %>%
      clearMarkers() %>%
      addMarkers(data = places, lng =~Long, lat = ~Lat,
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
    DT=vals$Data
    DT[["Select"]]<-paste0('<input type="checkbox" name="row_selected" value="Row',1:nrow(vals$Data),'"><br>')
    
    DT[["Actions"]]<-
      paste0('
             <div class="btn-group" role="group" aria-label="Basic example">
             <button type="button" class="btn btn-secondary delete" id=delete_',1:nrow(vals$Data),'>Delete</button>
             <button type="button" class="btn btn-secondary modify"id=modify_',1:nrow(vals$Data),'>Modify</button>
             </div>
             
             ')
    datatable(DT,
              escape=F,
              options = list(scrollX = TRUE))}
      )
  
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
      `Visit end` = Sys.Date())
    new_row <- new_row %>%
      mutate(Lat = 31,
             Long = -65)
    new_row$Event <- 'Some event'
    vals$Data<-bind_rows(new_row,vals$Data)
  })
  
  
  observeEvent(input$Del_row_head,{
    row_to_del=as.numeric(gsub("Row","",input$checked_rows))
    vals$Data=vals$Data[-row_to_del,]}
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
                   vals$Data=vals$Data[-row_to_del,]
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
      cn <- names(old_row)[i]
      message(i)
      message(cn)
      if (is.numeric(vals$Data[[cn]])){
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
    message('Session ended.')
    pool::poolClose(pool)
  })
  
  }
message('Done defining server')
