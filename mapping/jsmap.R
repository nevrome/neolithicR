#load libraries
library(leaflet)
library(magrittr)
library(dplyr)

#load dataset
matrix <- read.csv("~/Rstats/neolithicR/data/radiocarbon/Europe.csv", 
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

#reduce the date selection to the oldest date of each site
oldest.dates1 <- lapply(
  split(matrix.red2, matrix.red2$SITE), 
  function(x) {
    x[which.max(x$CALAGE), c(1:6)]
  }
)

oldest.dates2 <- do.call(rbind, oldest.dates1)

#sort dates by age
oldest.dates2 <- oldest.dates2[order(oldest.dates2$CALAGE),]

#define sources of background map
tiles <- "http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
att <- 'Map data: &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'

#text popup definition
site.popup <- paste0(
  "<strong>Site: </strong>", 
  oldest.dates2$SITE, 
  "<br><strong>Lab number: </strong>",
  oldest.dates2$LABNR, 
  "<br><strong>Age: </strong>",
  oldest.dates2$CALAGE, 
  "calBP",
  "<br><strong>Reference: </strong>",
  oldest.dates2$REFERENCE 
)

#mapping the complete dataset with leaflet
leaflet(oldest.dates2) %>% 
  addTiles(
    urlTemplate = tiles,
    attribution = att) %>% 
  addCircles(
    lat = ~ LATITUDE, 
    lng = ~ LONGITUDE, 
    color = rainbow(length(oldest.dates2[,1]), alpha = NULL, start = 0, end = 2/6), 
    radius = ~ CALAGE,
    popup = site.popup) %>%
  clearBounds()
