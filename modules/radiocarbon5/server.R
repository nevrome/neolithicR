#Reminder: starting app and push to shinyapps.io
# library(shiny)
# runApp("modules/radiocarbon5/", launch.browser=TRUE)
# library(rsconnect)
# deployApp('modules/radiocarbon5/')


#### loading libraries ####

library(shiny)
library(leaflet)
library(magrittr)
library(dplyr)
library(ggplot2)
library(gtools)
library(DT)
library(Bchron)


#### server output ####  

shinyServer(function(input, output, session) {

  #load data
  withProgress(message = 'Load Data', value = 0, {
    
    load(file = "data/c14data.RData")
    dates <- datestable
    
    data(intcal13)
    
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
    
    withProgress(message = '● Loading Density Plot', value = 0, {
    
      ggplot(datasetInput(), aes(x = CALAGE)) +
        geom_rug() +
        geom_line(
          stat = "density",
          color = "red"
        ) + 
        xlim(
          input$`range`[1], 
          input$`range`[2]
        ) + 
        labs(
          y = "",
          x = "calibrated Age BP"
        ) +
        ggtitle("Density of date selection") +
        theme_bw()
      
    })
      
  })
  
  
  #rendering calibration plot for output
  output$calplot <- renderPlot({
    
    ggplot(datasetInput(), aes(x = CALAGE, y = C14AGE)) +
      geom_point() +
      geom_rug() +
      geom_errorbarh(aes(xmin = CALAGE-CALSTD, xmax = CALAGE+CALSTD), alpha = 0.3) +
      ggtitle("Calibration Overview") +
      xlab("calibrated Age BP") + 
      ylab("C14 Age BP") + 
      theme_bw() +
      # coord_cartesian(
      #   xlim = c(min(datasetInput()$CALAGE), max(datasetInput()$CALAGE)),
      #   ylim = c(min(datasetInput()$C14AGE), max(datasetInput()$C14AGE))
      # ) +
      xlim(input$`range`[1], input$`range`[2]) +
      ylim(min(datasetInput()$C14AGE), max(datasetInput()$C14AGE)) +
      geom_smooth(data = intcal13, aes(y = X46401, x = X50000), color = "darkgreen") +
      annotate(
        "text", x = Inf, y = -Inf, hjust = 1.1, vjust = -5, 
        label = "Spline based on IntCal13", 
        size = 5, color = "darkgreen"
      ) +      
      annotate(
        "text", x = Inf, y = -Inf, hjust = 1.1, vjust = -3, 
        label = "www.radiocarbon.org", 
        size = 5, color = "darkgreen"
      )
      
      
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
          -70,
          -75,
          270,
         65
          )

      })
  })
  
  observe({
    
    withProgress(message = '● Rendering Map', value = 0, {
    
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
          color = ~MAINCOLOR,
          radius = ~CALAGE,
          popup = site.popup
        )    
    
    })
  
  })
  
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable({
    
    tab <- datasetInput()[,c("ORIGIN", "LABNR", "SITE", "CALAGE", "CALSTD")]
      
    DT::datatable(tab)
    
  })
  
  #render textelement with number of dates
  output$numbertext = renderPrint({
    cat(nrow(datasetInput()), " of ", nrow(datestable), " dates are selected")
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