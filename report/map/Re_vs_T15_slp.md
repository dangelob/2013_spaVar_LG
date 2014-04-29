Title
========================================================



```r
loadenv <- function() {
    source("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/load.R")
    # source('/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_JourNuit/src/3_functions/reportFn.R')
    set_alias(w = "fig.width", h = "fig.height")
    # cat('loadenv : done \n')
}

# Calls
loadenv()
```

```
## matrixStats v0.8.14 (2013-11-23) successfully loaded. See ?matrixStats for help.
```

```r
dfCO2 <- ld_CO2()
dfPT <- ld_PT(long = F)
dfTE <- ld_TE()

df <- join(join(dfCO2, dfPT), dfTE)
```

```
## Joining by: placette, date, ID_camp
## Joining by: placette, date, ID_camp
```

```r
df$ID_camp <- as.factor(df$ID_camp)
df$ReAbs <- abs(df$Re)

cors <- ddply(df[which(!is.na(df$T15) & !is.na(df$ReAbs)), ], .(placette), summarise, 
    cor = round(cor(T15, ReAbs), 2), mdl1_sqR = round(summary(lm(ReAbs ~ T15))$r.squared, 
        2), mdl1_slp = round(summary(lm(ReAbs ~ T15))$coef[2], 2), mdl2_sqR = round(summary(lm(log(ReAbs) ~ 
        T15))$r.squared, 2), mdl2_slp = round(summary(lm(log(ReAbs) ~ T15))$coef[2], 
        2), mdl3_sqR = round(summary(lm(ReAbs ~ T15 + WT))$r.squared, 2), mdl3_slp = round(summary(lm(ReAbs ~ 
        T15 + WT))$coef[2], 2))

colnames(cors)[1] <- "PLACETTE"
```


You can also embed plots, for example:


```r

Fct.file <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/commons/"
source(paste(Fct.file, "R_FCT_ContourBase.R", sep = ""))
source(paste(Fct.file, "R_FCT_CoordEmbaseLG_VS.R", sep = ""))

contourLG <- R_FCT_ContourBase()
```

```
## Loading required package: sp
## Checking rgeos availability: TRUE
## rgdal: version: 0.8-16, (SVN revision 498)
## Geospatial Data Abstraction Library extensions to R successfully loaded
## Loaded GDAL runtime: GDAL 1.9.0, released 2011/12/29
## Path to GDAL shared files: /usr/share/gdal/1.9
## Loaded PROJ.4 runtime: Rel. 4.7.1, 23 September 2009, [PJ_VERSION: 470]
## Path to PROJ.4 shared files: (autodetected)
## Loading required package: rgeos
## rgeos version: 0.3-3, (SVN revision 437)
##  GEOS runtime version: 3.3.3-CAPI-1.7.4 
##  Polygon checking: TRUE
```

```r
dfGPS <- R_FCT_CoordEmbaseLG_VS()


trtdata <- cbind(R_FCT_CoordEmbaseLG_VS(), cors)


map <- contourLG + ggtitle("pente Re vs T15") + geom_point(data = trtdata, aes(x = LON, 
    y = LAT, size = (trtdata$mdl1_slp * 10)), shape = 20, alpha = 0.5, color = "tomato") + 
    geom_text(data = trtdata, aes(label = PLACETTE, x = LON, y = LAT), vjust = 1.5, 
        color = "black", size = 4) + scale_size_identity(guide = "legend") + 
    labs(size = "pente x10") + # theme(legend.position=c(0,1), legend.justification=c(0,1))
theme(legend.position = "right", legend.key = element_rect(fill = NA, linetype = "blank"))
print(map)
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 





