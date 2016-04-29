#### loading libraries ####

library(leaflet)
library(ShinyDash)

#### definition of frontend output/input ####
shinyUI(
  navbarPage(
    "neolithicRC - Search tool for radiocarbon dates", 
    id="nav",
    
    tabPanel("Search and Filter",
    
      fluidRow( 
        
        singleton(
          tags$head(tags$script(src = "message-handler.js"))
        ),
        
        column(3,
             
          select2Input(
            "originselect",
            "Data source selection",
            choices = unique(datestable$ORIGIN),
            selected = unique(datestable$ORIGIN),
            type = c("input"),
            width = "100%"
          ),
          
          select2Input(
            "countryselect",
            "Country selection",
            choices = unique(datestable$COUNTRY),
            select = c(),
            type = c("input"),
            width = "100%"
          )
          
        ),
        
        column(3,
          
         select2Input(
           "materialselect",
           "Material selection",
           choices = unique(datestable$MATERIAL),
           select = c(),
           type = c("input")
         ),
         
         select2Input(
           "speciesselect",
           "Species selection",
           choices = unique(datestable$SPECIES),
           type = c("input")
         )     
      
        ),
        
        column(3,
               
         textInput(
           "siteselect",
           "Site selection"
         ),
         
         select2Input(
           "periodselect",
           "Period/Culture selection",
           choices = c(unique(datestable$PERIOD), unique(datestable$CULTURE)),
           type = c("input")
         )
               
        ),
        
        column(3,
               
          textOutput('numbertext')
               
        )
        
      ),
      
      sliderInput(
        "range", 
        "calibrated age BP:", 
        width = "100%", 
        min = min(datestable$CALAGE),
        max = max(datestable$CALAGE),
        step= 100,
        value = c(min(datestable$CALAGE), max(datestable$CALAGE))
      ),
      
      #datatable output
      dataTableOutput("radiodat"),

      #selection buttons and download
      downloadButton(
        'downloadseldates', 
        'Download current selection as tab separated .csv file'
      )
            
    ),
    
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
           #textOutput('numbertext'),
           
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
           
         )
         
      )
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
  