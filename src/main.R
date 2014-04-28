source(paste(getwd(),"/src/load.R", sep=""))


# Non CO2 data
rawTOcleaned()

# CO2
# Sélect date
# FN_CleanDate
#     diagplt/regselec 

# FN_CO2_Concat



# Cleaning CO2 ------------------------------------------------------------
detach("package:vaisCO2", unload=TRUE)
library(vaisCO2)

dateList <- get_dateList(type="all")

date <- "2013-03-05"

pth_raw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/raw/CO2/"
pth_deraw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/"

ID_camp <- paste0(date, "_LG_VS")
pth_camp <- paste0(pth_raw, ID_camp)
pathTOm70 <- paste0(pth_camp, "/", date, "_LG_VAm70")
# IDcamp <- "2014-03-19_LG_VS"

df <- prepVis(pathTOm70)

pth_regsel <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/diagnostic/CO2_cleaning"
diagplot(df,outname=paste0(IDcamp, "_diagplt.pdf") ,outpath=pth_regsel) # package vaisCO2 nécessite un champ fileid

# TODO utilisation de regselect, il renvoie un df en renseignant un champ keep
df <- regselect(df, path=pth_regsel, file=paste0(date,"_regselect.csv"))

# Faire une fonction regenDiagPlot qui alnce regselect puis diagplot


# per campaign cleaning and flux categorizing 
rawTOderaw(df)
# Concat and go to cleaned
derawTOcleaned()

