# REOURNE LES COORDONNES GPS DES EMBASES DE VARIABILITE SPATIALE SUR LA GUETTE
### OBJECTIF #===========================================================================
# 
### PRE-REQUIS
# 
#
### MODIFICATIONS
# 2013-09-20 : Première tentative 

####### fonction definition #============================================================
R_FCT_CoordEmbaseLG_VS <- function(){
  
  ### LIBRARY #============================================================================
  library(plyr)
  library(maptools)
  library(ggplot2)
  library(sp)
  library(rgdal)
  gpclibPermit()
  
  ### Récupération du working directory actuel  
  original_wd <- getwd()
  
  ### set up repertoire de travail pour lecture des fichiers #=============================
  setwd("/home/dangelo/Documents/4.ScienceStuff/1.Ressources/8.Programmes/R_PGM_PROD/CommonData/FondCarte")
  ### Lecture #============================================================================
  embase<-readShapeSpatial(("embase.shp"),
                             proj4string=CRS("+proj=longlat +datum=WGS84"))
    
  ### On remet le working directory original
  setwd(original_wd)
  
  ##### function result #==================================================================
  return(embase) 
}