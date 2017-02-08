#Reminder: starting app 
# library(shiny)
# runApp("modules/radiocarbon5/", launch.browser=TRUE)

#Reminder: push to shinyapps.io
# library(rsconnect)
# deployApp('modules/radiocarbon5/')

#Reminder: installing packages
# install.packages(c(
#   "magrittr", "dplyr", "shiny", "ggplot2", "gtools", "DT", "Bchron",
#   "leaflet", "maps", "mapproj", "devtools", "raster", "plyr"
# ), repos = "http://cran.uni-muenster.de/")
# library(devtools)
# devtools::install_github("AnalytixWare/ShinySky")
# devtools::install_github("trestletech/ShinyDash")

#Reminder: push to vm
# scp -r -P PORTNUMBER /home/clemens/Rstats/neolithicR/modules/radiocarbon5/* USERNAME@134.2.2.137:/home/USERNAME/ShinyApps/neolithicRC/

#Reminder: restart shiny server
# sudo systemctl restart shiny-server 

#### loading libraries ####

library(shiny)
library(leaflet)
library(magrittr)
library(ggplot2)
library(gtools)
library(DT)
library(Bchron)
library(maps)
library(mapproj)
library(shinysky)
library(dplyr)
library(raster)
library(plyr)

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
        "This tool allows to search, filter and visualize radiocarbon dates. The credit for the collection of the dates goes to the editors of the databases aDRAC, CalPal, EUROEVOL, RADON and CONTEXT. For reference see https://github.com/nevrome/neolithicR. - Last data update: 08.02.2017"
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
  
  #rendering density plot of date selection
  output$datesdensity <- renderPlot({
    
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
        scale_x_reverse() +
        ggtitle("Density of date selection") +
        theme_bw()

  })
  
  
  #rendering calibration plot for output
  output$calplot <- renderPlot({
    
    # plot without data
    calplotc <- ggplot(datasetInput(), aes(x = CALAGE, y = C14AGE)) +
      ggtitle("Calibration Overview") +
      xlab("calibrated Age BP") + 
      ylab("C14 Age BP") + 
      theme_bw() +
      xlim(min(datasetInput()$CALAGE) - 200, max(datasetInput()$CALAGE) + 200) +
      geom_smooth(data = intcal13, aes(y = V2, x = V1), color = "darkgreen") +
      scale_x_reverse() +
      annotate(
        "text", x = Inf, y = -Inf, hjust = -0.2, vjust = -5, 
        label = "Spline based on IntCal13", 
        size = 5, color = "darkgreen"
      ) +      
      annotate(
        "text", x = Inf, y = -Inf, hjust = -0.3, vjust = -3, 
        label = "www.radiocarbon.org", 
        size = 5, color = "darkgreen"
      )
    
    # plot with data
    if (nrow(datasetInput()) > 0) {  
      
      # plot with a big amount of dates
      calplotc <- calplotc +
        geom_point() +
        ylim(min(datasetInput()$C14AGE) - 200, max(datasetInput()$C14AGE) + 200)

      # plot with a small amount of dates  
      if (nrow(datasetInput()) < 200) {
        
        calplotc <- calplotc +
          geom_rug() +
          geom_errorbarh(aes(xmin = CALAGE-CALSTD, xmax = CALAGE+CALSTD), alpha = 0.3) +
          geom_errorbar(aes(ymin = C14AGE-C14STD, ymax = C14AGE+C14STD), alpha = 0.3)
     
      }

    } 
    
    calplotc
      
  })
  
  # prepare the pictures for the basemap select input
  mapurl <- session$registerDataObj(
    
    name = 'basemapselection',
    data = NULL,
    
    filter = function(data, req) {
      
      query <- parseQueryString(req$QUERY_STRING)
      base <- query$base  
      
      # save picture to a temporary PNG file
      image <- tempfile()
      tryCatch({
        png(image, width = 200, height = 100, bg = 'transparent')
          paste0("data/images/", base) %>%  
            brick %>%
            plotRGB
      }, finally = dev.off())
      
      # send the PNG image back in a response
      shiny:::httpResponse(
        200, 'image/png', readBin(image, 'raw', file.info(image)[, 'size'])
      )
      
    }
  )
  
  # update the render function for the basemap select input
  updateSelectizeInput(
    session, 'basemapselect', server = TRUE,
    choices = c(
      "Esri.WorldImagery",
      "Esri.WorldPhysical",
      "Esri.NatGeoWorldMap",
      "OpenTopoMap",
      "OpenMapSurfer.Roads"
    ),
    selected = "Esri.WorldImagery",
    options = list(render = I(sprintf(
      "{
          option: function(item, escape) {
            return '<div><img width=\"100\" height=\"50\" ' +
                'src=\"%s&base=' + escape(item.value) + '\" />' +
                escape(item.value) + '</div>';
          }
      }",
      mapurl
    )))
  )
  
  #rendering the map file for output
  output$radiocarbon = renderLeaflet({
    
    withProgress(message = '● Loading Map', value = 0, {

      # tile source switch
      tiles <- switch(
        input$basemapselect,
        "Esri.WorldImagery" = {"http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"},
        "Esri.WorldPhysical" = {"https://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}"},
        "OpenTopoMap" = {"http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"},
        "OpenMapSurfer.Roads" = {"http://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}"},
        "Esri.NatGeoWorldMap" = {"http://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/{z}/{y}/{x}"}
      )

      #define sources (static, then dynamic)
      att <- ""
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
      
      setProgress(value = 0.3)
      
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
      mapres <- leaflet(seldata) %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att)  %>% 
        fitBounds(
          min(seldata$LONGITUDE) - 1,
          min(seldata$LATITUDE) - 1,
          max(seldata$LONGITUDE) + 1,
          max(seldata$LATITUDE) + 1
          ) %>% 
        addCircles(
          lat = seldata$LATITUDE, 
          lng = seldata$LONGITUDE, 
          color = seldata$MAINCOLOR,
          radius = seldata$CALAGE/2,
          popup = site.popup
        )    

      setProgress(value = 1)
      
      return(mapres)
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
      "REFERENCE",
      "SPATQUAL"
    )]
      
    DT::datatable(tab)
    
  })
  
  #render textelements
  output$numbertext = renderPrint({
    cat(nrow(datasetInput()), " of ", nrow(datestable), " dates are selected.")
  })
  
  output$numbertext2 = renderPrint({
    cat(nrow(
      datasetInput()), " selected and", 
      sum(datasetInput()$SPATQUAL == "possibly correct"), 
      " well mappable.")
  })
  
  output$originamounttext = renderPrint({
    linklist <- unique(datasetInput()$ORIGIN) %>%
      mapvalues(
        from = c("RADON", "aDRAC", "EUROEVOL", "CALPAL", "CONTEXT"),
        to = c(
          "<a href = 'http://radon.ufg.uni-kiel.de/'>RADON</a>",
          "<a href = 'https://github.com/dirkseidensticker/aDRAC'>aDRAC</a>",
          "<a href = 'http://discovery.ucl.ac.uk/1469811/'>EUROEVOL</a>",
          "<a href = 'https://uni-koeln.academia.edu/BernhardWeninger/CalPal'>CALPAL</a>",
          "<a href = 'http://context-database.uni-koeln.de'>CONTEXT</a>"
        ),
        warn_missing = FALSE
      )
    
    HTML(
      "The selected dates are from the following source databases: ", 
      "<br>",
      paste(linklist, collapse = ' ')
    )
  })
  
  output$duplitext = renderPrint({
    dupli <- nrow(datasetInput()) - length(unique(datasetInput()$LABNR))
    cat(dupli, " dates appear in more than one source database.")
  })
  
  output$spatqualtext = renderPrint({
    notcorr <- nrow(datasetInput()) - sum(datasetInput()$SPATQUAL == "possibly correct")
    cat(notcorr, " dates have no or doubtful spatial information.")
  })
  
  output$link = renderPrint({
     HTML("<a href = 'http://leaflet-extras.github.io/leaflet-providers/preview/'>tile source list</a>")
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