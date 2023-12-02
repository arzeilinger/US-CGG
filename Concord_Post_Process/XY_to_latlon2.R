XY_to_latlon2 <- function(lat.center, lon.center, x.ls, y.ls) {
  #library(SpatialEpi)
  
  utm.center <- SpatialEpi::latlong2grid(data.frame(x = lon.center,
                                                    y = lat.center))
  
  utm.all <- data.frame(x = x.ls / 1000 + utm.center$x,
                        y = y.ls / 1000 + utm.center$y)
  
  latlong <- SpatialEpi::grid2latlong(utm.all)
  
  return(latlong)
}