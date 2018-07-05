
zone_numbers = 4 #5:6
for(zone_num in zone_numbers){
sim_path = str_c("L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/FCZ1_FCZ11/FCZ", zone_num)

if(dir.exists(str_c(sim_path, "/errors")) == FALSE) dir.create(str_c(sim_path, "/errors"))

# sim_path = "L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/2017-11-29 residential FCZ12 update/FCZ12_ALL_GAS_LOW"
# sim_path <- ("~/2016-11-08 Load Shapes 1631/2017-11-29 residential FCZ12 update/EP_input_batch")

sim_files <- dir(sim_path)[which(str_detect(dir(sim_path), "Meter"))]

# Figure out unique building_subcategories in folder
subcategories <- str_replace_all(sim_files, "[[0-9]]", "") %>%
  str_replace("FCZ_", "") %>%
  str_replace("-RunMeter.csv", "") %>%
  unique()

zone = str_split(sim_files[1], "_")[[1]][1]

# Read in billing data file
billing_data_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Cleaned Data/engineering"
billing_data <- read_csv(str_c(billing_data_path, "/", zone, ".csv")) %>%
  mutate(date = ymd_hms(str_c(date, " ", hour, ":00:00")))

# i = 1
# j = 2

parametrics <- read_csv("parametric_values.csv")

for(j in 1:length(subcategories)){
  building_subcategory <- subcategories[j]
  subcategory_files <- sim_files[grep(building_subcategory, sim_files)]
  cat("Calculating error matrix for subcategory ", building_subcategory, ".\n")

  RMSE_all <- vector()
  RMSE_peaks <- vector()
  identifier <- vector()
  runs <- vector()

  for(i in 1:length(subcategory_files)){
    # Pick apart the simulation file name to get building subcategory for meter data filter
    run_elements <- str_split(str_replace(subcategory_files[i], "Meter.csv", ""), "_")[[1]]
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
  } # loop of individual files

batch_errors <- tibble(file = subcategory_files,
                       subsector = identifier,
                       error_all = RMSE_all,
                       error_peak = RMSE_peaks,
                       sufflist = runs) %>%
  left_join(parametrics)

write.csv(batch_errors, str_c(zone, "/errors/", building_subcategory,"_errors.csv"))

} # building subcategories
} # climate zones

# min_batch_errors <- batch_errors %>%
# group_by(subsector) %>%
# summarise(min_error = min(error), best_run = file[which(error == min(error))])
