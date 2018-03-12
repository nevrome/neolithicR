#### Reminders ####

## General hints: 

# start app: 
# library(shiny) 
# runApp("modules/radiocarbon5/", launch.browser=TRUE)

# push to shinyapps.io:
# library(rsconnect)
# deployApp()

# install all necessary packages:
# automagic::make_deps_file()
# automagic::automagic()

## Setup on server 134.2.24.118 

# traditional setup: 
# push data: scp -r -P PORTNUMBER /home/clemens/Rstats/neolithicR/* USERNAME@134.2.2.137:/home/USERNAME/ShinyApps/neolithicRC/
# restart server: sudo systemctl restart shiny-server 
# config file: /etc/shiny-server/shiny-server.conf

# docker setup:
# build docker container: docker build -t neol .
# run docker container: docker run --name neo -d -p 3838:3838 neol
# install docker on CentOS: https://docs.docker.com/install/linux/docker-ce/centos/#upgrade-docker-ce
# install and run docker container from dockerhub: docker run --restart=always --name neolithicrc -d -p 3838:3838 nevrome/neolithicr

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
library(rgdal)
library(raster)
library(plyr)
library(ShinyDash)
library(sodium)

#### loading data ####

data(intcal13)

#### helper functions ####

prep_dataset <- function() {
  c14bazAAR::get_all_dates() %>%
    # dplyr::sample_n(500) %>%
    # c14bazAAR::as.c14_date_list() %>%
    c14bazAAR::mark_duplicates() %>%
    c14bazAAR::classify_material() %>%
    c14bazAAR::coordinate_precision() %>%
    c14bazAAR::finalize_country_name() %>% 
    c14bazAAR::calibrate(choices = c("probdist", "sigmarange")) %>%
    dplyr::arrange(dplyr::desc(c14age)) %>%
    return()
}

#### server output ####  

