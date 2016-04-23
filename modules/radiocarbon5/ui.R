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
           top = 60, 
           left = "auto", 
           right = 20, 
           bottom = "auto",
           width = 330, 
           height = "auto",
           
           h2("neolithicRC")
           
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
             value = c(300, 1000)
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

    #Analysis
    tabPanel(
      'Analysis (selection)',
      
      fluidRow(
        
        #dates density plot
        plotOutput(
          "datesdensity", 
          height = "200px", 
          width = "100%"
        )
        
      ),
      
      fluidRow(
        
        column(6,
        
          #period barplot output 
          plotOutput(
            "barplotcountry", 
            height = "400px", 
            width = "100%"
          )
          
        ),
        
        column(6,
               
          #material barplot output 
          plotOutput(
            "barplotmaterial", 
            height = "400px", 
            width = "100%"
          )
          
        )
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
  