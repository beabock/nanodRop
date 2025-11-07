#' parse_waves
#'
#' @param dataset the dataset being used. must be run through read_nanodrop()
#' @param wv1 #First peak of interest
#' @param wv2 #First valley to compare first peak to
#' @param wv3 #Second peak of interest
#' @param wv4 #Second valley to compare second peak to
#' @param formula_int y intercept value
#' @param nm_542_coef multiplier for if the peak is at 542 or not
#' @param diff_coef coefficient for the peak height
#'
#' @return final_combined
#' @export
#' @import tidyr
#' @import dplyr
#' @import purrr
#' @import rlang
#'
#' @examples test <- parse_waves(dataset = ds1)
# Create a list of wavelengths and their corresponding column names
parse_waves <- function(dataset, samps_col = "samps", waves_col = "waves", abs_col = "abs", wave_pairs = list(c(300, 400), c(542, 644))) {

  #270, 223 is weird and seemingly not helpful.

  # Check if required columns exist
  if (!all(c(samps_col, waves_col, abs_col) %in% names(dataset))) {
    stop("Dataset must contain columns specified by samps_col, waves_col, and abs_col")
  }

  # Ensure abs column is numeric
  dataset <- dataset %>%
    dplyr::mutate(!!rlang::sym(abs_col) := as.numeric(!!rlang::sym(abs_col)))

  # Create a list of wavelengths and their corresponding column names
  result_list <- list()

  for (pair in wave_pairs) {
    wv1 <- pair[1]
    wv2 <- pair[2]

    # Select and rename columns dynamically
    temp_data <- dataset %>%
      dplyr::filter(!!rlang::sym(waves_col) %in% c(wv1, wv2)) %>%
      tidyr::pivot_wider(names_from = !!rlang::sym(waves_col), values_from = !!rlang::sym(abs_col), names_prefix = paste0(abs_col, "_"), values_fill = NA)

    # Only add diff column if both absorbance columns exist
    if (paste0(abs_col, "_", wv1) %in% names(temp_data) && paste0(abs_col, "_", wv2) %in% names(temp_data)) {
      temp_data <- temp_data %>%
        dplyr::mutate(!!paste0("diff_", wv1, "_", wv2) := !!dplyr::sym(paste0(abs_col, "_", wv1)) - !!dplyr::sym(paste0(abs_col, "_", wv2)))
    } else {
      temp_data <- temp_data %>%
        dplyr::mutate(!!paste0("diff_", wv1, "_", wv2) := NA_real_)
    }

    result_list[[paste0("diff_", wv1, "_", wv2)]] <- temp_data
  }

  # Combine the results
  final_combined <- purrr::reduce(result_list, dplyr::full_join, by = samps_col)



  return(final_combined)
}
