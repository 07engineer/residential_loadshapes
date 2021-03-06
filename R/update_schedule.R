#' Update EnergyPlus Schedules
#'
#' The analytic models produce schedules. We need to update the EnergyPlus schedule files with the new end-uses.
#'
#'
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' update_schedule("L:/P/1631/Schedules/Final", "FCZ12_ALL_Usage_Level_LOW_GAS_Schedules.csv")

update_schedule <- function(){
  energyplus_schedule <- read_csv("Residential_sch.csv") %>%
    mutate(date = as_date(mdy_hm(Schedule)))

  energyplus_start_date = min(energyplus_schedule$date)
  energyplus_end_date   = max(energyplus_schedule$date)

  analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>%
    # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>%
    filter(date >= energyplus_start_date, date <= energyplus_end_date)

  if(sum(analytic_schedule$date == energyplus_schedule$date) != 8760) stop("Schedule update failure... dates may not match")

  # In the analytic model, the hdd_base and cdd_base column are regression change point values.
  # In the energy plus schedule, they are actual setpoints.
  # John said not to update these.

  do_not_update <- c("date") # , "hdd_base", "cdd_base"
  cols_to_update <- names(energyplus_schedule)[names(energyplus_schedule) %in% names(analytic_schedule)]
  cols_to_update <- cols_to_update[!(cols_to_update %in% do_not_update)]
  analytic_schedule <- analytic_schedule[, cols_to_update]

  # #Check that no schedule values are outside zero and one

  analytic_schedule[analytic_schedule < 0] <- 0
  analytic_schedule[analytic_schedule > 1] <- 1

  # Remember not to change the column order of the EnergyPlus file columns! They are referenced in the .idf file
  energyplus_schedule[, cols_to_update] <- analytic_schedule[, cols_to_update]

  # Adjust the setpoint schedules
  # analytic_schedule$cdd_base <- as.numeric(analytic_schedule$cdd_base)
  # normalized_analytic_cdd_changepoints <- (analytic_schedule$cdd_base - mean(analytic_schedule$cdd_base)) / sd(analytic_schedule$cdd_base)
  # setpoint_mean <- 23 # degrees Celsius
  # setpoint_sd <- 3 # degrees Celsius
  # heat_set_gap <- 5 # degrees Celsius
  # energyplus_schedule$Cooling <- normalized_analytic_cdd_changepoints * setpoint_sd + setpoint_mean
  # energyplus_schedule$Heating <- energyplus_schedule$Cooling - heat_set_gap

  #write_csv(energyplus_schedule, "Residential_sch.csv")
  #write_csv(energyplus_schedule, str_c("schedules/", building_subcategory, ".csv"))
  write_csv(energyplus_schedule, str_c(EP_schedule_path, building_subcategory, ".csv"))


}


