sgl_spec_plot<-function(data.in,
                        target.var,
                        zL.rng.i=NA,
                        zL.rng.f=NA,
                        x.rng.i=NA,
                        x.rng.f=NA,
                        y.rng.i=NA,
                        y.rng.f=NA,
                        plot.text=NA,
                        plot.x.axis=F,
                        plot.y.label=F,
                        plot.loess=F,
                        log.y.value=F){
  
  #data.in<-cspec.data.pre
  #target.var<-"fCwu"
  #zL.rng.i<-(-0.01)
  #zL.rng.f<-(0.02)
  
  target.var.ls<-c("fSu","fSv","fSw","fSt","fSq","fSc","fSm",
                   "fCwu","fCwv","fCwt","fCwq","fCwc","fCwm")
  
  target.var.txt.ls<-c(expression(fS[u]),
                       expression(fS[v]),
                       expression(fS[w]),
                       expression(fS[t]),
                       expression(fS[c]),
                       expression(fS[q]),
                       expression(fS[m]),
                       expression(fC[wu]),
                       expression(fC[wv]),
                       expression(fC[wt]),
                       expression(fC[wc]),
                       expression(fC[wq]),
                       expression(fC[wm]))
  
  target.var.loc<-which(target.var.ls==target.var)
  
  ### create a subset of data
  data.tmp<-data.in[,c("zL","f","fh.u",target.var)]
  
  if(!is.na(zL.rng.i)){
    data.tmp[!is.na(data.tmp$zL)&data.tmp$zL<zL.rng.i,c(target.var)]<-NA  
  }  
  if(!is.na(zL.rng.f)){
    data.tmp[!is.na(data.tmp$zL)&data.tmp$zL>zL.rng.f,c(target.var)]<-NA  
  }  
  data.tmp<-data.tmp[!is.na(data.tmp[,c(target.var)]),]
  
  #### plot only if enough data
  if(nrow(data.tmp)>50){
    
    if(log.y.value){ ## log-transform y values, or not
      data.tmp$log.y<-log10(abs(data.tmp[,c(target.var)]))
    }else{ 
      data.tmp$log.y<-(data.tmp[,c(target.var)])  
    }
    
    data.tmp$log.x<-log10(data.tmp$fh.u)
    
    data.tmp<-data.tmp[order(data.tmp$fh.u),]
    
    ##    these ranges are used for plot.range
    if(is.na(x.rng.i)){x.rng.i<-(min(data.tmp$log.x)-0.2)}
    if(is.na(x.rng.f)){x.rng.f<-(max(data.tmp$log.x)+0.2)}
    if(is.na(y.rng.i)){y.rng.i<-(min(data.tmp$log.y)-0.2)}
    if(is.na(y.rng.f)){y.rng.f<-(max(data.tmp$log.y)+0.2)}
    
    ## these ranges are used only for axis label generation
    x.rng2.i<-ifelse(!is.na(x.rng.i),floor(x.rng.i),floor(min(data.tmp$log.x))) 
    x.rng2.f<-ifelse(!is.na(x.rng.f),ceiling(x.rng.f),ceiling(max(data.tmp$log.x))) 
    y.rng2.i<-ifelse(!is.na(y.rng.i),floor(y.rng.i),floor(min(data.tmp$log.y))) 
    y.rng2.f<-ifelse(!is.na(y.rng.f),ceiling(y.rng.f),ceiling(may(data.tmp$log.y))) 
    
    
    plot(data.tmp$log.x,
         data.tmp$log.y,
         xlab="",ylab="",xlim=c(x.rng.i,x.rng.f),ylim=c(y.rng.i,y.rng.f),
         xaxt="n",yaxt="n",pch=21,bg="grey",col="black",cex=0.8)
    
    if(log.y.value){
      axis(side=2,at=c(0,rep(log10(seq(1,10,length.out=11)[-1]),y.rng2.f-y.rng2.i))+c(y.rng2.i,rep(c(y.rng2.i:(y.rng2.f-1)),each=10)),labels=NA,tcl=-0.2)
      axis(side=2,at=seq(-6,6,1),labels=c(expression(10^{-6}),expression(10^{-5}),expression(10^{-4}),
                                          expression(10^{-3}),expression(10^{-2}),expression(10^{-1}),
                                          expression(10^{0}),expression(10^{1}),expression(10^{2}),
                                          expression(10^{3}),expression(10^{4}),expression(10^{5}),
                                          expression(10^{6})),tcl=-0.4,las=2)
    }else{
      axis(side=2,at=seq(y.rng2.i,y.rng2.f,by=0.1),labels=NA,tcl=-0.2)
      axis(side=2,at=seq(y.rng2.i,y.rng2.f,by=1),tcl=-0.4,las=2)
    }
    
    if(plot.y.label){
      mtext(side=2,target.var.txt.ls[target.var.loc],line=3,font=2,outer=F,adj=0.5)  
    }
    
    if(plot.x.axis){
      axis(side=1,at=c(0,rep(log10(seq(1,10,length.out=11)[-1]),x.rng2.f-x.rng2.i))+c(x.rng2.i,rep(c(x.rng2.i:(x.rng2.f-1)),each=10)),labels=NA,tcl=-0.2)
      axis(side=1,at=seq(-6,6,1),labels=c(expression(10^{-6}),expression(10^{-5}),expression(10^{-4}),
                                          expression(10^{-3}),expression(10^{-2}),expression(10^{-1}),
                                          expression(10^{0}),expression(10^{1}),expression(10^{2}),
                                          expression(10^{3}),expression(10^{4}),expression(10^{5}),
                                          expression(10^{6})),tcl=-0.4,las=1)
      mtext(side=1,expression(fz~'/'~U),line=3,font=2,outer=F,adj=0.5)
    }
    
    if(plot.loess){
      loess.tmp<-loess(log.y~log.x,
                       data=data.tmp)
      lines(loess.tmp$x,loess.tmp$fitted,lwd=3,col="darkgrey")
      
      log.fh.u.max<-loess.tmp$x[which(loess.tmp$fitted==max(loess.tmp$fitted,na.rm=T))]
      log.fS.max<-loess.tmp$fitted[which(loess.tmp$fitted==max(loess.tmp$fitted,na.rm=T))]
      fh.u.max<-10^log.fh.u.max
      abline(v=log.fh.u.max,col="red",lwd=1.5,lty=2)
      text(log.fh.u.max+0.1,log.fS.max-1,paste(round(fh.u.max,digits=2)),adj=c(0,1),col="red",font=3)
    }
    
    if(!is.na(plot.text)){
      text(x.rng.i+0.1,y.rng.f,plot.text,adj=c(0,1),font=3)
    }
    
  }else{
    ##    these ranges are used for plot.range
    if(is.na(x.rng.i)){x.rng.i<-(-3)}
    if(is.na(x.rng.f)){x.rng.f<-2}
    if(is.na(y.rng.i)){y.rng.i<-(-2)}
    if(is.na(y.rng.f)){y.rng.f<-2}
    
    ## these ranges are used only for axis label generation
    x.rng2.i<-x.rng.i
    x.rng2.f<-x.rng.f
    y.rng2.i<-y.rng.i
    y.rng2.f<-y.rng.f
    
    plot(0,0,
         xlab="",ylab="",xlim=c(x.rng.i,x.rng.f),ylim=c(y.rng.i,y.rng.f),
         xaxt="n",yaxt="n",pch=21,bg="white",col="white",cex=0.8)
    
    if(log.y.value){
      axis(side=2,at=c(0,rep(log10(seq(1,10,length.out=11)[-1]),y.rng2.f-y.rng2.i))+c(y.rng2.i,rep(c(y.rng2.i:(y.rng2.f-1)),each=10)),labels=NA,tcl=-0.2)
      axis(side=2,at=seq(-6,6,1),labels=c(expression(10^{-6}),expression(10^{-5}),expression(10^{-4}),
                                          expression(10^{-3}),expression(10^{-2}),expression(10^{-1}),
                                          expression(10^{0}),expression(10^{1}),expression(10^{2}),
                                          expression(10^{3}),expression(10^{4}),expression(10^{5}),
                                          expression(10^{6})),tcl=-0.4,las=2)
    }else{
      axis(side=2,at=seq(y.rng2.i,y.rng2.f,by=0.1),labels=NA,tcl=-0.2)
      axis(side=2,at=seq(y.rng2.i,y.rng2.f,by=1),tcl=-0.4,las=2)
    }
    
    if(plot.y.label){
      mtext(side=2,target.var.txt.ls[target.var.loc],line=3,font=2,outer=F,adj=0.5)  
    }
    
    if(plot.x.axis){
      axis(side=1,at=c(0,rep(log10(seq(1,10,length.out=11)[-1]),x.rng2.f-x.rng2.i))+c(x.rng2.i,rep(c(x.rng2.i:(x.rng2.f-1)),each=10)),labels=NA,tcl=-0.2)
      axis(side=1,at=seq(-6,6,1),labels=c(expression(10^{-6}),expression(10^{-5}),expression(10^{-4}),
                                          expression(10^{-3}),expression(10^{-2}),expression(10^{-1}),
                                          expression(10^{0}),expression(10^{1}),expression(10^{2}),
                                          expression(10^{3}),expression(10^{4}),expression(10^{5}),
                                          expression(10^{6})),tcl=-0.4,las=1)
      mtext(side=1,expression(fz~'/'~U),line=3,font=2,outer=F,adj=0.5)
    }
    
    if(!is.na(plot.text)){
      text(x.rng.i+0.1,y.rng.f,plot.text,adj=c(0,1),font=3)
    }
  }
}
