# CREATION D'UN CONTOUR DE CARTE DE LA GUETTE
### OBJECTIF #===========================================================================
# Créer UNE CONTOUR DE CARTE A UTILISER COMME FOND DE CARTE
### PRE-REQUIS
# 
#
### MODIFICATIONS
# 2013-09-20 : Première tentative 

####### fonction definition #============================================================
R_FCT_ContourBase <- function(){
  
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
#   embase<-readShapeSpatial(("embase.shp"),
#                            proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  contour<-readShapeSpatial(("1944_Shp_WGS84.shp"),
                            proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  ### Transformation du contour en en format lisible par ggplot #==========================
  ggcontour <- fortify(contour, region="Id")
  
  ### Création du contour de carte #=======================================================
  ggmap.contour <- ggplot(ggcontour, aes(x=long, y=lat))+
    geom_polygon(fill=NA, alpha=0)+
    geom_path(color="lightgrey", size=1)+
    coord_equal()+
    theme_bw()
  
  ### On remet le working directory original
  setwd(original_wd)
  
  ##### function result #==================================================================
  return(ggmap.contour) 
}