# load libraries
library(RSQLite)

#load thesauri
files <- list.files(path = "modules/thesaurus/", pattern='*.RData', recursive=T)
files = lapply(files, function(x) paste0('modules/thesaurus/', x))
thes <- lapply(files, load, .GlobalEnv)

# connect to database and load the content of the table "dates" into a dataframe
con <- dbConnect(RSQLite::SQLite(), "data/rc.db")
datestable = dbGetQuery(con, 'select * from dates')

# loop to check and correct every single date 
for (i in 1:nrow(datestable)) {
  
  print(i)
  
  for (k in 1:length(thes)) {
    cur_thes_name <- thes[[k]]
    cur_thes <- get(thes[[k]])
  
    if(datestable[,cur_thes_name][i] %in% cur_thes$var) {
      pr <- match(datestable[,cur_thes_name][i], cur_thes$var)
      datestable[,cur_thes_name][i] <- cur_thes$cor[pr]
    }
  }
  
}

# write results back into database
dbWriteTable(con, "dates", datestable, overwrite = TRUE)

# test new state
# test <- dbGetQuery(con, 'select * from dates')