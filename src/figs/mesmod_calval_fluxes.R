# filename:
rm(list=ls(all=TRUE)) # Clean start

# CRAN packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)
library(rprojroot)
## Find project root
r <- rprojroot::is_rstudio_project
root <- r$find_file()
## Folder to save the treatements
outpath <- file.path(root, "data", "processed")
savpath <- file.path(root, "graphs", "modelisation")


# Load data ---------------------------------------------------------------
## ER calibration
ercal <- read.csv(file.path(root, "data", "processed", "ER_pred_cal.csv"))%>%
  select(-pER_res)%>%
  filter(mdl %in% c("exp-Tair", "exp-Tair_H"))
## GPP calibration
gppcal <- read.csv(file.path(root, "data", "processed", "GPPsatGPP_pred_cal.csv"))%>%
  select(-pGPPsat)%>%
  filter(mdl %in% c("exp-Tair", "exp-Tair_IVcov"))
## CH4 calibration
ch4cal <- read.csv(file.path(root, "data", "processed", "CH4_pred_cal.csv"))%>%
  select(-pCH4_res)%>%
  filter(mdl %in% c("exp-Tair", "exp-IVcov"))%>%
  mutate(mdl=factor(mdl, levels=c("exp-Tair", "exp-IVcov")))

## ER validation
erval <- read.csv(file.path(root, "data", "processed", "ER_pred_val.csv"))%>%
  filter(mdl %in% c("exp-Tair", "exp-Tair_H"))
## GPP validation
gppval <- read.csv(file.path(root, "data", "processed", "GPP_pred_val.csv"))%>%
  select(-pGPPsat)%>%
  filter(mdl %in% c("exp-Tair", "exp-Tair_IVcov"))
## CH4 validation
ch4val <- read.csv(file.path(root, "data", "processed", "CH4_pred_val.csv"))%>%
  # select(-pCH4_res)%>%
  filter(mdl %in% c("exp-Tair", "exp-IVcov"))%>%
  mutate(mdl=factor(mdl, levels=c("exp-Tair", "exp-IVcov")))

# graphs ------------------------------------------------------------------
## commons

pt_size <- 3

p <- theme_classic()+
  theme(panel.grid.major.y = element_line(size=.1, colour="gray95"),
        panel.grid.major.x = element_line(size=.1, colour="gray95"),
        legend.position=c(.2,.87),
        legend.background=element_blank(),
        legend.key=element_blank(),
        legend.title=element_blank())


## Calibration
### ER
p1 <- ggplot(ercal, aes(x=ER, y=pER))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,10),y=c(0,10))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("ER-1", "ER-2"))+
  p
### GPP
p2 <- ggplot(gppcal, aes(x=GPP, y=pGPP))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,15),y=c(0,15))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("GPP-1", "GPP-2"))+
  p
### CH4
p3 <- ggplot(ch4cal, aes(x=CH4, y=pCH4))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,0.2),y=c(0,0.2))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("CH4-1", "CH4-2"))+
  p

## Validations
### ER
p4 <- ggplot(erval, aes(x=ER, y=pER))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,6.5),y=c(0,6.5))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("ER-1", "ER-2"))+
  p
### GPP
p5 <- ggplot(gppval, aes(x=GPP, y=pGPP))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,6),y=c(0,6))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("GPP-1", "GPP-2"))+
  p
### CH4
p6 <- ggplot(ch4val, aes(x=CH4, y=pCH4))+
  geom_abline(slope=1, intercept = 0)+
  lims(x=c(0,0.1),y=c(0,0.1))+
  labs(x="measured", y="modeled")+ 
  geom_point(aes(fill=mdl), size = pt_size, shape=21)+
  scale_fill_manual(values=c("black", "white"), 
                    labels=c("CH4-1", "CH4-2"))+
  p


grid.arrange(p1, p4, p2, p5, p3, p6, ncol=2)
g1 <- arrangeGrob(p1,p2,p3, ncol=1, top="            Calibration")
g2 <- arrangeGrob(p4,p5,p6, ncol=1, top="     Evaluation")

gt <- arrangeGrob(g1,g2, ncol=2)
# grobframe <- arrangeGrob(p1, p4, p2, p5, p3, p6, ncol=2, top="Calibration    Validation")
ggsave("fig_art_mdl.pdf", plot=gt, path = savpath, width = 6, height = 9)

