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

  #Delete out design days. Aim for January 1, but if there are two of them, go for the second one.



  #Delete design days. Put in logic protecting from two Jan 1s resulting from it being a design day too
  Jan_1_row <- which(out$date == min(out$date))

  if(length(Jan_1_row) == 1){
    out <- out[Jan_1_row:nrow(out),]
  } else {
    out <- out[Jan_1_row[2]:nrow(out),]
  }

  # Delete design days... 2 weeks worth, but not exactly, so this bugs out
  #out <- out[337:nrow(out),]

  # Delete design days... but this bugs out if design day is Jan 1
  #Jan_1_row <- which(out$date == min(out$date))
  #

  out <- JtoKW(out)
}

