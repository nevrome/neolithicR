#### loading libraries ####

library(leaflet)
library(ShinyDash)
library(shinysky)
library(DT)

#### definition of frontend output/input ####
shinyUI(
  
  navbarPage(
    "neolithicRC - Search tool for radiocarbon dates", 
    id = "nav",

    tabPanel("Update Local Database ⛁",
      
      HTML('
        <a href = "https://github.com/nevrome/neolithicR">
          <img style="position: absolute; top: 0; right: 0; border: 0; z-index:1000" 
               src="https://camo.githubusercontent.com/e7bbb0521b397edbd5fe43e7f760759336b5e05f/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677265656e5f3030373230302e706e67" 
               alt="Fork me on GitHub" 
               data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_green_007200.png">
        </a>  
      '),
      
      shiny::includeMarkdown("README.md"),
      
      hr(),
      
      htmlOutput('startmessage'),
      br(),
      
      shinyjs::useShinyjs(),
      uiOutput("updateriddle"),
      uiOutput("updatebutton"),
      br(), br(),
      textOutput("c14bazAArout")
    ),
    
    tabPanel("Search and Filter ⌕",
    
      HTML('
        <a href = "https://github.com/nevrome/neolithicR">
          <img style="position: absolute; top: 0; right: 0; border: 0; z-index:1000" 
               src="https://camo.githubusercontent.com/e7bbb0521b397edbd5fe43e7f760759336b5e05f/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677265656e5f3030373230302e706e67" 
               alt="Fork me on GitHub" 
               data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_green_007200.png">
        </a>  
      '),        
             
      fluidRow( 
        
        singleton(
          tags$head(
            tags$script(src = "message-handler.js"),
            tags$style(
              HTML(".shiny-notification {
              height: 50px;
              width: 400px;
              position: fixed;
              top: calc(50% - 50px);;
              left: calc(50% - 200px);;
              font-size: 18px;
              text-align: center;
              }"
              )
            )
          )
        ),
        
        column(2,
             
          uiOutput("sourcedb_selection")
          
        ),
        
        column(2,
          
          uiOutput("country_selection"),
          uiOutput("material_selection")      

        ),
        
        column(2,
               
         textInput(
           "siteselect",
           "Site search"
         ),
         
         textInput(
           "culselect",
           "Period/Culture search"
         )
         
        ),
        
        column(2,
               
          textInput(
            "labselect",
            "Lab Number search"
          )   
          
        ),
        
        column(4,
               
          textOutput('numbertext'),
          htmlOutput('originamounttext'),
          textOutput('duplitext'),
          textOutput('mappingwarning')
               
        )
        
      ),
      
      uiOutput("age_slider"),
      
      #datatable output
      DT::dataTableOutput("radiodat"),

      #selection buttons and download
      downloadButton(
        'downloadseldates', 
        'Download current selection as tab separated .csv file'
      )
            
    ),
    
    tabPanel("Interactive map ⚆",
       
      div(
        
        class="outer",

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
         
        bootstrapPage(
        # Panel 1 (Plots)
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
          
          HTML('
            <button 
              data-toggle = "collapse" 
              data-target = "#dataplots"
              class  = "closeopen"> 
              ▼ See date density and calibration plots ▼
            </button>
          '),
           
          div(
             
            id = 'dataplots',  
            class = "collapse", # start collapsed
            #class="collapse in", # start not collapsed
            
            #period barplot output 
            plotOutput(
              "calplot", 
              height = "600px", 
              width = "100%"
            )
          ) 
        ),

        # Panel 2 (Basemap)
        absolutePanel(
          id = "controls",
          class = "panel panel-default",
          fixed = TRUE,
          draggable = TRUE,
          top = 65,
          right = "auto",
          left = 50,
          bottom = "auto",
          width = 350,
          height = "auto",

          htmlOutput('link'),
    
          HTML('
            <button 
              data-toggle = "collapse" 
              data-target = "#basemapset"
              class  = "closeopen"> 
              ▼ Select basemap ▼
            </button>
          '),
          
          div(
            
            id = 'basemapset',  
            class = "collapse", # start collapsed

            selectizeInput(
              'basemapselect', 
              label = NULL, 
              choices = NULL
            ),
            
            helpText(
              "You can change the appearance of this map by replacing the tile source."
            )
          )
        )
       )
      )
    )
  )
    
)
  