library(plyr)
library(tidyverse)
library(stringr)
library(lubridate)
library(readr)
library(devtools)

# FOR DJ ONLY
# document("residential")
# install("residential")

# FOR OTHER USERS, if there are code updates: 
install_github("07engineer/residential_loadshapes")

library(residential)

rm(list = ls())

# Set your working directory to the location of this file.
# setwd("~/2016-11-08 Load Shapes 1631/2017-11-29 residential FCZ12 update")
# setwd("L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/2017-11-29 residential FCZ12 update")

analytic_schedule_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Results/Schedules/Final"
coefficients_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Constrained Regression Coefficients"
pre_processor_path = "C:\\EnergyPlusV8-5-0\\PreProcess\\ParametricPreProcessor\\parametricpreprocessor"

# Clean out batch folder if you want
#batch_files_to_delete <- dir("EP_input_batch")[!dir("EP_input_batch") %in% "RunDirMulti.bat"]
#file.remove(str_c("EP_input_batch", batch_files_to_delete, sep = "/"))

# For debugging or individual runs: 
family = "ALL" # "SINGLEFAMILY" or "MULTIFAMILY" , or "ALL" for FCZ12
fuel = "ELECTRIC" # Must be "GAS" or "ELECTRIC"
size = "HIGH"  #Must be "LOW", "MEDIUM", "HIGH"
climate_zone = "FCZ12"

# # For batch runs
# families = c("SINGLEFAMILY", "MULTIFAMILY")
# fuels = c("GAS", "ELECTRIC")
# sizes = c("LOW", "MEDIUM", "HIGH")
# climate_zones = str_c("FCZ", 1:11)

# for(i in seq_along(families)){
# for(j in seq_along(fuels)){
# for(k in seq_along(sizes)){
# for(m in seq_along(climate_zones)){
#   family = families[i]
#   fuel = fuels[j]
#   size = sizes[k]
#   climate_zone = climate_zones[m]

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
analytic_schedule_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "Schedules.csv", sep = "_")
coefficients_file <- str_c(climate_zone, family,"Usage_Level", size, fuel, "coefficients.csv", sep = "_")

file.remove(str_c("EP_input" , dir("EP_input") , sep = "/"))
file.remove(str_c("EP_output", dir("EP_output"), sep = "/"))

#########################################
#### Update Schedule Section References #
#########################################

update_schedule_section_references(building_subcategory)

#########################################
#### Update Enduse Coefficients ######### 
#########################################

update_enduse_coefficients(coefficients_path, coefficients_file, file_00)

#########################################
#### Combine Sections ################### 
#########################################

combine_sections(building_subcategory, file_00)

#########################################
#### Run Parametric Pre-processor ####### 
#########################################

files_before_PP = dir("EP_input")
system(str_c(pre_processor_path, " EP_input", "\\", building_subcategory, ".idf"))
files_after_PP = dir("EP_input")
runs <- files_after_PP %>% 
  str_subset(str_c(building_subcategory, "-")) 
file.copy(str_c("EP_input", runs, sep = "/"), str_c("EP_input_batch", runs, sep = "/"), overwrite = TRUE)

#########################################
#### Update EnergyPlus Schedules ########
#########################################

# This can be done earlier as a separate script
#update_schedule(analytic_schedule_path, analytic_schedule_file, building_subcategory)
update_schedule()

#########################################
#### Update Setpoint Schedules ##########
#########################################

#change_setpoint_schedules(building_subcategory, "setpoint_research.csv")

# }
# }
# }
# }

#########################################
#### Update RunEPlus.bat         ######## 
#########################################

update_RunEPlus_batch()




