
polar2cart<-function(x,y,dist,bearing,as.deg=FALSE){
  ## Translate Polar coordinates into Cartesian coordinates
  ## based on starting location, distance, and bearing
  ## as.deg indicates if the bearing is in degrees (T) or radians (F)
  
  if(as.deg){
    ##if bearing is in degrees, convert to radians
    bearing=bearing*pi/180
  }
  
  newx<-x+dist*sin(bearing)  ##X
  newy<-y+dist*cos(bearing)  ##Y
  return(list("x"=newx,"y"=newy))
}
