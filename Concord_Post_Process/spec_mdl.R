spec_mdl<-function(target.spec,
                   log.f.rng=seq(-4,4,0.001),
                   all.mdl=F){
  
  ## output single data frame contains log(f)=log(nZ/U) different models of nSx/var(x) or nCxy/cov(xy)
  
  spec.out<-data.frame(f=10^log.f.rng,
                       log.f=log.f.rng,
                       mdl1=NA,log.mdl1=NA,
                       mdl2=NA,log.mdl2=NA,
                       mdl3=NA,log.mdl3=NA,
                       mdl4=NA,log.mdl4=NA)
  
  spec.mdl.txt.ls<-list(fSx=c("Kaimal 72"),
                        fCxy=c("Kaimal 72","Sakai 01","Su 04","Su 04"))
  
  coeff1.ls<-data.frame(mdl=c("K72"),
                        bu1=c(105),
                        bu2=c(33),
                        bv1=c(17),
                        bv2=c(9.5),
                        bw1=c(2),
                        bw2=c(5.3),
                        bt1=c(53.4),
                        bt2=c(24),
                        bt3=c(24.4),
                        bt4=c(12.5))
  
  coeff2.ls<-data.frame(mdl=c("K72","S01","S04UMB","S04MMF"),
                        buw1=c(12,8.5,14.8,13.0),
                        buw2=c(9.6,12.4,11.4,10.1),
                        bwt1=c(11,7.6,5.4,5.6),
                        bwt2=c(13.3,11.5,11.0,11.9),
                        bwt3=c(4,7.6,1.8,0.9),
                        bwt4=c(3.8,11.5,2.7,1.8))
  
  if(substr(target.spec,start=1,stop=2)=="fS"){
    if(target.spec=="fSu"){
      
      ## Kaimal 1972, emprical
      spec.out$mdl1<-coeff1.ls$bu1[1]*spec.out$f/(1+coeff1.ls$bu2[1]*spec.out$f)^(5/3)/6.2
      spec.out$log.mdl1<-log10(spec.out$mdl1)
      
    }else{
      if(target.spec=="fSv"){
      
        ## Kaimal 1972, emprical
        spec.out$mdl1<-coeff1.ls$bv1[1]*spec.out$f/(1+coeff1.ls$bv2[1]*spec.out$f)^(5/3)/3.0
        spec.out$log.mdl1<-log10(spec.out$mdl1)
        
      }else{
        if(target.spec=="fSw"){
          
          ## Kaimal 1972, emprical
          spec.out$mdl1<-coeff1.ls$bw1[1]*spec.out$f/(1+coeff1.ls$bw2[1]*spec.out$f^(5/3))/1.7
          spec.out$log.mdl1<-log10(spec.out$mdl1)

        }else{  #fCt
          
          ## Kaimal 1972, emprical
          spec.out$mdl1[spec.out$f<=0.15]<-coeff1.ls$bt1[1]*spec.out$f[spec.out$f<=0.15]/(1+coeff1.ls$bt2[1]*spec.out$f[spec.out$f<=0.15])^(5/3)/4
          spec.out$mdl1[spec.out$f>0.15]<-coeff1.ls$bt3[1]*spec.out$f[spec.out$f>0.15]/(1+coeff1.ls$bt4[1]*spec.out$f[spec.out$f>0.15])^(5/3)/4
          spec.out$log.mdl1<-log10(spec.out$mdl1)
          
        }
      }
    }
  }else{ ## fCxy
    if(target.spec=="fCwu"){
      
      ## Kaimal 1972, empirical
      spec.out$mdl1<-coeff2.ls$buw1[1]*spec.out$f/(1+coeff2.ls$buw2[1]*spec.out$f)^(7/3)
      spec.out$log.mdl1<-log10(spec.out$mdl1)
      
      ## Sakai 2001, empirical
      spec.out$mdl2<-coeff2.ls$buw1[2]*spec.out$f/(1+(coeff2.ls$buw2[2]*spec.out$f)^(7/3))
      spec.out$log.mdl2<-log10(spec.out$mdl2)
      
      ## Su 2004, empirical, UMB
      spec.out$mdl3<-coeff2.ls$buw1[3]*spec.out$f/(1+coeff2.ls$buw2[3]*spec.out$f)^(7/3)
      spec.out$log.mdl3<-log10(spec.out$mdl3)
      
      ## Su 2004, empirical, MMF
      spec.out$mdl4<-coeff2.ls$buw1[4]*spec.out$f/(1+coeff2.ls$buw2[4]*spec.out$f)^(7/3)
      spec.out$log.mdl4<-log10(spec.out$mdl4)
      
    }else{  # fCwt
      
      ## Kaimal 1972, empirical
      spec.out$mdl1[spec.out$f<=1]<-coeff2.ls$bwt1[1]*spec.out$f[spec.out$f<=1]/(1+coeff2.ls$bwt2[1]*spec.out$f[spec.out$f<=1])^(7/4)
      spec.out$mdl1[spec.out$f>1]<-coeff2.ls$bwt3[1]*spec.out$f[spec.out$f>1]/(1+coeff2.ls$bwt4[1]*spec.out$f[spec.out$f>1])^(7/3)
      spec.out$log.mdl1<-log10(spec.out$mdl1)
      
      ## Sakai 2001, empirical
      spec.out$mdl2<-coeff2.ls$bwt1[2]*spec.out$f/(1+(coeff2.ls$bwt2[2]*spec.out$f)^(7/3))
      spec.out$log.mdl2<-log10(spec.out$mdl2)
      
      ## Su 2004, empirical, UMB
      spec.out$mdl3[spec.out$f<=1]<-coeff2.ls$bwt1[3]*spec.out$f[spec.out$f<=1]/(1+(coeff2.ls$bwt2[3]*spec.out$f[spec.out$f<=1])^(7/4))
      spec.out$mdl3[spec.out$f>1]<-coeff2.ls$bwt3[3]*spec.out$f[spec.out$f>1]/(1+coeff2.ls$bwt4[3]*spec.out$f[spec.out$f>1])^(7/3)
      spec.out$log.mdl3<-log10(spec.out$mdl3)
      
      ## Su 2004, empirical, MMF
      spec.out$mdl4[spec.out$f<=1]<-coeff2.ls$bwt1[4]*spec.out$f[spec.out$f<=1]/(1+(coeff2.ls$bwt2[4]*spec.out$f[spec.out$f<=1])^(7/4))
      spec.out$mdl4[spec.out$f>1]<-coeff2.ls$bwt3[4]*spec.out$f[spec.out$f>1]/(1+coeff2.ls$bwt4[4]*spec.out$f[spec.out$f>1])^(7/3)
      spec.out$log.mdl4<-log10(spec.out$mdl4)
      
    }
  }
  ### clean out alternatives if 'all.mdl' is set to False
  if(!all.mdl){spec.out<-spec.out[,c(1:which(colnames(spec.out)=="log.mdl1"))]}
  
  return(list(spec.out,spec.mdl.txt.ls))
}