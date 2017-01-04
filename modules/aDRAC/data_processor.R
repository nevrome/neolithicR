# load libraries
library(RCurl)
library(RSQLite)

# read data from URL
myfile <- getURL(
  'https://raw.githubusercontent.com/dirkseidensticker/aDRAC/master/data/aDRAC.csv', 
  ssl.verifyhost = FALSE, 
  ssl.verifypeer = FALSE
)

aDRAC <- read.csv(
  textConnection(myfile), 
  header = TRUE, 
  sep = ","
)

# adjust attribute names
colnames(aDRAC)[c(10,11,12)] <- c("LATITUDE", "LONGITUDE", "REFERENCE")

# add key attributes ORIGIN and ID
aDRAC <- data.frame(
  ORIGIN = "aDRAC",
  ID = 1:nrow(aDRAC), 
  aDRAC
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# merge database with new data
aDRACres <- merge(
  aDRAC,
  datestable,
  all = TRUE
)

# write results into database
dbWriteTable(con, "dates", aDRACres, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')