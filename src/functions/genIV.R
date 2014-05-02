## Calcul de la Biomasse : 
## Fonction calcul de la Biomasse
CalcBioMBruy <- function(hauteur, recouvrement, plante)
{
  ## Variable
  #Surface embase
  DiamEmbase <- 31.5 # en cm
  SurfEmbase <- pi*(DiamEmbase/2)**2
  #Surface de calibration
  S.cal <- 400 #(cm2)
  #Équation Y = AX^B ; BiomasseCalc = A*Hauteur(g)^B
  if(plante == "erica") {
    A <- 0.2994
    B <- 1.3967
    # Correction factor
    CF <- 0.5049
    print("erica")
  } else {
    A <- 0.2357
    B <- 1.4081
    # Correction factor
    CF <- 0.3938
    print("calluna")
  }
  
  #Biomasse en g
  Biomasse <- A*hauteur**B
  #Biomasse corrigée du biais d'estimation
  BioM.corr <- Biomasse/CF
  #Biomasse rapportée à la surface de l'embase et au recouvrement
  BioM <- (BioM.corr/S.cal*SurfEmbase*(recouvrement/100))
  return(BioM)
}


CalcIVbruy <- function(bioM.cal, bioM.eri, bioM.cal.max, bioM.eri.max)
{
  IV <- (bioM.cal + bioM.eri) / (bioM.cal.max + bioM.eri.max)
  #   IV <- (bioM.cal / bioM.cal.max) + (bioM.eri / bioM.eri.max)
  return(IV)
}

R_FCT_IVBruy <- function()
{
  ##LIBRARY
  library(plyr)
  
  ### FONCTIONS #==========================================================================
  # Fct.file <- "~/Documents/4.ScienceStuff/1.Ressources/8.Programmes/R_FCT/"
  #   source(paste(Fct.file,"regAuto.R", sep="")) # Inutilisé
  source(paste(pth_functions,"R_FCT_CalcBioMBruy.R", sep=""))
  source(paste(pth_functions,"R_FCT_CalcIVbruy.R", sep=""))
  
  dfrec <- ld_VG_REC(long=TRUE)
  dfcpt <- ld_VG_CPT()
  dfcpt$Veg <- as.character(dfcpt$Veg)
  dfcpt[which(dfcpt$Veg == "Sphg.Rubel"),"Veg"] <- "Sphagnum"
  dfcpt$Veg <- as.factor(dfcpt$Veg)
  levels(dfrec$Veg) <- c("Calluna","Erica", "Sphagnum", "Sphg.Cuspi", "Molinia", "Eriophorum", "Polytrick", "Mousse")
  df <- join(dfrec, dfcpt)

  
  
  ## Calcul de la biomasse #===============================================================
  df$BioM <- NA
  df[which(df$Veg == "Calluna"),"BioM"] <- CalcBioMBruy(df[which(df$Veg == "Calluna"),"mean"], df[which(df$Veg == "Calluna"),"REC"], "calluna")
  df[which(df$Veg == "Erica"),"BioM"] <- CalcBioMBruy(df[which(df$Veg == "Erica"),"mean"], df[which(df$Veg == "Erica"),"REC"], "erica")
#   df$cal_BioM <- CalcBioMBruy(df$H.mean.calu, df$Calluna_Rec, "calluna")
#   df$eri_BioM <- CalcBioMBruy(df$H.mean.eric, df$Erica_Rec, "erica")
  
  ## Calcul des maximums pour chaque BioM #============================================
  maxBiomCal <- max(df[which(df$Veg == "Calluna"),"BioM"], na.rm=TRUE)
  maxBiomEri <- max(df[which(df$Veg == "Erica"),"BioM"], na.rm=TRUE)
  
  ## Calcul de l'Indice de Végétation appel de fonction #==================================
  # cal, eri, cal.max, eri.max
  IV <- CalcIVbruy(df[which(df$Veg == "Calluna"),"BioM"], df[which(df$Veg == "Erica"),"BioM"], maxBiomCal, maxBiomEri)
  
  edf <- ld_VG_REC(long=FALSE)
  export <- cbind(edf[,c("placette", "date", "ID_camp")],IV)

  
  return(export)
}
