# Script to interpolate PAR ponctual measurement to hourly data (ponctual to continuous)
# 
# Setup -------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
# Homemade 
library(laguettevarspa)
library(snoweather)

# CRAN
library(dplyr)
library(tidyr)
library(data.table)
library(rprojroot)

## Find project root
r <- rprojroot::is_rstudio_project
root <- r$find_file()

outpath <- file.path(root, "data", "processed")

# loading and formating data ----------------------------------------------

## Ponctual data (pckg: laguettevarspa)
df_p <- svCtrlFact %>%
  select(ID_camp, placette, date, NEE_time, PAR_Deb, PAR_Fin)%>%
  mutate(p_ts=as.POSIXct(paste(date, NEE_time, sep=" "), format="%Y-%m-%d %H:%M"))%>%
  group_by(p_ts)%>%
  mutate(PAR = mean(c(PAR_Deb, PAR_Fin), na.rm=T))%>%
  ungroup()%>%
  select(date, p_ts, PAR)%>%
  group_by(date)%>%
  summarise(PAR = mean(PAR, na.rm=T), p_ts = mean(p_ts, na.rm=T))


## "High" frequency data (pckg: snoweather)
df_c <- wrLGT %>%
  select(timestamp, Rad_kW, Rad_MJ)%>%
  filter(timestamp >= as.POSIXct("01/01/2013", format = "%d/%m/%Y"))

# treatment ---------------------------------------------------------------

## Create keys
df_p <- data.table(df_p, key = "p_ts")
df_c <- data.table(df_c, key = "timestamp")

df <- df_c[df_p, roll="nearest"]

## Linear model forced to 0 intercept

mdl <-lm_get_std(lm(df$PAR~0+df$Rad_kW)) %>%
  mutate(pval_star=tc_pval(pval))%>%
  mutate(slope=intercept, intercept=0)

## For all p7 pooled: hourly mean
result_all <- df_c%>%
  mutate(hour = cut(timestamp, breaks="hours"))%>% # daily mean
  select(-timestamp)%>%
  group_by(hour)%>%
  summarise_each(funs(mean))%>%
  mutate(timestamp = as.POSIXct(hour, format="%Y-%m-%d %H:%M:%S"))%>%
  select(-hour)

## Interpolate
cPAR <- result_all %>%
  mutate(PAR = mdl$intercept[1] + mdl$slope[1]*Rad_kW)%>%
  select(timestamp, PAR)

# Save --------------------------------------------------------------------

write.csv(cPAR, file.path(outpath,"cPAR_hour.csv"), row.names=FALSE, quote=FALSE)
# write.csv(mdl, file.path(outpath, "cPAR_par.csv"), row.names=FALSE, quote=FALSE)
