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
      tabPanel('Settings',       
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
          "oldest", 
          "How to deal with the oldest dates?:",
          list(
            "Oldest Dates" = "dates1",
            "Second Oldest Dates" = "dates2",
            "Third Oldest Dates" = "dates3"
          ) 
        )
      ),
    
      #output datatable
      tabPanel(
        'Datatable',
        dataTableOutput("radiodat")
      )
      
    )
    
  )
  
)