shinyServer(function(input, output, session) {

  
  # loading data
  shiny::withProgress(message = 'Loading data...', value = 0, {
    shiny::incProgress(0.1)
    last_updated <- "<font color = 'red'><b>not available - please update</b></font>"
    if (file.exists("data/c14data2.RData") & file.exists("data/last_updated.RData")) {
      load(file = "data/c14data2.RData")
      dates <- datestable
      load(file = "data/last_updated.RData")
    }
    shiny::incProgress(1)
  })
  
  # render start message
  output$startmessage = renderPrint({
    HTML("<font color = 'red'><b>Last data update: </b></font>", paste(last_updated))
  })
  
  # update riddle to hide update button
  output$updateriddle <- renderUI({
    list(
      HTML("You can rebuild the database if you know the secret passphrase:"),
      passwordInput("updateriddleanswer", NULL)
    )
  })
  
  # secret passphrase encrypted by sodium::password_store()
  passphrase <- "$7$C6..../....KJmqQLQZdPEkNIEf7L65NGM6JZx5awzmpsrk3sFk7E2$Dv893Y6Eu8HVUoIrtV1PQ2v4.oRbv7kzG9z4c9tKjlC"
  
  # hide user update button on condition
  output$updatebutton <- renderUI({
    if (!is.null(input$updateriddleanswer)) {
      if(sodium::password_verify(passphrase, input$updateriddleanswer)) {
        return(actionButton("updatedb", "Update neolithicRC local database"))
      }
    }
  })
  
  # allow data update by user
  observeEvent({input$updatedb}, {
    shiny::withProgress(message = 'Updating database...', value = 0, {
      withCallingHandlers({
        
        shinyjs::html("Routput", "")
        
        message("
          <b>Install latest version of c14bazAAR (from 
          <a href = 'https://github.com/ISAAKiel/c14bazAAR/'>github.com/ISAAKiel/c14bazAAR</a>)
          and all its dependencies.</b>")
        
        devtools::install_github(
          "ISAAKiel/c14bazAAR",
          dependencies = TRUE,
          upgrade_dependencies = TRUE,
          force = TRUE,
          force_deps = TRUE,
          quick = TRUE,
          quiet = TRUE
        )
        
        shiny::incProgress(0.2)
        
        message("<b>Update internal database. This may take up to 30 minutes.</b>")
        
        datestable <- prep_dataset()
        
        shiny::incProgress(0.9)
        
        save(datestable, file = "data/c14data2.RData")
        last_updated <- Sys.time()
        save(last_updated, file = "data/last_updated.RData") 
        
        dates <- datestable
        
        shiny::incProgress(1)
        
        message(
          "<font color = 'green'>
          <b>Done. <a href=\"javascript:history.go(0)\"> Restart neolithicRC to work with the new data ↻</a></b>
          </font>"
        )
      },
      message = function(m) {
        shinyjs::html(
          id = "c14bazAArout", 
          html = paste0(crayon::strip_style(m$message), "<br>"), 
          add = TRUE)
      },
      warning = function(m) {
        shinyjs::html(
          id = "c14bazAArout", 
          html = paste0("<font color = 'red'>", m$message, "</font><br>"), 
          add = TRUE)
      }) 
    })
  })
  
  #### render controls ####
  
  output$sourcedb_selection <- renderUI({
    select2Input(
      "originselect",
      "Data source selection",
      choices = unique(dates$sourcedb),
      selected = unique(dates$sourcedb),
      type = c("input"),
      width = "100%"
    )
  })
  
  output$country_selection <- renderUI({
    select2Input(
      "countryselect",
      "Country selection",
      choices = sort(unique(dates$country_final)),
      type = c("input"),
      width = "100%"
    )
  })
  
  output$material_selection <- renderUI({
    select2Input(
      "materialselect",
      "Material selection",
      choices = sort(unique(dates$material_thes)),
      type = c("input")
    ) 
  })
  
  output$age_slider <- renderUI({
    sliderInput(
      "range", 
      "uncalibrated age BP:", 
      width = "100%", 
      min = min(dates$c14age, na.rm = TRUE),
      max = max(dates$c14age, na.rm = TRUE),
      step= 10,
      value = c(min(dates$c14age), max(dates$c14age))
    )
  })
  
  # change to map view directly after start to preload map
  #updateTabsetPanel(session, "nav", selected = "Interactive map")
  
  #reactive dataset selection based on user choice 
  datasetInput <- reactive({
    
    # wait for input to load
    req(
      input$originselect,
      input$range
    )
    
    # prepare input
    sel_country <- input$countryselect
    if(length(sel_country) == 0){
      sel_country <- unique(dates$country_final)
    }
    
    sel_material <- input$materialselect
    if(length(sel_material) == 0){
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

    # preselection for dates with no age: 
    # only include them if the user didn't make any concious age selection
    # or: only apply normal filter if the user makes any decision
    if (min(dates$c14age, na.rm = TRUE) != input$range[1] | 
        max(dates$c14age, na.rm = TRUE) != input$range[2]) {
      dates <- dates %>% dplyr::filter(
        c14age >= input$range[1] & c14age <= input$range[2]
      )
    }
    
    # selection of data
    dates <- dplyr::filter(
      dates,
      sourcedb %in% input$originselect &
      country_final %in% sel_country & 
      material_thes %in% sel_material
    )

  })
  
  #rendering calibration plot for output
  output$calplot <- renderPlot({
    
    # data prep
    date_segments <- datasetInput() %>%
      dplyr::select(c14age, calrange) %>%
      dplyr::filter(purrr::map_lgl(calrange, function(x){nrow(x) > 0})) %>%
      tidyr::unnest()

    date_dens <- datasetInput() %>%
      dplyr::select(calprobdistr) %>%
      dplyr::filter(purrr::map_lgl(calprobdistr, function(x){nrow(x) > 0})) %>%
      tidyr::unnest() %>%
      dplyr::group_by(calage) %>%
      dplyr::summarise(dens = sum(density))    
    
    # density sum plot
    dens_sum_plot <- ggplot(date_dens, aes(x = calage, y = dens)) +
      geom_line(
        color = "red"
      ) + 
      labs(
        y = "",
        x = "calibrated Age BP"
      ) +
      scale_x_reverse(limits = c(max(date_dens$calage), min(date_dens$calage))) +
      ggtitle("Density sum of date selection") +
      theme_bw()
    
    # calibration plot
    cal_plot <- ggplot() +
      ggtitle("Calibration Overview") +
      xlab("calibrated Age BP") + 
      ylab("C14 Age BP") + 
      theme_bw() +
      geom_smooth(data = intcal13, aes(y = V2, x = V1), color = "darkgreen") +
      scale_x_reverse(limits = c(max(date_dens$calage), min(date_dens$calage))) +
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
    
    # add data
    if (nrow(dates) > 0) {  
      
      cal_plot <- cal_plot +
        geom_segment(
          aes(
            x = from,
            y = c14age,
            xend = to,
            yend = c14age
          ),
          data = date_segments
        ) +
        #ylim(min(date_segments$c14age) - 200, max(date_segments$c14age) + 200) +
        geom_rug(aes(y = c14age), data = date_segments)
      
    } 
    
    grid::grid.newpage()
    grid::grid.draw(rbind(ggplotGrob(dens_sum_plot), ggplotGrob(cal_plot), size = "last"))
      
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
    
    withProgress(message = 'Loading map...', value = 0, {

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
        !is.na(lat) & !is.na(lon)
      )  
      
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
        seldata$c14age, "calBP",
        "<br><strong>Reference: </strong>",
        seldata$shortref 
      )
      
      #preparation of mapping for shiny frontend
      mapres <- leaflet(seldata) %>% 
        addTiles(
          urlTemplate = tiles,
          attribution = att)  %>% 
        addMarkers(
          lat = seldata$lat, 
          lng = seldata$lon, 
          popup = site.popup,
          clusterOptions = markerClusterOptions()
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
      "c14age",
      "c14std",
      "lat",
      "lon",
      "country_final", 
      "site",
      "period",
      "culture",
      "material_thes", 
      "shortref",
      "duplicate_group"
    )]
      
    DT::datatable(tab) # %>%
      # DT::formatStyle(
      #   'duplicate_group',
      #   'duplicate_group',
      #   backgroundColor = DT::styleEqual(
      #     unique(tab$duplicate_group), 
      #     ifelse(
      #       is.na(unique(tab$duplicate_group)),
      #       "white",
      #       "red"
      #     )
      #   )
      # )
    
  })
  
  #render textelements
  output$numbertext = renderPrint({
    cat(nrow(datasetInput()), " of ", nrow(dates), " dates are selected.")
  })
  
  output$numbertext2 = renderPrint({
    cat(nrow(datasetInput()), " selected")
  })
  
  output$originamounttext = renderPrint({
    linklist <- unique(datasetInput()$sourcedb) %>%
      mapvalues(
        from = c("AustArch", "14SEA", "RADON", "RADON-B", "aDRAC", "EUROEVOL", "CALPAL", "CONTEXT", "KITEeastafrica"),
        to = c(
          "<a href = 'https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJLNRJ'>KITEeastafrica</a>",
          "<a href = 'http://archaeologydataservice.ac.uk/archives/view/austarch_na_2014/'>AustArch</a>",
          "<a href = 'http://www.14sea.org/'>14SEA</a>",
          "<a href = 'http://radon.ufg.uni-kiel.de/'>RADON</a>",
          "<a href = 'http://radon-b.ufg.uni-kiel.de/'>RADON-B</a>",
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
    HTML(
      sum(!is.na(datasetInput()$duplicate_group)),
      " of these dates are duplicates. Their labnr appears more than once."
    )
  })
  
  output$mappingwarning = renderPrint({
    if (nrow(datasetInput()) > 10000) {
      cat("⚠ You've selected more than 10000 individual dates - depending on your browser and your internet connection that could cause neolithicRC to react pretty slowly.")
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
      
      # remove list columns
      tab <- datasetInput() %>% dplyr::select(
        -calprobdistr, -calrange, -sigma
      )

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