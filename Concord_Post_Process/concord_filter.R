concord_filter<-function(data.in){
  
  ## Change units
  data.in$w.co2_cov<-data.in$w.co2_cov*1000
  data.in$sonic_temperature<-data.in$sonic_temperature-273.15
  
  ## QC filtering
  # coordinate rotation angle
  data.in[!is.na(data.in$pitch)&abs(data.in$pitch)>6,c("co2_flux","H","LE",
                                                       "w.co2_cov","w.h2o_cov","w.ts_cov")]<-NA
  # statistics of sonic-T
  data.in[!is.na(data.in$w.ts_cov)&
            abs(data.in$w.ts_cov)>0.3,c("w.ts_cov")]<-NA
  data.in[!is.na(data.in$ts_var)&
            abs(data.in$ts_var)>1,c("ts_var")]<-NA
  
  # LI7500 signal strength
  data.in[!is.na(data.in$co2_signal_strength_7500_mean)&
            data.in$co2_signal_strength_7500_mean<85,c("co2_flux","LE",
                                                       "w.co2_cov","w.h2o_cov",
                                                       "co2_var","h2o_var",
                                                       "co2_molar_density","h2o_molar_density", "RH", "VPD")]<-NA
  # H2O statistics
  data.in[!is.na(data.in$h2o_molar_density)&
            data.in$h2o_molar_density>2000,c("h2o_var",
                                             "h2o_molar_density")]<-NA
  data.in[!is.na(data.in$h2o_var)&
            data.in$h2o_var>3000,c("h2o_var",
                                   "h2o_molar_density")]<-NA
  data.in[!is.na(data.in$w.h2o_cov)&
            abs(data.in$w.h2o_cov-5.5)>6.5,c("LE",
                                             "w.h2o_cov",
                                             "h2o_var",
                                             "h2o_molar_density")]<-NA
  # CO2 statistics
  data.in[!is.na(data.in$co2_molar_density)&
            data.in$co2_molar_density<12,c("co2_var",
                                           "co2_molar_density")]<-NA
  data.in[!is.na(data.in$co2_var)&
            data.in$co2_var>0.02,c("co2_var",
                                   "co2_molar_density")]<-NA
  data.in[!is.na(data.in$w.co2_cov)&
            abs(data.in$w.co2_cov-(-15))>35,c("co2_flux",
                                              "w.co2_cov",
                                              "co2_var",
                                              "co2_molar_density")]<-NA
  
  # Stationary / Integral Turbulence Characteristics (Foken flag)
  # check which system is used (0-1-2 or 1-9)
  data.in$co2_flux[!is.na(data.in$qc_co2_flux)&data.in$qc_co2_flux>1]<-NA
  data.in$H[!is.na(data.in$qc_H)&data.in$qc_H>1]<-NA
  data.in$LE[!is.na(data.in$qc_LE)&data.in$qc_LE>1]<-NA
  data.in$h2o_flux[!is.na(data.in$qc_h2o_flux)&data.in$qc_h2o_flux>1]<-NA
  
  #adgusting air temperature
  data.in$air_temperature_adj= (data.in$air_temperature-273.15)
  
  #Net radiation
  
  #adding correct coefficient
  data.in$Correct_NR= (data.in$NR_Wm2_Avg*10)/14.2
  
  #filtering NR based on upper and lower bounds
  data.in$Correct_NR[!is.na(data.in$Correct_NR)&(data.in$Correct_NR<(-150)|data.in$Correct_NR>800)]<-NA
  #summary(data.in$Correct_NR)
  #plot(data.in$Correct_NR)
  

  
  #PAR in and PAR Out 
  #Filtering out anything before 12-6-2019. That is when we installed rest is noise
  data.in$PAR_in_mV_Avg[(data.in$TIMESTAMP<
                           as.POSIXct(strptime("2019-12-07 00:00:00",
                                               "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8")))]<-NA
  
  data.in$PAR_in_uEm2_Avg[(data.in$TIMESTAMP<
                           as.POSIXct(strptime("2019-12-07 00:00:00",
                                               "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8")))]<-NA
  
  data.in$PAR_out_mV_Avg[(data.in$TIMESTAMP<
                             as.POSIXct(strptime("2019-12-07 00:00:00",
                                                 "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8")))]<-NA
  data.in$PAR_out_uEm2_Avg[(data.in$TIMESTAMP<
                            as.POSIXct(strptime("2019-12-07 00:00:00",
                                                "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8")))]<-NA
  #adding correct PAR coefficient
  data.in$PAR_in_uEm2_Avg= (data.in$PAR_in_mV_Avg*1000)/(6.38*0.604)
  
  data.in$PAR_out_uEm2_Avg= (data.in$PAR_out_mV_Avg*1000)/(6.38*0.604)
  
  
  #Converting PAR to Rg readins
  
  data.in$Rg = (data.in$PAR_in_uEm2_Avg)*0.47
  
  data.in$out_going_rad = (data.in$PAR_out_uEm2_Avg)*0.47


  
  #doing basic filters for our two RH readings
  #filtering anything over 100 and less than 0
  data.in$RH[!is.na(data.in$RH)&(data.in$RH<(0)|data.in$RH>100)]<-NA
  data.in$RH_Avg[!is.na(data.in$RH_Avg)&(data.in$RH_Avg<(0)|data.in$RH_Avg>100)]<-NA
  
  
  #Soil Heat Flux
  
  #adding coefficients for heatflux plate 1 and 2
  data.in$Correct_shf_1 = (data.in$SHF_1_mV_Avg*16.455)
  data.in$Correct_shf_2 = (data.in$SHF_2_mV_Avg*16.319)
  
  
  
  
  
  
  #filtering SHF based on upper and lower bounds
  data.in$Correct_shf_1[!is.na(data.in$Correct_shf_1)&(data.in$Correct_shf_1<(-500)|data.in$Correct_shf_1>500)]<-NA
  
  #not installed until november 18 and then Met Sensors went down until 12/5. so readings don't begin until
  #11/18/2020 at the earliest, most likely 12/5. Anything before 11/18 is noise!!!!!!
  data.in$Correct_shf_2[!is.na(data.in$Correct_shf_2)&(data.in$Correct_shf_2<(-500)|data.in$Correct_shf_2>500)]<-NA
  
  #filter based on timestamp
  #SHF 2 not installed until 2019-11-18
  data.in$Correct_shf_2[(data.in$TIMESTAMP<
                           as.POSIXct(strptime("2019-11-18 00:00:00",
                                               "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8")))]<-NA
  
  #SHF 1 started giving bad readings in May. Figured out and fixed the instruments on 7/21.
  data.in$Correct_shf_1[(data.in$TIMESTAMP>
                           as.POSIXct(strptime("2020-05-01 00:00:00",
                                               "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8"))&
                                        data.in$TIMESTAMP  <
                                        as.POSIXct(strptime("2020-07-22 00:00:00",
                                                            "%Y-%m-%d %H:%M:%S",tz="Etc/GMT-8"))
                           
                           )]<-NA
  
  
  #Air Temp
  data.in$AirT_Avg[!is.na(data.in$AirT_Avg)&(data.in$AirT_Avg<(0)|data.in$AirT_Avg>50)]<-NA
  
  #Soil Temperature, looping through all variables naming like "TC_Avg"
  TC.ls <- which(grepl("TC_Avg",colnames(data.in)))
  for(i in 1:length(TC.ls)){
    data.in[,TC.ls[i]][!is.na(data.in[,TC.ls[i]])&(data.in[,TC.ls[i]]<(-5)|data.in[,TC.ls[i]]>50)]<-NA
  }
  
  return(data.in)
  
}