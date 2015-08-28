
# Plot functions ----------------------------------------------------------
# Flux evolution againt time across field campaign
flplt <- function(X, laby="netCO2F"){  
  p <- ggplot(X, aes(x=date, y=netCO2F))+
    geom_point(shape=21, size=4)+
    annotate("text", x=as.Date("2013-03-15"), y=18, label=nobs, size=3.5)+
    labs(y = laby)+
    scale_colour_manual(values=c("red","black"))+
    theme_bw()+
    guides(color=guide_legend(title=NULL))+
    theme(panel.grid.major.x = element_blank(), # DIAPO
          panel.grid.major.y = element_line(size=.05, colour="gray95"), # DIAPO
          panel.grid.minor = element_blank())# DIAPO
  return(p)
}

# Individual plot measurement
p7_fl_plt <- function(X, laby="netCO2F"){
  p <- ggplot(X, aes(x=date, y=netCO2F))+
    geom_line(aes(group = year))+
    geom_point()+
    labs(y=laby)+
    geom_text(data=df, aes(x=date, y=netCO2F+4, label=time), size=2.5, angle=90)+
    facet_wrap(~placette)+
    theme_bw()+
    theme(legend.position="none", axis.text.x=element_text(angle=30, hjust=1))
  return(p)
}
  
# Montly ER means per year
ann_month_mean_fl <- function(X, laby="netCO2F"){
  ammean <- X %>%
    group_by(year, month) %>%
    summarise(fl = mean(netCO2F, na.rm=T), fl_sd = sd(netCO2F, na.rm=T))
  
  ggplot(ammean, aes(x=month, y=fl, color=year))+
    geom_point()+
    labs(y=laby)+
    geom_line(aes(x=month, y=fl+fl_sd, group=year))+
    geom_line(aes(x=month, y=fl-fl_sd, group=year))+
    theme_bw()
}

# Montly flux mean (pooling all years)
month_mean_fl <- function(X, laby="netCO2F"){
  # data summary   
  mm <- X %>%
    group_by(month) %>%
    summarise(fl = mean(netCO2F, na.rm=T), fl_sd = sd(netCO2F, na.rm=T))
  # month mean plot
  p <- ggplot(mm, aes(x=month, y=fl))+
    geom_point()+
    labs(y=laby)+
    geom_line(aes(x=month, y=fl+fl_sd, group=1))+
    geom_line(aes(x=month, y=fl-fl_sd, group=1))+
    theme_bw()
  return(p)
}