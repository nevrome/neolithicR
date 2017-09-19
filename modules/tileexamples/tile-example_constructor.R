library(ggmap)
library(ggplot2)

### Set a range
lat <- c(44.49, 44.5)                
lon <- c(11.33, 11.36)   

### Get a map
map <- get_map(
  location = c(
    lon = mean(lon), 
    lat = mean(lat)), 
    zoom = 14,
    maptype = "satellite", 
    source = "google"
  )

### When you draw a figure, you limit lon and lat.      
foo <- ggmap(map)+
  scale_x_continuous(limits = c(11.33, 11.36), expand = c(0, 0)) +
  scale_y_continuous(limits = c(44.49, 44.5), expand = c(0, 0))

foo