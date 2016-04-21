theme_interp <- theme_classic() + 
  theme(axis.title=element_text(size=14),
        axis.text=element_text(size=13),
        axis.title.x=element_blank(),
        plot.margin=unit(c(.1, .1, .1, .1), "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(size=.05, colour="gray95"),
        panel.grid.minor = element_blank())