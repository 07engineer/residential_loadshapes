#' Read Energy Plus Outputs
#'
#' This function reads the EnergyPlus output file(s) into R and munges them for use in the autocalibration alogorithms.
#' @param fileName The name of the file containing billing data to be read in. Must be .csv format.
#' @keywords EnergyPlus,Model Data, Calibration
#' @export
#' @examples
#' read_EP_Output("parametricModel1_Outputs.csv")
#' 

#fileName <- "MF-GAS-LOW-HIGHMeter.csv"

read_EP_Output <- function(fileName){
  out <- read_csv(fileName)
                                                    # Delete design days
  names(out)[1] = "date"
  
  fixDate <- function(df, year){                                            # Add year to the date, format
    dateTime <- ldply(strsplit(as.character(df$date), split = " ")) %>%
      rename(dayMonth = V1, time = V3) %>%
      select(-V2)
    dateTime <- within(dateTime,{
      dayMonth <- paste(dayMonth,"/",year, sep="")
      fin <- mdy_hms(paste(dayMonth,time, sep=" "))
    })
    df$date <- dateTime$fin
    df
  }
  
  out <- fixDate(out, "2014")
  Jan_1_row <- which(out$date == min(out$date)) # Delete design days
  out <- out[Jan_1_row:nrow(out),]
  out <- JtoKW(out) 
}

