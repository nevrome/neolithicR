#Reminder: starting app and push to shinyapps.io
#library(shiny)
#runApp("mapping/shiny_app/radiocarbon3/", launch.browser=TRUE)
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
oldest.dates1 <- do.call(rbind, oldest.dates1)
#Add offset column with values for the oldest graves
oldest.dates1 <- data.frame(oldest.dates1, OFFSET=-0.05, COLOR="#990033")

#reduce the date selection to the youngest date of each site
youngest.dates1 <- lapply(
  split(matrix.red2, matrix.red2$SITE), 
  function(x) {
    x[which.min(x$CALAGE), c(1:6)]
  }
)
youngest.dates2 <- do.call(rbind, youngest.dates1)
#Add offset column with values for the oldest graves
youngest.dates2 <- data.frame(youngest.dates2, OFFSET=0.05, COLOR="#3058e5")

#create a combined list with the oldest and the youngest dates of the site
dates1 <- rbind(oldest.dates1, youngest.dates2)

#remove the oldest dates from the dataset
matrix.red3 <- matrix.red2[!(matrix.red2$LABNR %in% oldest.dates1$LABNR),]

#reduce the date selection to the second oldest date of each site
oldest.dates2 <- lapply(
  split(matrix.red3, matrix.red3$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates2 <- do.call(rbind, oldest.dates2)
#Add offset column with values for the oldest graves
oldest.dates2 <- data.frame(oldest.dates2, OFFSET=-0.05, COLOR="#FF3300")

dates2 <- rbind(oldest.dates2, youngest.dates2)

#remove the oldest dates from the dataset again
matrix.red4 <- matrix.red3[!(matrix.red3$LABNR %in% oldest.dates2$LABNR),]

#reduce the date selection to the third oldest date of each site
oldest.dates3 <- lapply(
  split(matrix.red4, matrix.red4$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates3 <- do.call(rbind, oldest.dates3)
#Add offset column with values for the oldest graves
oldest.dates3 <- data.frame(oldest.dates3, OFFSET=-0.05, COLOR="#FF33CC")

dates3 <- rbind(oldest.dates3, youngest.dates2)


#### server output ####  

shinyServer(function(input, output, session) {

  #define sources of background map
  tiles <- "http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
  att <- 'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    #switch to decide how to deal with oldest dates
    if (input$oldest=="dates1") {
      dates <- dates1
    } else if (input$oldest=="dates2") {
      dates <- dates2
    } else if (input$oldest=="dates3") {
      dates <- dates3
    }    
    
    #selection to defined range (ui.R)
    dates <- filter(dates, CALAGE>=input$`range`[1], CALAGE<=input$`range`[2])
   
    #sort dates by age
    #dates <- dates[order(dates$CALAGE, decreasing = TRUE),]
    
    #text popup definition
    site.popup <- paste0(
      "<strong>Site: </strong>", 
      dates$SITE, 
      "<br><strong>Lab number: </strong>",
      dates$LABNR, 
      "<br><strong>Age: </strong>",
      dates$CALAGE, 
      "calBP",
      "<br><strong>Reference: </strong>",
      dates$REFERENCE 
    )
    
    #preparation of mapping for shiny frontend
    map = leaflet(dates) %>% 
      addTiles(
        urlTemplate = tiles,
        attribution = att) %>%  
      addCircles(
        lat = dates$LATITUDE, 
        lng = dates$LONGITUDE + dates$OFFSET, 
        color = dates$COLOR,
        radius = dates$CALAGE,
        popup = site.popup
      )     
  })
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable(
    options = list(pageLength = 10), 
    {filter(dates, CALAGE>=input$`range`[1], CALAGE<=input$`range`[2])}
  )

})