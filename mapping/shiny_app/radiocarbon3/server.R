#Reminder: starting app and push to shinyapps.io
#library(shiny)
#runApp("mapping/shiny_app/radiocarbon3/", launch.browser=TRUE)
#
#shinyapps::deployApp('mapping/shiny_app/radiocarbon3/')


#### loading libraries ####

library(shiny)
library(leaflet)
library(magrittr)
library(dplyr)


#### data preparation ####

#load dataset
Europe.red1 <- read.csv("data/Europe.red1.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

Europe.red2 <- read.csv("data/Europe.red2.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

Europe.red3 <- read.csv("data/Europe.red3.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

youngoldsel1 <- read.csv("data/youngoldsel1.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

youngoldsel2 <- read.csv("data/youngoldsel2.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

youngoldsel3 <- read.csv("data/youngoldsel3.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)


#### server output ####  

shinyServer(function(input, output, session) {
 
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    #define sources of background map (static, then dynamic)
    tiles <- input$tiles
    att <- input$tiles
    
    if(input$type=="type1"){
      
      #switch to decide how to deal with oldest dates
      if (input$oldest=="youngoldsel1") {
        dates <- Europe.red1
      } else if (input$oldest=="youngoldsel2") {
        dates <- Europe.red2
      } else if (input$oldest=="youngoldsel3") {
        dates <- Europe.red3
      } 
      
      #selection to defined range (ui.R)
      dates <- filter(
        dates, CALAGE>=input$`range`[1], 
        CALAGE<=input$`range`[2]
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
          lng = dates$LONGITUDE, 
          color = dates$MAINCOLOR,
          radius = dates$CALAGE,
          popup = site.popup
        )      
      
    } else if(input$type=="type2"){
    
      #switch to decide how to deal with oldest dates
      if (input$oldest=="youngoldsel1") {
        dates <- youngoldsel1
      } else if (input$oldest=="youngoldsel2") {
        dates <- youngoldsel2
      } else if (input$oldest=="youngoldsel3") {
        dates <- youngoldsel3
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
        
        dates <- Europe.red1
        
        #selection to defined range (ui.R)
        dates <- filter(
          dates, CALAGE>=input$`range`[1], 
          CALAGE<=input$`range`[2]
        )
      
      } else if(input$type=="type2"){
      
        #switch to decide how to deal with oldest dates
        if (input$oldest=="youngoldsel1") {
          dates <- youngoldsel1
        } else if (input$oldest=="youngoldsel2") {
          dates <- youngoldsel2
        } else if (input$oldest=="youngoldsel3") {
          dates <- youngoldsel3
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