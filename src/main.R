source(paste(getwd(),"/src/load.R", sep=""))


# idée interface

# Non CO2 (ce qui est autre que le CO2)
# FN_CandC (Clean and Concat) 

# CO2
# Sélect date
# FN_CleanDate
#     diagplt/regselec 

# FN_CO2_Concat



# Cleaning CO2 ------------------------------------------------------------
detach("package:vaisCO2", unload=TRUE)
library(vaisCO2)

dateList <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/meta/listeDateVS.csv")

date <- "2013-03-05"

pathRawdat <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/raw/CO2/"

ID_camp <- paste0(date, "_LG_VS")
pth_camp <- paste0(pathRawdat, ID_camp)
pathTOm70 <- paste0(pth_camp, "/", date, "_LG_VAm70")
# IDcamp <- "2014-03-19_LG_VS"

df <- prepVis(pathTOm70)

pth_regsel <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/diagnostic/CO2_cleaning"
diagplot(df,outname=paste0(IDcamp, "_diagplt.pdf") ,outpath=pth_regsel) # package vaisCO2 nécessite un champ fileid

# TODO utilisation de regselect, il renvoie un df en renseignant un champ keep
df <- regselect(df, path=pth_regsel, file=paste0(date,"_regselect.csv"))

# Faire une fonction regenDiagPlot qui alnce regselect puis diagplot

# Nettoyage du dataframe : (retrait des lignes keep == FALSE)
df <- df[which(df$keep == TRUE),]
df$keep <- NULL
#−−# A ce stade on doit avoir un fichier contenant les données CO2 complètement propre
#−−# du type : date, time, RH, temperature, CO2, fileid, timestamp, keep
dflux <- df # si jamais on veut l'ensemble des data de flux...

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


#--# On save pour concat un fichier du type : ???? juste les flux net pas séparés en NEP, RE ... intérêt ?
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
df_wide <- cbind(df_J[,c("placette","temp.mean", "temp.sd", "hr.mean", "hr.sd")], df_N[,c("temp.mean", "temp.sd", "hr.mean", "hr.sd")])
# Renommer la première colonne "placette" + les colonnes jour + colonne nuit
colnames(df_wide) <- c("placette", "T_Chb_J.mean", "T_Chb_J.sd", "HR_Chb_J.mean", "HR_Chb_J.sd", "T_Chb_N.mean", "T_Chb_N.sd", "HR_Chb_N.mean", "HR_Chb_N.sd")
# colnames(df_wide) <- c("placette", "T_Chb_N.mean", "T_Chb_N.sd", "HR_Chb_N.mean", "HR_Chb_N.sd")

### Calcul Re NEP GPP
# Calcul et ajout de la colonne NEP
df_wide <- cbind(df_wide, "NEP"=(-df_J$netC02F))
# Calcul et ajout de la colonne Re
df_wide <- cbind(df_wide, "Re"=(-df_N$netC02F))
# Calcul et ajout de la colonne GPP
df_wide$GPP <- (df_wide$NEP-df_wide$Re)

# Créer une colonne date (nécessite stringr)
df_wide$date <- str_extract(df_J$filename, "20..-..-..")
df_wide$ID_camp <- dateList[which(dateList$date == date),]$terrNum

sav_deraw <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/"
write.csv(df_wide, paste0(sav_deraw, paste0(date, "_df_wide.csv")))






# CONCAT PASSAGE DE DERAW A CLEANED 



# Concat pour l'ensemble des dates de chaque fichier CO2
gCO2 <- data.frame()

for (i in dateList$terrNum){
  ID_CO2 <- paste0("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/deraw/CO2/", dateList$date[i], "_df_wide.csv")
  CO2 <- read.csv(ID_CO2)
  gCO2 <- rbind(gCO2, CO2)
}


# Concat pour l'ensemble des dates de chaque fichier (TE, HR...)
# gTE <- data.frame()
assign("gTE", data.frame()) # POur automatisation ?
gHR <- data.frame()
gPT <- data.frame()
gVG_REC <- data.frame()
gVG_CPT <- data.frame()

for (i in dateList$terrNum){
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

gTE <- cln_TE(gTE)
gHR <- cln_HR(gHR)
gPT <- cln_PT(gPT)
gVG_REC <- cln_VG_REC(gVG_REC)
gVG_CPT <- cln_VG_CPT(gVG_CPT)

sav_cln <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/cleaned/"
write.csv(gCO2, paste0(sav_cln,"gCO2.csv"))
write.csv(gTE, paste0(sav_cln,"gTE.csv"))
write.csv(gHR, paste0(sav_cln,"gHR.csv"))
write.csv(gPT, paste0(sav_cln,"gPT.csv"))
write.csv(gVG_REC, paste0(sav_cln,"gVG_REC.csv"))
write.csv(gVG_CPT, paste0(sav_cln,"gVG_CPT.csv"))

