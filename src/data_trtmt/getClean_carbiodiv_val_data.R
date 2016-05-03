# Obj ---------------------------------------------------------------------
# This script gather all carbiodiv data needed to validate models

# Output : 
# This script output 1 files :
# - cl_carbiodiv_val.csv 

# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
# Homemade
library(carbiodiv)
library(snoweather)
# CRAN
library(dplyr)
library(tidyr)
library(rprojroot)

## Find project root
r <- rprojroot::is_rstudio_project
root <- r$find_file()

# Folder to save the treatements ------------------------------------------
outpath <- file.path(root, "data", "processed")

# Calculations ------------------------------------------------------------
# Données flux
df3F <- cdNetFlux %>% # package carbiodiv
  filter(treatment == "C")%>%
  select(campaign, cycle_no, treatment, localisation, replicate, netCO2F, type)%>%
  group_by(campaign, cycle_no, treatment, localisation, replicate)%>%
  spread(type, netCO2F)%>%
  rename(ER=Re)%>%
  mutate(GPP = NEE + ER)%>%
  group_by(campaign,  localisation)%>%
  summarise(NEE = mean(NEE, na.rm=T), ER = mean(ER, na.rm=T), GPP = mean(GPP, na.rm=T))

# Données CH4
dfch4 <- cdCH4 %>%
  filter(treatment == "C")%>%
  select(campaign, treatment, localisation, replicate, ch4)%>%
  group_by(campaign,  localisation)%>%
  # group_by(campaign, localisation, replicate)%>%
  summarise(ch4 = (mean(ch4, na.rm=T)))

# Donnée PAR 
dfpar <- cdNetFlux %>%
  select(campaign, cycle_no, treatment, localisation, replicate, PAR_deb, PAR_fin)%>%
  gather("PAR_type", "PAR_val", 6:7)%>%
  group_by(campaign, cycle_no, treatment, localisation, replicate)%>%
  summarise(PAR=mean(PAR_val, na.rm=T))%>%
  ungroup()%>%
  group_by(campaign,  localisation)%>%
  summarise(PAR = mean(PAR, na.rm=T))

# Données végétation (a mettre dans pkg carbiodiv)
dfveg <- read.csv(file.path(outpath, "cdIVcov.csv"))%>%
  filter(campaign > 1)%>%
  filter(treatment == "C")%>%
  mutate(replicate=as.factor(replicate))%>%
  group_by(campaign, localisation)%>%
  summarise(IVcov = mean(IVcov, na.rm=T), H = mean(H, na.rm=T))

# Création data pour campagne 1
crea <- dfveg %>%
  ungroup()%>%
  filter(campaign == 2)%>%
  mutate(campaign = 1)
dfveg <- rbind(crea, dfveg)


# Données météo
dfwr1 <- wrLGT %>% # Données station
  select(timestamp, Ta, Ts_1)%>%
  rename(Tair=Ta, T5=Ts_1)%>%
  filter(timestamp >= as.POSIXct("01/01/2014", format = "%d/%m/%Y"))
dfwr2 <- cdNetFlux %>% # Tableau type données carbiodiv
  select(timestamp, campaign, cycle_no, treatment, localisation, replicate)%>%
  mutate(timestamp = as.POSIXct(round(timestamp, "hours")))
dfwr <- left_join(dfwr2, dfwr1)%>% # Fusion des 2
  group_by(campaign, localisation)%>%
  summarise(Tair = mean(Tair, na.rm=T), T5 = mean(T5, na.rm=T))

df <- df3F %>%
  left_join(., dfch4)%>%
  left_join(., dfpar)%>%
  left_join(., dfveg, by=c("campaign", "localisation"))%>%
  left_join(., dfwr)%>%
  ungroup()%>%
  filter(campaign > 1)

# Save treatement in file -------------------------------------------------
write.csv(df, file.path(outpath, "cl_carbiodiv_val.csv"), quote=F, row.names=F)