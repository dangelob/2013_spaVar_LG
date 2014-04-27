# Flux calculation

getNF <- function(RF=.1, Dchb_mm=300, Hchb_mm=300, Patm=101300, T_Cel=25){
  # Constante
  R <- 8.3144621
  # Conversions
  Dchb_m <- Dchb_mm/1000 # Diamètre de la chambre en mm
  Hchb_m <- Hchb_mm/1000 # Diamètre de la chambre en mm 
  T_Kel <- T_Cel+273.15
  # Calcul surface et volume
  S_chb <- pi*(Dchb_m/2)^2 # Surface de la chambre en m2
  V_chb <- Hchb_m * S_chb # Volume de la chambre en m3
  #   NF <- (RF*(V_chb/S_chb)*Patm)/(R*T_Kel)
  NF <- (RF*(Hchb_m)*Patm)/(R*T_Kel)
  
  return(NF)
}