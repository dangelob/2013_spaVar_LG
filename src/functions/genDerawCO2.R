### OBJECTIF #==========================================================================
# Fonctions permettant de générer des fichiers CO2 DERAW d'après les fichiers 
# stockés dans le dossier RAW : 
# dossier m70
#
### PRE-REQUIS
#
#   
### MODIFICATIONS
# 2014-04-27 : V1 des fonction
#       
### TODO
#

# RAW to DERAW ------------------------------------------------------------
rawTOderaw <- function(df){
  # Nettoyage du dataframe : (retrait des lignes keep == FALSE)
  df <- df[which(df$keep == TRUE),]
  df$keep <- NULL
  
  #−−# A ce stade on doit avoir un fichier contenant les données CO2 complètement propre
  #−−# du type : date, time, RH, temperature, CO2, fileid, timestamp, keep
  gRAWCO2<- df # si jamais on veut l'ensemble des data de flux...
  write.csv(gRAWCO2, paste0(pth_deraw, paste0(date, "_gRAWCO2.csv")),
            row.names = FALSE, quote = FALSE)
  
  
  
  # On sort un df de la forme 
  # filename, rawCO2F, sqR, temp.mean, temp.sd, hr.mean, hr.sd 
  df <- extrcFlux(df)
  
  # Creation d'un fichier de la forme : 
  # placette, date, patm, heure, jn, filename
  df_patm <- link_flux_patm(date)
  
  # fusion des df (nécessite le package plyr)
  df <- join(df, df_patm, type="inner", by="filename")
  
  ### P1 CTRL : Longeur de Output (normalement = 40) #==========================
  if (NROW(df) != 40){
    print("WARNING : le nombre de ligne d'Output est différent de 40 !")
  }
  
  df$netC02F <- getNF(RF=df$rawCO2F, Patm=df$patm, T_Cel=df$temp.mean)
  
  
  #--# On save pour concat un fichier du type : ???? juste les flux net pas séparés en NEP, RE ... intérêt ?
  # "filename"  "fluxCO2"   "sqR"       "temp.mean" "temp.sd"   "hr.mean"   "hr.sd" 
  # "placette"  "date"      "patm"      "heure"     "jn"        "netC02F" 
  
  ### P2 Conversion en NEP GPP et Re #=====================================================
  #Subset jour et nuit
  #Jour
  df_J <- df[which(df$jn == "J"),]
  df_J <- df_J[order(df_J$placette),]
  # Nuit
  df_N <- df[which(df$jn == "N"),]
  df_N <-df_N[order(df_N$placette),]
  
  # Création d'un df en extrayant la colonne placette du ss jour
  # Ajout des colonnes nuit
  catCO2 <- cbind(df_J[,c("placette","temp.mean", "temp.sd", "hr.mean", "hr.sd")], df_N[,c("temp.mean", "temp.sd", "hr.mean", "hr.sd")])
  # Renommer la première colonne "placette" + les colonnes jour + colonne nuit
  colnames(catCO2) <- c("placette", "T_Chb_J.mean", "T_Chb_J.sd", "HR_Chb_J.mean", "HR_Chb_J.sd", "T_Chb_N.mean", "T_Chb_N.sd", "HR_Chb_N.mean", "HR_Chb_N.sd")
  # colnames(catCO2) <- c("placette", "T_Chb_N.mean", "T_Chb_N.sd", "HR_Chb_N.mean", "HR_Chb_N.sd")
  
  ### Calcul Re NEP GPP
  # Calcul et ajout de la colonne NEP
  catCO2 <- cbind(catCO2, "NEP"=(-df_J$netC02F))
  # Calcul et ajout de la colonne Re
  catCO2 <- cbind(catCO2, "Re"=(-df_N$netC02F))
  # Calcul et ajout de la colonne GPP
  catCO2$GPP <- (catCO2$NEP-catCO2$Re)
  
  # Créer une colonne date (nécessite stringr)
  catCO2$date <- str_extract(df_J$filename, "20..-..-..")
  catCO2$ID_camp <- dateList[which(dateList$date == date),]$terrNum
  
  sav_deraw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/"
  write.csv(catCO2, paste0(sav_deraw, paste0(date, "_catCO2.csv")))
}
