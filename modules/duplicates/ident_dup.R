# load libraries
library(RSQLite)
library(stringr)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

labnum <- datestable$LABNR 
labnum <- head(labnum, 10000)
dasize <- length(labnum)

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

# find simple dublicated values
res <- as.integer((duplicated(labnum) | duplicated(labnum, fromLast = TRUE)))

count <- 0

pb2 <- txtProgressBar(min = 0, max = dasize, initial = 0, style = 3)

# find other possibly dublicated values
while (TRUE) {
  
  count <- count + 1
  
  cur <- unlist(labsep[1])
  
  # reduce size of list gradually
  labsep[1] <- NULL
  
  # break condition
  if (length(labsep) == 0) {
    break
  }
  
  # nested loop to check every possible relation
  for (p2 in 1:length(labsep)) {
    
    cur2 <- unlist(labsep[p2])
    
    if (res[count] == 0) {
      if (all(cur %in% cur2)) {
        res[count] <- 2
      } 
    }
    
    if (res[count + p2] == 0) {
      if (all(cur2 %in% cur)) {
        res[count + p2] <- 2
      }
    }
  }
  
  setTxtProgressBar(pb2, count)
}

close(pb2)

# write results into database
#dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')