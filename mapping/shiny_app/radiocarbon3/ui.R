#### loading libraries ####

library(leaflet)
library(ShinyDash)



#### defining country vector ####

cl <- c("Germany","Greece","Former Yugoslavia","Spain","Iran","Syria","Jordan",
  "Turkey","Israel/Palestina","Belgium","Irak","Cyprus","England/Wales","Egypt/Sinai",
  "France","Sweden","Denmark","???","Andorra","Saudi Arabia","Morocco",
  "Italy","Ukraine","Netherlands","Serbia","Portugal","Switzerland","Ireland",          
  "Corsica","U.A.E.","Oman","Slovakia","Russia","Romania","Libya",            
  "Lebanon","Luxembourg","Croatia","Scotland","Slovenia","Crete","Hungary",          
  "Yemen","Austria","Albania","Bulgaria","Macedonia","Qatar","Azerbaijan",       
  "Armenia","Libanon","Poland","Georgia","Channel Isles","Malta","Sardinia",         
  "Mallorca") 

countries <- setNames(cl, cl)

countries <- sort(countries)

countries1 <- unique(countries[1:length(countries)/2])
countries2 <- countries[!countries %in% countries1]

#### defining period list ####

periods <- list(
  "Palaeolithic" = "palaeolithic",
  "Epipalaeolithic" = "epipalaeolithic",
  "Neolithic" = "neolithic", 
  "Chalcolithic" = "chalcolithic",
  "Bronze age" = "bronzeage",
  "Iron age" = "ironage",
  "Egypt" = "egypt",
  "Other" = "other"
)



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
           
           h2("neolithicRC"),
           
           #input switch
           
           selectInput(
             "type", 
             "Type of visualisation", 
             c(
               "Show every date" = "type1",
               "Show oldest and youngest date" = "type2"
             ),
             selected = "type1"
           ),
           
           selectInput(
             "oldest", 
             "How to deal with the oldest dates?",
             c(
               "Show all dates" = "youngoldsel1",
               "Remove oldest dates of each site and show second oldest dates" = "youngoldsel2",
               "Remove oldest and second oldest dates of each site and show third oldest dates" = "youngoldsel3"
             ),
             selected = "youngoldsel1"
           ),
           
           #input checkboxes     
           checkboxGroupInput(
             "periodselect", 
             "Select Period (attribution in DB inconsistent) ",
             choices = periods,
             selected = periods
           ),
           
           #input checkboxes     
           checkboxGroupInput(
             "materialselect", 
             "Select Material",
             list(
               "Charcoal" = "charcoal",
               "Bone" = "bone",
               "Other" = "other",
               "???" = "nd"
             ),
             selected = c(
               "charcoal",
               "bone",
               "other"
             )
           ),
           
           h5("Select Country?"),
           
           checkboxInput(
             "countrydecide",
             "Yes please!",
             value = FALSE
           )
           
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
             value =c(8000,10000)
           )
         ),
         
         # Control Panel 3 (Countries)
         conditionalPanel(
           condition = "input.countrydecide",

         absolutePanel(
           id = "controls", 
           class = "panel panel-default", 
           fixed = TRUE, 
           draggable = TRUE, 
           top = 60, 
           left = "auto", 
           right = "81%", 
           bottom = "auto",
           width = 330, 
           height = "auto",
           
           column( 
             width = 6, 
             #input checkboxes     
             checkboxGroupInput(
               "countryselect1", 
               "Select Country",
               choices = countries1,
               selected = ""
             )
           ),
           
           column( 
             width = 4, 
             #input checkboxes     
             checkboxGroupInput(
               "countryselect2", 
               " ",
               choices = countries2,
               selected = "Turkey"
              )
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
            "barplotperiod", 
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
    
    #complete datatable  
    tabPanel(
      'Datatable (complete)',
      dataTableOutput("radiodat_complete")
    ),
      
    tabPanel(
      'Basemap settings',
      
      textInput(
        "tiles", 
        "Specify Basemap tile sources", 
        value = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
        width = 800
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
  