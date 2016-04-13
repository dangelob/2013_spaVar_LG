# Script to retrieve and clean CH4 dat
# Remove measurement campaign without a corresponding CO2  campaign
# Remove measurement point that are not used in the "spatial variability experiment
# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
library(laguettevarspa)
library(dplyr)
library(tidyr)


# Folder to save the treatements ------------------------------------------
outpath <- "/home/dangelo/Documents/4.ScienceStuff/2.Projects/2013_spaVar_LG/data/processed"

#  Notation correspondance ------------------------------------------------
lookup <- c("1" = "p01", "2" = "p02", "3" = "p03", "4" = "p04", "5" = "p05", "6" = "p06", "5'"="A", "5\""="B", "ETREPEE"="C")

vsCH4 <- svCH4 %>%
  mutate(date=as.Date(date, format="%Y-%m-%d")) %>%
  filter(CH4 < 1) %>% #
  select(ID_camp_co2, date, time, plot, CH4)%>%
  filter(ID_camp_co2 != "none")%>% # remove CH4 campaign without a CO2 correspondance
  filter(plot %in% c(1,2,3,4,5,6))%>% # keep only "spatial variability" measurement points
  mutate(plot = as.numeric(as.character(plot)))%>%
  mutate(placette = lookup[plot])%>%
  select(-plot)%>%
  mutate(time = as.character(time))%>%
  mutate(time = ifelse(is.na(time), "12:00:00", time))%>%
  mutate(ts_ch4 = paste(as.character(date), as.character(time)))%>%
  mutate(ts_ch4 = as.POSIXct(ts_ch4, format="%Y-%m-%d %H:%M:%S"))%>%
  rename(ID_camp = ID_camp_co2)%>%
  mutate(ID_camp = as.numeric(as.character(ID_camp)))%>%
  group_by(ID_camp, placette)%>%
  summarise(timestamp=min(ts_ch4, na.rm=T), CH4=mean(CH4, na.rm=T))%>%
  mutate(timestamp=as.POSIXct(round(timestamp, "hours")))

# Save treatement in file -------------------------------------------------
write.csv(vsCH4, file.path(outpath, "cl_CH4.csv"), quote=F, row.names=F)