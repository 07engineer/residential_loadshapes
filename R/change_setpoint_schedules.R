#' Change Setpoint Schedules
#'
#' Replaces schedule columns with ones in a research schedule file
#'
#'
#' @param building_subctegory Building Subcategory
#' @pram research_schedule_name A schedule of setpoints to try
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' change_setpoint_schedules(building_subcategory, setpoint_research.csv)


change_setpoint_schedules <- function(building_subcategory, research_schedule_name){
subcategory_schedule <- read_csv(str_c("schedules/", building_subcategory, ".csv"))

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