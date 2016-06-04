# load libraries
library(RSQLite)
library(sp)
library(rworldmap)
library(rworldxtra)
library(dplyr)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# load thesaurus
load("modules/radiocarbon5/thesauri/COUNTRY_thesaurus.RData")

# transform long and lat value to numeric
datestable$LONGITUDE <- as.numeric(datestable$LONGITUDE)
datestable$LATITUDE <- as.numeric(datestable$LATITUDE)

# load world map
world <- getMap(resolution='high')

# determine country from coordinates
nna <- unique(c(
  which(is.na(datestable$LONGITUDE)),
  which(is.na(datestable$LATITUDE))
))
datesred <- datestable[-nna,]

coords <- data.frame(lon = datesred$LONGITUDE, lat = datesred$LATITUDE)
coords <- SpatialPoints(coords, proj4string=CRS(proj4string(world)))
coordcountry <- as.character(over(coords, world)$ADMIN)

datestable$COORDCOUNTRY[-nna] <- coordcountry

# loop to check country-coordinate relation for every date
ldb <- nrow(datestable)
for (i in 1:ldb) {

  # progress bar
  print(paste("ToDo: ", ldb-i))
  
  # simple coord tests
  lon <- datestable$LONGITUDE[i]
  lat <- datestable$LATITUDE[i]
  
  if (is.na(lon) | is.na(lat) | (lon == 0 & lat == 0)) {
    datestable$SPATQUAL[i] <- "no coords"
    next()
  }
  
  if (lon > 180 | lon < -180 | lat > 90 | lat < -90) {
    datestable$SPATQUAL[i] <- "wrong coords"
    next()
  }
  
  # comparison of country info in db and country info determined from coords
  coordcountry <- datestable$COORDCOUNTRY[i]
  dbcountry <- datestable$COUNTRY[i]
  
  if (is.na(coordcountry)) {
    datestable$SPATQUAL[i] <- "doubtful coords"
    next()
  }
  
  corc <- filter(COUNTRY_thesaurus, var == dbcountry)$cor
  dbcountrysyn <- unique(c(dbcountry, corc, filter(COUNTRY_thesaurus, cor == corc)$var))
  
  spatqual <- datestable$SPATQUAL[i]
  
  if (dbcountry %in% c("", "n/a", "nd", "NoCountry") | is.na(dbcountry)) {
    datestable$COUNTRY[i] <- coordcountry
    datestable$SPATQUAL[i] <- "possibly correct"
    next()
  } else if (!(coordcountry %in% dbcountrysyn)) {
    datestable$COUNTRY[i] <- coordcountry
    datestable$SPATQUAL[i] <- "doubtful coords"
    next()
  } else {
    datestable$SPATQUAL[i] <- "possibly correct"
  }
  
}

# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')