
#' Create reports from ADM error tables and simulation result files
#'
#' Edits the calibration markdown file and runs it for each climate zone, placing reports in a folder.
#'

#' @keywords EnergyPlus, Parametrics, Calibration
#' @export
#' @examples
#' create_reports()
#'
#'
#'


create_report_of_best_run <- function(batch_errors){
  judgement_column = "error_all"
  best_rownum = which(batch_errors[, judgement_column] == max(batch_errors[, judgement_column]))
  best_file = as.character(batch_errors[best_rownum, "file"])

  markdown_file <- str_split(read_file("residential_loadshapes/calibration.Rmd"),  "\r\n")[[1]]

  sim_path_index  <- which(str_detect(markdown_file, "sim_path <- "))
  file_name_index <- which(str_detect(markdown_file, "sim_file <- "))

  markdown_file[sim_path_index]  <- str_c("sim_path <- \"", sim_path, "\"")
  markdown_file[file_name_index] <- str_c("sim_file <- \"", best_file, "\"")

  markdown_file <- str_c(markdown_file, collapse = "\r\n")


  rmd_filename <- str_c(str_replace(best_file, "Meter.csv", ""), ".Rmd")

  write_file(markdown_file, str_c("FCZ", zone_num, "/reports/", rmd_filename))

  rmarkdown::render(str_c("FCZ", zone_num, "/reports/", rmd_filename))
}

zone_numbers = 1:7
for(zone_num in zone_numbers){
  cat("Generating calibration reports for zone ", zone_num, ".\n")

  sim_path <- str_c("L:/P/1631/Task 4 - Baseline Profiles/Residential Calibrated Models 09182017/FCZ1_FCZ11/FCZ", zone_num)
  if(dir.exists(str_c(sim_path, "/reports")) == FALSE) dir.create(str_c(sim_path, "/reports"))

  error_files <- str_c("FCZ", zone_num, "/errors/", dir(str_c("FCZ", zone_num, "/errors")))
  list_of_error_dataframes <- map(error_files, read_csv)

  #batch_errors <- list_of_error_dataframes[[1]]

  map(list_of_error_dataframes, create_report_of_best_run)
}



