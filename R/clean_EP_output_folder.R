
#' Remove Extra EnergyPlus Output Files
#'
#' EnergyPlus runs produce many files. This script cleans up the unnecessary ones.
#'
#'
#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' clean_EP_output_folder("./results/FCZ9_Office-Like_ALL")

clean_EP_output_folder <- function(directory){
  files <- dir(directory)
  keep_strings <- c(".bat", ".csv", ".idf", ".err", "tempsim")
  delete_strings <- c("Meter", "Ssz", "Table", "Zsz", ".expidf")
  files_to_keep <- files[str_detect(files, str_c(keep_strings, collapse = "|"))]
  files_to_keep <- files_to_keep[!str_detect(files_to_keep, str_c(delete_strings, collapse = "|"))]
  files_to_delete <- files[!(files %in% files_to_keep)]
  file.remove(str_c(directory, files_to_delete, sep = "/"))
}

# directory = "L:/EnergyPlus/testing/FCZ1"
# directory = "./results/practice"

# building_subcategory = str_c(climate_zone, family, fuel, size, sep = "_")
# cat("\nBUILDING SUBCATEGORY: ", building_subcategory, "\n")


