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
      icon=icon("eye")),
    menuItem(
      text="Edit data",
      tabName="edit_data",
      icon=icon("edit")),
    menuItem(
      text = 'About',
      tabName = 'about',
      icon = icon("cog", lib = "glyphicon"))
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
        fluidRow(div(img(src='partnership logo.bmp', align = "center"), style="text-align: center;"),
                 br(),
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
      uiOutput("MainBody"))
    
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
  vals <- reactiveValues()
  vals$Data<-filter_events(events = events,
                           visit_start = min(date_dictionary$date),
                           visit_end = max(date_dictionary$date))
  observeEvent(input$Del_row_head, {
    vals$Data <- vals$Data
  })

  # # observeEvent(filter_dates(),{
  # #   fd <- filter_dates()
  # #   print(fd)
  # #   ev <- vals$Data
  # #   print(head(ev))
  # #   # ev
  # #   vals$Data <- filter_events(events = ev,
  # #                              visit_start = fd[1],
  # #                              visit_end = fd[2])
  # #   print(head(vals$Data))
  # # })
  # observeEvent({input$search
  #   # filter_dates()
  #   }, {
  #   # fd <- filter_dates()
  #   message(fd)
  #   ev <- vals$Data
  #   vals$Data <- filter_events(events = ev,
  #                              # visit_start = fd[1],
  #                              # visit_end = fd[2],
  #                              search = input$search)
  # })
  filtered_events <- reactive({
    # x <- vals$Data
    fd <- filter_dates()
    x <- filter_events(events = vals$Data,
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
  
  output$MainBody<-renderUI({
    fluidPage(
      box(width=12,
          h3(strong("Create, modify, and delete travel events"),align="center"),
          hr(),
          column(6,offset = 6,
                 HTML('<div class="btn-group" role="group" aria-label="Basic example">'),
                 actionButton(inputId = "Add_row_head",label = "Add a new row"),
                 actionButton(inputId = "Del_row_head",label = "Delete selected rows"),
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
    new_row=data_frame(
      Person = 'Jane Doe',
      Organization = 'World Bank',
      `City of visit` = 'New York',
      `Country of visit` = 'United States',
      Counterpart = 'Donald Trump',
      `Visit start` = Sys.Date() - 3,
      `Visit end` = Sys.Date())
    new_row <- new_row %>%
      mutate(`Visit month` = format(`Visit start`, '%B')) %>%
      mutate(Lon = -74.00597,
             Lat = 40.71278)
    # place <- paste0(new_row$`City of visit`, ', ', new_row$`Country of visit`)
    # ll <- ggmap::geocode(location = place, output = 'latlon')
    # new_row$Long <- ll$lon
    # new_row$Lat <- ll$lat
    new_row$file <- 'headshots/circles/new.png'
    vals$Data<-bind_rows(new_row,vals$Data)
  })
  
  
  observeEvent(input$Del_row_head,{
    row_to_del=as.numeric(gsub("Row","",input$checked_rows))
    
    vals$Data=vals$Data[-row_to_del,]}
  )

  output$sales_plot<-renderPlot({
    require(ggplot2)
    ggplot(vals$fake_sales,aes(x=month,y=sales,color=Brands))+geom_line()
  })
  
  ##Managing in row deletion
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
    row_change=list()
    for (i in colnames(old_row)){
      # if(class(vals$Data[[i]])[1] == 'Date'){
      #   row_change[[i]]<-paste0('<input class="new_input" type="date" id=new_',i,'><br>')
      # } else 
        if (is.numeric(vals$Data[[i]]))
      {
        row_change[[i]]<-paste0('<input class="new_input" type="number" id=new_',i,'><br>')
      }
      else
        row_change[[i]]<-paste0('<input class="new_input" type="text" id=new_',i,'><br>')
    }
    row_change=as.data.table(row_change)
    setnames(row_change,colnames(old_row))
    for(j in which(the_dates)){
      old_row[,j] <- as.character(old_row[,j])
    }
    for(j in which(the_nums)){
      old_row[,j] <- as.character(old_row[,j])
    }
    DT=bind_rows(old_row,row_change)
    rownames(DT)<-c("Current values","New values")
    for(j in which(the_dates)){
      old_row[,j] <- as.Date(as.numeric(old_row[,j]), origin = '1970-01-01')
    }
    for(j in which(the_nums)){
      old_row[,j] <- as.numeric(old_row[,j])
    }
    
    DT
    
  },escape=F,options=list(dom='t',ordering=F),selection="none"
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
                 DF=data_frame(lapply(newValue, function(x) t(data_frame(x))))
                 colnames(DF)=colnames(vals$Data)
                 vals$Data[as.numeric(gsub("modify_","",input$lastClickId))]<-DF
                 
               }
  )
  
  
  }

shinyApp(ui, server)