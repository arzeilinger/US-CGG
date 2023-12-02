rm(list = ls())

workDir <- "D:\\Housen\\Flux\\Data-exploring\\02_Concord_Eden\\flux_site_working\\"
outDir <- dataDir <- paste0("D:\\Housen\\Flux\\Data-exploring\\02_Concord_Eden\\AmeriFlux_working\\")
rDir <- paste0(workDir, "R\\")

source(file.path(rDir, "ext_radiation_v2.R"))
source(file.path(rDir, "math_util.R"))

file.ls <- "2023-05-30_master_eddy_met_concord_prefiltering.csv"
#file.ls <- "master_eddy_pro_concord.csv"

case <- "US-CGG"

sw_in_pot <- ext_radiation_v2(latitude = 37.9380, 
                              longitude = -121.9761,
                              year = c(2019:2022),
                              utc.offset = -8)

##########################################################################################################
# read in pre-processed/quality-controlled file
data.work <- data.org <-
  read.csv(paste0(dataDir, file.ls),
           header = T,
           stringsAsFactors = F)

######################################################################################
###### Filter flux variables by qc flags, sensor signal strength
data.work[!is.na(data.work$used_records) &
            data.work$used_records < 18000 * 0.9,
          c("H", "LE", "co2_flux", "u.")] <- NA
data.work$H[!is.na(data.work$qc_H) & data.work$qc_H == 2] <- NA
data.work$LE[(!is.na(data.work$qc_LE) & data.work$qc_LE == 2) |
               (
                 !is.na(data.work$co2_signal_strength_7500_mean) &
                   data.work$co2_signal_strength_7500_mean < 90
               )] <- NA
data.work$co2_flux[(!is.na(data.work$qc_co2_flux) &
                      data.work$qc_co2_flux == 2) |
                     (
                       !is.na(data.work$co2_signal_strength_7500_mean) &
                         data.work$co2_signal_strength_7500_mean < 90
                     )] <- NA

## Filter flux variables using a non-overlapped moving window
# For each window, the code filters out points that are outsides of the 
# window_mean +/- filter_criteria * window_sd. Currently, the process iterates
# twice, using two different sizes of windows and thresholds.
get.var <- c(which(colnames(data.work) %in% c("H", "LE", "co2_flux")))
# define window size, days * points per days, scalar or vector
filter_window <- c(14 * 48, 7 * 48)
# define criteria for filtering (times +/- sd), scalar or vector
filter_criteria <- c(4, 3)
n_window <- floor(nrow(data.work) / filter_window)

for(v in 1:length(get.var)){
  for(w in 1:length(n_window)) {
    for (ww in 1:n_window[w]) {
      window_mean <-
        mean(data.work[c(((ww - 1) * filter_window[w] + 1):
                           (ww * filter_window[w])), get.var[v]], na.rm = T)
      window_sd <-
        sd(data.work[c(((ww - 1) * filter_window[w] + 1):
                         (ww * filter_window[w])), get.var[v]], na.rm = T)
      
      if (is.finite(window_mean) & is.finite(window_sd)) {
        outlier.up <-
          which(data.work[c(((ww - 1) * filter_window[w] + 1):
                              (ww * filter_window[w])), get.var[v]] > 
                  window_mean + filter_criteria[w] * window_sd)
        outlier.lo <-
          which(data.work[c(((ww - 1) * filter_window[w] + 1):
                              (ww * filter_window[w])), get.var[v]] < 
                  window_mean - filter_criteria[w] * window_sd)
        
        data.work[c(((ww - 1) * filter_window[w] + 1):
                      (ww * filter_window[w])), get.var[v]][c(outlier.lo,
                                                           outlier.up)] <- NA
      }
    }
  }
}

TIMESTAMP <-
  strptime(data.work$TIMESTAMP, format = "%Y-%m-%d %H:%M:%S", tz = "GMT")

## shift time stamp to align with potential incoming radiation
TIMESTAMP <- TIMESTAMP - 30 * 60
TIMESTAMP <-
  strptime(TIMESTAMP, format = "%Y-%m-%d %H:%M:%S", tz = "GMT")

#### bring in potential incoming radiation, for day/night separation
data.work$TIMESTAMP_END <-
  as.character(((TIMESTAMP$year + 1900) * 10 ^ 8 +
                  (TIMESTAMP$mon + 1) * 10 ^ 6 +
                  (TIMESTAMP$mday) * 10 ^ 4 +
                  TIMESTAMP$hour * 10 ^ 2 +
                  TIMESTAMP$min
  ))

####### Merge with SW_IN_POT to get full time series
sw_in_pot <- sw_in_pot[c(1 : which(sw_in_pot$TIMESTAMP_END == data.work$TIMESTAMP_END[nrow(data.work)])), ]
time_start <- which(sw_in_pot$TIMESTAMP_END == data.work$TIMESTAMP_END[1])
TIMESTAMP.full <-
  strptime(sw_in_pot$TIMESTAMP_START, format = "%Y%m%d%H%M", tz = "GMT")
  
data.work <- merge.data.frame(sw_in_pot[, -3],
                              data.work,
                              by = "TIMESTAMP_END",
                              all.x = T)

