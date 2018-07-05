result_folders <- dir("L:/EnergyPlus/")

for(m in 1:length(result_folders)){
  clean_EP_output_folder(str_c("L:/EnergyPlus/", result_folders[m]))
}


# result_folders <- dir("results")[str_detect(dir("results"), "FCZ")]

# for(m in 1:length(result_folders)){
#   clean_EP_output_folder(str_c("results/", result_folders[m]))
# }

start_time <- now()
clean_EP_output_folder("L:/EnergyPlus/FCZ11")
now() - start_time


# Delete out files of larger run numbers:
start_time <- now()
loc <- "L:/EnergyPlus/FCZCOASTAL/"
remove_files_with <- str_c("Run", 13:44)
files <- dir(loc)
files_to_remove <- files[str_detect(files, str_c(remove_files_with, collapse = "|"))]
file.remove(str_c(loc, files_to_remove))
now() - start_time
