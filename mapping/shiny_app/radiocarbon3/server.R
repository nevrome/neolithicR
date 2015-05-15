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
Europe <- read.csv("Europe.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

dates1 <- read.csv("dates1.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

dates2 <- read.csv("dates2.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

dates3 <- read.csv("dates3.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)


#### server output ####  

shinyServer(function(input, output, session) {

  #define sources of background map
  tiles <- "http://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}"
  att <- 'Tiles &copy; Esri &mdash; Source: US National Park Service'
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    if(input$type=="type1"){
      
      dates <- Europe
      
      #selection to defined range (ui.R)
      dates <- filter(
        dates, CALAGE>=input$`range`[1], 
        CALAGE<=input$`range`[2]
        )
      
      #sort dates by age
      dates <- dates[order(dates$CALAGE),]
      
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
          lng = dates$LONGITUDE, 
          color = "green",
          radius = dates$CALAGE*3,
          popup = site.popup
        )      
      
    } else if(input$type=="type2"){
    
      #switch to decide how to deal with oldest dates
      if (input$oldest=="dates1") {
        dates <- dates1
      } else if (input$oldest=="dates2") {
        dates <- dates2
      } else if (input$oldest=="dates3") {
        dates <- dates3
      }    
      
      #selection to defined range (ui.R)
      dates <- filter(
        dates, 
        CALAGE>=input$`range`[1] | PARTNERAGE>=input$`range`[1], 
        CALAGE<=input$`range`[2] | PARTNERAGE<=input$`range`[2]
      )
     
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
      
    }
    
  })
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable(
    options = list(pageLength = 10), 
    {
    
      if(input$type=="type1"){
        
        dates <- Europe
        
        #selection to defined range (ui.R)
        dates <- filter(
          dates, CALAGE>=input$`range`[1], 
          CALAGE<=input$`range`[2]
        )
      
      } else if(input$type=="type2"){
      
        #switch to decide how to deal with oldest dates
        if (input$oldest=="dates1") {
          dates <- dates1
        } else if (input$oldest=="dates2") {
          dates <- dates2
        } else if (input$oldest=="dates3") {
          dates <- dates3
        }    
        
        #selection to defined range (ui.R)
        dates <- filter(
          dates, 
          CALAGE>=input$`range`[1] | PARTNERAGE>=input$`range`[1], 
          CALAGE<=input$`range`[2] | PARTNERAGE<=input$`range`[2]
        )
        
      }
      
    }
  )

})