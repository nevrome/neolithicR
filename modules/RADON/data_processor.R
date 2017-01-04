# load libraries
library(RCurl)
library(RSQLite)

# read data from URL
myfile <- getURL(
  '134.245.38.100/radondownload/radondaily.txt', 
  ssl.verifyhost = FALSE, 
  ssl.verifypeer = FALSE,
  .encoding = "UTF-8"
)

RADON <- read.table(
  textConnection(myfile), 
  header = TRUE, 
  sep = "\t",
  strip.white = TRUE,
  fill = TRUE,
  quote = "",
  stringsAsFactors = FALSE
)

# remove ID column
RADON <- RADON[, -1]

# add key attributes ORIGIN and ID
RADON <- data.frame(
  ORIGIN = "RADON",
  ID = 1:nrow(RADON),
  RADON
)

# rename columns
colnames(RADON)[c(13)] <- c("FEATURE_DESC")

# add page info into reference column
for (i in 1:nrow(RADON)) {
  if (!(RADON$REFERENCE[i] == "")) {
    if (!(RADON$PAGES[i] == "")) {
      RADON$REFERENCE[i] <- paste(RADON$REFERENCE[i], "p." , RADON$PAGES[i])
    }
  }
}

# remove pages column
RADON = subset(
  RADON, 
  select = -PAGES
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# merge database with new data
RADONres <- merge(
  RADON,
  datestable,
  all = TRUE
)

# write results into database
dbWriteTable(con, "dates", RADONres, overwrite = TRUE)

# # test new state
# # test <- dbGetQuery(con, 'select * from dates')