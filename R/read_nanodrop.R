#' Read and Process Nanodrop Data
#'
#' @param filepath Path to the input TSV file.
#' @param max_wv Maximum wavelength value as a string. Default is "850.0".
#' @param min_wv Minimum wavelength value as a string. Default is "190.0".
#' @param error Error character to check in the "samps" column. Default is "e".
#'
#' @return A data.table with processed data.
#' @import data.table
#' @import stringr
#' @import readr
#' @export
read_nanodrop <- function(filepath, max_wv = "850.0", min_wv = "190.0", error = "e") {
#"C:/Users/beabo/OneDrive/Documents/NAU/Dark Web/Datasets/NanoDrop Readings/Dark_Web_Samples/UV-Vis 5_21_2024 5_40_43 PM 1-10.tsv"

  # Read the file
  tsv <- data.table::fread(filepath, header = FALSE, sep = "\t", fill = TRUE)

  # Split the first column by the tab separator
  tsv <- stringr::str_split_fixed(as.matrix(tsv[, 1]), n = 2, pattern = "\t")

  start_rows <- which(tsv[, 1] == min_wv)
  end_rows <- which(tsv[, 1] == max_wv)

  if (length(start_rows) == 0 || length(end_rows) == 0) {
    stop("Specified min_wv or max_wv not found in the dataset.")
  }

  if (length(start_rows) != length(end_rows)) {
    stop("Mismatch between the number of start and end rows. Please check the dataset.")
  }

  nsamples <- length(start_rows)

  ds <- data.table::data.table(samps = character(), waves = numeric(), abs = numeric()) # Initialize an empty data.table

  for (i in 1:nsamples) {
    waves <- as.numeric(tsv[start_rows[i]:end_rows[i], 1])
    abs <- as.numeric(tsv[start_rows[i]:end_rows[i], 2])

    samps <- rep(tsv[which(grepl("\\d{1,2}/\\d{1,2}/\\d{4} \\d{1,2}:\\d{2} (AM|PM)", tsv[, 1]))-1, 1][i], length(waves))


    tog <- data.table::data.table(samps = samps, waves = waves, abs = abs)
    ds <- rbind(ds, tog)
  }

  # Optimize the process of removing rows and renaming
  remove_indices <- integer()
  rename_indices <- integer()

  # Populate remove_indices and rename_indices
  for (i in 2:nrow(ds)) {
    if (stringr::str_ends(ds$samps[i], error)) {
      if (ds$samps[i - 1] == sub(paste0(error, "$"), "", ds$samps[i])) {
        remove_indices <- c(remove_indices, i - 1)
        rename_indices <- c(rename_indices, i)
      }
    }
  }

  # Remove and rename rows only if there are rows to be removed
  if (length(remove_indices) > 0) {
    ds <- ds[-remove_indices]
  }

  # Rename rows only if there are rows to be renamed
  if (length(rename_indices) > 0) {
    ds$samps[rename_indices] <- gsub(paste0(error, "$"), "", ds$samps[rename_indices])
  }
  return(ds)
}

# Example usage:
# result <- read_nanodrop("path_to_your_file.tsv")
