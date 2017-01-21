###########################################################################################################
# DEPENDENCIES                                                                                            #
# ============                                                                                            #
# Check if all packages required for generating the DB are installes                                      #
# If something is missing, install is                                                                     #
# http://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages #
###########################################################################################################

requiredPackages = c('Bchron',
                     'data.table',
                     'dplyr',
                     'DT',
                     'ggplot2',
                     'gtools',
                     'leaflet',
                     'magrittr',
                     'maps',
                     'mapproj',
                     'plyr',
                     'raster',
                     'RCurl',
                     'rsconnect',
                     'RSQLite',
                     'rworldmap',
                     'rworldxtra',
                     'shiny',
                     'sp',
                     'stringr',
                     'taRifx')


for(p in requiredPackages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# Pakete, die nicht in CRAN enthalten sind:
library(devtools)
devtools::install_github("ShinyDash", "trestletech")
devtools::install_github("AnalytixWare/ShinySky")
