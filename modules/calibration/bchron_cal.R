# load libraries
library(Bchron)
library(RSQLite)
library(magrittr)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# precalculated values
afaktor <- (1-0.683)/2

# determine dates that are out of the range of the calcurve can not be calibrated
which(datestable$C14AGE < 100) -> toosmall
which(datestable$C14AGE > 45000) -> toobig
c(toosmall, toobig) %>% unique -> outofrange

# copy these dates without calibration
datestable$CALAGE[outofrange] <- datestable$C14AGE[outofrange]
datestable$CALSTD[outofrange] <- datestable$C14STD[outofrange]

# calibration
interval683 <- datestable[-outofrange, ] %>%
  # calculate density vector
  BchronCalibrate(
    ages = use_series(., C14AGE),
    ageSds = use_series(., C14STD),
    calCurves = rep("intcal13", nrow(.))
  ) %>%
  set_names(
    sprintf("date%i", 1:length(.))
  ) %>%
  # draw 1000 samples from density vector
  # https://github.com/andrewcparnell/Bchron/blob/master/vignettes/Bchron.Rmd
  sapply(
    ., function(x){sample(x$ageGrid, size = 1000, replace = TRUE, prob = x$densities)}
  ) %>% 
  # determine upper and lower border of 68% interval of density distribution
  #interval95 <- apply(age_samples, 2, quantile, prob = c(0.025, 0.975))
  apply(
    ., 2, quantile, prob = c(afaktor, 1-afaktor)
  ) %>%
  t %>%
  as.data.frame
 
# preliminary: take the mean of the borders as CALAGE and the distance
# of CALAGE to the upper and lower 68.3% interval as CALSTD 
top <- round(interval683[,2])
amean <- apply(interval683, 1, function(x){round(mean(x))})
datestable$CALAGE[-outofrange] <- amean
datestable$CALSTD[-outofrange] <- top - amean

# write results into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')