#Reminder: starting app and push to shinyapps.io
#library(shiny)
#runApp("mapping/shiny_app/radiocarbon1/", launch.browser=TRUE)
#
#shinyapps::deployApp('mapping/shiny_app/radiocarbon2/')


#### loading libraries ####

library(shiny)
library(leaflet)
library(magrittr)
library(dplyr)


#### data preparation ####

#load dataset
matrix <- read.csv("Europe.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

#reduce main data.frame to necessary information for mapping (LABNR, SITE, LATITUDE, LONGITUDE, CALAGE, REFERENCE)
matrix.red1 <- matrix[,c(1,8,13,14,16,18)]

#replace "," by "." in the position columns
matrix.red1$LATITUDE <- chartr(old=",",new=".",x=matrix.red1$LATITUDE)
matrix.red1$LONGITUDE <- chartr(old=",",new=".",x=matrix.red1$LONGITUDE)

#convert values in position colums to numeric
matrix.red1$LATITUDE <- as.numeric(matrix.red1$LATITUDE)
matrix.red1$LONGITUDE <- as.numeric(matrix.red1$LONGITUDE)

#remove radiocarbon dates without age information or position
matrix.red2 <- filter(matrix.red1, matrix.red1$CALAGE!="0") 
matrix.red2 <- filter(matrix.red2, matrix.red2$LONGITUDE!="0" & matrix.red2$LATITUDE!="0")

#reduce the date selection to the oldest date of each site
oldest.dates1 <- lapply(
  split(matrix.red2, matrix.red2$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates2 <- do.call(rbind, oldest.dates1)


#### server output ####  

shinyServer(function(input, output, session) {

  #define sources of background map
  tiles <- "http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
  att <- 'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    #selection to defined range (ui.R)
    oldest.dates3 <- filter(oldest.dates2, CALAGE>=input$`range`[1], CALAGE<=input$`range`[2])
    
    #sort dates by age
    oldest.dates3 <- oldest.dates3[order(oldest.dates3$CALAGE, decreasing = TRUE),]
    
    #text popup definition
    site.popup <- paste0(
      "<strong>Site: </strong>", 
      oldest.dates3$SITE, 
      "<br><strong>Lab number: </strong>",
      oldest.dates3$LABNR, 
      "<br><strong>Age: </strong>",
      oldest.dates3$CALAGE, 
      "calBP",
      "<br><strong>Reference: </strong>",
      oldest.dates3$REFERENCE 
    )
    
    #preparation of mapping for shiny frontend
    map = leaflet(oldest.dates3) %>% 
      addTiles(
        urlTemplate = tiles,
        attribution = att) %>%  
      addCircles(
        lat = ~ LATITUDE, 
        lng = ~ LONGITUDE, 
        color = "blue",
        radius = 8000,
        popup = site.popup
      )
    
  })
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable(
    options = list(pageLength = 10), 
    {filter(oldest.dates2, CALAGE>=input$`range`[1], CALAGE<=input$`range`[2])}
  )

})