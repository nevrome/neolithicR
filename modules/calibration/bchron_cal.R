# setup progress bar
pb <- txtProgressBar(
  max = 100,
  style = 3
)



# load libraries
library(Bchron)
library(RSQLite)
library(magrittr)
library(plyr)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# determine dates that are out of the range of the calcurve can not be calibrated
which(datestable$C14AGE < 100) -> toosmall
which(datestable$C14AGE > 45000) -> toobig
c(toosmall, toobig) %>% unique -> outofrange

# copy these dates without calibration
datestable$CALAGE[outofrange] <- datestable$C14AGE[outofrange]
datestable$CALSTD[outofrange] <- datestable$C14STD[outofrange]



# increment progress bar 
setTxtProgressBar(pb, 5)


# precalculated values
threshold <- (1-0.9545)/2

# calibration
interval95 <- datestable[-outofrange, ] %$% 
  # calculate density vector
  BchronCalibrate(
    ages      = C14AGE,
    ageSds    = C14STD,
    calCurves = rep("intcal13", nrow(.)),
    eps       = 1e-06
  ) %>% 
  plyr::ldply(., function(x) {
      x$densities            %>% cumsum -> a
      which(a <= threshold)  %>% max -> my_min
      which(a > 1-threshold) %>% min -> my_max
      x$ageGrid[c(my_min, my_max)]
    }
  ) 



# increment progress bar 
setTxtProgressBar(pb, 95)


 
# preliminary: take the mean of the borders as CALAGE and the distance
# of CALAGE to the upper and lower 95.45% interval as CALSTD 
top <- round(interval95[, 3])
amean <- apply(interval95[, 2:3], 1, function(x){round(mean(x))})

# write result back into datestable
datestable$CALAGE[-outofrange] <- amean
datestable$CALSTD[-outofrange] <- top - amean

# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')



# increment progress bar 
setTxtProgressBar(pb, 100)

# close progress bar
close(pb)
