
#' Combine EnergyPlus Input File Sections
#'
#' At ADM we divide the EnergyPlus input files into various sections to make things easier. 
#'   
#'
#' @param building_subcategory Name of the EnergyPlus run
#' @param file_00 The first input file section
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' combine_sections(building_subcategory, file_00)

combine_sections <- function(building_subcategory, file_00){

  sections <- c(file_00, "01_RunControl.idf", "02_Schedules.idf", "03_Parametrics.idf", "04_Outputs.idf")
  filenames <- str_c("sections", sections, sep = "/")
  
  #filenames <- str_c(sections_folder, dir(sections_folder), sep = "/")
  read_input_files <- sapply(filenames, function(x) read_file(x))
  input_combined <- paste(read_input_files, collapse = "\n")
  write_file(input_combined, str_c("EP_input/", building_subcategory, ".idf"))
}