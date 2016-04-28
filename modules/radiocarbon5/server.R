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
library(maps)
library(mapproj)


#### server output ####  

shinyServer(function(input, output, session) {

  load(file = "data/c14data.RData")
  
  dates <- datestable
  
  data(intcal13)

  
  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
    #selection to defined range (ui.R)
    dates <- filter(
      dates, 
      CALAGE >= input$range[1], 
      CALAGE <= input$range[2]
    )
    
    #selection of data origin (ui.R)
    dates <- filter(
      dates, 
      ORIGIN %in% input$originselect
    )

  })
  
  # output$card <- renderUI({
  #   tags$a(href = "https://github.com/dirkseidensticker/CARD", "Github")
  # })
  # 
  # output$euroevol <- renderUI({
  #   tags$a(href = "http://discovery.ucl.ac.uk/1469811/", "UCL")
  # })
  # 
  # output$radon <- renderUI({
  #   tags$a(href = "http://radon.ufg.uni-kiel.de/", "Uni Kiel")
  # })
  # 
  # output$radonb <- renderUI({
  #   tags$a(href = "http://radon-b.ufg.uni-kiel.de/", "Uni Kiel")
  # })
  
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
    
    # plot without data
    calplotc <- ggplot(datasetInput(), aes(x = CALAGE, y = C14AGE)) +
      ggtitle("Calibration Overview") +
      xlab("calibrated Age BP") + 
      ylab("C14 Age BP") + 
      theme_bw() +
      xlim(input$`range`[1], input$`range`[2]) +
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
    
    # plot with data
    if (nrow(datasetInput()) > 0) {  
      
      # plot with a big amount of dates
      calplotc <- calplotc +
      geom_point() +
      ylim(min(datasetInput()$C14AGE), max(datasetInput()$C14AGE))

      # plot with a small amount of dates  
      if (nrow(datasetInput()) < 200) {
        
        calplotc <- calplotc +
        geom_rug() +
        geom_errorbarh(aes(xmin = CALAGE-CALSTD, xmax = CALAGE+CALSTD), alpha = 0.3)
     
      }

    } 
    
    calplotc
      
  })
  
  # render density maps
  output$datedens <- renderPlot({
  
    withProgress(message = '● Loading Plot', value = 0, {
      
      # select dataset by user choice
      if (input$mapsel == "cd") {
        dfp <- datestable
      } else if (input$mapsel == "cs") {
        dfp <- datasetInput()
      } else if (input$mapsel == "ca") {
        dfp <- filter(
          datestable, 
          ORIGIN == "CARD"
        )
      } else if (input$mapsel == "eu") {
        dfp <- filter(
          datestable, 
          ORIGIN == "EUROEVOL"
        )
      }
      
      # prepare map
      ggplot() +
        stat_density2d(
          data = dfp,
          aes(x = LONGITUDE, y = LATITUDE, size = ..density.., colour = ..density..),
          contour = FALSE,
          n = 200,
          geom = "point"
        ) +
        scale_colour_gradient(
          low = "white", high = "blue",
          guide = "colourbar"
        ) +
        guides(
          density = FALSE,
          size = FALSE
        ) +
        geom_polygon(
          data = map_data("world"),  
          aes(x = long, y = lat, group = group),
          alpha = 0, 
          colour = "grey"
        ) +
        coord_map(
          projection = "vandergrinten",
          xlim = c(min(dfp$LONGITUDE)-20, max(dfp$LONGITUDE)+20),
          ylim = c(min(dfp$LATITUDE)-2, max(dfp$LATITUDE)+2)
        ) +
        theme_bw()

    })
      
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
        "<strong>Data Source: </strong>", 
        seldata$ORIGIN, 
        "<br><strong>Site: </strong>", 
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
          radius = ~CALAGE*2,
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