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
      height = "800px"
    ),
  
    #output of filter criteria
    verbatimTextOutput(
      "filterText"
    ),
    
    #output of number of results
    verbatimTextOutput(
      "numberText"
    ),
  
    #output of download button
    downloadButton(
      'downloadseldatescsv', 
      'Download current selection as tab separated .csv file'
    )
    
  )
)