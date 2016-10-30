# load libraries
library(RSQLite)
library(stringr)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

labnum <- datestable$LABNR 
labnum <- head(labnum, 3000)
dasize <- length(labnum)

# slow and not precise
#
# grepres <- rep(FALSE, dasize)
# 
# pb1 <- txtProgressBar(min = 0, max = dasize, initial = 0, style = 3) 
# 
# for (i in 1:dasize) {
#   grepres <- grep(labnum[i], labnum, ignore.case = TRUE)
#   
#   if (length(grepres) >= 2) {
#     grepres[i] <- TRUE
#   } 
# 
#   setTxtProgressBar(pb1, i)
# }
# 
# close(pb1)

labsep <- list()

pb1 <- txtProgressBar(min = 0, max = dasize, initial = 0, style = 3)

for (i in 1:dasize) {
  # remove leading and trailing whitespace
  labnum[i] <- str_trim(labnum[i])
  # translate characters to lower case
  labnum[i] <- tolower(labnum[i])
  # split into substrings by -, space and /
  labsep[i] <- str_split(labnum[i], "-|[ X]|/")

  setTxtProgressBar(pb1, i)
}

close(pb1)

res <- rep(FALSE, dasize)

count <- 0

pb2 <- txtProgressBar(min = 0, max = dasize, initial = 0, style = 3)

while (TRUE) {
  
  count <- count + 1
  
  if (res[count]) {
    labsep[1] <- NULL
    next
  }
  
  cur <- unlist(labsep[1])
  labsep[1] <- NULL
  
  if (length(labsep) == 0) {
    break;
  }
  
  for (p2 in 1:length(labsep)) {
    
    if (res[count + p2]) {
      next
    }
    
    cur2 <- unlist(labsep[p2])
    comp1 <- cur %in% cur2
    comp2 <- cur2 %in% cur
    if (all(comp1) | all(comp2)) {
      res[count] <- TRUE
      res[count + p2] <- TRUE
    } 
  }
  
  setTxtProgressBar(pb2, count)
}

close(pb2)

# write results into database
#dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')