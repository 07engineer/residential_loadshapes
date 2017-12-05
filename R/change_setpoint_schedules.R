#' Change Setpoint Schedules
#'
#' Replaces schedule columns with calculated values
#'
#'
#' @param building_subctegory Building Subcategory
#' @pram research_schedule_name A schedule of setpoints to try
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' change_setpoint_schedules(building_subcategory, setpoint_research.csv)


change_setpoint_schedules <- function(building_subcategory, research_schedule_name){
  
  energyplus_schedule <- read_csv("Residential_sch.csv") %>%
    mutate(date = as_date(mdy_hm(Schedule)))
  
  energyplus_start_date = min(energyplus_schedule$date)
  energyplus_end_date   = max(energyplus_schedule$date)

analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>% 
  # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>% 
  filter(date >= energyplus_start_date, date <= energyplus_end_date)


analytic_schedule$cdd_base <- as.numeric(analytic_schedule$cdd_base)
normalized_analytic_cdd_changepoints <- (analytic_schedule$cdd_base - mean(analytic_schedule$cdd_base)) / sd(analytic_schedule$cdd_base)
setpoint_mean <- 23 # degrees Celsius
setpoint_sd <- 3 # degrees Celsius
heat_set_gap <- 5 # degrees Celsius
energyplus_schedule$Cooling <- normalized_analytic_cdd_changepoints * setpoint_sd + setpoint_mean
energyplus_schedule$Heating <- energyplus_schedule$Cooling - heat_set_gap


setpoint_research_schedule <- read_csv(str_c("schedules/", "setpoint_research.csv"))

new_col_names <- names(setpoint_research_schedule)[names(setpoint_research_schedule) != "Schedule"]

for(i in new_col_names){
  subcategory_schedule[, i] <- setpoint_research_schedule[, i]
}

write_csv(subcategory_schedule, str_c("schedules/", building_subcategory, ".csv"))
}

# subcategory_schedule$Heating <- setpoint_research_schedule$Heating
# subcategory_schedule$Cooling <- setpoint_research_schedule$Cooling

# energyplus_start_date = min(subcategory_schedule$date)
# energyplus_end_date   = max(subcategory_schedule$date)

# analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>% 
#   # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>% 
#   filter(date >= energyplus_start_date, date <= energyplus_end_date)