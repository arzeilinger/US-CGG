pbl_height <- function(latitude,
                       TIMESTAMP,
                       zL,
                       USTAR,
                       MO_LENGTH,
                       WT,
                       Tv,
                       DAYNIGHT,
                       neutral.cri = 0.05,
                       hr,
                       plot.out = T,
                       outDir,
                       file.ext = "")
{
  Tv <- Tv + 273.15
  
  omega <- 0.000072921                # angular velocity (m/s)
  f <- 2 * omega * sin(latitude / 180 * pi)   # Coriolis parameter
  Cn <- 0.3                           # Hanna & Chang 1993, neutra; coeff
  C1 <- 3.8                           # Nieuwstadt 1981, neutral-stable coeff
  C2 <- 2.28                          # Nieuwstadt 1981, neutral-stable coeff
  gamma <- 0.01                       # gradient of potential temp above convective BL, Batchvarova & Grying 1991
  A <- 0.2                            # unstable model, Batchvarova & Grying 1991
  B <- 2.5
  C <- 8
  k <- 0.4
  g <- 9.81
  
  data.tmp <- data.frame(zL,
                         USTAR,
                         MO_LENGTH,
                         Tv,
                         WT,
                         DAYNIGHT,
                         pbl = NA,
                         d.pbl = NA)
  
  ## stable case, Equation (B1) in Kljun 2015
  data.tmp$pbl[!is.na(data.tmp$zL) &
                 data.tmp$zL > (neutral.cri)] <-
    data.tmp$MO_LENGTH[!is.na(data.tmp$zL) &
                         data.tmp$zL > (neutral.cri)] / C1 *
    (-1 + (1 + C2 * data.tmp$USTAR[!is.na(data.tmp$zL) &
                                     data.tmp$zL > (neutral.cri)] / f /
             data.tmp$MO_LENGTH[!is.na(data.tmp$zL) &
                                  data.tmp$zL > (neutral.cri)]) ^ 0.5)
  
  ## neutral case Equation (B2) in Kljun 2015
  data.tmp$pbl[!is.na(data.tmp$zL) &
                 abs(data.tmp$zL) <= (neutral.cri)] <- Cn *
    data.tmp$USTAR[!is.na(data.tmp$zL) &
                     abs(data.tmp$zL) <= (neutral.cri)] /
    abs(f)
  
  # also for all other nighttime case,
  data.tmp$pbl[is.na(data.tmp$pbl) & data.tmp$DAYNIGHT == "NIGHT"] <-
    Cn *
    data.tmp$USTAR[is.na(data.tmp$pbl) & data.tmp$DAYNIGHT == "NIGHT"] /
    abs(f)
  
  # also for dawn when sensible heat still negative
  data.tmp$pbl[!is.na(data.tmp$WT) & data.tmp$WT < 0] <- Cn *
    data.tmp$USTAR[!is.na(data.tmp$WT) & data.tmp$WT < 0] /
    abs(f)
  
  ## fill all short gap with linear interpolation
  data.tmp$pbl <- zoo::na.approx(data.tmp$pbl, na.rm = F, maxgap = 3)
  
  ## Work on unstable case, Equation (B5) in Kljun 2015
  
  na.ls <- which(is.na(data.tmp$pbl))
  if (length(which(na.ls == 1)) > 0) {
    na.ls <- na.ls[-which(na.ls == 1)]
  }
  
  for (l1 in 1:length(na.ls)) {
    data.tmp$d.pbl[na.ls[l1]] <-
      hr * 60 *  ## convert from m s-1 to per averaging interval
      data.tmp$WT[na.ls[l1] - 1] / gamma *
      ((
        data.tmp$pbl[na.ls[l1] - 1] ^ 2 / ((1 + 2 * A) * data.tmp$pbl[na.ls[l1] -
                                                                        1] - 2 * B * k * data.tmp$MO_LENGTH[na.ls[l1] - 1])
      ) +
        (C * data.tmp$USTAR[na.ls[l1] - 1] ^ 2 * data.tmp$Tv[na.ls[l1] -
                                                               1] /
           (
             gamma * g * ((1 + A) * data.tmp$pbl[na.ls[l1] - 1] - B * k * data.tmp$MO_LENGTH[na.ls[l1] -
                                                                                               1])
           ))) ^ (-1)
    
    data.tmp$pbl[na.ls[l1]] <-
      data.tmp$pbl[na.ls[l1] - 1] + data.tmp$d.pbl[na.ls[l1]]
  }
  
  ## filter unrealistic pbl values
  data.tmp$pbl[!is.na(data.tmp$pbl) &
                 (data.tmp$pbl < 0 | data.tmp$pbl > 5000)] <- NA
  
  ## fill all short gap with linear interpolation
  data.tmp$pbl <- zoo::na.approx(data.tmp$pbl, na.rm = F, maxgap = 3)
  
  if (plot.out) {
    png(
      paste(outDir, file.ext, "_PBL.png", sep = ""),
      width = 9.5,
      height = 4,
      units = "in",
      pointsize = 10,
      res = 200
    )
    plot(
      TIMESTAMP,
      data.tmp$pbl,
      pch = 21,
      type = "b",
      cex = 0.4,
      col = "black",
      bg = "grey"
    )
    dev.off()
  }
  
  return(data.tmp$pbl)
}
