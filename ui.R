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
                   h6('Pick the start/end dates for analysis of itineraries:',
                      align = 'center'),
                   uiOutput('datey'),
                   h6('Or set the date range using the below slider:',
                      align = 'center'),
                   uiOutput('dater'),
                   h6('Or click forward or back to move over time',
                      align = 'center'),
                   fluidRow(column(1,
                                   actionButton("action_back", "Back", icon = icon('arrow-circle-left'))),
                            column(4, NULL),
                            column(1,
                                   actionButton("action_forward", "Forward", icon=icon("arrow-circle-right")))),
                   
                   h6('Or click on any date below to jump around:',
                      align = 'center'),
                   htmlOutput('g_calendar'))
          ),
          column(1),
          column(6,
                 leafletOutput('leafy'),
                 fluidRow(column(3),
                          column(9,
                                 textInput('search',
                                           'Filter for people, places, organizations, etc.'))))),
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
        fluidRow(div(img(src='partnershiplogo.png', align = "center"), style="text-align: center;"),
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
