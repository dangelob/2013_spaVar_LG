### OBJECTIF #==========================================================================
# Fonctions permettant de générer des fichiers propre d'après les fichiers 
# stockés dans le dossier RAW : 
# TE, HR, PT, VG_REC, VG_CPT 
#
# stockés dans de dossier DERAW :
#
### PRE-REQUIS
# 
#   
### MODIFICATIONS
# 2014-04-27 : V1 des fonction
#       
### TODO
# Add check if all file exists 


# RAW to CLEANED ----------------------------------------------------------
rawTOcleaned <- function(){
  # Get date list -----------------------------------------------------------
  dateList <- get_dateList(type = "all")
  
  # Concat ------------------------------------------------------------------
  # Concat pour l'ensemble des dates de chaque fichier (TE, HR...)
  assign("gTE", data.frame()) # POur automatisation ?
  gHR <- data.frame()
  gPT <- data.frame()
  gVG_REC <- data.frame()
  gVG_CPT <- data.frame()
  
  
  for (i in seq_along(dateList$date)){
    ID_camp <- paste0(dateList$date[i], "_LG_VS/")
    pth_camp <- paste0(pathRawdat, ID_camp)
    
    # Concat TE
    ID_TE <- paste0(pth_camp, dateList$date[i], "_LG_TE.csv")
    TE <- cbind(read.csv(ID_TE), ID_camp = i) 
    gTE <- rbind(gTE, TE)
    
    # Concat HR
    ID_HR <- paste0(pth_camp, dateList$date[i], "_LG_HR.csv")
    HR <- cbind(read.csv(ID_HR), ID_camp = i)
    gHR <- rbind(gHR, HR)
    
    # Concat PT
    ID_PT <- paste0(pth_camp, dateList$date[i], "_LG_PT.csv")
    PT <- cbind(read.csv(ID_PT), ID_camp = i)
    gPT <- rbind(gPT, PT)
    
    # Concat VG_REC
    ID_VG_REC <- paste0(pth_camp, dateList$date[i], "_LG_VG_REC.csv")
    VG_REC <- cbind(read.csv(ID_VG_REC), ID_camp = i)
    gVG_REC <- rbind(gVG_REC, VG_REC)
    
    # Concat VG_CPT
    ID_VG_CPT <- paste0(pth_camp, dateList$date[i], "_LG_VG_CPT.csv")
    VG_CPT <- cbind(read.csv(ID_VG_CPT), ID_camp = i)
    gVG_CPT <- rbind(gVG_CPT, VG_CPT)
  }
  
  
  # Cleaning ----------------------------------------------------------------
  gTE <- cln_TE(gTE)
  # gHR <- cln_HR(gHR)
  gPT <- cln_PT(gPT)
  gVG_REC <- cln_VG_REC(gVG_REC)
  # gVG_CPT <- cln_VG_CPT(gVG_CPT)
  
  
  # Writing -----------------------------------------------------------------
  lst <- list(gTE=gTE, gHR=gHR, gPT=gPT, gVG_REC=gVG_REC, gVG_CPT=gVG_CPT)
  
  sav_cln <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/cleaned/"
  
  lapply(names(lst),
         function(x, lst) write.csv(lst[[x]], paste0(sav_cln, x, ".csv"),
                                    quote = FALSE, row.names = FALSE),
         lst)
} # Fin fonction


# RAW to CLEANED CO2 ------------------------------------------------------

derawTOcleaned <- function(){
  sav_cln <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/cleaned/"
  # CONCAT PASSAGE DE DERAW A CLEANED 
  # Concat pour l'ensemble des dates de chaque fichier CO2
  gCO2 <- data.frame()
  
  for (i in dateList$terrNum){
    ID_CO2 <- paste0("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/", dateList$date[i], "_catCO2.csv")
    CO2 <- read.csv(ID_CO2)
    gCO2 <- rbind(gCO2, CO2)
  }
  write.csv(gCO2, paste0(sav_cln,"gCO2.csv"))
}