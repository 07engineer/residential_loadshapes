#' Change Setpoint Schedules
#'
#' Replaces schedule columns with calculated values
#'
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' change_setpoint_schedules(building_subcategory, setpoint_research.csv)


change_setpoint_schedules <- function(anamoly_changepoint = 70, max_drop = 20, cooling_setpoint = 24, heating_set_delta = 2){
  # Grab billing data for temperature column
  billing_data_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Cleaned Data/engineering"
 
  # Read in billing data file 
  billing_data <- read_csv(str_c(billing_data_path, "/", climate_zone, ".csv")) %>%
    filter(usage_level == size, 
                   heat_fuel == fuel, 
                   iou_building_type == family)
  
  
  energyplus_schedule <- read_csv(str_c("schedules/", building_subcategory, ".csv")) 
  
  
  # energyplus_schedule <- read_csv("Residential_sch.csv") %>%
  #   mutate(date = as_date(mdy_hm(Schedule)))
  
  energyplus_start_date = min(energyplus_schedule$date)
  energyplus_end_date   = max(energyplus_schedule$date)

  # Read in wet bulb file for filtering: 
  wb <- read.csv("weather/FCZ12_mean_wb.csv")
  
  setpoint_experiments <- select(wb, wb) %>%
    bind_cols(select(energyplus_schedule, Heating, Cooling)) %>%
    mutate(setpoint_bump = ifelse(wb - anamoly_changepoint > 0, (anamoly_changepoint - wb) / (max(wb) - anamoly_changepoint) * max_drop, 0))
  
  
  # setpoint_experiments <- select(billing_data, date, kW, TemperatureF) %>%
  #   bind_cols(select(energyplus_schedule, Heating, Cooling)) %>%
  #   mutate(setpoint_bump = ifelse(TemperatureF - anamoly_changepoint > 0, (anamoly_changepoint - TemperatureF) / (max(TemperatureF) - anamoly_changepoint) * max_drop, 0))
  # 
  # ggplot(setpoint_experiments, aes(x = date, y = TemperatureF)) + geom_point()
  # ggplot(setpoint_experiments, aes(x = date, y = setpoint_bump)) + geom_point()
  # ggplot(setpoint_experiments, aes(x = TemperatureF, y = setpoint_bump)) + geom_point()
  
  energyplus_schedule <- energyplus_schedule %>% 
    mutate(Cooling = cooling_setpoint + setpoint_experiments$setpoint_bump, 
           Heating = Cooling - heating_set_delta)
  
  
  # energyplus_schedule <- energyplus_schedule %>% 
  #   mutate(Cooling = Cooling + setpoint_experiments$setpoint_bump, 
  #          Heating = Heating + setpoint_experiments$setpoint_bump)

write_csv(energyplus_schedule, str_c("schedules/", building_subcategory, ".csv"))
}

#analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>%
#  # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>%
#  filter(date >= energyplus_start_date, date <= energyplus_end_date)

# analytic_schedule$cdd_base <- as.numeric(analytic_schedule$cdd_base)
# normalized_analytic_cdd_changepoints <- (analytic_schedule$cdd_base - mean(analytic_schedule$cdd_base)) / sd(analytic_schedule$cdd_base)
# setpoint_mean <- 23 # degrees Celsius
# setpoint_sd <- 3 # degrees Celsius
# heat_set_gap <- 5 # degrees Celsius
# energyplus_schedule$Cooling <- normalized_analytic_cdd_changepoints * setpoint_sd + setpoint_mean
# energyplus_schedule$Heating <- energyplus_schedule$Cooling - heat_set_gap
# 
# 
# setpoint_research_schedule <- read_csv(str_c("schedules/", "setpoint_research.csv"))
# 
# new_col_names <- names(setpoint_research_schedule)[names(setpoint_research_schedule) != "Schedule"]
# 
# for(i in new_col_names){
#   subcategory_schedule[, i] <- setpoint_research_schedule[, i]
# }
# 
# write_csv(subcategory_schedule, str_c("schedules/", building_subcategory, ".csv"))

# subcategory_schedule$Heating <- setpoint_research_schedule$Heating
# subcategory_schedule$Cooling <- setpoint_research_schedule$Cooling

# energyplus_start_date = min(subcategory_schedule$date)
# energyplus_end_date   = max(subcategory_schedule$date)

# analytic_schedule <- read_csv(str_c(analytic_schedule_path, analytic_schedule_file, sep = "/")) %>% 
#   # select(which(names(analytic_schedule) %in% names(energyplus_schedule))) %>% 
#   filter(date >= energyplus_start_date, date <= energyplus_end_date)