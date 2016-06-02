# load libraries
library(RSQLite)
library(sp)
library(rworldmap)
library(rworldxtra)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

datestable <- data.frame(datestable, spatqual = NA)

points <- na.omit(data.frame(as.numeric(datestable$LONGITUDE), as.numeric(datestable$LATITUDE)))


# The single argument to this function, points, is a data.frame in which:
#   - column 1 contains the longitude in degrees
#   - column 2 contains the latitude in degrees
coords2country = function(points)
{  
  # load detailed worldmap
  countriesSP <- getMap(resolution='high')

  # setting CRS to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  # get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  
  # return the ADMIN names of each country
  indices$ADMIN  
}

coords2country(points)


# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')