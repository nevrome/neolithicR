#### loading libraries ####

library(leaflet)
library(ShinyDash)

#### definition of frontend output/input ####
shinyUI(
  navbarPage(
    "neolithicRC", 
    id="nav",
    
    tabPanel("Interactive map",
       
      div(class="outer",
         
         # Include custom CSS  
         tags$head(
           includeCSS("styles.css")
         ),
  
         #output of map
         leafletOutput(
           "radiocarbon", 
           width = "100%", 
           height = "100%"
         ),
         
         # Control Panel 1 (General)
         absolutePanel(
           id = "controls", 
           class = "panel panel-default", 
           fixed = TRUE, 
           draggable = TRUE, 
           top = 65, 
           left = "auto", 
           right = 10, 
           bottom = "auto",
           width = 600, 
           height = "auto",
           
           h3("NeolithicRC"),
           textOutput('numbertext'),
           
           fluidRow(
             
             column(8,
               #input checkbox     
               checkboxGroupInput(
                 "originselect", 
                 label = NULL,
                 list(
                   "CARD" = "CARD", 
                   "EuroEvol" = "EUROEVOL" #,
                   # "Radon" = "Radon",
                   # "Radon-b" = "Radon-b"
                 ),
                 selected = c(
                   "CARD",
                   "EUROEVOL"
                 ),
                 inline = TRUE
                )
             )
             
             # column(4,
             #  htmlOutput("card"),
             #  htmlOutput("euroevol"),
             #  htmlOutput("radon"),
             #  htmlOutput("radonb")
             # )

           ),
           
           #dates density plot
           plotOutput(
             "datesdensity", 
             height = "250px", 
             width = "100%"
           ),
          
           #period barplot output 
           plotOutput(
             "calplot", 
             height = "350px", 
             width = "100%"
           )
           
         ),
         
         # Control Panel 2 (Slider)
         absolutePanel(
           id = "controls", 
           class = "panel panel-default", 
           fixed = TRUE, 
           draggable = TRUE, 
           top = "90%", 
           left = "auto", 
           right = "27%", 
           bottom = "auto",
           width = "70%", 
           height = 100,
           
           # timeframe slider
           sliderInput(
             "range", 
             "calibrated age BP:", 
             width = "100%", 
             min = 0,
             max = 18000,
             step= 100,
             value = c(7000, 7500)
           )
         )
         
          
        
      )
    ),
  

    #output datatable
    tabPanel(
      'Datatable',
      
      #selection buttons and download
      downloadButton(
        'downloadseldates', 
        'Download current selection as tab separated .csv file'
      ),
      
      #datatable output
      dataTableOutput("radiodat")
    
    ),

    tabPanel(
      'Context maps',
      
      fluidRow(
      
        column(3, 
        
          selectInput("mapsel", "Select map", choices = c(
             "Complete dataset" = "cd",
             "Current data selection" = "cs",
             "CARD" = "ca",
             "EUROEVOL" = "eu"
            )
          )
          
        ),
        
        column(6, 
      
           helpText(
             "Density estimation maps for the different datasets and the current selection. Loading the maps takes some time."
           ),
           
           helpText(
             "Map projection is Van der Grinten."
           )     
               
        )
      
      ), 
      
      plotOutput(
          "datedens",
          height = "700px",
          width = "100%"
        )
      
    ),
    
    tabPanel(
      'Basemap settings',
      
      textInput(
        "tiles", 
        "Specify Basemap tile sources", 
        value = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
        width = 800
      ),
      
      a(href= "http://leaflet-extras.github.io/leaflet-providers/preview/", 
        "See http://leaflet-extras.github.io/leaflet-providers/preview/ for other setups."),
      helpText(
        "You can change the appearance of this map by replacing the tile source link above."
      )
        
    )
      
  )
    
)
  