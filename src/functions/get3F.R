# Script to calculate and output GPP with this other fluxes
# 
# The non-complete data (missing temperature profiles from 2014-05-19) are 
# removed and not gap-filled 
# 
# TO DO : profiles models

# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE))
library(laguettevarspa)
library(bdphdtoolbox)
library(dplyr)
library(tidyr)

# source("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/functions/ld_fn_model.R")

outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

# loading and formating data ----------------------------------------------
# Retrieve ER data
dRe <- svNetFlux %>%
  filter(type == "ER") %>%
  # filter(date <= as.Date("2014-01-01"))%>%
  select(placette, date, netCO2F, ID_camp) %>%
  rename("ER" = netCO2F)%>%
  mutate(F_type = "ER")
# negative flux are impossible : probably 0
dRe$ER<- ifelse(dRe$ER < 0, 0.0001, dRe$ER)

# Retrieve NEE data
dNEE <- svNetFlux %>%
  filter(type == "NEE") %>%
  select(placette, date, netCO2F, ID_camp) %>%
  rename("NEE" = netCO2F)%>%
  mutate(F_type = "NEE")

# Calculate GPP
dGPP<- inner_join(dRe[,c(1:4)], dNEE[,c(1:4)])%>%
  mutate(GPP = NEE + ER, F_type = "GPP")%>%
  select(ID_camp, placette, date, GPP, F_type)

# Rename before merge : 
dRe <- rename(dRe, flux=ER)
dNEE <- rename(dNEE, flux=NEE)
dGPP <- rename(dGPP, flux=GPP)

# Merge all flux data
dflux <- bind_rows(dRe, dNEE, dGPP)

filepath_mdl <- paste0(outpath, "/3F_data.csv")
write.csv(dflux, filepath_mdl, quote=F, row.names=F)
