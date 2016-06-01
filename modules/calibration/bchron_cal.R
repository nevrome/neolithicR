# load libraries
library(Bchron)
library(RSQLite)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# newcali <- 0
# alreadycali <- 0

# precalculated values
afaktor <- (1-0.683)/2

# loop to calibrate every single date by its own
for (i in 1:nrow(datestable)) {

  # alreadycali <- alreadycali + 1
  #
  # # just calibrate dates, that are not already calibrated (!!! dangerous !!!)
  # if (is.na(datestable$CALAGE[i])) {
  # 
  #   alreadycali <- alreadycali - 1
  #   newcali <- newcali + 1
  #   
  #   print(paste("Already:", alreadycali, "New:", newcali, "To check:", nrow(datestable) - (newcali+alreadycali)))
  
    print(paste("To Do:", nrow(datestable) - i))
  
    # dates that are out of the range of the calcurve can not be calibrated
    if (datestable$C14AGE[i] > 100 && datestable$C14AGE[i] < 45000) {
      
      # calibration
      age <- BchronCalibrate(
        datestable$C14AGE[i], 
        datestable$C14STD[i], 
        calCurves = "intcal13"
      ) 
      #plot(age)
      
      # determine center and upper and lower border of the 95% probability interval
      # https://github.com/andrewcparnell/Bchron/blob/master/vignettes/Bchron.Rmd
      age_samples <- sapply(
        age, 
        function(x){sample(x$ageGrid, size = 1000, replace = TRUE, prob = x$densities)}
      )
      #interval95 <- apply(age_samples, 2, quantile, prob = c(0.025, 0.975))
      interval683 <- apply(age_samples, 2, quantile, prob = c(afaktor, 1-afaktor))
      
      #low <- round(interval683[1,1])
      up <- round(interval683[2,1])
      
      # preliminary: take the mean of the borders as CALAGE and the distance
      # of CALAGE to the upper and lower 68.3% interval as CALSTD
      datestable$CALAGE[i] <- round(mean(interval683))
      datestable$CALSTD[i] <- up-datestable$CALAGE[i]
      
    } else {
      
      datestable$CALAGE[i] <- datestable$C14AGE[i]
      datestable$CALSTD[i] <- datestable$C14STD[i]
      
    }
    
  # }
  
}

# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')