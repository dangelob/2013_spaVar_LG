# Objectives --------------------------------------------------------------
# This script gather all continous data (interpolated or not) needed to calculate the cumulated fluxes over the measurement period
# It take as input the result of data interpolation (cf report/data_treatment/ponctual_to_continuous)
# 
# Output:
# One hourly compiled dataset: env_var_interp.csv

# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
## Home made package
library(snoweather)
## CRAN package
library(dplyr)
library(tidyr)
## Folder to save the treatements
outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

# Retrieve data -----------------------------------------------------------
# Interpolated temperature data
cT2 <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/pdata_to_cdata/cTprofile_all.csv")%>%
  select(timestamp, Tair, T5)%>%
  rename(cTair = Tair, cT5 = T5)

cT <- wrLGT %>%
  select(timestamp, Ta, Ts_1)%>%
  filter(timestamp >= as.POSIXct("01/01/2013", format = "%d/%m/%Y"))%>%
  rename(Tair=Ta, T5=Ts_1)%>%
  mutate(hour = cut(timestamp, breaks="hours"))%>% # daily mean
  # mutate(day = cut(timestamp, breaks="days"))%>% # daily mean
  select(-timestamp)%>%
  group_by(hour)%>%
  # group_by(day)%>%
  summarise_each(funs(mean))%>%
  mutate(timestamp = as.POSIXct(hour, format="%Y-%m-%d %H:%M:%S"))%>%
  # mutate(timestamp = as.POSIXct(day, format="%Y-%m-%d"))%>%
  select(-hour)%>%
  # select(-day)%>%
  mutate(timestamp = as.factor(timestamp))

cT <- merge(cT, cT2)%>% # Tair T5 station
  rename(stTair = Tair, stT5 = T5)%>%
  rename(Tair = cTair, T5 = cT5) # Tair T5 interpolé à partir mesures

## Interpolated PAR
cPAR <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/pdata_to_cdata/cPAR_all_hour.csv")

## Interpolated vegetation data
cVEG <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/pdata_to_cdata/cVeg_all_hour.csv")

## Interpolated Soil Water Content
cRH <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/pdata_to_cdata/cRH_all_hour.csv")

# Merge all datasets ------------------------------------------------------
## Merge data and filter the time duration needed
BdC <- cT %>%
  inner_join(.,cPAR)%>%
  left_join(.,cVEG)%>%
  left_join(.,cRH)%>%
  mutate(timestamp = as.POSIXct(timestamp, format="%Y-%m-%d %H:%M:%S"))%>%
  filter(timestamp >= as.POSIXct("22/02/2013", format = "%d/%m/%Y"))%>%
  filter(timestamp <= as.POSIXct("17/02/2015", format = "%d/%m/%Y"))

# Save treatement in file -------------------------------------------------
write.csv(BdC, file.path(outpath, "env_var_interp.csv"), quote=F, row.names=F)