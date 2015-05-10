#load libraries
library(leaflet)
library(ShinyDash)

#leaflet output within shiny
shinyUI(
  fluidPage(
    leafletOutput(
      "radiocarbon", "100%", 900
    )
  )
)