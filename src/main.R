wd <- getwd()
source(paste(wd,"/src/load.R", sep=""))


pth_raw <- paste0(wd, "/data/raw/CO2/")
pth_deraw <- paste0(wd, "/data/deraw/CO2/")
pth_regsel <- paste0(wd, "/data/diagnostic/CO2_cleaning")
# pth_raw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/raw/CO2/"
# pth_deraw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/"
# pth_regsel <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/diagnostic/CO2_cleaning"

dateList <- get_dateList(type="all")
# Non CO2 data ------------------------------------------------------------
# Use datelist to concat all file in cleaned
rawTOcleaned()


# Cleaning CO2 ------------------------------------------------------------
detach("package:vaisCO2", unload=TRUE)
library(vaisCO2)


date <- "2013-03-05"
date <- "2013-04-18"
date <- "2013-05-14"
date <- "2013-06-11"
date <- "2013-07-04"
date <- "2013-07-24"
date <- "2013-08-29"
date <- "2013-09-24"
date <- "2013-10-22"
date <- "2013-12-12"
date <- "2014-03-19"
date <- "2014-04-14"

ID_camp <- paste0(date, "_LG_VS")
pth_camp <- paste0(pth_raw, ID_camp)
pathTOm70 <- paste0(pth_camp, "/", date, "_LG_VAm70")
# IDcamp <- "2014-03-19_LG_VS"

df <- prepVis(pathTOm70)

diagplot(df,outname=paste0(ID_camp, "_diagplt.pdf") ,outpath=pth_regsel) # package vaisCO2 nécessite un champ fileid

# TODO utilisation de regselect, il renvoie un df en renseignant un champ keep
df <- regselect(df, path=pth_regsel, file=paste0(date,"_regselect.csv"))

# Faire une fonction regenDiagPlot qui lance regselect puis diagplot

# per campaign cleaning and flux categorizing 
rawTOderaw(df)


# Concat and go to cleaned
derawTOcleaned()

