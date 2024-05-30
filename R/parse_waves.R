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
#'
#' @examples test <- parse_waves(dataset = ds1)
# Create a list of wavelengths and their corresponding column names
parse_waves <- function(dataset, samps_col = "samps", waves_col = "waves", abs_col = "abs", wave_pairs = list(c(223, 270), c(542, 644))) {

  # Create a list of wavelengths and their corresponding column names
  result_list <- list()

  for (pair in wave_pairs) {
    wv1 <- pair[1]
    wv2 <- pair[2]

    # Select and rename columns dynamically
    temp_data <- dataset %>%
      dplyr::filter(waves %in% c(wv1, wv2)) %>%
      tidyr::pivot_wider(names_from = waves, values_from = abs, names_prefix = "abs_") %>%
      dplyr::mutate(!!paste0("diff_", wv1, "_", wv2) := !!dplyr::sym(paste0("abs_", wv1)) - !!dplyr::sym(paste0("abs_", wv2)))

    result_list[[paste0("diff_", wv1, "_", wv2)]] <- temp_data
  }

  # Combine the results
  final_combined <- purrr::reduce(result_list, dplyr::full_join, by = "samps")



  return(final_combined)
}
