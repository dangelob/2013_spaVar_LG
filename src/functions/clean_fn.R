### OBJECTIF #===========================================================================
# Vérifier et Nettoyer les données Terrain 
#
### PRE-REQUIS
# Un dataframe contenant les données concaténées (tous les terrains)
#   
### MODIFICATIONS
# 2013-10-15 : V1 de la fonction
# 2014-04-27 : V2 de la fonction
#       
### PARAMETRE
# df : Le dataframe à traiter
#

# TE ----------------------------------------------------------------------
cln_TE <- function(df){
  # Traitement --------------------------------------------------------------
  df$WT <- (df$PiezoNap-df$PiezoVeg)
  return(df)
} # Fin fonction


# HR ----------------------------------------------------------------------
cln_HR <- function(df){
  # Traitement --------------------------------------------------------------
  return(df)
} # Fin fonction


# PT ----------------------------------------------------------------------
cln_PT <- function(df){
  # Traitement --------------------------------------------------------------
  if("TairDeb" %in% colnames(df) & "TairFin" %in% colnames(df))
  {
    # Calcul de la moyenne de la Température de l'air
    df$Tair <- rowMeans(subset(df, select = c(TairDeb, TairFin)), na.rm = TRUE)
    # Suppression des colonnes TariDeb et TairFin
    drops <- c("TairDeb","TairFin")
    df <- df[,!(names(df) %in% drops)]
    # Réorganisation des colonnes
    df <- df[,c("placette", "date", "Tair", "Tsurf",
                "X.0.05", "X.0.1", "X.0.15", "X.0.2", "X.0.25", "X.0.3",
                "X.0.4", "X.0.5", "X.0.6", "X.0.7", "X.0.8", "X.0.9", "X.1")]
  }else{}
  return(df)
} # Fin fonction


# VG_REC ------------------------------------------------------------------
cln_VG_REC <- function(df, long=TRUE, dbg=FALSE){
  # Traitement --------------------------------------------------------------
  # Replacer les NA et NULL par 0
  df[is.na(df)]=0
  df[is.null(df)]=0
  # HUM TOUJOURS DES BLANCS
  return(df)  
} # Fin fonction


