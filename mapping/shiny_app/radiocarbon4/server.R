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
Europe.red1 <- read.csv("data/Europe.red1.csv", 
                        sep="\t", 
                        header=TRUE, 
                        row.names=1, 
                        stringsAsFactors = FALSE)


#### server output ####  

shinyServer(function(input, output, session) {
  
  #reactive dataset selection based on URL
  datasetInput <- reactive({
    
    if (session$clientData$url_search == "") {
      
      dates <- Europe.red1
      
    } else {
      
      dates <- Europe.red1
      
      #get request from URL
      query <- parseQueryString(session$clientData$url_search)
  
      #period filter
      periodquery <- c(unlist(query[names(query) == "period"], use.names = FALSE))
      
      if (!is.null(periodquery)) {
        dates <- filter(
          dates, 
          PERIOD %in% periodquery
        )
      }
      
      #material filter
      materialquery <- c(unlist(query[names(query) == "material"], use.names = FALSE))
      
      if (!is.null(materialquery)) {
        dates <- filter(
          dates, 
          MATERIAL %in% materialquery
        )
      }
      
      #spezies filter
      speciesquery <- c(unlist(query[names(query) == "species"], use.names = FALSE))
      
      if (!is.null(speciesquery)) {
        dates <- filter(
          dates, 
          SPECIES %in% speciesquery
        )
      }
      
      #country filter
#       countryquery <- c(unlist(query[names(query) == "country"], use.names = FALSE))
#       
#       if (!is.null(countryquery)) {
#         dates <- filter(
#           dates, 
#           COUNTRY %in% countryquery
#         )
#       }
      
      #site filter
      sitequery <- c(unlist(query[names(query) == "site"], use.names = FALSE))
      
      if (!is.null(sitequery)) {
        dates <- filter(
          dates, 
          SITE %in% sitequery
        )
      }
      
      dates
    }
  })
  
  
  output$urlText <- renderText({
    paste(sep = "",
          "search: ",   session$clientData$url_search,   "\n",
          "number of results: ", nrow(datasetInput()), "\n"
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