# CONTIENT LES FONCTION DE RECUPERATION DES METADATA
### OBJECTIF #===========================================================================
# Facilité le choix des dates à traiter
### PRE-REQUIS
# 
#
### MODIFICATIONS
# 2013-09-20 : Première tentative 

####### fonction definition #============================================================
get_dateList <- function(type="date"){ 
  #type = date retourne des dates ;
  #type = num retourne les numéros des campagnes
  #type = all retourne le df contenant les dates ET les numéros
  

  # Lecture -----------------------------------------------------------------
  pth_meta <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/meta/"

  df <- read.csv(paste0(pth_meta,"listeDateVS.csv")
                 , sep="," #Précise le séparateur de colonne
                 , header=TRUE # précise si le fichier contient les entêtes de colonne
                 , dec="." #Précise le séparateur décimal
  )
  
  ### Conversion en date 
  df$date <- as.Date(df$date)

  # Fn output ---------------------------------------------------------------

  if (type == "date"){
    return(df$date) 
  } else if(type == "num"){
    return(df$terrNum) 
  } else if(type == "all"){
    return(df)
    }else{
    print("erreur dans le type de données reçue par la fonction")
  }
  
}


