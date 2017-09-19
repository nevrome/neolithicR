calipath <- "~/C14/calibrator/bin"

system(paste0("cd ", calipath, " && ", "./calibrator -b 5000 -s 30 -o csv"), intern = TRUE)



library(Bchron)

BchronCalibrate(
  5000, 
  30, 
  calCurves = "intcal13"
) 

library(rbenchmark)

benchmark(
  system(paste0("cd ", calipath, " && ", "./calibrator -b 5000 -s 30 -o csv"), intern = TRUE),
  BchronCalibrate(
    5000, 
    30, 
    calCurves = "intcal13"
  ) 
)