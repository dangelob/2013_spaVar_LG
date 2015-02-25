# Script to calculate models per plot
# 
# The non-complete data (missing temperature profiles from 2014-05-19) are 
# removed and not gap-filled 
# 
# TO DO : profiles models

# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE))
library(laguettevarspa)
library(dplyr)
library(tidyr)

source("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/functions/ld_fn_model.R")

outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

# loading and formating data ----------------------------------------------
# Retrieve ER data
dRe <- svNetFlux %>%
  filter(type == "ER") %>%
  select(placette, date, netCO2F) %>%
  rename("ER" = netCO2F)%>%
  mutate(F_type = "ER")
# negative flux are impossible : probably 0
dRe$ER<- ifelse(dRe$ER < 0, 0.0001, dRe$ER)

# Retrieve NEE data
dNEE <- svNetFlux %>%
  filter(type == "NEE") %>%
  select(placette, date, netCO2F) %>%
  rename("NEE" = netCO2F)%>%
  mutate(F_type = "NEE")
  
# Calculate GPP
dGPP<- inner_join(dRe[,c(1:3)], dNEE[,c(1:3)])%>%
  mutate(GPP = NEE + ER, F_type = "GPP")%>%
  select(placette, date, GPP, F_type)

# Rename before merge : 
dRe <- rename(dRe, flux=ER)
dNEE <- rename(dNEE, flux=NEE)
dGPP <- rename(dGPP, flux=GPP)

# Merge all flux data
dflux <- bind_rows(dRe, dNEE, dGPP)

# Retrive temperature profile and put them in long format
dTP <- svTemperature %>%
  select(placette, date, ID_camp,
         Tair, Tsurf, T5, T10, T15, T20, T25, T30, T40, T50,
         T60, T70, T80, T90, T100) %>%
  mutate(placette = as.character(placette))%>%
  gather("T_type", "T_value", 4:18) %>%
  do(filter(., complete.cases(.))) %>%
  group_by(T_type, placette) %>%
  filter(n() >= 8)%>% # keep if 8 obs (or more)
  ungroup()

# Merge T profiles and ER fluxes
df <- full_join(dTP, dflux, by=c("placette", "date"))

# Merge with WTL
dWT <- svCtrlFact %>%
  mutate(placette = as.character(placette))%>%
  select(placette, date, WTL)

df <- left_join(df, dWT)

# For now no gap filling, the non-complete cases are removed
# 10 T profiles are missing in the 2014-05-19 campaign
df <- filter(df, !is.na(T_type))

# Compute models 
mdl <- df %>%
  group_by(placette, T_type, F_type) %>%
  do(mdl_calc(.))

# Compute Q10
mdl$Q10 <- ifelse(mdl$equation == "exponential", exp(10*mdl$slope) , NA)

# Write the output in a file
# Models output
filepath_mdl <- paste0(outpath, "/mdl_p7.csv")
write.csv(mdl, filepath_mdl, quote=F, row.names=F)
# Data compilation
filepath_flux <- paste0(outpath, "/flux_p7.csv")
write.csv(df, filepath_flux, quote=F, row.names=F)

