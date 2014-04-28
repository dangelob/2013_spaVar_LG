### Auto Compl   #======================================================================
# Tentative d'automatisation de création du fichier AAAA-MM-JJ_LG_Compl
#
# 2013-06-21 : V1
#

# TODO
# - what if fichier csv (codage en dur de l'extension pour le moment)
# utiliser les données à partir de CLEANED plutot que RAW ?
# Pro : pas de manip sur les données brutes
# Cons : nécessite de traiter d'abord le fichier TE (et probablemente les autres) avant le CO2...

####### fonction definition #============================================================
link_flux_patm <- function(date=date){
  
  ### LIBRARY #============================================================================
  
  ### Set Up Working Environnement   #=====================================================
  # date <- "2013-03-05"
  # date <- "2013-06-11"
  # set up repertoire de travail
  wd <- paste("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/raw/CO2/", date, "_LG_VS/", sep="")
  # setwd(wd)
  
  ### Read Input File (LG_TE)  #===========================================================
  file <- paste(wd, date, "_LG_TE.csv", sep="")
  dat.TE <- read.csv(file
                     , sep="," #Précise le séparateur de colonne
                     , header=TRUE # précise si le fichier contient les entêtes de colonne
                     , dec="." #Précise le séparateur décimal
  )
  
  ### Data check after import (if needed)  #===============================================
  
  ### Add a Patm.mean  #===================================================================
  dat.TE$Patm.mean <- (dat.TE$Patm_Deb+dat.TE$Patm_Fin)/2
  
  ### Dataframes creation  #===============================================================
  df.jour <- dat.TE[,c("placette","date","Patm.mean", "NEP_time")]
  df.nuit <- dat.TE[,c("placette","date","Patm.mean", "Re_time")]
  
  ### Add a Jour/Nuit Column  #============================================================
  df.jour$jn <- rep("J", length(df.jour$placette))
  df.nuit$jn <- rep("N", length(df.nuit$placette))
  
  ### Change name of NEP_time and Re_time #================================================
  colnames(df.jour) <- c("placette", "date", "patm","heure","jn")
  colnames(df.nuit) <- c("placette", "date", "patm","heure","jn")
  
  ### Merge the two df in one #============================================================
  AutoCompl <- rbind(df.jour,df.nuit)
  
  ### Création de la clé pour le merge avec OutputCO2 #===========================
  AutoCompl$filename <- paste(AutoCompl$date, " ",
                              (str_replace(AutoCompl$heure, ":", "_")),
                              " ", AutoCompl$placette, ".m70" , sep="")
  
  ##### function result #==================================================================
  return(AutoCompl)
}