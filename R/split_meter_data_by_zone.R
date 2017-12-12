#' Split Meter Data By Zone
#'
#' The meter files by utility are too big and calibrations tend to be done by zone
#'  
#' @param meter_path Path to meter data
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' split_meter_by_zone()

# meter_path <- "L:/P/1631/Task 4 - Baseline Profiles/Residential Pre-Processor 091417/Data/Cleaned Data"
# For some reason I get an error calling this function, but running the pieces works fine

split_meter_by_zone <- function(meter_path){
  #meter_file <- "SDGE Residential Interval Meter Data 2014-2015.csv"
  meter_files <- dir(meter_path)
  
  #Split up meter files by climate zone... too big. 
  for(i in 1:length(meter_files)){
    meter_data <-  read_csv(str_c(meter_path, meter_files[i], sep = "/")) %>%
      mutate(date = ymd_hms(str_c(date, " ", hour, ":00:00"))) %>%
      filter(year(date) == 2014) 
    zones <- unique(meter_data$FCZ)
    for(j in min(zones):max(zones)){
      zone_data <- filter(meter_data, FCZ == j) %>%
        write_csv(str_c(meter_path,"/engineering/FCZ", j, ".csv"))
    }
  }
}

