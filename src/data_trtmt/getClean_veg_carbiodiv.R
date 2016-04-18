# Obj ---------------------------------------------------------------------
# This script gather and treat CARBIODIV vegetation data.
# These are elaborate data that have been treated : 
# The vegetation data are treated by : [details TODO]

# Output : 
# This script output 1 files :
# - cdIVcov.csv 


library(carbiodiv)
library(tidyr)
library(dplyr)

outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

# setup output df ---------------------------------------------------------
# Génération d'un tableau vide pour la végétation des campagnes "variabilité spatiale"

# Recouvrement
rec <- cdVegetation %>%
  select(campaign, treatment, localisation, replicate, specie, rec) %>%
  group_by(campaign, treatment, localisation, replicate)%>%
  spread(specie, rec)%>%
  replace(is.na(.), 0)%>%
  mutate(A = calluna + erica_tetralix, H = molinia + eriophorum, M = sphagnum) %>%
  select(campaign, treatment, localisation, replicate, A, H, M)%>%
  mutate(IVcov = ((A+H+M)/300))

filepath <- paste0(outpath, "/cdIVcov.csv")
write.csv(rec, filepath, quote=F, row.names=F)