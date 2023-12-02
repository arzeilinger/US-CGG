footprint_plot_v6 <- function(fpt.shp.comb,
                              shp.comb1,
                              shp.comb2,
                              longitude,
                              latitude,
                              basemap,
                              dist.target = 500,
                              map.comment,
                              map.comment.short,
                              path.out) {
  #source("XY_to_latlon2.R")
  #source("find_equal_dist.R")
  
  # lsp.cvt <- data.frame(
  #   lon = find_equal_dist(
  #     mylat = latitude,
  #     mylon = longitude,
  #     dist.target = dist.target
  #   )[, 1],
  #   lat = find_equal_dist(
  #     mylat = latitude,
  #     mylon = longitude,
  #     dist.target = dist.target
  #   )[, 2]
  # )
  
  fpt.shp.comb.sp <- ggplot2::fortify(fpt.shp.comb)
  shp.comb1.sp <- ggplot2::fortify(shp.comb1)
  #shp.comb2.sp<-fortify(shp.comb2)
  #fpt.shp.comb.sp<-fpt.shp.comb.sp[grepl(paste0("_",crop.contour),fpt.shp.comb.sp$id),]
  #fpt.shp.comb.sp$color<-ifelse(grepl("DAY",fpt.shp.comb.sp$id),"DAY","NIGHT")
  
  target.dist.ls <- seq(100, dist.target, by = 100)
  
  lsp.cvt <- NULL
  for (j1 in 1:length(target.dist.ls)) {
    lsp.cvt <- rbind.data.frame(lsp.cvt,
                                data.frame(
                                  long = find_equal_dist(
                                    mylat = latitude,
                                    mylon = longitude,
                                    dist.target =
                                      target.dist.ls[j1]
                                  )[, 1],
                                  lat = find_equal_dist(
                                    mylat = latitude,
                                    mylon = longitude,
                                    dist.target =
                                      target.dist.ls[j1]
                                  )[, 2],
                                  group = j1
                                ))
  }
  
  map.lon.rng <- range(lsp.cvt$lon, na.rm = T)
  map.lat.rng <- range(lsp.cvt$lat, na.rm = T)
  
  label.dt <- data.frame(
    x = rep(longitude, 10),
    y = c(
      min(lsp.cvt$lat[lsp.cvt$group == 1], na.rm = T),
      min(lsp.cvt$lat[lsp.cvt$group == 2], na.rm = T),
      min(lsp.cvt$lat[lsp.cvt$group == 3], na.rm = T),
      min(lsp.cvt$lat[lsp.cvt$group == 4], na.rm = T),
      min(lsp.cvt$lat[lsp.cvt$group == 5], na.rm = T)
    ),
    lab = c("100 m", "200 m", "300 m", "400 m", "500 m"),
    stringsAsFactors = F
  )
  
  map.lon.rng <- range(lsp.cvt$lon, na.rm = T)
  map.lat.rng <- range(lsp.cvt$lat, na.rm = T)
  
  sitemap1 <- ggmap::ggmap(basemap) +
    scale_x_continuous(limits = map.lon.rng, expand = expansion(mult = 0.02)) +
    scale_y_continuous(limits = map.lat.rng, expand = expansion(mult = 0.02)) +
    geom_polygon(
      aes(x = long,
          y = lat,
          group = group),
      color = "white",
      fill = NA,
      size = 0.2,
      data = lsp.cvt,
      na.rm = T
    ) +
    geom_label(
      aes(x = x,
          y = y,
          label = lab),
      data = label.dt,
      size = 3,
      vjust = 0.5,
      hjust = 0.5
    ) +
    geom_polygon(
      aes(x = long,
          y = lat,
          group = id),
      color = "yellow",
      fill = NA,
      size = 0.1,
      data = fpt.shp.comb.sp,
      na.rm = T
    ) +
    geom_polygon(
      aes(
        x = long,
        y = lat,
        group = id,
        color = as.factor(id)
      ),
      fill = NA,
      size = 0.2,
      data = shp.comb1.sp,
      na.rm = T
    ) +
    # geom_point(aes(x=long,
    #                y=lat,
    #                group=id,
    #                color=as.factor(id)),
    #            size=3,shape=1,
    #            data=shp.comb2.sp,
    #            na.rm=T)+
    
    geom_hline(
      yintercept = latitude,
      color = "white",
      linetype = 4,
      size = 0.3
    ) +
    geom_vline(
      xintercept = longitude,
      color = "white",
      linetype = 4,
      size = 0.3
    ) +
    geom_point(
      aes(x = longitude, y = latitude),
      color = "red",
      size = 4,
      shape = 3
    ) +
    geom_point(
      aes(x = longitude, y = latitude),
      fill = "pink",
      color = "red",
      size = 2,
      shape = 21
    ) +
    labs(x = "", y = "") +
    ggtitle(map.comment) +
    theme(
      legend.title = element_blank(),
      legend.position = "none"
    )
  
  ggplot2::ggsave(
    sitemap1,
    file = paste(path.out, map.comment.short, ".png", sep = ""),
    width = 5.5,
    height = 5.5,
    units = "in",
    dpi = 250,
    type = "cairo-png"
  )
  
  return(sitemap1)
  
}