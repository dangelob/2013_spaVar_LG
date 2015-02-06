lmp <- function (modelobject) {
  if (class(modelobject) != "lm") stop("Not an object of class 'lm' ")
  f <- summary(modelobject)$fstatistic
  p <- pf(f[1],f[2],f[3],lower.tail=F)
  attributes(p) <- NULL
  return(p)
}

get_param <- function (modelobj) {
  if (class(modelobj) != "lm") stop("Not an object of class 'lm' ")
  m <- summary(modelobj)
  r2 <- m$r.squared
  r2a <- m$adj.r.squared
  intercept <- coef(m)[1]
  slope <- coef(m)[2]
  intercept_se <- coef(m)[3]
  slope_se <- coef(m)[4]
  intercept_p <- coef(m)[7]
  slope_p <- coef(m)[8]
  R <- cor(modelobj$model)[1,2]
  #   p <- lmp(modelobj)
  rse <- m$sigma
  AIC <- AIC(modelobj)
  result <- data.frame(intercept=intercept, slope=slope, R2=r2, R2a=r2a, R=R, 
                       #                        pvalue=p, 
                       se=rse, 
                       #                          rmse=rmse, rmse_pct=rmse_pct, 
                       AIC=AIC, intercept_se=intercept_se, intercept_p=intercept_p, slope_se=slope_se, slope_p=slope_p)
  return(result)
}

AUCc <- function(prof, temp, coef = "none"){
  idp <- order(prof) # ascending depth (0, 5, 10, 20, 30 cm)
  epaisseur <- diff(prof[idp]) # layer thickness
  Pmoy <- rollmean(prof[idp], 2) # mean depth between 2 layers
  Tmoy <- rollmean(temp[idp], 2) # mean temperature between 2 layer
  # return AUC function of coeff
  if(coef == "1/z"){
    AUC <- sum(epaisseur*Tmoy*(1/Pmoy))
  }else if (coef == "1/z2"){
    AUC <- sum(epaisseur*Tmoy*(1/(Pmoy^2)))
  }else if (coef == "none"){
    AUC <- sum(epaisseur*Tmoy)
  }else{
    AUC <- "error"
  }
  return(AUC)
}

modarr <- function(df) {
  Rboltz <- 8.314472
  Temp_K <- df$T_value
  Y <- log(df$flux)
  X <- 1/Temp_K
  fit <- lm(Y~X)
  fit <- get_param(fit)
  return(fit)
}

get_res <- function(df, equation){
  if(equation == "linear"){
    res <- df %>%
      mutate(predRe = a + b*T_value) %>%
      mutate(res = Re - predRe)
  }else if(equation == "exponential"){
    res <- df %>%
      mutate(predRe = a * exp(b*T_value)) %>%
      mutate(res = Re - predRe)
  }else if(equation == "arrhenius"){
    res <- df %>%
      mutate(predRe = a * exp(-b/8.314472*(1/T_value))) %>%
      mutate(res = Re - predRe) 
  }
  return(res)
}

mdl_calc <- function(df){
  # With one dataset, compute different model parameters and bind all
  # linear
  lin <- get_param(lm(flux~T_value, data = df)) %>%
    mutate(equation = "linear",
           a=intercept,
           b=slope)
  # exponential  
  exp <- get_param(lm(log(flux)~T_value, data = df)) %>%
    mutate(equation = "exponential",
           a=exp(intercept),
           b=slope)
  # arrhenius
  arr <- (modarr(df)) %>%
    mutate(equation = "arrhenius", 
           a=exp(intercept),
           b=-slope*8.314472)
  
  result <- bind_rows(lin, exp, arr)
}