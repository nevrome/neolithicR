#Reminder: starting app 
# library(shiny)
# runApp("modules/radiocarbon5/", launch.browser=TRUE)

#Reminder: push to shinyapps.io
# library(rsconnect)
# deployApp('modules/radiocarbon5/')

#Reminder: installing packages
# install.packages(c(
#   "magrittr", "dplyr", "shiny", "ggplot2", "gtools", "DT", "Bchron",
#   "leaflet", "maps", "mapproj", "devtools", "raster", "plyr", "shinyjs"
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

data(intcal13)

#### server output ####  

shinyServer(function(input, output, session) {

  # loading data
  load(file = "data/c14data2.RData")
  dates <- datestable
  load(file = "data/last_updated.RData")
  
  # render start message
  output$startmessage = renderPrint({
    HTML(
      "This tool allows to search, filter and visualize radiocarbon dates. ", 
      "The credit for the collection of the dates goes to the editors of the databases. ",
      "For reference see https://github.com/nevrome/neolithicR.",
      "<br>",
      "Last data update: ", paste(last_updated)
    )
  })
  
  # allow data update by user
  observeEvent(input$updatedb, {
    withCallingHandlers({
      shinyjs::html("Routput", "")
      
      message("<b>Update. This may take up to 30 minutes.</b>")
      
      datestable <- c14bazAAR::get_all_dates() %>%
        c14bazAAR::calibrate() %>%
        c14bazAAR::estimate_spatial_quality() %>%
        c14bazAAR::rm_doubles(mark = TRUE) %>%
        c14bazAAR::thesaurify() %>%
        dplyr::arrange(dplyr::desc(calage)) %>%
        dplyr::mutate(
          maincolor = rainbow(nrow(.), alpha = NULL, start = 0, end = 2/6)
        )
      
      save(datestable, file = "data/c14data2.RData")
      last_updated <- Sys.time()
      save(last_updated, file = "data/last_updated.RData") 
      
      message(
        "<font color = 'green'>
        <b>Done. Restart neolithicRC to work with the new data</b>
        </font>"
      )
    },
    message = function(m) {
      shinyjs::html(
        id = "c14bazAArout", 
        html = paste0(m$message, "<br>"), 
        add = TRUE)
    },
    warning = function(m) {
      shinyjs::html(
        id = "c14bazAArout", 
        html = paste0("<font color = 'red'>", m$message, "</font><br>"), 
        add = TRUE)
    }) 
  })
  
  # change to map view directly after start to preload map
  #updateTabsetPanel(session, "nav", selected = "Interactive map")
  
  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
    sel_country <- input$countryselect
    if(length(sel_country) != 0 && "ALL" %in% sel_country){
      sel_country <- unique(dates$country_thes)
    }
    
    sel_material <- input$materialselect
    if(length(sel_material) != 0 && "ALL" %in% sel_material){
      sel_material <- unique(dates$material_thes)
    } 
    
    labterm = input$labselect
    if (labterm != "") {
      lnv <- grep(paste("(", labterm, ")+", sep = ""), dates$labnr, ignore.case = TRUE)
      dates <- dates[lnv, ]
    }
    
    siteterm = input$siteselect
    if (siteterm != "") {
      sv <- grep(paste("(", siteterm, ")+", sep = ""), dates$site, ignore.case = TRUE)
      dates <- dates[sv, ]
    }

    culterm = input$culselect
    if (culterm != "") {
      pev <- grep(paste("(", culterm, ")+", sep = ""), dates$period, ignore.case = TRUE)
      cuv <- grep(paste("(", culterm, ")+", sep = ""), dates$culture, ignore.case = TRUE)
      pecuv <- unique(c(pev, cuv))
      dates <- dates[pecuv, ]
    }

    #selection of data (ui.R)
    dates <- dplyr::filter(
      dates,
      calage >= input$range[1] &
      calage <= input$range[2] &
      sourcedb %in% input$originselect &
      country_thes %in% sel_country & 
      material_thes %in% sel_material
    )

  })
  
  #rendering density plot of date selection
  output$datesdensity <- renderPlot({
    
      ggplot(datasetInput(), aes(x = calage)) +
        geom_rug() +
        geom_line(
          stat = "density",
          color = "red"
        ) + 
        xlim(min(datasetInput()$calage), max(datasetInput()$calage)) + 
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
    calplotc <- ggplot(datasetInput(), aes(x = calage, y = c14age)) +
      ggtitle("Calibration Overview") +
      xlab("calibrated Age BP") + 
      ylab("C14 Age BP") + 
      theme_bw() +
      xlim(min(datasetInput()$calage) - 200, max(datasetInput()$calage) + 200) +
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
        ylim(min(datasetInput()$c14age) - 200, max(datasetInput()$c14age) + 200)

      # plot with a small amount of dates  
      if (nrow(datasetInput()) < 200) {
        
        calplotc <- calplotc +
          geom_rug() +
          geom_errorbarh(aes(xmin = calage-calstd, xmax = calage+calstd), alpha = 0.3) +
          geom_errorbar(aes(ymin = c14age-c14std, ymax = c14age+c14std), alpha = 0.3)
     
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
        spatial_quality != "no coords",
        spatial_quality != "wrong coords"
      )  
      
      if (!input$doubtfulcheck){
        seldata <- filter(
          seldata,
          spatial_quality != "doubtful coords"  
        )
      }
      
      setProgress(value = 0.3)
      
      #text popup definition
      site.popup <- paste0(
        "<strong>Data Source: </strong>", 
        seldata$sourcedb, 
        "<br><strong>Site: </strong>", 
        seldata$site, 
        "<br><strong>Lab number: </strong>",
        seldata$labnr, 
        "<br><strong>Age: </strong>",
        seldata$calage, "calBP",
        "<br><strong>Reference: </strong>",
        seldata$shortref 
      )
      
      #preparation of mapping for shiny frontend
      mapres <- leaflet(seldata) %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att)  %>% 
        fitBounds(
          min(seldata$lon) - 1,
          min(seldata$lat) - 1,
          max(seldata$lon) + 1,
          max(seldata$lat) + 1
          ) %>% 
        addCircles(
          lat = seldata$lat, 
          lng = seldata$lon, 
          color = seldata$maincolor,
          radius = seldata$calage/2,
          popup = site.popup
        )    

      setProgress(value = 1)
      
      return(mapres)
    })
  })
  
  #render datatable, that shows the currently mapped dates
  output$radiodat = renderDataTable({
    
    tab <- datasetInput()[,c(
      "sourcedb", 
      "labnr", 
      "country_thes", 
      "site",
      "period",
      "culture",
      "material", 
      "calage", 
      "calstd",
      "shortref",
      "spatial_quality"
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
      sum(datasetInput()$spatial_quality == "possibly correct"), 
      " well mappable.")
  })
  
  output$originamounttext = renderPrint({
    linklist <- unique(datasetInput()$sourcedb) %>%
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
  
  # output$duplitext = renderPrint({
  #   
  #   adates <- datasetInput() %>% nrow
  #   ainddates <- datasetInput()$LABNR %>% unique %>% length
  #   
  #   if (adates != ainddates) {
  #     
  #     doubles <- datasetInput()[
  #       duplicated(datasetInput()$LABNR) |
  #       duplicated(datasetInput()$LABNR, fromLast = TRUE),
  #     ] 
  # 
  #     if (nrow(doubles) > 1000) {
  #       cat(">1000 dates (by LABNR) appear more than once.")
  #     } else {
  #       doubles %>%
  #         `[[`("LABNR") %>% 
  #         mapply(function(x){
  #           doubles[which(doubles$LABNR == x),] %>%
  #             `[[`("ORIGIN") %>% 
  #             unique %>%
  #             length %>%
  #             `>`(1)
  #         }, .) %>%
  #         which %>% 
  #         length -> dupli
  #       
  #       if (dupli == 0) {  
  #         cat("No dates (by LABNR) appear in more than one source database.") 
  #       } else {
  #         cat(dupli, " dates (by LABNR) appear in more than one source database.") 
  #       }
  #       
  #     }
  #   } else {
  #     cat("No dates (by LABNR) appear more than once.")
  #   } 
  # })
  
  output$spatqualtext = renderPrint({
    notcorr <- nrow(datasetInput()) - sum(datasetInput()$spatial_quality == "possibly correct")
    cat(notcorr, " dates have no or doubtful spatial information.")
  })
  
  output$mappingwarning = renderPrint({
    if (nrow(datasetInput()) > 1500) {
      cat("⚠ You've selected more than 1500 individual dates - depending on your browser and your internet connection that could be too many for mapping.")
    }
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
      #tab <- subset(datasetInput(), select=-c(COORDCOUNTRY, MAINCOLOR))
      tab <- datasetInput()
      
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