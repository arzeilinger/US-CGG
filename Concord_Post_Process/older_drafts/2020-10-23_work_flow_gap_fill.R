library(REddyProc)
library(dplyr)
#library(lognorm) ## for Computation of effective number of observations, used in annual/daily aggregation

## change to local dir
root.ditr<-"D:\\Housen\\Flux\\Data-exploring\\Hualien_DNDF\\"
data.dir<-paste0(root.ditr,"data\\") ## where DNDF202007-4.txt locate
out.dir<-paste0(root.ditr,"output\\") ## store all output figures/files

flux.var <- c('NEE', 'LE', 'H')
met.var <- c('Rg', 'Tair', 'Tsoil', 'VPD', 'Ustar')

####################################################################################
# REddyProc typical workflow
#+++ Load data with 1 header and 1 unit row from (tab-delimited) text file
fileName <- "DNDF202007-4.txt"
EddyData <- fLoadTXTIntoDataframe(fileName,Dir = data.dir)

#+++ Replace long runs (repeated constants) of flux variables by NA
EddyData <- filterLongRuns(EddyData, flux.var)

#+++ Add time stamp in POSIX time format
EddyDataWithPosix <- fConvertTimeToPosix(EddyData,
                                         TFormat = 'YDH',
                                         Year = 'Year',
                                         Day = 'DoY',
                                         Hour = 'Hour')

#######  addtional filtering before processing
## a few likely LE outliers in nighttime, Jun-Aug, 2019
EddyDataWithPosix$LE[EddyDataWithPosix$Year == 2019 &
                       EddyDataWithPosix$DoY > 150 &
                       EddyDataWithPosix$DoY < 240 &
                       (EddyDataWithPosix$Hour < 6 | EddyDataWithPosix$Hour > 18) &
                       !is.na(EddyDataWithPosix$LE) & EddyDataWithPosix$LE > 50] <- NA

#+++ Initalize R5 reference class sEddyProc for post-processing of eddy data
#+++ with the variables needed for post-processing later
EProc <- sEddyProc$new('DNDF',
                       Data = EddyDataWithPosix,
                       ColNames = c(flux.var,met.var),
                       ColPOSIXTime = 'DateTime')

## plot flux variables before gap-filling 
for(i in 1:length(flux.var)){

  EProc$sPlotDiurnalCycle(flux.var[i],
                          Dir = out.dir)
  EProc$sPlotHHFluxes(flux.var[i],
                      Dir = out.dir)
  
}

#################################################################################################
###### LE and H processing
#### Gap fill variable with specified variables and limits (change as needed)
#    Marginal distribution sampling method by Reichstein et al.2005
#    It loops through gaps, and fill them iteratively by diff environmental condition, window size 
EProc$sMDSGapFill(Var = 'LE',
                  V1 = 'Rg', T1 = 30,   ## 'Rg' within +/-30 W m-2
                  V2 = 'VPD', T2 = 5,   ## 'VPD' within +/-5 hPa)
                  FillAll = TRUE)   

EProc$sMDSGapFill(Var = 'H',
                  V1 = 'Rg', T1 = 30,   ## 'Rg' within +/-30 W m-2
                  V2 = 'Tair', T2 = 2,  ## 'Tair' within +/-2 degC 
                  FillAll = TRUE)   

## plot flux variables after gap-filling 
for(i in 2:length(flux.var)){
  
  EProc$sPlotDiurnalCycle(paste0(flux.var[i],"_f"),
                          Dir = out.dir)
  EProc$sPlotHHFluxes(paste0(flux.var[i],"_f"),
                      Dir = out.dir)
  
}

################################################################################################
###### NEE processing
#### Ustar threshold determination; moving-point-transition (MP) 
#    described originally by Reichstein et al.2005 and Papale et al.2006
#    include bootstrapping to get a distribution of possible ustar thresholds
EProc$sEstimateUstarScenarios(nSample = 100L, 
                              probs = c(0.05, 0.5, 0.95)) ## 5th, 50th, 95th precentiles of ustar thresholds

#### REddyProc support another approach determining Ustar threshol
#     Change Point Detection (CPT) method, by Barr et al 2013
#     note: this method takes longer to run, and usually yields higher thresholds and marks more data as gap
# EProc$sEstimateUstarScenarios(nSample = 100L, 
#                               probs = c(0.05, 0.5, 0.95),
#                               ctrlUstarEst = usControlUstarEst(isUsingCPTSeveralT = TRUE) )

# inspect the thresholds to be used by default
EProc$sGetEstimatedUstarThresholdDistribution()
EProc$sGetUstarScenarios()

#### Gap fill variable with specified variables and limits (change as needed)
#    Marginal distribution sampling method by Reichstein et al.2005
#    It loops through gaps, and fill them iteratively by diff environmental condition, window size 
EProc$sMDSGapFillUStarScens('NEE',
                            V1 = 'Rg', T1 = 30, ## 'Rg' within +/-30 W m-2
                            V2 = 'Tair', T2 = 2,  ## 'Tair' within +/-2 degC
                            V3 = 'VPD', T3 = 5,   ## 'VPD' within +/-5 hPa
                            FillAll = TRUE)

# get a list of gap-filled NEE, based on diff ustar thresholds
flux.gf.var <- grep("NEE_.*_f$",names(EProc$sExportResults()), value = TRUE)

