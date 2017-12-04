#' Create Parametric Section of EnergyPlus Input File Section
#'
#' At ADM we divide the EnergyPlus input files into various sections to make things easier. 
#'   
#'
#' @param run_name Name of the EnergyPlus run
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' combine_sections()

create_parametric <- function(){
  n_EPD = 5
  n_cooling_eff = 4
  
  EPD_values <- seq(from = 10, to = 50, length.out =  n_EPD)
  cooling_eff_values <- seq(from = 2, to = 5, length.out =  n_cooling_eff)
  
  values <- as.tibble(expand.grid(EPD = EPD_values, cooling_efficiency = cooling_eff_values))
  n = nrow(values)
  values <- values %>% 
    mutate(sufflist = map_chr(1:n, function(x) str_c("Run_", x)),
           File = "Residential_sch.csv",
           insulation_wall = 2.37,
           insulation_roof =  4.32, 
           window =  "Window_U_0.44_SHGC_0.26",
           heating_efficiency = 4.1,
           fan_efficiency = 0.55575,
           OSA =0.057,
           exterior_lighting = 1,
           LPD = 5
    )
  
  parametric_file <- c(
    str_c("Parametric:FileNameSuffix, sufflist, ", str_c(values$sufflist, collapse = ", "), ";"),
    str_c("Parametric:SetValueForRun, $8760File, ", str_c(values$File, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $insulation_wall, ", str_c(values$insulation_wall, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $insulation_roof, ", str_c(values$insulation_roof, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $window, ", str_c(values$window, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $cooling_efficiency, ", str_c(values$cooling_efficiency, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $heating_efficiency, ", str_c(values$heating_efficiency, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $fan_efficiency, ", str_c(values$fan_efficiency, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $OSA, ", str_c(values$OSA, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $LPD, ", str_c(values$LPD, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $EPD, ", str_c(values$EPD, collapse = ", "),";"),
    str_c("Parametric:SetValueForRun, $exterior_lighting, ", str_c(values$exterior_lighting, collapse = ", "),";")
  )
  
  write.csv(values, "parametric_values.csv")
  write_file(str_c(parametric_file, collapse = "\r\n"), "sections/03_Parametrics.idf")
  cat("Parametric file written.\n")
}
