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
    
    Europe_complete <- read.csv("data/Europe_complete.csv", 
                                sep="\t", 
                                header=TRUE, 
                                row.names=1, 
                                stringsAsFactors = FALSE)
    
    incProgress(1/3, detail = paste("Primary Data"))
    
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
    
    incProgress(2/3, detail = paste("Secondary Data"))
    
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
    
  })
  
  
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
        dates, 
        CALAGE>=input$`range`[1], 
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
    
    #selection to defined material (ui.R)
    dates <- filter(
      dates, 
      SIMMATERIAL %in% input$materialselect
    )
    
    #selection to defined country (ui.R)
    dates.country <- filter(
      dates, 
      SIMCOUNTRY %in% c(input$countryselect1, input$countryselect2)
    )

    #switch to activate country selection (ui.R)
    if (input$countrydecide) {
      dates.country
    } else {
      dates
    }
      
  })
  
  #select all dates button
  observe({
    if (input$selectall > 0) {
      updateCheckboxGroupInput(
        session = session, 
        inputId = "periodselect", 
        selected = periods
      )
      updateCheckboxGroupInput(
        session = session, 
        inputId = "materialselect", 
        selected = list(
          "Charcoal" = "charcoal",
          "Bone" = "bone",
          "Other" = "other",
          "???" = "nd")
      )
      updateCheckboxInput(
        session = session, 
        inputId = "countrydecide", 
        value = FALSE
      )
      updateSliderInput(
        session = session, 
        inputId = "range", 
        value = c(0, 18000)
      )
    }
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
  
  
  #rendering barplot of periods for output
  output$barplotperiod <- renderPlot({
    
    ggplot(datasetInput(), aes(SIMPERIOD)) +
      geom_bar() +
      ggtitle("Period distribution") +
      xlab("")+ 
      ylab("")
      
  })
  
  
  #rendering barplot of materials for output
  output$barplotmaterial <- renderPlot({
    
    ggplot(datasetInput(), aes(SIMMATERIAL)) +
      geom_bar() +
      ggtitle("Material distribution") +
      xlab("")+ 
      ylab("")
    
  })

 
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    withProgress(message = 'Loading Map', value = 0, {
    
      #define sources of background map (static, then dynamic)
      tiles <- input$tiles
      att <- "see Basemap settings"
      
      if(input$type=="type1"){
        
        manualsel <- input$radiodat_rows_selected
        
        if (length(manualsel) != 0){
          seldata <-datasetInput()[manualsel,]
        } else {
          seldata <-datasetInput()
        }
        
        
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
        
        incProgress(1, detail = paste("● Live Rendering"))
        
        #preparation of mapping for shiny frontend
        map = leaflet(seldata) %>% 
          addTiles(
            urlTemplate = tiles,
            attribution = att) %>%  
          addCircles(
            lat = seldata$LATITUDE, 
            lng = seldata$LONGITUDE, 
            color = seldata$MAINCOLOR,
            radius = seldata$CALAGE,
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
        
        incProgress(1, detail = paste("● Live Rendering")) 
        
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
    
  })
  
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable(
      DT::datatable(datasetInput()[,1:ncol(datasetInput())-1],
                    filter = 'top',
                    extensions = c('colVis', 'Responsive'),
                    options = list(pageLength = 10,
                                   lengthMenu = c(10, 20, 50, 100, nrow(datasetInput())),
                                   dom = 'C<"clear">lfrtip',
                                   colVis = list(exclude = c(0,1)))
                    #selection = list(selected = c(1, 3, 4, 6, 9))
      )
  )
  
  # render selection buttons for manual selection
  proxy = dataTableProxy('radiodat')
  
  observeEvent(input$clear1, {
    selectRows(proxy, NULL)
  })
  observeEvent(input$selall, {
    selectRows(proxy, input$radiodat_rows_all)
  })
  
  #render text output for manual selection
  output$selectiontext = renderPrint({
    s = datasetInput()[input$radiodat_rows_selected,]$LABNR
    if (length(s)) {
      cat('These dates were selected:\n')
      cat(s, sep = ', ')
    }
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