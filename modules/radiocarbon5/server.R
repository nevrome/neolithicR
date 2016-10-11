#Reminder: starting app 
# library(shiny)
# runApp("modules/radiocarbon5/", launch.browser=TRUE)

#Reminder: push to shinyapps.io
# library(rsconnect)
# deployApp('modules/radiocarbon5/')

#Reminder: installing packages
# install.packages(c("magrittr", "dplyr", "shiny", "ggplot2", "gtools", "DT", "Bchron", "maps", "mapproj", "devtools"))
# devtools::install_github("AnalytixWare/ShinySky")
# devtools::install_github("trestletech/ShinyDash")

#Reminder: push to vm
# scp -r -P PORTNUMBER /home/clemens/Rstats/neolithicR/modules/radiocarbon5/* USERNAME@134.2.2.137:/home/USERNAME/ShinyApps/neolithicRC/



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
library(shinysky)

#### loading data ####

load(file = "data/c14data.RData")
dates <- datestable
data(intcal13)

files <- list.files(path = "thesauri/", pattern='*.RData', recursive=T)
files = lapply(files, function(x) paste0('thesauri/', x))
lapply(files, load, .GlobalEnv)

#### server output ####  

shinyServer(function(input, output, session) {

  # change to map view directly after start to preload map
  #updateTabsetPanel(session, "nav", selected = "Interactive map")
  
  # send start message
  observe({
    session$sendCustomMessage(
        type = 'startmessage',
        message = 
        "This tool allows to search, filter and visualize radiocarbon dates. The credit for the collection of the dates goes to the editors of the databases aDRAC, CalPal-DB, EUROEVOL and RADON. For reference see https://github.com/nevrome/neolithicR"
      )
  })

  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
    country = input$countryselect
    if(length(country) != 0 && "ALL" %in% country){
      country = unique(dates$COUNTRY)
    } else if (length(country) != 0) {
      country = c(COUNTRY_thesaurus$var[COUNTRY_thesaurus$cor %in% country], country)
    }
    
    material = input$materialselect
    if(length(material) != 0 && "ALL" %in% material){
      material = unique(dates$MATERIAL)
    } else if (length(country) != 0) {
      material = c(MATERIAL_thesaurus$var[MATERIAL_thesaurus$cor %in% material], material)
    }
    
    labterm = input$labselect
    if (labterm != "") {
      lnv <- grep(paste("(", labterm, ")+", sep = ""), dates$LABNR, ignore.case = TRUE)
      dates <- dates[lnv,]
    }
    
    siteterm = input$siteselect
    if (siteterm != "") {
      sv <- grep(paste("(", siteterm, ")+", sep = ""), dates$SITE, ignore.case = TRUE)
      dates <- dates[sv,]
    }

    culterm = input$culselect
    if (culterm != "") {
      pev <- grep(paste("(", culterm, ")+", sep = ""), dates$PERIOD, ignore.case = TRUE)
      cuv <- grep(paste("(", culterm, ")+", sep = ""), dates$CULTURE, ignore.case = TRUE)
      pecuv <- unique(c(pev, cuv))
      dates <- dates[pecuv,]
    }

    #selection of data (ui.R)
    dates <- filter(
      dates,
      CALAGE >= input$range[1] &
      CALAGE <= input$range[2] &
      ORIGIN %in% input$originselect &
      COUNTRY %in% country & 
      MATERIAL %in% material
    )

  })
  
  # output$aDRAC <- renderUI({
  #   tags$a(href = "https://github.com/dirkseidensticker/aDRAC", "Github")
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
        xlim(min(datasetInput()$CALAGE), max(datasetInput()$CALAGE)) + 
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
      xlim(min(datasetInput()$CALAGE), max(datasetInput()$CALAGE)) +
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
  
  # # render density maps
  # output$datedens <- renderPlot({
  # 
  #   withProgress(message = '● Loading Plot', value = 0, {
  #     
  #     # select dataset by user choice
  #     if (input$mapsel == "cd") {
  #       dfp <- datestable
  #     } else if (input$mapsel == "cs") {
  #       dfp <- datasetInput()
  #     } else if (input$mapsel == "ca") {
  #       dfp <- filter(
  #         datestable, 
  #         ORIGIN == "aDRAC"
  #       )
  #     } else if (input$mapsel == "eu") {
  #       dfp <- filter(
  #         datestable, 
  #         ORIGIN == "EUROEVOL"
  #       )
  #     }
  #     
  #     # prepare map
  #     ggplot() +
  #       stat_density2d(
  #         data = dfp,
  #         aes(x = LONGITUDE, y = LATITUDE, size = ..density.., colour = ..density..),
  #         contour = FALSE,
  #         n = 200,
  #         geom = "point"
  #       ) +
  #       scale_colour_gradient(
  #         low = "white", high = "blue",
  #         guide = "colourbar"
  #       ) +
  #       guides(
  #         density = FALSE,
  #         size = FALSE
  #       ) +
  #       geom_polygon(
  #         data = map_data("world"),  
  #         aes(x = long, y = lat, group = group),
  #         alpha = 0, 
  #         colour = "grey"
  #       ) +
  #       coord_map(
  #         projection = "vandergrinten",
  #         xlim = c(min(dfp$LONGITUDE)-20, max(dfp$LONGITUDE)+20),
  #         ylim = c(min(dfp$LATITUDE)-2, max(dfp$LATITUDE)+2)
  #       ) +
  #       theme_bw()
  # 
  #   })
  #     
  # })
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    withProgress(message = '● Loading Map', value = 0, {

      #define sources (static, then dynamic)
      tiles <- input$tiles
      att <- "see Basemap settings"
      seldata <- datasetInput()
      
      seldata <- filter(
        seldata,
        SPATQUAL != "no coords",
        SPATQUAL != "wrong coords"
      )  
      
      if (!input$doubtfulcheck){
        seldata <- filter(
          seldata,
          SPATQUAL != "doubtful coords"  
        )
      }
      
      #text popup definition
      site.popup <- paste0(
        "<strong>Data Source: </strong>", 
        seldata$ORIGIN, 
        "<br><strong>Site: </strong>", 
        seldata$SITE, 
        "<br><strong>Lab number: </strong>",
        seldata$LABNR, 
        "<br><strong>Age: </strong>",
        seldata$CALAGE, "calBP",
        "<br><strong>Reference: </strong>",
        seldata$REFERENCE 
      )
      
      #preparation of mapping for shiny frontend
      leaflet(seldata) %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att)  %>% 
        fitBounds(
          min(seldata$LONGITUDE),
          min(seldata$LATITUDE),
          max(seldata$LONGITUDE)+10,
          max(seldata$LATITUDE)
          # -70, -35, 270, 65
          ) %>% 
        addCircles(
          lat = seldata$LATITUDE, 
          lng = seldata$LONGITUDE, 
          color = seldata$MAINCOLOR,
          radius = seldata$CALAGE*2,
          popup = site.popup
        )    

    })
  })
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable({
    
    tab <- datasetInput()[,c(
      "ORIGIN", 
      "LABNR", 
      "COUNTRY", 
      "SITE",
      "PERIOD",
      "CULTURE",
      "MATERIAL", 
      "CALAGE", 
      "CALSTD",
      "SPATQUAL"
    )]
      
    DT::datatable(tab)
    
  })
  
  #render textelement with number of dates
  output$numbertext = renderPrint({
    cat(nrow(datasetInput()), " of ", nrow(datestable), " dates are selected.")
  })
  
  output$originamounttext = renderPrint({
    unique(datasetInput()$ORIGIN)
    cat("The selected dates are from the source databases: ", unique(datasetInput()$ORIGIN, "."))
  })
  
  output$duplitext = renderPrint({
    dupli <- nrow(datasetInput()) - length(unique(datasetInput()$LABNR))
    cat(dupli, " dates appear in more than one source database.")
  })
  
  output$spatqualtext = renderPrint({
    notcorr <- nrow(datasetInput()) - sum(datasetInput()$SPATQUAL == "possibly correct")
    cat(notcorr, " dates have no or doubtful spatial information.")
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
      tab <- subset(datasetInput(), select=-c(COORDCOUNTRY, MAINCOLOR))
      
      write.table(
        tab, 
        file,
        dec = ".",
        sep = '\t',
        col.names = TRUE,
        row.names = FALSE,
        eol = "\n",
        qmethod = "double"
      )
      
    }
  )

})