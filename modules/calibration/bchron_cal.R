# load libraries
library(Bchron)
library(RSQLite)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# create empty vectors to store calibrated age
CALAGE <- c()
CALSTD <- c()

# loop to calibrate every single date by its own
for (i in 1:nrow(datestable)) {

  # dates that are out of the range of the calcurve casn not be calibrated
  if (datestable$C14AGE[i] > 100 && datestable$C14AGE[i] < 30000) {
    
    # calibration
    age <- BchronCalibrate(
      datestable$C14AGE[i], 
      datestable$C14STD[i], 
      calCurves = "intcal13"
    ) 
    #plot(age)
    
    # determine upper and lower border of the 95% probability interval
    # https://github.com/andrewcparnell/Bchron/blob/master/vignettes/Bchron.Rmd
    age_samples <- sapply(
      age, 
      function(x){sample(x$ageGrid, size = 2000, replace = TRUE, prob = x$densities)}
    )
    interval95 <- apply(age_samples, 2, quantile, prob = c(0.025, 0.975))
  
    low <- round(interval95[1,1])
    up <- round(interval95[2,1])
    
    # preliminary: take the mean of the borders as CALAGE and the distance
    # of CALAGE to the upper and lower 95% interval as CALSTD
    CALAGE[i] <- round(mean(interval95))
    CALSTD[i] <- up-CALAGE[i]
    
  } else {
    
    CALAGE[i] <- datestable$C14AGE[i]
    CALSTD[i] <- datestable$C14STD[i]
    
  }
  
}

# write calculated values into database data.frame
datestable$CALAGE <- CALAGE
datestable$CALSTD <- CALSTD

# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')