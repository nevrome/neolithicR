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
      tabPanel('Define timeframe',       
        sliderInput(
          "range", 
          "calibrated age BP:", 
          width = "100%", 
          min = 0,
          max = 18000,
          step= 100,
          value =c(9000,10000))
      ),
    
      #output datatable
      tabPanel(
        'Datatable',
        dataTableOutput("radiodat")
      )
      
    )
    
  )
  
)