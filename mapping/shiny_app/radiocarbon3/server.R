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
library(ggplot2)


#### data preparation ####

#load dataset
#load dataset
Europe_complete <- read.csv("data/Europe_complete.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

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
  
  
  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
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
    
    #selection to defined period (ui.R)
    dates <- filter(
      dates, 
      SIMPERIOD %in% input$periodselect
    )
    
  })
  
  #rendering barplot of periods for output
  output$barplotperiod <- renderPlot({
    
    qplot(
      SIMPERIOD, 
      data=datasetInput(),
      geom = "histogram", 
      xlab = "", 
      ylab= "",
      main = "Period distribution of currently shown dates")
  
  })

 
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    #define sources of background map (static, then dynamic)
    tiles <- input$tiles
    att <- input$tiles
    
    if(input$type=="type1"){
      
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
      
    } else if(input$type=="type2"){
    
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
          lng = datasetInput()$LONGITUDE + datasetInput()$OFFSET, 
          color = datasetInput()$COLOR,
          radius = datasetInput()$CALAGE,
          popup = site.popup
        )
      
    }
    
  })
  
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable(
    options = list(pageLength = 5), 
    {
    
      #reduce data.frame to necessary information (LABNR, SITE, LATITUDE, LONGITUDE, CALAGE, REFERENCE)
      dates <- datasetInput()[,c(1:6)]
      
    }
  )
  
  
  #render datatable, that shows all dates
  output$radiodat_complete = renderDataTable(
    options = list(pageLength = 5), 
    {
  
      Europe_complete
               
    }
  )
  
  
  #render data-download
  output$downloadseldates = downloadHandler(
    filename = function() { 
      
      paste(
        "dateselection", 
        '.csv'
        ) 
      
      },
    content = function(file) {
      
      #reduce data.frame to necessary information (LABNR, SITE, CALAGE, REFERENCE)
      dates <- datasetInput()[,c(1,2,5,6)]
      
      write.table(
        dates, 
        file,
        dec = ".",
        sep='\t',
        col.names = TRUE,
        row.names=FALSE
      )
      
    }
  )

})