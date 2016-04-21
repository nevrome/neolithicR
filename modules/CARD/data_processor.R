# load libraries
library(RCurl)
library(RSQLite)

# read data from URL
myfile <- getURL(
  'https://raw.githubusercontent.com/dirkseidensticker/CARD/master/data/CARD.csv', 
  ssl.verifyhost = FALSE, 
  ssl.verifypeer = FALSE
)

CARD <- read.csv(
  textConnection(myfile), 
  header = T, 
  sep = ","
)

# adjust attribute names
colnames(CARD)[c(10,11,12)] <- c("LATITUDE", "LONGITUDE", "REFERENCE")

# add key attributes ORIGIN and ID
CARD <- data.frame(
  ORIGIN = rep("CARD", nrow(CARD)),
  ID = 1:nrow(CARD), 
  CARD
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# merge database with new data
CARDres <- merge(
  CARD, 
  datestable, 
  all.x = TRUE, all.y = TRUE, 
  incomparables = NULL
)

# write results into database
dbWriteTable(con, "dates", CARDres, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')