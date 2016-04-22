# Obj ---------------------------------------------------------------------
# This script gather and treat vegetation data.
# These are elaborate data that have been treated : 
# The vegetation data are treated by : [details TODO]

# Output : 
# This script output 1 files :
# - cdIVcov.csv 

rm(list=ls(all=TRUE)) # Clean start
# Homemade
library(laguettevarspa)
# CRAN
library(tidyr)
library(dplyr)
library(rprojroot)

## Find project root
r <- rprojroot::is_rstudio_project
root <- r$find_file()

outpath <- file.path(root, "data", "processed")

# setup output df ---------------------------------------------------------
# Génération d'un tableau vide pour la végétation des campagnes "variabilité spatiale"
p7 <- c("p01", "p02", "p03", "p04", "p05", "p06", "p07", "p08", "p09", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20")

veg <- c("sphagnum", "erica", "calluna", "molinia", "eriophorum")

# strate de la végétation (Muscinale, Arbustive, Herbacée)
strt <- c("M", "A", "A", "H", "H")

nb_campagne <- 20
nb_p7 <- NROW(p7)
nb_specie <- NROW(veg)


A <- rep(c(1:nb_campagne), each=(nb_p7*nb_specie))
B <- rep(rep(p7, each=nb_specie), nb_campagne)
C <- rep(veg, (nb_p7*nb_campagne)) 
D <- rep(strt, (nb_p7*nb_campagne)) 

dfA <- data.frame(ID_camp=A, placette=B, specie=C, strate=D)


# préparation des df a merger
# cover -------------------------------------------------------------------
cvr <- svVegetation %>%
  select(ID_camp, placette, specie, cover)%>%
  filter(cover != "9999") # different sphagn sp unused

dfcover <- dfA %>%
  left_join(., cvr, by=c("ID_camp", "placette", "specie"))%>%
  mutate(cover = as.character(cover))%>%
  mutate(cover = ifelse(cover %in% c("<5", "<1"), 0, cover))%>%
  mutate(cover = as.numeric(cover))%>%
  mutate(cover = ifelse(is.na(cover), 0, cover))

# number ------------------------------------------------------------------
nbr <- svVegetation %>%
  filter(cover != "9999") %>% # different sphagn sp unused
  select(ID_camp, placette, specie, number)

dfnumber <- dfA %>%
  left_join(., nbr, by=c("ID_camp", "placette", "specie"))%>%
  mutate(number = ifelse(specie %in% c("molinia", "eriophorum") & ID_camp >=10 & is.na(number), 0, number))


# height ------------------------------------------------------------------
hght <- svVegetation %>%
  filter(cover != "9999") %>% # different sphagn sp unused
  select(ID_camp, placette, specie, height_m, height_sd, N)

dfheight<- dfA %>%
  left_join(., hght, by=c("ID_camp", "placette", "specie"))


# merge all ---------------------------------------------------------------
df <- dfA %>%
  left_join(., dfcover, by=c("ID_camp", "placette", "specie", "strate"))%>%
  left_join(., dfnumber, by=c("ID_camp", "placette", "specie", "strate"))%>%
  left_join(., dfheight, by=c("ID_camp", "placette", "specie", "strate"))


# verif -------------------------------------------------------------------
# Pas plus de 100 % de cover pour chaque strate de veg
# TO CORRECT 15 occurences !
maxcover <- df %>%
  group_by(ID_camp, placette, strate)%>%
  summarise(cover = sum(cover, na.rm=T))%>%
  filter(cover > 100)



# indices de vegetation ---------------------------------------------------
idf <- df%>%
  group_by(ID_camp, placette, strate)%>%
  summarise(cover = sum(cover, na.rm=T))%>%
  mutate(cover = ifelse(cover >= 100, 100, cover))%>% # correction temporaire des cover > à 100 % dans une strate
  spread(strate, cover)%>%
  mutate(IVcov = ((A+H+M)/300))%>%
  mutate(IVcov_A = (A/100))%>%
  mutate(IVcov_H = (H/100))%>%
  mutate(IVcov_M = (M/100))

# filepath <- paste0(outpath, "/svIVcov.csv")
# write.csv(idf, filepath, quote=F, row.names=F)


#  À tester sur 2014 ------------------------------------------------------
# Avant d'en faire un gap filling énorme...


mol <- df %>%
  filter(specie == "molinia")%>%
  mutate(area = mol_LtoS(height_m*10)) # area in mm2
  
m <- lm(mol$area~mol$cover)
# m <- lm(mol$number~mol$cover)
# m <- lm(mol$height_m~mol$cover)

imol <- mol %>%
  mutate(area = ifelse(cover == 0 & is.na(area), 0, area))%>%
  mutate(area = ifelse(cover != 0 & is.na(area), (coef(m)[1]+ cover*coef(m)[2]), area))%>%
  mutate(H_area = area/1000000)%>% # conversion m2)
  select(ID_camp, placette, H_area)

maxarea <- max(imol$H_area)

idf2 <- idf %>%
  left_join(.,imol)%>%
  mutate(IVcov_area=(A+M+H_area)/(200+maxarea))

# filepath <- paste0(outpath, "/svIVcov.csv")
write.csv(idf2, file.path(outpath, "svIVcov.csv"), quote=F, row.names=F)