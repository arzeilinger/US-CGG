rm(list=ls())

source("concord_filter.R")
source("cospectra_plot3.R")
na.count<-function(x) sum(is.na(x))

## change root.path as needed
root.path<-"C:\\Users\\Tommy\\flux\\Data-exploring\\02_Concord\\"
eddypro.path<-paste0(root.path,"01_Proccessed_Data\\Master_Eddy\\") ## this is where the EddyPro outputs located
plot.path<-paste0(root.path,"01_Proccessed_Data\\spectrum_plot\\") ## this is where the output plots located

## use follows to specify the versions of EddyPro outputs
cdata.proc.case<-"spectral_data"
cdata.proc.time<-"2020-04-17T161020"
cdata.proc.ext<-"_adv"
#20190614-1700_binned_cospectra_2020-04-17T161020_adv
##############################################################
## handle full output file
# file name
cdata.file2<-paste0("master_eddy_pro_concord.csv")



#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\master_eddy_pro_concord.csv"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\eddypro_binned_cospectra"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\eddypro_full_cospectra"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\spectrum_plot"


## read in full output file
cdata<-read.csv(paste(eddypro.path,cdata.file2,sep=""),
               skip=3,
               header=F,
               na.strings="-9999",
               stringsAsFactors=F)
colnames(cdata)<-colnames(read.csv(paste(eddypro.path,cdata.file2,sep=""),
                                  skip=1,
                                  header=T,
                                  na.strings="NaN"))

cdata<-cdata[cdata$filename!="not_enough_data"&
               !is.na(cdata$used_records),]

datetime<-data.frame(datetime=paste0(cdata$date," ",cdata$time))
TIMESTAMP<-strptime(datetime$datetime,format="%Y-%m-%d %H:%M",tz="EST")

#############################################################
## Unit conversion & site-specified filtering

cdata<-concord_filter(data.in=cdata)

##############################################################
################### work on (co)spectra data ##############################

zL.cut.rng<-c(-5,-0.1,0.1,1) ## setting the 3 Z/L ranges for plotting
cspec.data.pre<-NULL

data.pre<-cdata  

## work on file name of spectrum files
cspec.name.ls<-paste(substr(as.character(data.pre$date),start=1,stop=4),
                     substr(as.character(data.pre$date),start=6,stop=7),
                     substr(as.character(data.pre$date),start=9,stop=10),
                     "-",
                     substr(as.character(data.pre$time),start=1,stop=2),
                     substr(as.character(data.pre$time),start=4,stop=5),
                     "_binned_cospectra_",
                     cdata.proc.time,
                     cdata.proc.ext,".csv",sep="")

## scan if spectrum files exist
cspec.file.exist<-file.exists(paste0(eddypro.path,
                                     "eddypro_binned_cospectra\\",
                                     cspec.name.ls,
                                     sep=""))

cspec.data.pre<-data.frame()
cspec.var.name<-c("n.f","f","fh.u","fSu","fSv","fSw","fSt","fSc","fSq","fSm","fSn",
                  "fCwu","fCwv","fCwt","fCwc","fCwq","fCwm","fCwn")
cspec.var.name.select<-c("n.f","f","fh.u","fSu","fSv","fSw","fSt","fSc","fSq",
                         "fCwu","fCwv","fCwt","fCwc","fCwq")

## which spectrum variables to plot 
target.cspec<-c("fSw","fSt","fSc","fSq",
                "fCwu","fCwt","fCwc","fCwq")

### loop through the spetrum files, combine them into a single dataframe for plotting
for(i1 in 1:length(cspec.name.ls)){
  if(cspec.file.exist[i1]){
    
    ## read in each (co)spectra files
    cspec.data<-read.csv(paste(eddypro.path,
                               "eddypro_binned_cospectra\\",
                               cspec.name.ls[i1],sep=""),
                         skip=11,
                         header=T,
                         na.strings=c("-9999","-9999.0"))
    
    colnames(cspec.data)<-cspec.var.name
    
    ## combine spetrum data with basic state variables, e.g., WS, WD
    cspec.data.tmp<-data.frame(date=rep(data.pre$date[i1],nrow(cspec.data)),
                               time=rep(data.pre$time[i1],nrow(cspec.data)),
                               zL=rep(data.pre$X.z.d..L[i1],nrow(cspec.data)),
                               L=rep(data.pre$L[i1],nrow(cspec.data)),
                               WS=rep(data.pre$wind_speed[i1],nrow(cspec.data)),
                               WD=rep(data.pre$wind_dir[i1],nrow(cspec.data)),
                               cspec.data[,cspec.var.name.select])
    
    ### filter spetrum data based on corresponding variance/covariance
    
    if(is.na(data.pre$u.[i1])){
      cspec.data.tmp$fSu<-NA
      cspec.data.tmp$fCwu<-NA
      cspec.data.tmp$fSv<-NA
      cspec.data.tmp$fCwv<-NA
      cspec.data.tmp$fSw<-NA
    }
    if(is.na(data.pre$H[i1])){
      cspec.data.tmp$fSt<-NA
      cspec.data.tmp$fCwt<-NA
    }
    if(is.na(data.pre$co2_flux[i1])){
      cspec.data.tmp$fSc<-NA
      cspec.data.tmp$fCwc<-NA
    }
    if(is.na(data.pre$LE[i1])){
      cspec.data.tmp$fSq<-NA
      cspec.data.tmp$fCwq<-NA
    }
    cspec.data.pre<-rbind.data.frame(cspec.data.pre,cspec.data.tmp)
  }else{
    print(paste(cspec.name.ls[i1],"not found"))  
  }                       
}

### output site-specific (co)spectra file (composite all records)
write.csv(cspec.data.pre,
          paste0(plot.path,
                 cdata.proc.case,
                 "_cospectra_compiled.csv",
                 sep=""),
          row.names=F)

#### loop through the target.var, do spetrum plotting 
for(m2 in 1:length(target.cspec)){
  
  cospectra_plot3(cspec.data.pre=cspec.data.pre,
                  target.var=target.cspec[m2], 
                  case="Concord",
                  year=TIMESTAMP[1]$year+1900,
                  doy.i=TIMESTAMP[1]$jday+1,
                  doy.f=TIMESTAMP[length(TIMESTAMP)]$jday+1,
                  output=T,
                  outDir=plot.path,
                  plot.loess=T,
                  postfix="",
                  log.y.value=T,
                  zL.cut.rng=zL.cut.rng)  
  
}



