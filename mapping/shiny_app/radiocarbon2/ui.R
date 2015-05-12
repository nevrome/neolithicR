#load libraries
library(leaflet)
library(ShinyDash)

#leaflet output within shiny
shinyUI(
  
  fluidPage(
    
    leafletOutput(
      "radiocarbon", width = "100%", height = "400px"
    ),
  
    sidebarPanel(
      sliderInput("range", 
                  "calibrated age BP:", 
                  min = 0,
                  max = 15000,
                  step= 100,
                  value =c(3000,4000))
    )
  )
)