### OBJECTIF #===========================================================================
# Fonction de chargement des données
#
### PRE-REQUIS
# Les données ont été traités/concaténées
# PACKAGES : 
#   matrixStats (rowSds) ; reshape2
#   
### MODIFICATIONS
# 2014-04-27 : V1 de la fonction
#       
### PARAMETRE
# type : Le type de données à charger
#


pth_cleaned <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/cleaned/"


# CO2 ---------------------------------------------------------------------
ld_CO2 <- function(){
  df <- read.csv(paste0(pth_cleaned,"gCO2.csv"))
  return(df)
}



# TE ----------------------------------------------------------------------
ld_TE <- function(){
  df <- read.csv(paste0(pth_cleaned,"gTE.csv"))
  return(df)
}



# HR ----------------------------------------------------------------------
# Nécessite matrixStats (rowSds) ; reshape2
ld_HR <- function(mean=TRUE){
  df <- read.csv(paste0(pth_cleaned,"gHR.csv"))
  
  # Calcul de la moyenne des HR
  df_mean <- data.frame(placette=df[,1], date=df[,2],
                        HR_mean=rowMeans(df[,c(-1,-2)], na.rm=TRUE),
                        HR_sd=rowSds(df[,c(-1,-2)], na.rm=TRUE))
  
  # Passage au format long
  df_long <- melt(df, id=c("placette", "date"),
                  variable.names="replicat",
                  value.name="HR",
                  na.rm=FALSE)
  # Renommage des colonnes
  colnames(df_long) <- c("placette", "date", "replicat", "HR") #Utile ?
  # levels(df_long$replicat) <- c("A", "B", "C", "D", "E")  INUTILE
  
  # output ------------------------------------------------------------------
  if (mean) {
    return(df_mean)
  } else {
    return(df_long)
  }
}


# PT ----------------------------------------------------------------------
ld_PT <- function(long=TRUE){
  df <- read.csv(paste0(pth_cleaned,"gPT.csv"))

  wide_df <- df
#   colnames(wide_df) <- c("placette", "date",
#                          "Tair", "Tsurf", 
#                          "T5", "T10", "T15", "T20", "T25", "T30",
#                          "T40", "T50", "T60", "T70", "T80", "T90", "T100")
  if (long) {
  # Passage au format long
  long_df <- melt(df, id=c("placette", "date", "ID_camp"),
                  value.name="temperature",
                  na.rm=FALSE)
  # Renommage des colonnes
  colnames(long_df) <- c("placette", "date", "profondeur", "temperature")
  # On change les "factor levels" pour pouvoir ensuite les convertir
  levels(long_df$profondeur) <- c("10","0",
                                  "-5", "-10", "-15", "-20", "-25", "-30",
                                  "-40", "-50", "-60", "-70", "-80", "-90", "-100")
  # Conversion en numéric
  long_df$profondeur <- as.numeric(as.character(long_df$profondeur))
    
  # output ------------------------------------------------------------------
    return(long_df)
  } else {
    return(wide_df)
  }
  
}


# VG_REC ------------------------------------------------------------------

ld_VG_REC <- function(long=TRUE){
  df <- read.csv(paste0(pth_cleaned,"gVG_REC.csv"))
  sav <- df$ID_camp
  df[df==""]<- 0
  df[df=="1"]<- 0
  df[df=="<1"]<- 0
  df[df=="<5"]<- 0
  df$ID_camp <- sav
  
  for (i in c(3,4,5,7,8,9)){
    f <- df[,i]
    df[,i] <- as.numeric(levels(f))[f]
  }  
  # output ------------------------------------------------------------------
  if (long) {
    df_long <- melt(df, id=c("placette", "date", "ID_camp"),
                    value.name="Recouvrement",
                    na.rm=FALSE)
    # Renommage des colonnes
    colnames(df_long) <- c("placette", "date", "ID_camp","Veg", "REC")
    return(df_long)
  } else {
    return(df)
  }
}


# VG_CPT ------------------------------------------------------------------

ld_VG_CPT <- function(mean=TRUE){
  df <- read.csv(paste0(pth_cleaned,"gVG_CPT.csv")) 
  df[df==""] <- NA
  if (mean) { # Si on ne veut quel les moyennes
  # Moyenne par colonne
  df_mean <- data.frame(placette=df[,1], date=df[,2], Veg=df[,3],
                        mean=rowMeans(df[,c(-1,-2, -3)], na.rm=TRUE),
                        sd=rowSds(df[,c(-1,-2, -3)], na.rm=TRUE)) # necéssite matrixstat
    return(df_mean)
  } else {
    return(df)
  }
  
} # F