for(i in 1:length(flux.gf.var)){
  
  EProc$sPlotDiurnalCycle(flux.gf.var[i],
                          Dir = out.dir)
  EProc$sPlotHHFluxes(flux.gf.var[i],
                      Dir = out.dir)
  
}

##################################################################################################
######  Partitioning NEE into GPP and Reco
####    Two approaches: 1) nighttime-based (Reichstein et al.2005)
#                       2) daytime-based (Lasslop et al. 2010)

# Lat/long and time zone to compute sunrise and sunset, used to differentiate daytime/nighttime.
EProc$sSetLocationInfo(LatDeg = 23.6, LongDeg = 121.4, TimeZoneHour = 8)

# while these variables don't needed gap-filling, the following partition functions need qc flags for these met variables 
EProc$sMDSGapFill('Tair', FillAll = FALSE,  minNWarnRunLength = NA)   
EProc$sMDSGapFill('Rg', FillAll = FALSE, minNWarnRunLength = NA)
EProc$sMDSGapFill('VPD', FillAll = FALSE,  minNWarnRunLength = NA) 

## Nighttime-based approach, partition all NEEs (e.g., NEE_ustar,NEE_U50,...) to corresponding GPP/RECO 
EProc$sMRFluxPartitionUStarScens(TempVar = 'Tair') # specify which temperature to use for building respiration model

# get a list of Reco and GPP_f by the respective ustar thresholds
gppreco.var.nt <- grep("GPP.*_f$|Reco.*",names(EProc$sExportResults()), value = TRUE)
gppreco.var.nt <- gppreco.var.nt[-which(grepl("_SD",gppreco.var.nt))]

for(i in 1:length(gppreco.var.nt)){
  
  EProc$sPlotDiurnalCycle(gppreco.var.nt[i],
                          Dir = out.dir)
  EProc$sPlotHHFluxes(gppreco.var.nt[i],
                      Dir = out.dir)
  
}

## Daytime-based approach, partition all NEEs (e.g., NEE_ustar,NEE_U50,...) to corresponding GPP/RECO 
#   two versions present: 1) sGLFluxPartitionUStarScens, based on original Lasslop 2010
#                         2) sTKFluxPartitionUStarScens, based on a modified version in Keenan 2019
#   note: this method takes long time & breaks sometimes, the argument 'uStarScenKeep' specify which 
#         ustar version should run to save time

#EProc$sGLFluxPartitionUStarScens(uStarScenKeep = "U50")
EProc$sTKFluxPartitionUStarScens(uStarScenKeep = "U50")

# get a list of Reco and GPP_f by the respective ustar thresholds
gppreco.var.dt <- grep("GPP_DT|Reco_DT",names(EProc$sExportResults()), value = TRUE)
gppreco.var.dt <- gppreco.var.dt[-which(grepl("_SD",gppreco.var.dt))]

for(i in 1:length(gppreco.var.dt)){
  
  EProc$sPlotDiurnalCycle(gppreco.var.dt[i],
                          Dir = out.dir)
  EProc$sPlotHHFluxes(gppreco.var.dt[i],
                      Dir = out.dir)
  
}

#############################################################################################################
###### Daily / Annual aggregation, accounting for correlation of errors among each half-hour 
#       see https://cran.r-project.org/web/packages/REddyProc/vignettes/aggUncertainty.html

####  quantify the error terms, i.e. model-data residuals
# FilledEddyData <- EProc$sExportResults() %>% mutate(
#   NEE.resid = ifelse(NEE_uStar_fqc == 0, NEE_uStar_orig - NEE_uStar_fall, NA )
# )

# #### Compute effective number of observations 
# #     based on the empirical autocorrelation function for given model-data residuals.
# autoCorr <- lognorm::computeEffectiveAutoCorr(FilledEddyData$NEE.resid)
# nEff <- lognorm::computeEffectiveNumObs(FilledEddyData$NEE.resid, na.rm = TRUE)
# 
# #### daily aggregation
# # create a daily index = year + doy/366
# FilledEddyData <- FilledEddyData %>% mutate(
#   DateTime = EddyDataWithPosix$DateTime,
#   YRDY = as.POSIXlt(DateTime)$year+1900 + as.POSIXlt(DateTime - 15*60)$yday/366 # midnight belongs to the previous
# )
# 
# aggDay <- FilledEddyData %>% group_by(YRDY) %>% 
#   summarise(
#     DateTime = first(DateTime),
#     nEff = computeEffectiveNumObs(
#       NEE.resid, effAcf = !!autoCorr, na.rm = TRUE),
#     NEE = mean(NEE_uStar_f, na.rm = TRUE),
#     sdNEE = if (nEff <= 1) NA_real_ else sqrt(
#       mean(NEE_uStar_fsd^2, na.rm = TRUE) / (nEff - 1)), 
#     sdNEEuncorr = if (nRec == 0) NA_real_ else sqrt(
#       mean(NEE_uStar_fsd^2, na.rm = TRUE) / (nRec - 1))
#   )

###############################################################################################################
# Storing the results in a csv-file
# The results still reside inside the sEddyProc class. We first export them to an R Data.frame, append the
# columns to the original input data, and write this data.frame to text file in a temporary directory.

FilledEddyData <- EProc$sExportResults()
CombinedData <- cbind(EddyData, FilledEddyData)

fWriteDataframeToFile(CombinedData,
                      'DNDF202007-Results4.txt',
                      Dir = out.dir)
