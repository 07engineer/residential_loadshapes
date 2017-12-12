#' Update RunEPlus.bat file
#'
#' EnergyPlus is launched using a batch file. Inside are paths which need updating. 
#' This function uses the working directory to make these updates.
#'
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' update_RunEPlus_batch()

update_RunEPlus_batch <- function(){
  working_directory <- getwd()
  working_directory_dos <- str_replace_all(working_directory, "/", "\\\\")

  bat <- read_file("RunEPlus.bat") 
  bat <-  str_split(bat, pattern = "\r\n")[[1]]
  
  bat[which(str_detect(bat, "input_path="))[1]] <- str_c(" set input_path=", working_directory_dos, "\\EP_input_batch\\")
  bat[which(str_detect(bat, "output_path="))[1]] <- str_c(" set output_path=", working_directory_dos, "\\EP_output\\")
  bat[which(str_detect(bat, "weather_path="))] <- str_c(" set weather_path=", working_directory_dos, "\\weather\\")
  
  bat <- str_c(bat, collapse = "\r\n")
  write_file(bat, "RunEPlus.bat")
}
