# result_folders <- dir("L:/EnergyPlus/")
# result_folders <- str_c("FCZ", 1:11)
# parent_folder <- "L:/EnergyPlus/testing/"
# parent_folder <- "L:/EnergyPlus/2018-07-03 residential blended/"
#parent_folder <- "L:/EnergyPlus/2018-07-03 residential miscOrig/"
parent_folder <- "L:/EnergyPlus/2018-07-03 residential subtracted/"
result_folders <- dir(parent_folder)

for(m in 1:length(result_folders)){
  clean_EP_output_folder(str_c(parent_folder, result_folders[m]))
}

# result_folders <- dir("results")[str_detect(dir("results"), "FCZ")]

# for(m in 1:length(result_folders)){
#   clean_EP_output_folder(str_c("results/", result_folders[m]))
# }

start_time <- now()
clean_EP_output_folder("L:/EnergyPlus/2018-07-03 residential subtracted/FCZ1")
now() - start_time


# Delete out files of larger run numbers:
start_time <- now()
loc <- "L:/EnergyPlus/FCZCOASTAL/"
remove_files_with <- str_c("Run", 13:44)
files <- dir(loc)
files_to_remove <- files[str_detect(files, str_c(remove_files_with, collapse = "|"))]
file.remove(str_c(loc, files_to_remove))
now() - start_time


