EPD_values <- seq(from = 15, to = 25, length.out =  3)
cooling_eff_values <- seq(from = 4, to = 8, length.out =  2)
heating_eff_values <- seq(from = 1, to = 2, length.out =  2)
cooling_setpoint_values <- str_c("C", 2:4)
heating_setpoint_values <- str_c("H", 1:3)
#cooling_setpoint_values <- seq(from = 25, to = 29, length.out =  3)
#heating_setpoint_values <- seq(from = 19, to = 23, length.out =  3)
infiltration_values <- floor(seq(from = 3, to = 4, length.out =  2))
#exterior_light_values <- seq(from = 5, to = 20, length.out =  4)
#schedule_names <- str_c("../../schedules/", building_subcategory, "_SCH", 1:3, ".csv")
#schedule_names <- str_c(building_subcategory, "_SCH", 1:2, ".csv")
#schedule_names <- str_c("SCH", 1:2, ".csv")

values <- as.tibble(expand.grid(EPD = EPD_values, 
                                cooling_efficiency = cooling_eff_values,
                                heating_efficiency = heating_eff_values,
                                cooling_schedule = cooling_setpoint_values,
                                heating_schedule = heating_setpoint_values,
                                infiltration_area = infiltration_values))

n = nrow(values)
values <- values %>% 
  mutate(sufflist = map_chr(1:n, function(x) str_c("Run", x)),
         #File = "Residential_sch.csv",
         insulation_wall = 2.37,
         insulation_roof =  4.32, 
         window =  "Window_U_0.44_SHGC_0.26",
         fan_efficiency = 0.55575,
         OSA =0.057,
         LPD = 5,
         exterior_lighting = 5
  )

parametric_file <- c(
  str_c("Parametric:FileNameSuffix,sufflist,", str_c(values$sufflist, collapse = ","), ";"),
#  str_c("Parametric:SetValueForRun,$schedule,", str_c(values$schedule, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$insulation_wall,", str_c(values$insulation_wall, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$insulation_roof,", str_c(values$insulation_roof, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$window,", str_c(values$window, collapse = ", "),";"),
  str_c("Parametric:SetValueForRun,$cooling_efficiency,", str_c(values$cooling_efficiency, collapse = ","),";"),
  str_c("Parametric:SetValueForRun,$cooling_schedule,", str_c(values$cooling_schedule, collapse = ","),";"),
  str_c("Parametric:SetValueForRun,$heating_efficiency, ", str_c(values$heating_efficiency, collapse = ","),";"),
  str_c("Parametric:SetValueForRun,$heating_schedule,", str_c(values$heating_schedule, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$fan_efficiency, ", str_c(values$fan_efficiency, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$OSA,", str_c(values$OSA, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$LPD,", str_c(values$LPD, collapse = ","),";"),
  str_c("Parametric:SetValueForRun,$EPD,", str_c(values$EPD, collapse = ","),";"),
#  str_c("Parametric:SetValueForRun,$exterior_lighting,", str_c(values$exterior_lighting, collapse = ","),";"),  
  str_c("Parametric:SetValueForRun,$infiltration_area,", str_c(values$infiltration_area, collapse = ","),";")
)

write.csv(values, "parametric_values.csv")
write_file(str_c(parametric_file, collapse = "\r\n"), "sections/03_Parametrics.idf")
cat("Parametric file written.\n")

#line_char_limit = 500 
#front_matter = str_count("Parametric:SetValueForRun,$schedule,")
#param_len = str_count("SCH1.csv,")
#cat("Possible num runs this file: ", floor((line_char_limit - front_matter) / param_len), "\n" )
