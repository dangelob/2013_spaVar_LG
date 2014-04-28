### Nettoyage du workspace avant de lancer le script #===================================
rm(list=ls(all=TRUE))
# setwd("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_variabiliteSpatialeLG")

# Library -----------------------------------------------------------------

library(ggplot2)
library(ggthemes)
library(plyr)
library(stringr)
library(reshape2)
library(matrixStats)
# library(zoo)
# library(xts)
library(knitr)
library(devtools)
library(rCharts)

# Functions ---------------------------------------------------------------
pth_fn <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/functions/"

# meta --------------------------------------------------------------------
source(paste(pth_fn,"metaData_fn.R", sep=""))

# genFiles ----------------------------------------------------------------
source(paste(pth_fn,"getNF.R", sep=""))
source(paste(pth_fn,"link_flux_patm.R", sep=""))
source(paste(pth_fn,"genDerawCO2.R", sep=""))
source(paste(pth_fn,"genClean.R", sep=""))
source(paste(pth_fn,"clean_fn.R", sep=""))

# load functions ----------------------------------------------------------
source(paste(pth_fn,"load_fn.R", sep=""))


# 
# source(paste(getwd(),"/src/3_functions/get_relative_path.R", sep=""))
# 
# source(paste(pth_functions,"trtVS_PT.R", sep=""))
# source(paste(pth_functions,"trtVS_HR.R", sep=""))
# source(paste(pth_functions,"trtVS_TE.R", sep=""))
# source(paste(pth_functions,"trtVS_CPT.R", sep=""))
# source(paste(pth_functions,"trtVS_REC.R", sep=""))
# 
# source(paste(pth_functions,"trtIVeri.R", sep=""))
# 
# source(paste(pth_functions,"extrct_dat_meteo.R", sep=""))
# 
# source(paste(pth_functions,"ggplotRegression.R", sep=""))
# 
# source(paste(pth_functions,"extrct_dat_vaisala.R", sep=""))
# 
# source(paste(pth_functions,"get_list_date_VS.R", sep=""))
# source(paste(pth_functions,"subset_date_VS.R", sep=""))
# 
# source(paste(pth_functions,"R_FCT_AutoCompl.R", sep=""))
# source(paste(pth_functions,"R_FCT_TrtParDate.R", sep=""))
# 
# source(paste(pth_functions,"R_FCT_IVBruy.R", sep=""))

# Other -------------------------------------------------------------------

# datelist <- as.character(get_list_date_VS())
