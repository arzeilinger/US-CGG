data_filtering <- function(data.work,
                           ustr.u,
                           ustr.l,
                           wd.u,
                           wd.l,
                           lo.u,
                           zl.u){

  # filtering data by setting USTAR thresholds
  data.work[!is.na(data.work$USTAR) &
              data.work$USTAR < ustr.l, c("USTAR", "WS", "MO_LENGTH")] <- NA
  data.work[!is.na(data.work$USTAR) &
              data.work$USTAR > ustr.u, c("USTAR", "WS", "MO_LENGTH")] <- NA

  # filtering data by setting WD thresholds
  if (!is.na(wd.l) & !is.na(wd.u)) {
    if (wd.l < wd.u) {
      data.work[!is.na(data.work$WD) &
                  data.work$WD < wd.l, c("USTAR", "WS", "MO_LENGTH")] <- NA
      data.work[!is.na(data.work$WD) &
                  data.work$WD > wd.u, c("USTAR", "WS", "MO_LENGTH")] <- NA
    } else{
      data.work[!is.na(data.work$WD) &
                  (data.work$WD < wd.l &
                     data.work$WD > wd.u), c("USTAR", "WS", "MO_LENGTH")] <- NA
    }
  }

  # filtering data by setting MO_LENGTH thresholds
  if (!is.na(lo.u)) {
    data.work[!is.na(data.work$MO_LENGTH) &
                data.work$MO_LENGTH > lo.u, c("USTAR", "WS", "MO_LENGTH")] <- NA
    data.work[!is.na(data.work$MO_LENGTH) &
                data.work$MO_LENGTH < (-lo.u), c("USTAR", "WS", "MO_LENGTH")] <- NA
  }
  data.work[!is.na(data.work$MO_LENGTH) &
              data.work$MO_LENGTH == 0, c("USTAR", "WS", "MO_LENGTH")] <- NA

  # filtering data by setting ZL thresholds
  if (!is.na(zl.u)) {
    data.work[!is.na(data.work$zL) &
                abs(data.work$zL) > zl.u, c("USTAR", "WS", "MO_LENGTH")] <- NA
  }

  data.work[!is.na(data.work$V_SIGMA) &
              data.work$V_SIGMA < 0, c("V_SIGMA")] <- NA

  return(data.work)
}


