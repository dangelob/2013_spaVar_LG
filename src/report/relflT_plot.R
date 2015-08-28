# Plot functions ----------------------------------------------------------
# histogramm + normal distribution plot
distr <- function(y, xlab){
  par(mar=c(5.1,5.1,2.1,2.1))
  hist(y,
       freq=FALSE,
       cex.lab=1.5, cex.axis=1.4, cex.main=1.5, cex.sub=1.5,
            breaks=4,
       xlab=xlab, ylab="densité", main="")
  curve(dnorm(x, mean=mean(y), sd=sd(y)), add=TRUE, col="darkblue", lwd=2) 
}

# Re ~ T per placette
plt_mdl_p7 <- function(df, Tsel, xlab="photosynthèse brute",ylab=expression(paste("photosynthèse brute (", mu, mol,m^-2,s^-1,")", sep="")), param=mlabel){
  #   set up data frames
  df <- filter(df, T_type == Tsel)
  param <- filter(param, T_type == Tsel)
  #   regselect use indicator
  df$ctrl <- ifelse(df$date > as.Date("2014-04-14"), 
                    "no", "yes")
  #   text annotation positionning
  txt_x <- 4.9
  txt_y <- floor(max(df$flux, na.rm=T))+1
  #   plot
  # plt <- ggplot(df, aes(x=T_value, y=flux, colour = ctrl))+
  plt <- ggplot(df, aes(x=T_value, y=flux))+
    geom_point(size=4, shape=21) +
    # scale_colour_manual(values=c("red", "black"))+
    labs(y=ylab, x=xlab)+
    #   geom_line(data=result, aes(x=T_value, y=mdl1), color = "red")+
    #   geom_line(data=result, aes(x=T_value, y=mdl2), color = "blue")+
    #   geom_line(data=result, aes(x=T_value, y=mdl3), color = "orange")+
    facet_wrap(~placette)+
    ylim(0,max(df$flux, na.rm=TRUE))+
    xlim(5,max(df$T_value, na.rm=TRUE))+
    theme_bw(base_size = 18)+ 
    #   theme(legend.position = "none")+
    geom_text(data=filter(param, equation == "linear"), aes(label=paste("R^2==", R2, "~~~slope==", slope, sep="")), x=txt_x, y=(txt_y-2), hjust=0, size=4, parse=T, color = "red")+
    geom_text(data=filter(param, equation == "exponential"), aes(label=paste("R^2==", R2, "~~~Q10==",Q10 ,sep="")), x=txt_x, y=(txt_y-4), hjust=0, size=4, parse=T, color = "blue")
    # geom_text(data=filter(param, equation == "arrhenius"), aes(label=paste("R^2==", R2, "(arr)", sep="")), x=txt_x, y=(txt_y-6), hjust=0, size=4, parse=T, color = "orange")
  return(plt)
  #   plt_name <- sprintf("/[pts][all][%s_%s].pdf",plt$labels$x, plt$labels$y)
#   ggsave(file.path(output_pth,f_name), width=12, height=8)
}
