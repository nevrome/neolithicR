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
library(gtools)
library(DT)


#### server output ####  

shinyServer(function(input, output, session) {

  #load data
  withProgress(message = 'Load Data', value = 0, {
    
    load(file = "data/c14data.RData")
    
  })
  
  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
    #selection to defined range (ui.R)
    dates <- filter(
      dates, 
      CALAGE >= input$range[1], 
      CALAGE <= input$range[2]
    )

  })
  
  #rendering density plot of date selection
  output$datesdensity <- renderPlot({
    
    withProgress(message = 'Loading Density Plot', value = 0, {
    
      ggplot(
        datasetInput(),
        aes(x = CALAGE)
      ) +
        geom_line(
          stat = "density"
        ) + 
        geom_point(
          aes(
            x = CALAGE, 
            y = 0,
            shape = 'barcode'
            ),
          size = 3
        ) +
        scale_shape_manual(
          values = c("barcode" = 124),
          guide = FALSE
        ) +
        xlim(
          input$`range`[1]-700, 
          input$`range`[2]+700
        ) +
        labs(
          y = "Density",
          x = "calibrated Age BP"
        ) +
        ggtitle("Density of date selection")
      
    })
      
  })
  
  
  #rendering barplot of countries for output
  output$barplotcountry <- renderPlot({
    
    ggplot(datasetInput(), aes(COUNTRY)) +
      geom_bar() +
      ggtitle("Country distribution") +
      xlab("") + 
      ylab("") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
      
  })
  
  
  #rendering barplot of materials for output
  output$barplotmaterial <- renderPlot({
    
    ggplot(datasetInput(), aes(MATERIAL)) +
      geom_bar() +
      ggtitle("Material distribution") +
      xlab("") + 
      ylab("") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
    
  })

 
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    withProgress(message = ' ', value = 0, {
    
      #define sources (static, then dynamic)
      tiles <- input$tiles
      att <- "see Basemap settings"
      #seldata <- datasetInput()
      
      #preparation of mapping for shiny frontend
      map = leaflet() %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att)  %>% 
        fitBounds(
          # min(seldata$LONGITUDE),
          # min(seldata$LATITUDE),
          # max(seldata$LONGITUDE),
          # max(seldata$LATITUDE)
          -150,
          -70,
          150,
          70
          )

      })
  })
  
  observe({
    
    #withProgress(message = '● Live Rendering', value = 0, {
    
      seldata <- datasetInput()
      
      #text popup definition
      site.popup <- paste0(
        "<strong>Site: </strong>", 
        seldata$SITE, 
        "<br><strong>Lab number: </strong>",
        seldata$LABNR, 
        "<br><strong>Age: </strong>",
        seldata$CALAGE, 
        "calBP",
        "<br><strong>Reference: </strong>",
        seldata$REFERENCE 
      )
      
      leafletProxy("radiocarbon", data = seldata) %>%
        clearShapes() %>%
        addCircles(
          lat = ~LATITUDE, 
          lng = ~LONGITUDE, 
          #color = seldata$MAINCOLOR,
          radius = ~CALAGE,
          popup = site.popup
        )    
    
    #})
  
  })
  
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable({
    
    tab <- datestable[,c("ORIGIN", "LABNR", "SITE", "CALAGE", "CALSTD")]
      
    DT::datatable(tab)
    
  })
  
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
      tab <- datestable[,c("ORIGIN", "LABNR", "SITE", "CALAGE", "CALSTD")]
      
      write.table(
        tab, 
        file,
        dec = ".",
        sep='\t',
        col.names = TRUE,
        row.names = FALSE,
        eol = "\n"
      )
      
    }
  )

})