#' read_nanodrop
#'
#' @param data dataset to use
#' @param max_wv max wavelength read by nanodrop
#' @param min_wv min wavelength read by nanodrop
#' @param increments wavelength increments set on machine
#' @param junk_rows number of rows of metadata in the Nanodrop output
#'
#' @return ds
#' @export
#'
#' @examples read_nanodrop()
read_nanodrop <- function(filepath,
                          max_wv = 850,
                          min_wv = 190,
                          increments = 0.5,
                          junk_rows = 10){

  # library(readr)
  # library(stringr)
  # library(ggplot2)
  # library(dplyr)

  tsv <- readr::read_tsv(filepath, col_names = F)

  wvs <- length(seq(from = min_wv, to = max_wv, by = increments))
  row_x_sample <- wvs + junk_rows
  nsamples <- nrow(tsv)/(wvs + junk_rows) #Works, round number

  ds <- data.frame()#empty df to store data

  for (i in 0:(nsamples-1)){

    waves <- as.numeric(unname(unlist(lapply(strsplit(unlist(tsv[seq(junk_rows+1+row_x_sample*i, row_x_sample*(i+1)),1]), "\t"), `[[`, 1))))
    abs <- as.numeric(unname(unlist(lapply(strsplit(unlist(tsv[seq(junk_rows+1+row_x_sample*i, row_x_sample*(i+1)),1]), "\t"), `[[`, 2))))
    samps <- as.character(unname(rep(tsv[1 + row_x_sample*i, 1], length(waves))))

    tog <- cbind(samps, waves, abs)

    ds <- rbind(ds, tog)
    ds$waves <- as.numeric(ds$waves)
    ds$abs <- as.numeric(ds$abs)

  }

  return(ds)

}
