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
        
        fluidRow(       
               
          sliderInput(
            "range", 
            "calibrated age BP:", 
            width = "100%", 
            min = 0,
            max = 18000,
            step= 100,
            value =c(5000,10000)
          )
        
        ),
        
        fluidRow(
        
          column(3,
                 
            #input switch
            radioButtons(
              "type", 
              "Type of visualisation:",
              list(
                "Type1: Show every date" = "type1",
                "Type2: Show oldest and youngest date" = "type2"
              ), 
              selected = "type1"
            ),
            
            #input switch
            radioButtons(
              "oldest", 
              "How to deal with the oldest dates?:",
              list(
                "Show all dates" = "youngoldsel1",
                "Remove oldest dates of each site and show second oldest dates" = "youngoldsel2",
                "Remove oldest and second oldest dates of each site and show third oldest dates" = "youngoldsel3"
              ) 
            )
            
          ),
          
          column(2,
            
            #input checkboxes     
            checkboxGroupInput(
              "periodselect", 
              "Select Period [experimental] (attribution inconsistent) ",
              list(
                "Palaeolithic" = "palaeolithic",
                "Epipalaeolithic" = "epipalaeolithic",
                "Neolithic" = "neolithic", 
                "Chalcolithic" = "chalcolithic",
                "Bronze age" = "bronzeage",
                "Iron age" = "ironage",
                "Egypt" = "egypt",
                "other" = "other"
                ),
              selected = c(
                "neolithic"
                )
              )
            
          )
          
        )
        
      ),
    
      #output datatable
      tabPanel(
        'Datatable (selection)',
        dataTableOutput(
          "radiodat"
          ),
        
        downloadButton(
          'downloadseldates', 
          'Download current selection as tab separated .csv file'
          )
      ),
      
      tabPanel(
        'Datatable (complete)',
        dataTableOutput("radiodat_complete")
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