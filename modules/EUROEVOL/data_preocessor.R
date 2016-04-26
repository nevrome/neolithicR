########################################################################
# Reading in the EUROEVOL-Dataset                                      #
# see http://openarchaeologydata.metajnl.com/articles/10.5334/joad.40/ #
# see http://discovery.ucl.ac.uk/1469811/                              #
########################################################################

# load libraries
library(RCurl)
library(RSQLite)

# THE SAMPLES
# read data from URL
myfile <- getURL(
  'http://discovery.ucl.ac.uk/1469811/7/EUROEVOL09-07-201516-34_C14Samples.csv', 
  ssl.verifyhost =  FALSE, 
  ssl.verifypeer = FALSE
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
  ssl.verifypeer = FALSE
)

CommonSites <- read.csv(
  textConnection(myfile), 
  header = T,
  sep = ",",
  dec = "."
)

# merging of the two tables (Right inner join)
EUROEVOL <- merge(x = C14Samples, y = CommonSites, by = "SiteID", all = FALSE)

# adjust attribute names
colnames(EUROEVOL)[c(11,12)] <- c("LATITUDE", "LONGITUDE")

# add key attributes ORIGIN and ID
EUROEVOL <- data.frame(
  ORIGIN = rep("EUROEVOL", nrow(EUROEVOL)),
  ID = 1:nrow(EUROEVOL), 
  EUROEVOL
)

# ...