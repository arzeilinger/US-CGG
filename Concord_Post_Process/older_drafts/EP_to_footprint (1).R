rm(list=ls())

##############################################################
######  Read in EddyPro full output file, reformat and select   
######   needed variables for online Kljun footprint model
######
##############################################################

#### data I/O directory
path<-"C:\\Users\\Tommy\\flux\\Data-exploring\\02_Concord\\"
path.in<-paste(path,"01_Proccessed_Data",sep="")
path.out<-paste(path,"02_Footprint_Analysis",sep="")

## "C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\2019-09-25_All_data_To_Date\eddypro_20190925_Concord_alltodate.csv"
ver<-"Master_Eddy" 
file.name<-paste("master_eddy_pro_concord",sep="")

#### read in eddypro full output file, parse variable names
data.in<-read.csv(paste(path.in,"\\",ver,"\\",file.name,".csv",sep=""),
                  header=F,
                  skip=3,
                  na.strings=c("-9999.0"),
                  stringsAsFactors = F)
colnames(data.in)<-colnames(
  read.csv(paste(path.in,"\\",ver,"\\",file.name,".csv",sep=""),
           header=T,
           skip=1))

## pharse time stamp
data.in$TIMESTAMP<-strptime(paste(data.in$date,data.in$time,sep=" "),
                            format="%Y-%m-%d %H:%M",tz="UTC")

#### correct the wind direction (shift North offset from 228.4 to 49 deg)
##data.in$wind_dir_corr<-data.in$wind_dir-(228.4-49)
##data.in$wind_dir_corr[!is.na(data.in$wind_dir_corr)&
                       ### data.in$wind_dir_corr<0] <-
  ###360 + data.in$wind_dir_corr[!is.na(data.in$wind_dir_corr)
                           ### &data.in$wind_dir_corr<0]

## filter ustar based on qc_Tau
data.in$u.[!is.na(data.in$qc_Tau)&data.in$qc_Tau==2]<-NA

## prepare file format for Kljun Online footprint model
data.fpt<-data.frame(yyyy=data.in$TIMESTAMP$year+1900,
                     mm=data.in$TIMESTAMP$mon+1,
                     day=data.in$TIMESTAMP$mday,
                     HH=floor(data.in$TIMESTAMP$hour),
                     MM=data.in$TIMESTAMP$min,
                     zm=3.67,  ## measurement height (m)
                     d=0,      ## displacement height (m)
                     z0=0.05,  ## roughness length (m)
                     u_mean=data.in$wind_speed,  ## wind speed
                     L=data.in$L,    ## Monin-Obukov length (m)
                     sigma_v=sqrt(data.in$v_var),  ## cross-wind standard deviation (m/s)
                     u_star=data.in$u.,  ## frisction velocity (m/s)
                     wind_dir=data.in$wind_dir)  ## wind direction

data.fpt<-na.omit(data.fpt)

write.csv(data.fpt,
          paste(path.out,ver,"_fpt_short.csv",sep=""),
          quote = T,
          row.names = F)

