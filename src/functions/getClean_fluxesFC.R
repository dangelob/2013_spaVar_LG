# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
library(laguettevarspa)
library(snoweather)
library(dplyr)
library(tidyr)

# Folder to save the treatements ------------------------------------------
outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

## Flux CO2
dfco2 <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/cl_CO2.csv") %>%
  spread(F_type, flux)%>%
  select(ID_camp, date, placette, ER, GPP, NEE)
  
## Flux CH4
dfch4 <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/cl_CH4.csv") %>%
  mutate(timestamp=as.POSIXct(as.character(timestamp)))%>%
  mutate(timestamp=as.POSIXct(round(timestamp, "hours")))%>%
  select(ID_camp, timestamp, placette, CH4)

# Retrieve environmental variables
dfctrl <- svCtrlFact %>%
  select(ID_camp, placette, WTL, RH_m, NPOC, PAR_Deb, PAR_Fin)%>%
  gather(type, val, 6:7)%>% # PAR mean calculation
  group_by(ID_camp, placette)%>%
  summarise(WTL=mean(WTL, na.rm=T), PAR=mean(val, na.rm=T), RH_m=mean(RH_m, na.rm=T), NPOC=mean(NPOC, na.rm=T))%>%
  ungroup()

# Retrieve temperature data
dfT <- svTemperature%>%
  select(ID_camp, placette, Tair, T5, T10, T20, T30, T40, T50, T60, T70, T80, T90, T100)%>%
  mutate(placette = as.character(placette))

# Retrieve vegetation data
dfveg <- read.csv("/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed/svIVcov.csv") %>%
  select(ID_camp, placette, IVcov, A, H, M)%>%
  mutate(placette = as.character(placette))

# Retrieve weather station data
cT <- wrLGT %>%
  select(timestamp, Ta, Ts_1, Ts_2, Ts_3, Ts_4)%>%
  filter(timestamp >= as.POSIXct("01/01/2013", format = "%d/%m/%Y"))%>%
  rename(TairS=Ta, T5S=Ts_1, T10S=Ts_2, T20S=Ts_3, T40S=Ts_4)%>%
  mutate(hour = cut(timestamp, breaks="hours"))%>% # daily mean
  select(-timestamp)%>%
  group_by(hour)%>%
  summarise_each(funs(mean))%>%
  mutate(timestamp = as.POSIXct(hour, format="%Y-%m-%d %H:%M:%S"))%>%
  select(-hour)

# Merge all data
df <- dfctrl %>%
  left_join(., dfco2)%>%
  left_join(., dfT)%>%
  left_join(., dfveg)%>%
  left_join(., dfch4)%>%
  left_join(., cT, by=c("timestamp"))#%>%
# filter(!is.na(CH4))#

# Save treatement in file -------------------------------------------------
write.csv(df, file.path(outpath, "cl_fluxesFC.csv"), quote=F, row.names=F)
