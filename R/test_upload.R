# Should be run from parent directory (traveldash)

library(openxlsx)
library(RPostgreSQL)
library(yaml)
library(pool)
library(lubridate)
library(magick)


# Define whether on Joe's computer (dev) or elsewhere (prod)
joe <- grepl('joebrew', getwd())

if(joe){
  dir <- getwd()
} else {
  dir <- paste0(dirname(path.expand("~")),"/WBG/Sinja Buri - FIG SSA MEL/MEL Program Operations/Knowledge Products/Dashboards & Viz/WBG Travel/GitHub/traveldash")
  setwd(dir)
}

# Source helper files
functions <- dir('R')
for(i in 1:length(functions)) 
{
  if (functions[i]=="test_upload.R") next 
  else source(paste0('R/', functions[i]), chdir = TRUE) 
}

test_upload <- function()
{
  pool <- create_pool(options_list = credentials_extract(),F)
  
  file <- paste0(getwd(),"/dev_database/Travel_Event_Dashboard_DATA_06_Mar.xlsx")
  ##file <- paste0(getwd(),"/dev_database/Travel Event Dashboard_DATA_20 Feb.xlsx")
  
  data <- read.xlsx(file,sheet=1,startRow=2,detectDates=F)
  
  LOGGED_IN_USER_ID <- 1 
  
  start_time <- Sys.time()
  upload_results <- upload_raw_data(pool=pool,data=data,logged_in_user_id=LOGGED_IN_USER_ID,return_upload_results = TRUE)
  end_time <- Sys.time()
  
  print(paste0("Database upload time: ", end_time - start_time))
  
  
  template <- paste0(getwd(),"/dev_database/TEMPLATE_WBG_traveldash.xlsx")
  
  conn <- poolCheckout(pool)
  
  download_results <- dbGetQuery(conn,paste0('select short_name as "Person", organization as "Organization",
                                             city_name as "City", country_name as "Country", trip_start_date as "Start", trip_end_date as "End",
                                             trip_group as "Trip Group", coalesce(event_title,venue_name) as "Venue", meeting_person_short_names as "Meeting",
                                             agenda as "Agenda", null as "CMD", trip_uid as "ID"
                                             from pd_wbgtravel.view_all_trips_people_meetings_venues where user_id = ',LOGGED_IN_USER_ID,';')) 
  
  poolReturn(conn)
  #Sys.setenv("R_ZIPCMD" = "C:/Program Files/R/Rtools/bin/zip.exe")
  workbook <- openxlsx::loadWorkbook(file=template)
  openxlsx::writeData(workbook,sheet="Travel Event Dashboard DATA",x=download_results,startCol=1,startRow=3,colNames=F,rowNames=F)
  openxlsx::saveWorkbook(workbook,paste0("WBG Travel Event Dashboard DATA-",today(),".xlsx"),overwrite= T)
  
}

test_image <- function()
{
  
  png(tf <- tempfile(fileext = ".png"), 1000, 1000)
  par(mar = rep(0,4), yaxs="i", xaxs="i", bg="transparent")
  plot(0, type = "n", ylim = c(0,1), xlim=c(0,1), axes=F, xlab=NA, ylab=NA)
  plotrix::draw.circle(.5,0.5,.5, col="gray")
  dev.off()
  
  
  img_mm_url <- "https://www.disneyclips.com/imagesnewb/images/mickeyface.gif"
  img_mm_url <- "http://akns-images.eonline.com/eol_images/Entire_Site/201808/rs_1024x759-180108174835-1024.donald-trump.ct.010818.jpg"
  img_mm <- image_read(path=img_mm_url)
  
  mask <- image_read(tf)
  size <- min(image_info(img_mm)$width,image_info(img_mm)$height)
  mask <- image_scale(mask, as.character(size))
  
  circle_img <- image_composite(mask, img_mm, "in") 
  circle_img <- image_scale(circle_img,"150")
  
  
  
  pool <- create_pool(options_list = credentials_extract(),F)
  start_time <- Sys.time()
  
  conn <- poolCheckout(pool)
  
  person_id <- dbGetQuery(conn,"insert into pd_wbgtravel.people(short_name,title,organization,is_wbg) 
                          values('Mickey Mouse','Mr.','Walt Disney Co.',0)
                          on conflict(short_name,organization) do update SET short_name=excluded.short_name
                          returning person_id;")
  person_id <- as.numeric(person_id)
  
  img_data <- image_data(circle_img)
  img_bytes <- serialize(img_data,NULL,ascii=F); 
  dbSendQuery(conn,"update pd_wbgtravel.people set image_data = $1 where person_id = $2",
              params=list(image_data=postgresqlEscapeBytea(conn, img_bytes),person_id = person_id))
  
  img <- dbGetQuery(conn,"select image_data from pd_wbgtravel.people where person_id = $1",list(person_id = person_id))
  img <- postgresqlUnescapeBytea(img)
  img <- unserialize(img)
  
  end_time <- Sys.time()
  
  print(paste0("Database upload/download time: ", end_time - start_time))
  
  img <- image_read(img)
  
  image_write(circle_img,path="./mickeymouse.png",format="png")
  
  poolReturn(conn)
  
  return (img)
}

library(shiny)

ui <- shinyUI(bootstrapPage(
  tags$script(type="text/javascript", "function dragend(event) 
              {
              var crop = document.getElementById('crop')
              document.is_drag=false;  
              document.getElementById('cropX').value = Number(crop.style.backgroundPositionX.replace('px',''))
              document.getElementById('cropY').value = Number(crop.style.backgroundPositionY.replace('px',''))
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
  
  sliderInput(inputId="scale",label="Resize",min=1,max=100,step=1,value=100),
  textInput(inputId='img_url', 'Image Url',value='https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Official_Portrait_of_President_Donald_Trump.jpg/1200px-Official_Portrait_of_President_Donald_Trump.jpg'),
  uiOutput('person'),
  textInput(inputId="cropX","Crop X",value="0"),
  textInput(inputId="cropY","Crop Y",value="0"),
  actionButton("button_crop", "Crop & Save")
  ))

#https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Official_Portrait_of_President_Donald_Trump.jpg/1200px-Official_Portrait_of_President_Donald_Trump.jpg

png(filename="www/mask-circle.png", 300, 300, units="px")
par(mar = rep(0,4), yaxs="i", xaxs="i", bg="transparent")
plot(0, type = "n", ylim = c(0,1), xlim=c(0,1), axes=F, xlab=NA, ylab=NA)
plotrix::draw.circle(.5,0.5,.5, col="gray")
dev.off()

png(filename="www/mask-square.png", 300, 300, units="px")
par(mar = rep(0,4), yaxs="i", xaxs="i", bg="black")
plot(0, type = "n", ylim = c(0,1), xlim=c(0,1), axes=F, xlab=NA, ylab=NA)
dev.off()

maskc <- image_read("www/mask-circle.png")
masks <- image_read("www/mask-square.png")

mask <- image_composite(maskc, masks, "out") 
image_write(mask,path="www/mask.png")

resourcepath <- paste0(getwd(),"/www")
server <- shinyServer(function(input, output, session) {
  
  addResourcePath("www", resourcepath)
  
  observeEvent(input$button_crop, ({
    <<<<<<< HEAD
    img_url <- gsub("\\s","",input$img_url)
    
    =======
      img_url <- input$img_url    
    >>>>>>> 4c261543d46082b567efcc4a73f62bbcd3bce459
    if (is.null(img_url) || img_url=="") return(NULL)
    
    scale = as.numeric(input$scale)
    cropX = as.numeric(input$cropX)
    cropY = as.numeric(input$cropY)
    <<<<<<< HEAD
    =======
      img_url <- gsub("\\s","",img_url)
    >>>>>>> 4c261543d46082b567efcc4a73f62bbcd3bce459
    
    size <- min(image_info(mask)$width,image_info(mask)$height)
    
    
    print(paste0("Resize: ",scale,"% X:",cropX," Y:",cropY))
    
    img_ob <- image_read(path=img_url)
    xscale <- ceiling(image_info(img_ob)$width * (as.numeric(scale))/100)
    yscale <- ceiling(image_info(img_ob)$height * (as.numeric(scale))/100)
    
    img_ob_r <- image_resize(img_ob,geometry=geometry_size_pixels(width=xscale,height=NULL,preserve_aspect = TRUE))
    img_ob_c <- image_crop(img_ob_r,geometry=geometry_area(x_off=cropX,y_off=cropY))
    
    
    circle_img <- image_composite(mask, img_ob_c, "out") 
    
    image_write(circle_img,path="www/circle_img.png")
    
  }))
  output$person <- renderUI({
    
    
    scale <- input$scale
    print(paste("Scale: ",scale))
    img_url <- gsub("\\s","",input$img_url)
    print(paste('Rendering image [ ',img_url,' ]'))
    if (is.null(img_url) || img_url=="") return(NULL)
    img_ob <- image_read(path=img_url)
    xscale <- ceiling(image_info(img_ob)$width * (as.numeric(scale))/100)
    yscale <- ceiling(image_info(img_ob)$height * (as.numeric(scale))/100)
    
    html<- list(
      HTML(paste0("<p>Uploaded Image</p>
                  <img src='/www/mask.png'
                  id='crop' name='crop' 
                  onmousedown=\"dragstart(event);\" 
                  onmouseup=\"dragend(event);\" 
                  onmousemove=\"dodrag(event);\" 
                  style=\"z-index:-1;background-image:url('",img_url,"');
                  background-repeat: no-repeat;background-size:",xscale,"px ",yscale,"px;\" width='300px';>"))
    )
    
    print(html)
    return (html)
  })
})
shinyApp(ui = ui, server = server)
