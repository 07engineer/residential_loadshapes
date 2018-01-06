library(plyr)
library(tidyverse)
library(stringr)
library(lubridate)
library(readr)
library(devtools)

# FOR DJ ONLY
# document("residential_loadshapes")
# install("residential_loadshapes")

# FOR OTHER USERS, if there are code updates:
install_github("07engineer/residential_loadshapes")

library(residential)

rm(list = ls())

# Set your working directory to the location of this file.
setwd("L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/FCZ1_FCZ11")
# setwd("~/2016-11-08 Load Shapes 1631/2017-11-29 residential FCZ12 update")
# setwd("L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/2017-11-29 residential FCZ12 update")

analytic_schedule_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Results/Schedules/Final"
coefficients_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Constrained Regression Coefficients"
pre_processor_path = "C:\\EnergyPlusV8-5-0\\PreProcess\\ParametricPreProcessor\\parametricpreprocessor"


# For debugging or individual runs:
# family = "MULTIFAMILY" # "SINGLEFAMILY" or "MULTIFAMILY" , or "ALL" for FCZ12
# fuel = "ELECTRIC" # Must be "GAS" or "ELECTRIC"
# size = "HIGH"  #Must be "LOW", "MEDIUM", "HIGH"
# climate_zone = "FCZ2"

# Clean out batch folder if you want
#batch_files_to_delete <- dir("EP_input_batch")[!dir("EP_input_batch") %in% "RunDirMulti.bat"]
#file.remove(str_c("EP_input_batch", batch_files_to_delete, sep = "/"))

# For batch runs
families = c("SINGLEFAMILY", "MULTIFAMILY")
fuels = c("GAS", "ELECTRIC")
sizes = c("LOW", "MEDIUM", "HIGH")
climate_zones = str_c("FCZ", 7:11)

for(m in seq_along(climate_zones)){
  climate_zone = climate_zones[m]
  batch_folder <- climate_zone

for(i in seq_along(families)){
for(j in seq_along(fuels)){
for(k in seq_along(sizes)){
  family = families[i]
  fuel = fuels[j]
  size = sizes[k]

  if(family == "SINGLEFAMILY" & fuel == "GAS") {
    file_00 <- "00_SF_Model_gasfurnace_crawlspace.idf"
  } else if(family == "SINGLEFAMILY" & fuel == "ELECTRIC") {
    file_00 <- "00_SF_Model_elecres_crawlspace.idf"
  } else if(family == "MULTIFAMILY" & fuel == "GAS"){
    file_00 <- "00_MF_Model_gasfurnace_crawlspace.idf"
  } else if(family == "MULTIFAMILY" & fuel == "ELECTRIC"){
    file_00 <- "00_MF_Model_elecres_crawlspace.idf"
  } else if (family == "ALL" & fuel == "GAS"){
    file_00 <- "00_SF_Model_gasfurnace_crawlspace.idf"
  } else {
    file_00 <- "00_SF_Model_elecres_crawlspace.idf"
  }

building_subcategory = str_c(climate_zone, family, fuel, size, sep = "_")
cat("\nBUILDING SUBCATEGORY: ", building_subcategory, "\n")
analytic_schedule_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "Schedules.csv", sep = "_")
coefficients_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "coefficients.csv", sep = "_")

file.remove(str_c("EP_input" , dir("EP_input") , sep = "/"))
file.remove(str_c("EP_output", dir("EP_output"), sep = "/"))

#########################################
#### Update Schedule Section References #
#########################################

cat("Updating schedule references in .idf file. \n")
update_schedule_section_references(building_subcategory)

#########################################
#### Update Enduse Coefficients #########
#########################################

cat("Updating end use coefficients in .idf file. \n")
update_enduse_coefficients(coefficients_path, coefficients_file, file_00)

#########################################
#### Combine Sections ###################
#########################################

cat("Combining sections of .idf file. \n")
combine_sections(building_subcategory, file_00)

#########################################
#### Run Parametric Pre-processor #######
#########################################

cat("Running parametric pre-processor. \n")

files_before_PP = dir("EP_input")
system(str_c(pre_processor_path, " EP_input", "\\", building_subcategory, ".idf"))
files_after_PP = dir("EP_input")
runs <- files_after_PP %>%
  str_subset(str_c(building_subcategory, "-"))
file.copy(str_c("EP_input", runs, sep = "/"), str_c(batch_folder, runs, sep = "/"), overwrite = TRUE)

#########################################
#### Update EnergyPlus Schedules ########
#########################################

# cat("Update energy plus schedule with analytic schedule values. \n")
# update_schedule()

#########################################
#### Update Setpoint Schedules ##########
#########################################

# cat("Change setpoint schedule. \n")
# change_setpoint_schedules(anamoly_changepoint = 70, max_drop = 20, cooling_setpoint = 24, heating_set_delta = 2)

}
}
}
}

#########################################
#### Update RunEPlus.bat         ########
#########################################

#cat("Update batch file")
#update_RunEPlus_batch()




