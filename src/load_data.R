# File name : /2013_spavar_LG/src/data_trtmt/load_data.R
# TODO : externalize interpolations of env. variable in there
# Set up ------------------------------------------------------------------
rm(list=ls(all=TRUE)) # Clean start
## CRAN library
library(rprojroot)
library(knitr)

## Find project root
r <- rprojroot::is_rstudio_project
root <- r$find_file()

## Set script path
path <- file.path(root, "src", "data_trtmt")

## Set environment to run script (avoid path to be deleted)
e <- new.env()

# Process data ------------------------------------------------------------
# No dependency except laguettevarspa
source(file.path(path,"getClean_co2.R"), local = e) # cl_CO2.csv
source(file.path(path,"getClean_ch4.R"), local = e) # cl_CH4.csv
source(file.path(path,"getClean_veg.R"), local = e) # svIVcov.csv

# No dependency except carbiodiv
source(file.path(path,"getClean_veg_carbiodiv.R"), local = e) # cdIVcov.csv

# dependency on previous scripts
## dep: snoweather, getClean_co2, getClean_ch4, getClean_veg
source(file.path(path,"getClean_fluxesFC.R"), local = e) # cl_fluxesFC.csv, cl_fluxesFC_avg.csv
## dep: trt continous (to externalize) //!\\
source(file.path(path,"gather_interpol_data.R"), local = e) # env_var_interp.csv
## dep: carbiodiv, snoweather, getClean_veg_carbiodiv
source(file.path(path,"getClean_carbiodiv_val_data.R"), local = e) # cl_carbiodiv_val.csv

# Cleaning
rm(e, path, r, root)
