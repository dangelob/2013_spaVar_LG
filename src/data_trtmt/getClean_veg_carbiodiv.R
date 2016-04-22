# Obj ---------------------------------------------------------------------
# This script gather and treat CARBIODIV vegetation data.
# These are elaborate data that have been treated : 
# The vegetation data are treated by : [details TODO]

# Output : 
# This script output 1 files :
# - cdIVcov.csv 

rm(list=ls(all=TRUE)) # Clean start
# Homemade
library(carbiodiv)
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

# Recouvrement
rec <- cdVegetation %>%
  select(campaign, treatment, localisation, replicate, specie, rec) %>%
  group_by(campaign, treatment, localisation, replicate)%>%
  spread(specie, rec)%>%
  replace(is.na(.), 0)%>%
  mutate(A = calluna + erica_tetralix, H = molinia + eriophorum, M = sphagnum) %>%
  select(campaign, treatment, localisation, replicate, A, H, M)%>%
  mutate(IVcov = ((A+H+M)/300))

# filepath <- paste0(outpath, "/cdIVcov.csv")
write.csv(rec, file.path(outpath, "cdIVcov.csv"), quote=F, row.names=F)