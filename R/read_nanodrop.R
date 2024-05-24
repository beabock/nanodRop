#' read_nanodrop
#'
#' @param filepath the filepath to your tsv file
#' @param max_wv max wavelength read by nanodrop
#' @param min_wv min wavelength read by nanodrop
#' @param increments wavelength increments set on machine
#' @param junk_rows number of rows of metadata in the Nanodrop output
#' @param filepath
#'
#' @return ds
#' @export
#'
#' @import readr
#' @import stringr
#'
#' @examples read_nanodrop("C:/Users/beabo/OneDrive/Documents/NAU/R Package Dev/nanodRop/data/UV-Vis 5_14_2024 5_03_11 PM.tsv")
read_nanodrop <- function(filepath,
                          max_wv = "850.0",
                          min_wv = "190.0",
                          increments = 0.5,
                          junk_rows = 10){

  tsv <- readr::read_tsv(filepath, col_names = F, show_col_types = F)

  tsv <- stringr::str_split_fixed(as.matrix(tsv[,1]), n = 2, pattern = "\t")

  start_rows <- which(tsv[,1]==min_wv)
  end_rows <- which(tsv[,1]==max_wv)

  nsamples <- length(start_rows)

  ds <- data.frame()#empty df to store data

  for (i in 1:nsamples){

    waves <- tsv[start_rows[i]:end_rows[i], 1]
    abs <- tsv[start_rows[i]:end_rows[i], 2]

    if (i == 1){
      samps <- rep(tsv[i, 1], length(waves))
    }
    else {
      samps <- rep(tsv[end_rows[i-1]+1, 1], length(waves))
    }

    tog <- cbind(samps, waves, abs)

    ds <- rbind(ds, tog)
    ds$waves <- as.numeric(ds$waves)
    ds$abs <- as.numeric(ds$abs)

  }
  unique(ds$samps)

  return(ds)

}
