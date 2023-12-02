get_extent<-function(x.ls,y.ls,scal.coeff=1){
  
  dist.ls<-sqrt(x.ls^2+y.ls^2)
  max.dist.loc<-which(dist.ls==max(dist.ls)[1])
  
  dist.target<-dist.ls[max.dist.loc]*scal.coeff
  #extent.ls<-data.frame(x.ls=scal.coeff*dist.target*cos(seq(0,2*pi,length=res.n)),
  #                      y.ls=scal.coeff*dist.target*sin(seq(0,2*pi,length=res.n)))
  
  return(dist.target)
}