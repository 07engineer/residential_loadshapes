

setwd("L:/EnergyPlus/2018-07-03 residential miscOrig/")
template_dir <- "L:/EnergyPlus/2018-07-03 residential miscOrig/"

#create empty folders for each climate zone
walk(1:12, function(x) dir.create(str_c("FCZ", x)))

# Create schededules:

for(m in seq_along(climate_zones)){
  climate_zone = climate_zones[m]
  # batch_folder <- climate_zone
  batch_folder <- str_c(EP_runs_path, climate_zone)

  for(i in seq_along(families)){
    for(j in seq_along(fuels)){
      for(k in seq_along(sizes)){
        family = families[i]
        fuel = fuels[j]
        size = sizes[k]

        building_subcategory = str_c(climate_zone, family, fuel, size, sep = "_")
        building_subcategory_schedule = str_c(climate_zone, family, "ALL", size, sep = "_")
        cat("\nBUILDING SUBCATEGORY: ", building_subcategory, "\n")
        #analytic_schedule_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "Schedules.csv", sep = "_")
        analytic_schedule_file <- str_c(climate_zone, family,"Usage_Level", "ALL", "ALL", "Schedules.csv", sep = "_")
        #coefficients_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "coefficients.csv", sep = "_")
        coefficients_file <- str_c(climate_zone, family,"Usage_Level", "ALL", "ALL", "coefficients.csv", sep = "_")

        #########################################
        #### Update EnergyPlus Schedules ########
        #########################################

         cat("Update energy plus schedule with analytic schedule values. \n")
         update_schedule()

      }
    }
  }
}
