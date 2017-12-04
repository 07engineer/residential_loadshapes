#' Update Schedule Section References
#' 
#' Note that the parametric file is set up to run multiple schedules.
#' For now, we are not going to go there. In "02_Schedules.idf" there are
#' calls to the parametric file using the code "$8760File". Rather than a
#' parametric run, this script replaces the file with the appropriate analytic
#' schedule name.
#' 
#'
#'
#' @param
#' 
#' 
#' 
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' update_schedule_section_references(schedules_folder, sections_folder, building_subcategory)

update_schedule_section_references <- function(building_subcategory){
  file <- str_split(read_file("sections/02_Schedules.idf"),  "\r\n")[[1]]
  target_lines <- which(str_detect(file, "Schedule:File")) + 3
  file[target_lines] <- str_c("    $schedule  !- Name of File")
  #file[target_lines] <- str_c("../../schedules/", building_subcategory, ".csv, !- Name of File")
  #file[target_lines] <- str_c("C:\\Users\\daniel.chapman\\Documents\\2016-11-08 Load Shapes 1631\\2017-11-29 residential FCZ12 update\\schedules\\", building_subcategory, ".csv, !- Name of File")
  file <- str_c(file, collapse = "\r\n")
  write_file(file, "sections/02_Schedules.idf")
}
  
  
