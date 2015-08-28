# Script to calculate models per plot
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

source("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/functions/ld_fn_model.R")
source("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/src/functions/get3F.R")

outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

# Get fluxes data with GPP
dflux <- read.csv(file.path(outpath, "3F_data.csv"))%>%
  mutate(date=as.Date(date))

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
# dWT <- svCtrlFact %>%
#   mutate(placette = as.character(placette))%>%
#   select(placette, date, WTL)
# df <- left_join(df, dWT)

# For now no gap filling, the non-complete cases are removed
# 10 T profiles are missing in the 2014-05-19 campaign
df <- filter(df, !is.na(T_type))


# Compute models per plots ------------------------------------------------
mdl <- df %>%
  group_by(placette, T_type, F_type) %>%
  do(lmc_calc_all(.$flux, .$T_value))
# Compute Q10
mdl$Q10 <- ifelse(mdl$equation == "exponential", exp(10*mdl$slope) , NA)




# Compute models with all plot pooled -------------------------------------
mdl_all <- df %>%
  group_by(T_type, F_type) %>%
  do(lmc_calc_all(.$flux, .$T_value))
# Compute Q10
mdl_all$Q10 <- ifelse(mdl_all$equation == "exponential", exp(10*mdl_all$slope) , NA)

# 2013
mdl2013 <- df %>%
  filter(date < as.Date("2014-01-01"))%>%
  group_by(T_type, F_type) %>%
  do(lmc_calc_all(.$flux, .$T_value))%>%
  mutate(Q10 = ifelse(equation == "exponential", exp(10*slope) , NA), year=2013)
# 2014
mdl2014 <- df %>%
  filter(date < as.Date("2015-01-01") & date >= as.Date("2014-01-01"))%>%
  group_by(T_type, F_type) %>%
  do(lmc_calc_all(.$flux, .$T_value))%>%
  mutate(Q10 = ifelse(equation == "exponential", exp(10*slope) , NA), year=2014)

mdl_pryr <- rbind(mdl2013, mdl2014)


# Write the output in a file
# Models output p7
filepath_mdl <- paste0(outpath, "/3F-T_p7_mdlpar.csv")
write.csv(mdl, filepath_mdl, quote=F, row.names=F)
# Models output all
filepath_mdl <- paste0(outpath, "/3F-T_eco_mdlpar.csv")
write.csv(mdl_all, filepath_mdl, quote=F, row.names=F)
# Models output all per year
filepath_mdl <- paste0(outpath, "/3F-T_eco_mdlpar_pryr.csv")
write.csv(mdl_pryr, filepath_mdl, quote=F, row.names=F)
# Data compilation
filepath_flux <- paste0(outpath, "/flux_p7.csv")
write.csv(df, filepath_flux, quote=F, row.names=F)

