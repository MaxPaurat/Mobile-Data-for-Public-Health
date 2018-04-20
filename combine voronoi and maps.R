library(readxl)
library(rgdal)
library(deldir)
library(dplyr)
library(ggplot2)
library(rgeos)
#library(UScensus2010)

#read in shapefiles
SEN <- readOGR(dsn = "data", layer = "SEN_outline")
SEN_level_1 <- readOGR(dsn = "data", layer = "SEN-level_1")
SEN_arr <- readOGR(dsn = "data", layer = "senegal_arr_2014_wgs")

#function to get Voronoi-SpatialPolygons from coordinates of antenna positions, inside a SpatialPolygonsDataframe
voronoipolygons <- function(x,poly) {
  require(deldir)
  if (.hasSlot(x, 'coords')) {
    crds <- x@coords  
  } else crds <- x
  bb = bbox(poly)
  rw = as.numeric(t(bb))
  z <- deldir(crds[,1], crds[,2],rw=rw)
  w <- tile.list(z)
  polys <- vector(mode='list', length=length(w))
  require(sp)
  for (i in seq(along=polys)) {
    pcrds <- cbind(w[[i]]$x, w[[i]]$y)
    pcrds <- rbind(pcrds, pcrds[1,])
    polys[[i]] <- Polygons(list(Polygon(pcrds)), ID=as.character(i))
  }
  SP <- SpatialPolygons(polys)
  
  voronoi <- SpatialPolygonsDataFrame(SP, data=data.frame(x=crds[,1],
                                                          y=crds[,2], row.names=sapply(slot(SP, 'polygons'), 
                                                                                       function(x) slot(x, 'ID'))))
  
  return(voronoi)
  
}

#use function above
antvor.coords<-voronoipolygons(coords,SEN)
gg = gIntersection(SEN,antvor.coords,byid=TRUE)

#plot without colour
plot(gg)

#define values to map
z = runif(1668, 0, 1)
poly_df= data.frame(z)

#combine to SpatialPolygonsDataFrame
s_poly <- SpatialPolygonsDataFrame(gg, poly_df, match.ID = FALSE)

#plot with colour
spplot(s_poly, zcol="z")


