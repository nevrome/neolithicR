#### loading libraries ####
library(dplyr)


#### general preparations ####

#load dataset
Europe <- read.csv("data/radiocarbon/Europe.csv", 
                   sep="\t", 
                   header=TRUE, 
                   row.names=1, 
                   stringsAsFactors = FALSE)

#reduce main data.frame to necessary information for mapping (LABNR, SITE, LATITUDE, LONGITUDE, CALAGE, REFERENCE)
Europe.red0 <- Europe[,c(1,8,13,14,16,18)]

#replace "," by "." in the position columns
Europe.red0$LATITUDE <- chartr(old=",",new=".",x=Europe.red0$LATITUDE)
Europe.red0$LONGITUDE <- chartr(old=",",new=".",x=Europe.red0$LONGITUDE)

#convert values in position colums to numeric
Europe.red0$LATITUDE <- as.numeric(Europe.red0$LATITUDE)
Europe.red0$LONGITUDE <- as.numeric(Europe.red0$LONGITUDE)

#remove radiocarbon dates without age information or position
Europe.red1 <- filter(Europe.red0, Europe.red0$CALAGE!="0") 
Europe.red1 <- filter(Europe.red1, Europe.red1$LONGITUDE!="0" & Europe.red1$LATITUDE!="0")

#sort dates by age
Europe.red1 <- Europe.red1[order(Europe.red1$CALAGE, decreasing=TRUE),]

#add column for main color (color by age)
Europe.red1 <- data.frame(
  Europe.red1, 
  MAINCOLOR = rainbow(length(Europe.red1[,1]), alpha = NULL, start = 0, end = 2/6)
  )


#### data selection for oldest + youngest dates / editing of the main dataset ####

##### youngest dates #####

#reduce the date selection to the youngest date of each site
youngest.youngoldsel1 <- lapply(
  split(Europe.red1, Europe.red1$SITE), 
  function(x) {
    x[which.min(x$CALAGE), c(1:6)]
  }
)
youngest.youngoldsel2 <- do.call(rbind, youngest.youngoldsel1)
#Add offset column with values for the oldest graves
youngest.youngoldsel2 <- data.frame(youngest.youngoldsel2, OFFSET=0.05, COLOR="#3058e5")


##### oldest dates level 1 + combination with youngest dates #####

#reduce the date selection to the oldest date of each site
oldest.youngoldsel1 <- lapply(
  split(Europe.red1, Europe.red1$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.youngoldsel1 <- do.call(rbind, oldest.youngoldsel1)
#Add offset column with values for the oldest graves
oldest.youngoldsel1 <- data.frame(oldest.youngoldsel1, OFFSET=-0.05, COLOR="#990033")

#create a combined list with the oldest and the youngest dates of the site
youngoldsel1 <- rbind(oldest.youngoldsel1, youngest.youngoldsel2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
youngoldsel1 <- data.frame(youngoldsel1, PARTNERAGE = youngoldsel1$CALAGE)

#exchange partner ages
youngoldsel1 <- lapply(
  split(youngoldsel1, youngoldsel1$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
youngoldsel1 <- do.call(rbind, youngoldsel1)


##### oldest dates level 2 + combination with youngest dates #####

#remove the oldest dates from the dataset
Europe.red2 <- Europe.red1[!(Europe.red1$LABNR %in% oldest.youngoldsel1$LABNR),]

#reduce the date selection to the second oldest date of each site
oldest.youngoldsel2 <- lapply(
  split(Europe.red2, Europe.red2$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.youngoldsel2 <- do.call(rbind, oldest.youngoldsel2)
#Add offset column with values for the oldest graves
oldest.youngoldsel2 <- data.frame(oldest.youngoldsel2, OFFSET=-0.05, COLOR="#FF3300")

#create a combined list with the oldest and the youngest dates of the site
youngoldsel2 <- rbind(oldest.youngoldsel2, youngest.youngoldsel2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
youngoldsel2 <- data.frame(youngoldsel2, PARTNERAGE = youngoldsel2$CALAGE)

#exchange partner ages
youngoldsel2 <- lapply(
  split(youngoldsel2, youngoldsel2$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
youngoldsel2 <- do.call(rbind, youngoldsel2)


##### oldest dates level 3 + combination with youngest dates #####

#remove the oldest dates from the dataset again
Europe.red3 <- Europe.red2[!(Europe.red2$LABNR %in% oldest.youngoldsel2$LABNR),]

#reduce the date selection to the third oldest date of each site
oldest.youngoldsel3 <- lapply(
  split(Europe.red3, Europe.red3$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)
oldest.youngoldsel3 <- do.call(rbind, oldest.youngoldsel3)
#Add offset column with values for the oldest graves
oldest.youngoldsel3 <- data.frame(oldest.youngoldsel3, OFFSET=-0.05, COLOR="#FF33CC")

#create a combined list with the oldest and the youngest dates of the site
youngoldsel3 <- rbind(oldest.youngoldsel3, youngest.youngoldsel2)

#add columns for related partner age (youngest date for oldest dates and vice versa)
youngoldsel3 <- data.frame(youngoldsel3, PARTNERAGE = youngoldsel3$CALAGE)

#exchange partner ages
youngoldsel3 <- lapply(
  split(youngoldsel3, youngoldsel3$SITE),
  function(x){
    if(length(x[,1])==2){
      x$PARTNERAGE[1] <- x$CALAGE[2]
      x$PARTNERAGE[2] <- x$CALAGE[1]
    }
    return(x)
  }
)
youngoldsel3 <- do.call(rbind, youngoldsel3)


##### export of date selections #####

write.table(youngoldsel1, "mapping/shiny_app/radiocarbon3/data/youngoldsel1.csv", sep="\t", col.names = NA)
write.table(youngoldsel2, "mapping/shiny_app/radiocarbon3/data/youngoldsel2.csv", sep="\t", col.names = NA)
write.table(youngoldsel3, "mapping/shiny_app/radiocarbon3/data/youngoldsel3.csv", sep="\t", col.names = NA)
write.table(Europe.red1, "mapping/shiny_app/radiocarbon3/data/Europe.red1.csv", sep="\t", col.names = NA)
write.table(Europe.red2, "mapping/shiny_app/radiocarbon3/data/Europe.red2.csv", sep="\t", col.names = NA)
write.table(Europe.red3, "mapping/shiny_app/radiocarbon3/data/Europe.red3.csv", sep="\t", col.names = NA)
