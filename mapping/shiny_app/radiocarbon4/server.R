#Reminder: starting app and push to shinyapps.io
#library(shiny)
#runApp("mapping/shiny_app/radiocarbon3/", launch.browser=TRUE)
#
#shinyapps::deployApp('mapping/shiny_app/radiocarbon4/')
#test url: http://127.0.0.1:3557/?period=Neolithic&period=Paleolithic&material=charcoal


#### loading libraries ####

library(shiny)
library(leaflet)
library(magrittr)
library(dplyr)
library(ggplot2)


#### data preparation ####

#load dataset
#load dataset
Europe.red0 <- read.csv("data/Europe.red0.csv", 
                        sep="\t", 
                        header=TRUE, 
                        row.names=1, 
                        stringsAsFactors = FALSE)


#### server output ####  

shinyServer(function(input, output, session) {
  
  #reactive dataset selection based on URL
  datasetInput <- reactive({
    
    dates <- Europe.red0
    
    query <- parseQueryString(session$clientData$url_search)
    
    periodquery <- unlist(query[names(query) == "period"], use.names = FALSE)
    
    dates <- filter(
      dates, 
      PERIOD %in% periodquery
    )
    
    materialquery <- unlist(query[names(query) == "material"], use.names = FALSE)
    
    dates <- filter(
      dates, 
      MATERIAL %in% materialquery
    )

  })
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    #define sources of background map (static, then dynamic)
    tiles <- "http://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}"
    att <- "ArcGIS World Physical Map"
    
    #text popup definition
      site.popup <- paste0(
        "<strong>Site: </strong>", 
        datasetInput()$SITE, 
        "<br><strong>Lab number: </strong>",
        datasetInput()$LABNR, 
        "<br><strong>Age: </strong>",
        datasetInput()$CALAGE, 
        "calBP",
        "<br><strong>Reference: </strong>",
        datasetInput()$REFERENCE 
      )
      
      #preparation of mapping for shiny frontend
      map = leaflet(datasetInput()) %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att) %>%  
        addCircles(
          lat = datasetInput()$LATITUDE, 
          lng = datasetInput()$LONGITUDE, 
          color = datasetInput()$MAINCOLOR,
          radius = datasetInput()$CALAGE,
          popup = site.popup
        )     
      
  }) 
  
})