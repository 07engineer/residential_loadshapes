#' Calc Errors: CVRSME
#'
#' This function calculates Coefficient of variation of the root mean square error. Metrics for checking model calibration.
#' From ASHRAE Guideline 14, pg 15, equations 5.4 and 5.5 
#' http://www.eeperformance.org/uploads/8/6/5/0/8650231/ashrae_guideline_14-2002_measurement_of_energy_and_demand_saving.pdf
#' For hourly analyses the suggested heuristics are < 30% CVRSME.
#' @param model Simulation data vector
#' @param actual Billing data vector
#' @keywords Autocalibration,EnergyPlus
#' @export
#' @examples
#' calc_CVRMSE()

calc_CVRMSE <- function(model, actual){
  sq_error = (model - actual) ^2
  n = length(model)
  p = 1
  mean = mean(actual, na.rm = TRUE)
  100 * sqrt(sum(sq_error, na.rm = TRUE) / (n - p)) / mean
}

#' Calc Errors: NMBE
#'
#' This function calculates Normalized mean bias error. Metrics for checking model calibration.
#' From ASHRAE Guideline 14, pg 15, equations 5.4 and 5.5 http://www.eeperformance.org/uploads/8/6/5/0/8650231/ashrae_guideline_14-2002_measurement_of_energy_and_demand_saving.pdf
#' For hourly analyses the suggested heuristics are < 30% CVRSME.
#' @param model Simulation data vector
#' @param actual Billing data vector
#' @keywords Autocalibration,EnergyPlus
#' @export
#' @examples
#' calc_NMBE()

calc_NMBE <- function(model, actual){
  error = model - actual
  n = length(model)
  p = 1
  mean = mean(actual, na.rm = TRUE)
  sum(error, na.rm = TRUE) / (n - p) / mean * 100
}

#' Convert to Jules to kW
#'
#' This function searches for fields in a dataframe representing an EnergyPlus output for units if [J] and then
#' converts them into units of [kW].
#' @param df The dataframe of EnergyPlus outputs to be converted
#' @keywords EnergyPlus,Model Data, Calibration
#' @export
#' @examples
#' JtoKW()

JtoKW <- function(df){
  J_columns <- grep(" \\[J\\]\\(Hourly\\)", names(df))
  numbers <- df[,J_columns] / (3600 * 1000)
  names(numbers) <- gsub(" \\[J\\]\\(Hourly\\)", "", names(numbers))
  df <- as_tibble(cbind(df[,"date"], numbers))
  
  return(df)
}

#' Delete some of the extra files from the folder with the batch executable RunDirMulti.bat
#'
#' This function searches for fields in a dataframe representing an EnergyPlus output for units if [J] and then
#' converts them into units of [kW].
#' @param path Folder location relative to working directory
#' @keywords EnergyPlus,Model Data, Calibration
#' @export
#' @examples
#' clean_RunDirMulti_folder(sim_path)

clean_RunDirMulti_folder <- function(path){
  files <- dir(path)
  keep <- which(str_detect(files, "RunDirMulti.bat|\\.idf|\\.err|Meter"))
  discard <- files[-keep]
  file.remove(str_c(path, discard, sep = "/"))
}
