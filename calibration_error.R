

sim_path = "L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/2017-11-29 residential FCZ12 update/FCZ12_ALL_GAS_LOW"
#sim_path <- ("~/2016-11-08 Load Shapes 1631/2017-11-29 residential FCZ12 update/EP_input_batch")

sim_files <- dir(sim_path)[which(str_detect(dir(sim_path), "Meter"))]

zone = 12

# Read in billing data file 
billing_data_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Cleaned Data/engineering"
billing_data <- read_csv(str_c(billing_data_path, "/FCZ", zone, ".csv")) %>%
  mutate(date = ymd_hms(str_c(date, " ", hour, ":00:00")))

# i = 1

RMSE_all <- vector()
RMSE_peaks <- vector()
identifier <- vector()
runs <- vector()
for(i in 1:length(sim_files)){
    # Pick apart the simulation file name to get building subcategory for meter data filter
    run_elements <- str_split(str_replace(sim_files[i], "Meter.csv", ""), "_")[[1]]
    #zone <- as.integer(str_replace_all(run_elements[1], "[[:alpha:]]", "")) # I need this outside the loop for speed. 
    level <- str_replace(run_elements[4], "-Run", "")%>% 
      str_replace_all("[:digit:]", "")
    type <- run_elements[2]
    fuel <- run_elements[3]
    run <- str_c("Run", str_c(str_extract_all(run_elements[4], "[:digit:]")[[1]], collapse = ""))
    
    sim <- read_EP_Output(str_c(sim_path, sim_files[i], sep = "/")) %>%
      rename(kW_sim = `ElectricityNet:Facility`)
    
    results <- billing_data %>%
      filter(usage_level == level, 
             heat_fuel == fuel, 
             iou_building_type == type) %>%
      select(kW_bills = kW) %>%
      bind_cols(select(sim, date, kW_sim)) %>%
      select(date, everything()) %>%
      mutate(kW_bills_norm  = kW_bills / sum(kW_bills), 
             kW_sim_norm = kW_sim / sum(kW_sim))
    
    identifier[i] <- str_c(type, fuel, level, sep = "_")  
    RMSE_all[i] <- sqrt(mean((results$kW_sim_norm - results$kW_bills_norm)^2))
    
    # peaks <- results %>% 
    #   filter(kW_bills > summary(results$kW_bills)["3rd Qu."])
    
    peaks <- results %>% 
      filter(kW_bills > 0.8 * max(kW_bills))
    
    RMSE_peaks[i] <- sqrt(mean((peaks$kW_sim_norm - peaks$kW_bills_norm)^2))
    runs[i] <- run
    
    cat(sim_files[i], "\n")
} # for loop

parametrics <- read_csv("parametric_values.csv")

batch_errors <- tibble(file = sim_files, 
                       subsector = identifier, 
                       error_all = RMSE_all, 
                       error_peak = RMSE_peaks, 
                       sufflist = runs) %>% 
  left_join(parametrics)

write.csv(batch_errors, "batch_errors.csv")



# min_batch_errors <- batch_errors %>% 
  # group_by(subsector) %>% 
  # summarise(min_error = min(error), best_run = file[which(error == min(error))])
