# load libraries
library(plyr)
library(RCurl)
library(RSQLite)

# read data from URL
temp <- tempfile()
download.file("http://context-database.uni-koeln.de/download/Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1csv.zip", temp)
con <- unzip(temp, "Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv")
context <- read.csv("Boehner_and_Schyle_Near_Eastern_radiocarbon_CONTEXT_database_2002-2006_doi10.1594GFZ.CONTEXT.Ed1.csv", 
                    sep = ';', 
                    fileEncoding="latin1")
unlink(temp)

# rename ID column to not interfere with generic ID produced later
context <- rename(context, c("ID"="origID"))

# add key attributes ORIGIN and ID
context <- data.frame(
  ORIGIN = "CONTEXT",
  ID = 1:nrow(context), 
  context
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# drop Columns which are not present in DB
drops <- c(setdiff(colnames(context), colnames(datestable)))
context <- context[ , !(names(context) %in% drops)]

# merge database with new data
contextres <- merge(
  context,
  datestable,
  all = TRUE
)

# write results into database
dbWriteTable(con, "dates", contextres, overwrite = TRUE)
