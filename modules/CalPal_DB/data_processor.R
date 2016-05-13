# load libraries
library(RCurl)
library(RSQLite)

# read data from URL
myfile <- getURL(
  'https://raw.githubusercontent.com/nevrome/CalPal-Database/master/CalPal_14C-Database.csv', 
  ssl.verifyhost = FALSE, 
  ssl.verifypeer = FALSE
)

CALPAL <- read.csv(
  textConnection(myfile), 
  header = T, 
  sep = ","
)

# remove ID column and empty colums at the end
CALPAL <- CALPAL[,2:20]

# add key attributes ORIGIN and ID
CALPAL <- data.frame(
  ORIGIN = rep("CALPAL", nrow(CALPAL)),
  ID = 1:nrow(CALPAL), 
  CALPAL
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# merge database with new data
CALPALres <- merge(
  CALPAL, 
  datestable, 
  all.x = TRUE, all.y = TRUE, 
  incomparables = NULL
)

# write results into database
dbWriteTable(con, "dates", CALPALres, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')