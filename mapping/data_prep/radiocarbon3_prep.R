#### loading libraries ####
library(dplyr)


#### general preparations ####

#load dataset
matrix <- read.csv("data/radiocarbon/Europe.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

#reduce main data.frame to necessary information for mapping (LABNR, SITE, LATITUDE, LONGITUDE, CALAGE, REFERENCE)
matrix.red1 <- matrix[,c(1,8,13,14,16,18)]

#replace "," by "." in the position columns
matrix.red1$LATITUDE <- chartr(old=",",new=".",x=matrix.red1$LATITUDE)
matrix.red1$LONGITUDE <- chartr(old=",",new=".",x=matrix.red1$LONGITUDE)

#convert values in position colums to numeric
matrix.red1$LATITUDE <- as.numeric(matrix.red1$LATITUDE)
matrix.red1$LONGITUDE <- as.numeric(matrix.red1$LONGITUDE)

#remove radiocarbon dates without age information or position
matrix.red2 <- filter(matrix.red1, matrix.red1$CALAGE!="0") 
matrix.red2 <- filter(matrix.red2, matrix.red2$LONGITUDE!="0" & matrix.red2$LATITUDE!="0")

#sort dates by age
matrix.red2 <- matrix.red2[order(matrix.red2$CALAGE, decreasing=TRUE),]

#add column for main color (color by age)
matrix.red2 <- data.frame(
  matrix.red2, 
  MAINCOLOR = rainbow(length(matrix.red2[,1]), alpha = NULL, start = 0, end = 2/6)
  )


##### youngest dates #####

#reduce the date selection to the youngest date of each site
youngest.dates1 <- lapply(
  split(matrix.red2, matrix.red2$SITE), 
  function(x) {
    x[which.min(x$CALAGE), c(1:6)]
  }
)
youngest.dates2 <- do.call(rbind, youngest.dates1)
#Add offset column with values for the oldest graves
youngest.dates2 <- data.frame(youngest.dates2, OFFSET=0.05, COLOR="#3058e5")


##### oldest dates level 1 + combination with youngest dates #####

#reduce the date selection to the oldest date of each site
oldest.dates1 <- lapply(
  split(matrix.red2, matrix.red2$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates1 <- do.call(rbind, oldest.dates1)
#Add offset column with values for the oldest graves
oldest.dates1 <- data.frame(oldest.dates1, OFFSET=-0.05, COLOR="#990033")

#create a combined list with the oldest and the youngest dates of the site
dates1 <- rbind(oldest.dates1, youngest.dates2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
dates1 <- data.frame(dates1, PARTNERAGE = dates1$CALAGE)

#exchange partner ages
dates1 <- lapply(
  split(dates1, dates1$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
dates1 <- do.call(rbind, dates1)


##### oldest dates level 2 + combination with youngest dates #####

#remove the oldest dates from the dataset
matrix.red3 <- matrix.red2[!(matrix.red2$LABNR %in% oldest.dates1$LABNR),]

#reduce the date selection to the second oldest date of each site
oldest.dates2 <- lapply(
  split(matrix.red3, matrix.red3$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates2 <- do.call(rbind, oldest.dates2)
#Add offset column with values for the oldest graves
oldest.dates2 <- data.frame(oldest.dates2, OFFSET=-0.05, COLOR="#FF3300")

#create a combined list with the oldest and the youngest dates of the site
dates2 <- rbind(oldest.dates2, youngest.dates2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
dates2 <- data.frame(dates2, PARTNERAGE = dates2$CALAGE)

#exchange partner ages
dates2 <- lapply(
  split(dates2, dates2$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
dates2 <- do.call(rbind, dates2)


##### oldest dates level 3 + combination with youngest dates #####

#remove the oldest dates from the dataset again
matrix.red4 <- matrix.red3[!(matrix.red3$LABNR %in% oldest.dates2$LABNR),]

#reduce the date selection to the third oldest date of each site
oldest.dates3 <- lapply(
  split(matrix.red4, matrix.red4$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.dates3 <- do.call(rbind, oldest.dates3)
#Add offset column with values for the oldest graves
oldest.dates3 <- data.frame(oldest.dates3, OFFSET=-0.05, COLOR="#FF33CC")

#create a combined list with the oldest and the youngest dates of the site
dates3 <- rbind(oldest.dates3, youngest.dates2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
dates3 <- data.frame(dates3, PARTNERAGE = dates3$CALAGE)

#exchange partner ages
dates3 <- lapply(
  split(dates3, dates3$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
dates3 <- do.call(rbind, dates3)


##### export of date selections #####

write.table(dates1, "mapping/shiny_app/radiocarbon3/dates1.csv", sep="\t", col.names = NA)
write.table(dates2, "mapping/shiny_app/radiocarbon3/dates2.csv", sep="\t", col.names = NA)
write.table(dates3, "mapping/shiny_app/radiocarbon3/dates3.csv", sep="\t", col.names = NA)
write.table(matrix.red2, "mapping/shiny_app/radiocarbon3/Europe.csv", sep="\t", col.names = NA)
