#### loading libraries ####

library(leaflet)
library(ShinyDash)


#### definition of frontend output/input ####

shinyUI(
  
  fluidPage(
    
    #output of map
    leafletOutput(
      "radiocarbon", 
      width = "100%", 
      height = "400px"
    ),
  
    #define presentation area
    tabsetPanel(
      
      #input slider
      tabPanel('Plot settings',       
        sliderInput(
          "range", 
          "calibrated age BP:", 
          width = "100%", 
          min = 0,
          max = 18000,
          step= 100,
          value =c(9000,10000)
        ),
        
        #input switch
        radioButtons(
          "type", 
          "Type of visualisation:",
          list(
            "Type1: Show every date" = "type1",
            "Type2: Show oldest and youngest date" = "type2"
          ), 
          selected = "type2"
        ),
        
        #input switch
        radioButtons(
          "oldest", 
          "How to deal with the oldest dates in Type2?:",
          list(
            "Oldest Dates" = "youngoldsel1",
            "Second Oldest Dates" = "youngoldsel2",
            "Third Oldest Dates" = "youngoldsel3"
          ) 
        )
        
      ),
    
      #output datatable
      tabPanel(
        'Datatable',
        dataTableOutput("radiodat")
      ),
      
      #output datatable
      tabPanel(
        'Basemap settings',
        
        textInput(
          "tiles", 
          "Specify Basemap tile sources", 
          value = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}"
        ),
        
        a(
          href="http://leaflet-extras.github.io/leaflet-providers/preview/", "See http://leaflet-extras.github.io/leaflet-providers/preview/ for other setups."
          ),
        helpText(
          "You can change the appearance of this map by replacing the tile source link above."
        )
        
      )
      
    )
    
  )
  
)