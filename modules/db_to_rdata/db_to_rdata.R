# load libraries
library(RSQLite)
library(dplyr)

# connect to database and load the content of the table "dates" into a dataframe datestable
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# remove dates without long and lat value
datestable <- datestable[!is.na(datestable$LONGITUDE),]
datestable  <- datestable[!is.na(datestable$LATITUDE),]

# transform long and lat value to numeric
datestable$LONGITUDE <- as.numeric(datestable$LONGITUDE)
datestable$LATITUDE <- as.numeric(datestable$LATITUDE)

# remove wrong values
datestable <- filter(datestable,
       datestable$LONGITUDE < 180 &
       datestable$LONGITUDE > -180 &
       datestable$LATITUDE < 90 &
       datestable$LATITUDE > -90  
       )

datestable <- filter(datestable,
                     datestable$LONGITUDE != 0 & 
                     datestable$LATITUDE != 0   
                     )

# sort by CALAGE
datestable <- datestable[order(datestable$CALAGE, decreasing=TRUE),]

# add colour value
datestable <- data.frame(
  datestable, 
  MAINCOLOR = rainbow(nrow(datestable), alpha = NULL, start = 0, end = 2/6)
)

# store data.frame datestable as a .RData object into the app file system
save(datestable, file = "modules/radiocarbon5/data/c14data.RData")

# test
# load(file = "modules/radiocarbon5/data/c14data.RData")
