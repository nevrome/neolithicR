# load libraries
library(RSQLite)
library(dplyr)

# connect to database and load the content of the table "dates" into a dataframe datestable
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

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
