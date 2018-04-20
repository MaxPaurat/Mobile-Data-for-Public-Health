#Read in Data
library(rgdal)
library(plyr)

##### DHS #####
#Cluster Coordinates#

DHSshapefile = readOGR("Data\\DHS Senegal 2012-13\\Stata\\SNGE6AFL","SNGE6AFL")
plot(DHSshapefile)

##### Mobile Data #####

rawmobility = read.csv( "Data\\Challenge Data\\SET2\\SET2_P01small.CSV", header = FALSE)
colnames(rawmobility) = c("V1"="user_ID", "V2"="timestamp", "V3"="site_ID")
rawmobility$timestamp = as.character(rawmobility$timestamp)

antennalocations = read.csv("Data\\Challenge Data\\ContextData\\SITE_ARR_LONLAT.CSV", header = TRUE)

