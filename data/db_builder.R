# For the first setup create database rc.db in data/ with
# sqlite3 rc.db

# load libraries
library(RSQLite)

# connect to database 
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")

# drop old table
dbSendQuery(
  conn = con, 
  "drop table dates"
)

# create new table
dbSendQuery(
  conn = con, 
  "CREATE TABLE dates(
    ID INT NOT NULL,
    ORIGIN VARCHAR(255) NOT NULL,
    LABNR VARCHAR(255),
    C14AGE INT NOT NULL,
    C14STD INT NOT NULL,
    C13 FLOAT,
    MATERIAL VARCHAR(255),
    SPECIES VARCHAR(255),
    COUNTRY VARCHAR(255),
    COORDCOUNTRY VARCHAR(255),
    FEATURE VARCHAR(1000),
    FEATURE_DESC VARCHAR(1000),
    SITE VARCHAR(255),
    PERIOD VARCHAR(255),
    CULTURE VARCHAR(255),
    PHASE VARCHAR(255),
    LOCUS VARCHAR(1000),
    LATITUDE FLOAT,
    LONGITUDE FLOAT,
    METHOD VARCHAR(255),
    CALAGE INT,
    CALSTD INT,
    REFERENCE VARCHAR(1000),
    NOTICE VARCHAR(1000),
    SPATQUAL VARCHAR(255),
    CONSTRAINT DATE_ID PRIMARY KEY (ID, ORIGIN))"
)

# run data_processor scripts for the different sources
source("modules/CALPAL/data_processor.R")
rm(list = ls())
source("modules/EUROEVOL/data_processor.R")
rm(list = ls())
source("modules/aDRAC/data_processor.R")
rm(list = ls())
source("modules/RADON/data_processor.R")
rm(list = ls())

# # connect to database 
# con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
# datestable = dbGetQuery(con, 'select * from dates')

# setup thesauri
source("modules/thesaurus/COUNTRY/setup.R")
rm(list = ls())
source("modules/thesaurus/MATERIAL/setup.R")
rm(list = ls())

# run country based spatial quality test
source("modules/spatialqual/estimatequal.R")
rm(list = ls())

# run calibration
source("modules/calibration/bchron_cal.R")
rm(list = ls())

# export db to .Rdata file and filter
source("modules/db_to_rdata/db_to_rdata.R")
rm(list = ls())

# load data
load(file = "modules/radiocarbon5/data/c14data.RData")
