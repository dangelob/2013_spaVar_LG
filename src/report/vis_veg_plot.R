# Plot for number and mean height évolution
veg_evol <- function(df, y){
  if(y == "number"){
    p <- ggplot(df, aes(x=date, y=number)) + geom_line()
  }else if(y == "height"){
    p <- ggplot(df, aes(x=date, y=height_m)) + geom_line()
  }else{}
  p <- p + geom_point(size = 3, shape=21, fill="white")+
    facet_wrap(~placette)+
    theme_bw()+
    theme(axis.text.x=element_text(angle=30, hjust=1))
  return(p)
}

# plot for cover evolution
veg_cover <- function(df){
  p <- ggplot(df, aes(x=ID_camp, y=cover))+
    geom_point(size = 3, shape=21)+
    facet_wrap(~placette)+
    theme_bw()
  return(p)
}