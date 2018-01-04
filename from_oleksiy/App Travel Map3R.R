# Oleksiy Anokhin
# January 2, 2018

# Travel Event Dashboard (Map Draft)

# Packages
library(shiny)
library(shinythemes)
library(leaflet)
library(rgdal)
library(tidyverse)
library(geojsonio)
library(RColorBrewer)
library(highcharter)
library(plotly)
library(ggplot2)
library(xlsx)

# Set directory
setwd("C:/DC/IFC/My Shiny apps/App Travel Map")

# Read csv, which was created specifically for this app
events<- read.csv("Fake events data1.csv", header = TRUE) 
names(events)

# Read a shapefile
countries <- readOGR(".","ne_50m_admin_0_countries")
countries$name

# Merge data
events.df <- merge(countries, events, by.x = "name", by.y = "Country.of.visit", duplicateGeoms = TRUE)
class(events.df) # "SpatialPolygonsDataFrame"


# UI code
ui <- shinyUI(fluidPage(theme = shinytheme("united"),
                        titlePanel(HTML(# "<h1><center><font size=14> 
                          "Travel Event Dashboard (Map Draft)"
                          #</font></center></h1>"
                        )), 
                        sidebarLayout(
                          sidebarPanel(
                            selectInput("personInput", "Person",
                                        choices = c("Choose person", 
                                                    "Jim Yong Kim",
                                                    "Kristalina Georgieva",
                                                    "Philippe Le Houerou",
                                                    "Paul Romer",
                                                    "Joaquim Levy"),
                                        selected = "Choose person"),
                            selectInput("organizationInput", "Organization",
                                        choices = c("Choose organization",  
                                                    "World Bank",
                                                    "IFC"),
                                        selected = "Choose organization"),
                            selectInput("cityInput", "City of visit",
                                        choices = c("Choose city",  
                                                    "Moscow",
                                                    "Berlin",
                                                    "Beijing",
                                                    "Kinshasa",
                                                    "New York",
                                                    "Brasilia",
                                                    "Johannesburg",
                                                    "London",
                                                    "Paris"),
                                        selected = "Choose city"),
                            selectInput("countryInput", "Country of visit",
                                        choices = c("Choose country",  
                                                    "Russia",
                                                    "Germany",
                                                    "China",
                                                    "Dem. Rep. Congo",
                                                    "United States",
                                                    "Brazil",
                                                    "South Africa",
                                                    "United Kingdom",
                                                    "France"),
                                        selected = "Choose country"),
                            selectInput("counterpartInput", "Counterpart",
                                        choices = c("Choose counterpart",  
                                                    "Vladimir Putin",
                                                    "Angela Merkel",
                                                    "Xi Jinping",
                                                    "Antonio Guterres",
                                                    "Donald Trump",
                                                    "Michel Temer",
                                                    "Michel Temer",
                                                    "Jacob Zuma",
                                                    "Theresa May",
                                                    "Emmanuel Macron"),
                                        selected = "Choose counterpart"),
                            
                            selectInput("monthInput", "Month",
                                        choices = c("Choose month",  
                                                    "January",
                                                    "February",
                                                    "March",
                                                    "April",
                                                    "May",
                                                    "June",
                                                    "July",
                                                    "August",
                                                    "September",
                                                    "October",
                                                    "November",
                                                    "December"),
                                        selected = "Choose month"),
                            dateRangeInput('dateRange',
                                           label = 'Date range input: yyyy-mm-dd',
                                           start = Sys.Date() - 2, end = Sys.Date() + 2)
                            
                          ),
                          
                          mainPanel(leafletOutput(outputId = 'map', height = 800) 
                          )
                        )
))

# SERVER

server <- shinyServer(function(input, output) {
  output$map <- renderLeaflet({
    leaflet(events.df) %>% 
      addProviderTiles(providers$Esri.WorldStreetMap) %>% 
      setView(11.0670977,0.912484, zoom = 4) # Change to global view in the best format
    
    
  })
  
  # Observers
  
  # Selected person
  selectedPerson <- reactive({
    tmp <- events.df[!is.na(events.df$Person),]
    tmp[tmp$Person == input$personInput, ] 
  })
  observe({
    
    leafletProxy("map", data = selectedPerson()) %>%
      clearMarkers() %>%
      addMarkers(~Long, ~Lat) 
    
  })

  # Selected organization
  selectedOrganization <- reactive({
    tmp1 <- events.df[!is.na(events.df$Organization),]
    tmp1[tmp1$Organization == input$organizationInput, ] 
  })
  
  observe({
    
    leafletProxy("map", data = selectedOrganization()) %>%
      clearMarkers() %>%
      addMarkers(~Long, ~Lat) 
  })   
    
    # Selected city
    selectedCity <- reactive({
      tmp2 <- events.df[!is.na(events.df$City.of.visit),]
      tmp2[tmp2$City.of.visit == input$cityInput, ] 
    })
    observe({
    
      leafletProxy("map", data = selectedCity()) %>%
        clearMarkers() %>%
        addMarkers(~Long, ~Lat) 
      
  })

    # Selected country
    selectedCountry <- reactive({
      #events.df[events.df$Country.of.visit == input$countryInput, ] 
      tmp3 <- events.df[!is.na(events.df$Country.of.visit),]
      tmp3[tmp3$Country.of.visit == input$countryInput, ] 
    })
    
    observe({
      
      leafletProxy("map", data = selectedCountry()) %>%
        clearMarkers() %>%
        addMarkers(~Long, ~Lat) 
      
    })     
    
    
    # Selected counterpart
    selectedCounterpart <- reactive({
      # events.df[events.df$Person == input$personInput, ] 
      tmp4 <- events.df[!is.na(events.df$Counterpart),]
      tmp4[tmp4$Counterpart == input$counterpartInput, ] 
    })
    
    observe({
      
      leafletProxy("map", data = selectedCounterpart()) %>%
        clearMarkers() %>%
        addMarkers(~Long, ~Lat) 
    
    })   
    
    # Selected month
    selectedMonth <- reactive({
      # events.df[events.df$Person == input$personInput, ] 
      tmp5 <- events.df[!is.na(events.df$Month),]
      tmp5[tmp5$Month == input$monthInput, ] 
    })
    
    observe({
      
      leafletProxy("map", data = selectedMonth()) %>%
        clearMarkers() %>%
        addMarkers(~Long, ~Lat) 
      
    })   
    
    
})


shinyApp(ui = ui, server = server)






