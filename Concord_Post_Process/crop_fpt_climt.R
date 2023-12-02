crop_fpt_climt <- function(x, # n vector
                           y, # m vector
                           z, # n*m matrix
                           crop.bound,  # 2*l matrix
                           trim.beyond.bound = T) {
  
  x.res <- (round(mean(x[-1] - x[-length(x)]), digits = 6))
  y.res <- (round(mean(y[-1] - y[-length(y)]), digits = 6))
  
  x <- seq(x[1], x[1] + (length(x) - 1) * x.res, by = x.res)
  y <- seq(y[1], y[1] + (length(y) - 1) * y.res, by = y.res)
  
  dat1 = list()
  dat1$x <- x 
  dat1$y <- y
  dat1$z <- z 
  
  weight.map <- raster::raster(dat1)
  
  crop.bound <- sp::Polygon(crop.bound)
  
  crop.bound <-
    sp::SpatialPolygons(list(sp::Polygons(list(crop.bound), "crop.bound")))
  
  crop.map <- raster::mask(weight.map, crop.bound)
  
  ## normalize weights to 80% extent (sum to 100%)
  crop.map <- crop.map / raster::cellStats(crop.map, stat = 'sum', na.rm = T)
  
  ## trim the outer areas beyond crop.bound
  if (trim.beyond.bound) {
    crop.map <- raster::trim(crop.map)
  }
  
  #plot(weight.map)
  crop.map.df <- as.data.frame(as.matrix(crop.map))
  # setting 'x' column names
  colnames(crop.map.df) <-
    seq(raster::extent(crop.map)[1] + x.res / 2,
        raster::extent(crop.map)[2] - x.res / 2,
        length.out = dim(crop.map)[2])
  # creating 'y' column names
  crop.map.df$y <-
    rev(seq(
      raster::extent(crop.map)[3] + y.res / 2,
      raster::extent(crop.map)[4] - y.res / 2,
      length.out = dim(crop.map)[1]
    ))
  
  # wide to long conversion
  crop.map.df <- reshape2::melt(crop.map.df, id.vars = "y")
  
  # better names
  colnames(crop.map.df) <- c("y", "x", "weight")
  
  # crop those empty cells
  #crop.map.df<-crop.map.df[!is.na(crop.map.df$weight),]
  crop.map.df$y <- as.numeric(paste(crop.map.df$y))
  crop.map.df$x <- as.numeric(paste(crop.map.df$x))
  #crop.map.df$weight<-as.numeric(paste(crop.map.df$weight))
  
  return(crop.map.df)
}