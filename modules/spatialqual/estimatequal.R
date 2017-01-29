# setup progress bar
pb <- txtProgressBar(
  max = 100,
  style = 3
)



#### preparations ####

# load libraries
library(RSQLite)
library(sp)
library(rworldmap)
library(rworldxtra)
library(dplyr)
library(magrittr)
library(taRifx)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# load country thesaurus
load("modules/radiocarbon5/thesauri/COUNTRY_thesaurus.RData")

# load world map
world <- getMap(resolution='high')
worldproj <- CRS(proj4string(world))

# increment progress bar 
setTxtProgressBar(pb, 10)



#### pre loop calculations #### 

# create longitude and latitude vectors (warnings turned off)
oldw <- getOption("warn")
options(warn = -1)

lonvec <- datestable$LONGITUDE %>%
  taRifx::destring()
latvec <- datestable$LATITUDE %>%
  taRifx::destring()

options(warn = oldw)

# determine dates without coordinate information
lonvec %>% is.na %>% which -> emptylon
latvec %>% is.na %>% which -> emptylat
c(emptylon, emptylat) %>% unique -> empty

# determine country from coordinates and world map
datestable$COORDCOUNTRY[-empty] <- data.frame(lon = lonvec, lat = latvec) %>%
  `[`(-empty, ) %>% 
  SpatialPoints(proj4string = worldproj) %>%
  over(., world) %>%
  `$`(ADMIN) %>% 
  as.character

# increment progress bar 
setTxtProgressBar(pb, 50)



#### loop to check country-coordinate relation for every date ####

# determine number of dates to be checked
ldb <- nrow(datestable)

# loop
for (i in 1:ldb) {

  lon <- lonvec[i]
  lat <- latvec[i]
  coordcountry <- datestable$COORDCOUNTRY[i]
  dbcountry <- datestable$COUNTRY[i]
  
  # test, if there are coords
  # yes: ok, go on
  # no: stop and store "no coords"
  if (is.na(lon) | is.na(lat) | (lon == 0 & lat == 0)) {
    datestable$SPATQUAL[i] <- "no coords"
    next()
  }
  
  # test, if the coords are within the spatial frame of reference
  # yes: ok, go on
  # no: stop and store "wrong coords"
  if (lon > 180 | lon < -180 | lat > 90 | lat < -90) {
    datestable$SPATQUAL[i] <- "wrong coords"
    next()
  }
  
  # test, if it was possible to determine country from coordinates
  # yes: ok, go on
  # no: stop and store "doubtful coords"
  if (is.na(coordcountry)) {
    datestable$SPATQUAL[i] <- "doubtful coords"
    next()
  }
  
  # compare country info in db and country info determined from coords
  # apply thesaurus to get every possible spelling of a country
  corc <- filter(COUNTRY_thesaurus, var == dbcountry)$cor
  if(length(corc) == 0) {
    stop(paste0('"', dbcountry, '"', " is not in the country thesaurus."))
  }
  dbcountrysyn <- c(
    dbcountry, 
    corc, 
    filter(COUNTRY_thesaurus, cor == corc)$var
  ) %>%
    unique

  # test, if the initial country value is a form of "nothing"
  # yes: stop and store country name determined from coords + "possibly correct"
  # no: go on
  if (corc == "unknown" | is.na(dbcountry)) {
    datestable$COUNTRY[i] <- coordcountry
    datestable$SPATQUAL[i] <- "possibly correct"
    next()
  # test, if the initial country value is equal to the country name determined 
  # from coords
  # yes: ok, go on
  # no: stop and store country name determined from coords + "doubtful correct"
  } else if (!(coordcountry %in% dbcountrysyn)) {
    datestable$COUNTRY[i] <- coordcountry
    datestable$SPATQUAL[i] <- "doubtful coords"
    next()
  # else (initial country value is equal to the country name determined from coords)
  # store "possibly correct"
  } else {
    datestable$SPATQUAL[i] <- "possibly correct"
  }
  
  # increment progress bar 
  setTxtProgressBar(pb, 50 + 48 * (i/ldb))
}

# test <- filter(
#   datestable,
#   SPATQUAL != "possibly correct" & SPATQUAL != "no coords"
# ) %>%
#   `[`(, c("LABNR", "SITE", "LATITUDE", "LONGITUDE", "COUNTRY",
#           "COORDCOUNTRY", "SPATQUAL"))



#### write results into database ####
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')



# increment progress bar 
setTxtProgressBar(pb, 100)

# close progress bar
close(pb)