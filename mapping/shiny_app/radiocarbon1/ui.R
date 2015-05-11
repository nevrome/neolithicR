#load libraries
library(leaflet)
library(ShinyDash)

#leaflet output within shiny
shinyUI(
  fluidPage(
    leafletOutput(
      "radiocarbon", width = "100%", height = "700px"
    )
  )
)