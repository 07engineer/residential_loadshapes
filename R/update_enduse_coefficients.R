#' Update Enduse Coefficients
#'
#' End use coefficients are calculated with a regression approach in the analytical calculator. This function reads them in, 
#' and updates the EnergyPlus input file with the new values.  
#'
#' @param coefficients_path Path to coefficients
#' @param coefficients_file Path to coefficients
#' @param file_00 Path to coefficients
#' 
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' update_enduse_coefficients()

#coefficients_path = coefficients_path
#coefficients_file = coefficients_file

update_enduse_coefficients <- function(coefficients_path, coefficients_file, file_00){
  
  files_coefficients <- dir(coefficients_path)
  EPD_constituents <- c("Cooking", 
                        "Dishwasher", 
                        "Dryer", 
                        "Freezer", 
                        "Miscellaneous", 
                        "Refrigerator", 
                        "Television", 
                        "Washer",
                        "Lighting") 
  
  coeffs <- read_csv(str_c(coefficients_path, coefficients_file, sep = "/")) %>% 
    filter(cec_end_use %in% EPD_constituents, year == 2014 )%>% 
    mutate(weight_ratio = weight / sum(weight)) %>% 
    select(cec_end_use, weight_ratio) %>%
    mutate(EP_schedule_name = str_replace_all(cec_end_use, "[a-z]", toupper),
           EP_schedule_name = str_c(EP_schedule_name, ","),
           parametric_name  = str_replace_all(cec_end_use, "[A-Z]", tolower))  
  
  file_name <- str_c("sections/", file_00)
  file <- str_split(read_file(file_name),  "\r\n")[[1]]
  
  for(i in 1:nrow(coeffs)){
    rows_to_change = grep(coeffs$EP_schedule_name[i], file) + 3
    row_replacement = str_c("    =$EPD*", coeffs$weight_ratio[i], ",    !- Watts per Zone Floor Area {W/m2}")
    #row_replacement = str_c("    =$EPD*$", coeffs$parametric_name[i], ",    !- Watts per Zone Floor Area {W/m2}")
    
    file[rows_to_change] <- row_replacement
  }

  file <- str_c(file, collapse = "\r\n")
  write_file(file, file_name)
  write_csv(coeffs, "enduse_weights.csv")
}

