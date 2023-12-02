find_equal_dist <- function(mylat,
                            mylon,
                            dist.target,
                            res.deg = 10 ^ -4,
                            echo = FALSE) {
  #require(geosphere)
  
  #mylat<-latitude
  #mylon<-longitude
  #dist.target<-5000
  
  get.bound <- XY_to_latlon2(
    lat.center = mylat,
    lon.center = mylon,
    x.ls = c(1, 0, -1, 0) * dist.target * 4,
    y.ls = c(0, 1, 0, -1) * dist.target * 4
  )
  
  res.deg <- max(c(res.deg,
                   (max(get.bound[, 1]) - min(get.bound[, 1])) / 10000,
                   (max(get.bound[, 2]) - min(get.bound[, 2])) / 10000))
  
  lon <- seq(min(get.bound[, 1]), max(get.bound[, 1]), by = res.deg)
  lat <- seq(min(get.bound[, 2]), max(get.bound[, 2]), by = res.deg)
  
  #prepare a matrix with coordinates of every position
  allCoords <- cbind(lon, rep(lat, each = length(lon)))
  
  #call the dist function and put the result in a matrix
  res <-
    abs(geosphere::distm(cbind(mylon, mylat), allCoords, fun = distHaversine) - dist.target) <=
    1
  
  if (sum(res) < 100) {
    
    if(echo){
      print(paste("only", sum(res), "points returned, double resolution"))  
    }

    res.deg <- max(c(res.deg / 4,
                     (max(get.bound[, 1]) - min(get.bound[, 1])) / 10000 /
                       4,
                     (max(get.bound[, 2]) - min(get.bound[, 2])) / 10000 /
                       4))
    
    lon <- seq(min(get.bound[, 1]), max(get.bound[, 1]), by = res.deg)
    lat <- seq(min(get.bound[, 2]), max(get.bound[, 2]), by = res.deg)
    
    #prepare a matrix with coordinates of every position
    allCoords <- cbind(lon, rep(lat, each = length(lon)))
    
    #call the dist function and put the result in a matrix
    res <-
      abs(geosphere::distm(cbind(mylon, mylat), allCoords, fun = distHaversine) - dist.target) <=
      1
    
  }
  
  outCoords.tmp <- as.data.frame(allCoords[res, ])
  colnames(outCoords.tmp) <- c("lon", "lat")
  
  outCoords.tmp1 <-
    outCoords.tmp[outCoords.tmp$lat > mylat |
                    (outCoords.tmp$lat == mylat & outCoords.tmp$lon > mylon), ]
  outCoords.tmp2 <-
    outCoords.tmp[outCoords.tmp$lat < mylat |
                    (outCoords.tmp$lat == mylat & outCoords.tmp$lon < mylon), ]
  
  outCoords <-
    rbind.data.frame(outCoords.tmp1[order(outCoords.tmp1$lon), ],
                     outCoords.tmp2[rev(order(outCoords.tmp2$lon)), ])
  outCoords <- rbind.data.frame(outCoords,
                                outCoords[1, ])
  
  return(outCoords)
  
}
