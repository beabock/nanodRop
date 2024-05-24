#' parse_waves
#'
#' @param dataset the dataset being used. must be run through read_nanodrop()
#' @param wv1 #First peak of interest
#' @param wv2 #First valley to compare first peak to
#' @param wv3 #Second peak of interest
#' @param wv4 #Second valley to compare second peak to
#'
#' @return final_long
#' @export
#' @import tidyr
#' @import dplyr
#' @import purrr
#'
#' @examples test <- parse_waves(dataset = ds)
parse_waves <- function(dataset, wv1 = 223, wv2 = 270, wv3 = 542, wv4 = 644){

  # Create a list of wavelengths and their corresponding column names
  wave_pairs <- list(c(wv1, wv2), c(wv3, wv4))
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

  final_long <- final_combined %>%
    tidyr::pivot_longer(
      cols = starts_with("diff_"),
      names_to = "diff_type",
      values_to = "diff"
    )

  final_long <- final_long %>%
    dplyr::mutate(
      nmdiff_542 = ifelse(diff_type == "diff_542_644", 1, 0),
      ug_dye = 0.03467 + 0.02321 * nmdiff_542 + 0.00271 * diff
    )

  return(final_long)
}