####### rename variables for AmeriFlux format
data.work <- data.work[, c("TIMESTAMP_START", "TIMESTAMP_END", 
                           "H", "LE", "co2_flux", "u.",
                           "co2_mole_fraction", "h2o_mole_fraction", "sonic_temperature",
                           "wind_speed", "wind_dir", "u_var", "v_var", "w_var",
                           "AirT_Avg", "RH_Avg", "AtmPressure_Avg",
                           "NR_Wm2_Avg", "PAR_in_mV_Avg", "PAR_out_mV_Avg",
                           "SHF_1_Wm2_Avg", "SHF_2_Wm2_Avg", 
                           "Precip_mm_Tot", "VWC_Avg", "VWC_2_Avg_Control",
                           "TC_Avg.1.", "TC_Avg.2.", "TC_Avg.3.",                    
                           "TC_Avg.4.", "TC_Avg.5.", "TC_Avg.6.",                    
                           "TC_Avg.7.", "TC_Avg.8.", "TC_Avg.9.",                    
                           "TC_Avg.10.", "TC_Avg.11.", "TC_Avg.12.",
                           "TC_Avg.13.", "TC_Avg.14.", "TC_Avg.15.",                   
                           "TC_Avg.16._control", "TC_Avg.17._control", "TC_Avg.18._control",           
                           "TC_Avg.19._control", "TC_Avg.20._control")]
colnames(data.work) <- c("TIMESTAMP_START", "TIMESTAMP_END",
                         "H", "LE", "FC", "USTAR",
                         "CO2", "H2O", "T_SONIC",
                         "WS", "WD", "U_SIGMA", "V_SIGMA", "W_SIGMA",
                         "TA", "RH", "PA",
                         "NETRAD", "PPFD_IN", "PPFD_OUT",
                         "G_1_1_1", "G_2_1_1", 
                         "P", "SWC_1_1_1", "SWC_2_1_1",
                         "TS_1_1_1", "TS_1_2_1", "TS_1_3_1",                    
                         "TS_1_4_1", "TS_1_5_1", "TS_2_1_1",                    
                         "TS_2_2_1", "TS_2_3_1", "TS_2_4_1",                    
                         "TS_2_5_1", "TS_3_1_1", "TS_3_2_1",
                         "TS_3_3_1", "TS_3_4_1", "TS_3_5_1",                   
                         "TS_5_1_1", "TS_5_2_1", "TS_5_3_1",           
                         "TS_5_4_1", "TS_5_5_1")

## unit conversion to AmeriFlux units
data.work$PPFD_IN <- data.work$PPFD_IN * 1000 / 6.38 / 0.604
data.work$PPFD_OUT <- data.work$PPFD_OUT * 1000 / 6.38 / 0.604
data.work$T_SONIC <- data.work$T_SONIC - 273.15
data.work$SWC_1_1_1 <- data.work$SWC_1_1_1 * 100
data.work$SWC_2_1_1 <- data.work$SWC_2_1_1 * 100
data.work$U_SIGMA <- sqrt(data.work$U_SIGMA)
data.work$V_SIGMA <- sqrt(data.work$V_SIGMA)
data.work$W_SIGMA <- sqrt(data.work$W_SIGMA)

###### Filter variables by plausible range
data.work$NETRAD[!is.na(data.work$NETRAD) & data.work$NETRAD > sw_in_pot$SW_IN_POT] <- NA
data.work$NETRAD[!is.na(data.work$NETRAD) &
                       (data.work$NETRAD > 900 | data.work$NETRAD < (-150))] <- NA

data.work$PPFD_IN[!is.na(data.work$PPFD_IN) & 
                    sw_in_pot$SW_IN_POT != 0 &
                    data.work$PPFD_IN > sw_in_pot$SW_IN_POT / 0.47 ] <- NA
data.work$PPFD_OUT[!is.na(data.work$PPFD_OUT) &
                     sw_in_pot$SW_IN_POT != 0 &
                     (data.work$PPFD_OUT > sw_in_pot$SW_IN_POT / 0.47 | 
                        data.work$PPFD_OUT > data.work$PPFD_OUT)] <- NA
## Noisy data before Dec 2019
data.work[c(1:which(data.work$TIMESTAMP_START == "201912050700")), c("PPFD_IN", "PPFD_OUT")] <- NA

data.work$G_1_1_1[!is.na(data.work$G_1_1_1) &
                          (data.work$G_1_1_1 > 150 | data.work$G_1_1_1 < (-150))] <- NA
data.work$G_2_1_1[!is.na(data.work$G_2_1_1) &
                          (data.work$G_2_1_1 > 150 | data.work$G_2_1_1 < (-150))] <- NA
## Noisy data before Dec 2019
data.work[c(1:which(data.work$TIMESTAMP_START == "201912050700")), c("G_1_1_1", "G_2_1_1")] <- NA

data.work$TA[!is.na(data.work$TA) &
                    (data.work$TA > 60 | data.work$TA < (0))] <- NA
data.work$RH[!is.na(data.work$RH) &
               (data.work$RH > 100 | data.work$RH < (0))] <- NA

get_ts <- grep("TS", colnames(data.work))
for(tt in 1:length(get_ts)){
  data.work[!is.na(data.work[, get_ts[tt]]) &
                 (data.work[, get_ts[tt]] > 60 | data.work[, get_ts[tt]] < (0)), get_ts[tt]] <- NA
}

## truncate record to earliest starting date
data.work <- data.work[c(time_start: nrow(data.work)), ]

## time series plots for all variables
pdf(paste0(outDir, case, "_all_var_plot.pdf"), 
    width = 8, 
    height = 11)
par(mfrow = c(5, 1), mar = c(3.5, 4.5, 0.5, 0.5))
for(v in 3:ncol(data.work)){
  plot(TIMESTAMP,
       data.work[, v],
       ylab = colnames(data.work)[v],
       xlab = NA,
       cex = 0.7,
       pch = 16,
       col = rgb(0.5, 0.5, 0.5, 0.5))
}
dev.off()

## output in AmeriFlux format
write.csv(data.work,
          paste0(outDir, case, "_HH_",
                 data.work$TIMESTAMP_START[1], "_",
                 data.work$TIMESTAMP_END[nrow(data.work)], 
                 ".csv"),
          na = "-9999",
          quote = F,
          row.names = F)
