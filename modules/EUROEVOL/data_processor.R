########################################################################
# Reading in the EUROEVOL-Dataset                                      #
# see http://openarchaeologydata.metajnl.com/articles/10.5334/joad.40/ #
# see http://discovery.ucl.ac.uk/1469811/                              #
########################################################################

# load libraries
library(RCurl)
library(RSQLite)
library(data.table)

# THE SAMPLES
# read data from URL
myfile <- getURL(
  'http://discovery.ucl.ac.uk/1469811/7/EUROEVOL09-07-201516-34_C14Samples.csv', 
  ssl.verifyhost =  FALSE, 
  ssl.verifypeer = FALSE,
  .encoding = "UTF-8"
)

C14Samples <- read.csv(
  textConnection(myfile), 
  header = T, 
  sep = ","
)

# THE SITES
# read data from URL
myfile <- getURL(
  'http://discovery.ucl.ac.uk/1469811/9/EUROEVOL09-07-201516-34_CommonSites.csv', 
  ssl.verifyhost = FALSE, 
  ssl.verifypeer = FALSE,
  .encoding = "UTF-8"
)

CommonSites <- data.frame(fread(myfile))

# merging of the two tables (Right inner join)
EUROEVOL <- merge(x = C14Samples, y = CommonSites, by = "SiteID", all = FALSE)

# adjust attribute selection
EUROEVOL <- subset(EUROEVOL, select=-c(SiteID, C14ID, PhaseCode))

# adjust attribute names
colnames(EUROEVOL) <- c(
  "PERIOD", 
  "C14AGE",
  "C14STD", 
  "LABNR", 
  "MATERIAL",
  "SPECIES",
  "COUNTRY",
  "LATITUDE", 
  "LONGITUDE",
  "SITE"
  )

# add key attributes ORIGIN and ID
EUROEVOL <- data.frame(
  ORIGIN = rep("EUROEVOL", nrow(EUROEVOL)),
  ID = 1:nrow(EUROEVOL), 
  EUROEVOL
)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# merge database with new data
res <- merge(
  EUROEVOL, 
  datestable, 
  all.x = TRUE, all.y = TRUE, 
  incomparables = NULL
)

# write results into database
dbWriteTable(con, "dates", res, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')