#' Change Setpoint Schedules
#'
#' The analytic models produce schedules. We need to update the EnergyPlus schedule files with the new end-uses.
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

subcategory_schedule$Heating <- setpoint_research_schedule$Heating
subcategory_schedule$Cooling <- setpoint_research_schedule$Cooling

write_csv(subcategory_schedule, str_c("schedules/", building_subcategory, ".csv"))
}

# energyplus_start_date = min(subcategory_schedule$date)
# energyplus_end_date   = max(subcategory_schedule$date)

# analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>% 
#   # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>% 
#   filter(date >= energyplus_start_date, date <= energyplus_end_date)