#' Compare absorbance at pairs of wavelengths
#'
#' For each sample measurement, extracts the absorbance at the wavelengths in
#' `wave_pairs` and computes the difference (`A1 - A2`) or ratio (`A1 / A2`)
#' for each pair, e.g. the A260/A280 purity ratio.
#'
#' @param dataset A long data frame of spectra, such as the output of
#'   [read_nanodrop()].
#' @param samps_col,waves_col,abs_col Names of the sample, wavelength and
#'   absorbance columns.
#' @param wave_pairs List of length-2 numeric vectors giving the wavelength
#'   pairs to compare. The defaults (300/400 and 542/644 nm) come from the dye
#'   work this package was first written for; set your own for other analyses.
#' @param type `"diff"` for `A1 - A2` or `"ratio"` for `A1 / A2`.
#' @param tol Wavelengths within `tol` nm of a requested wavelength count as a
#'   match, which guards against floating point mismatches.
#' @param id_cols Columns that identify one spectrum. By default, `samps_col`
#'   plus `file` and `measurement` when present, so repeated measurements of the
#'   same sample stay separate.
#'
#' @return A tibble with one row per spectrum: the `id_cols`, an
#'   `<abs_col>_<wavelength>` column for each requested wavelength, and a
#'   `diff_<w1>_<w2>` or `ratio_<w1>_<w2>` column for each pair. Wavelengths
#'   missing from a spectrum give `NA`.
#' @export
#' @examples
#' parse_waves(ds)
#'
#' # Nucleic acid purity ratios
#' parse_waves(ds, wave_pairs = list(c(260, 280), c(260, 230)), type = "ratio")
parse_waves <- function(dataset, samps_col = "samps", waves_col = "waves", abs_col = "abs",
                        wave_pairs = list(c(300, 400), c(542, 644)),
                        type = c("diff", "ratio"), tol = 1e-6, id_cols = NULL) {
  type <- match.arg(type)
  if (!is.data.frame(dataset)) {
    stop("`dataset` must be a data frame.", call. = FALSE)
  }
  if (!all(c(samps_col, waves_col, abs_col) %in% names(dataset))) {
    stop("Dataset must contain columns specified by samps_col, waves_col, and abs_col",
         call. = FALSE)
  }
  if (!is.list(wave_pairs) || !all(vapply(wave_pairs, function(p) is.numeric(p) && length(p) == 2, logical(1)))) {
    stop("`wave_pairs` must be a list of length-2 numeric vectors.", call. = FALSE)
  }
  if (is.null(id_cols)) {
    id_cols <- intersect(c("file", samps_col, "measurement"), names(dataset))
  }

  dataset <- as.data.frame(dataset)
  waves <- as.numeric(dataset[[waves_col]])
  values <- as.numeric(dataset[[abs_col]])

  out <- unique(dataset[id_cols])
  for (target in unique(unlist(wave_pairs))) {
    hit <- abs(waves - target) <= tol
    at_target <- dataset[hit, id_cols, drop = FALSE]
    at_target[[wave_col_name(abs_col, target)]] <- values[hit]
    at_target <- at_target[!duplicated(at_target[id_cols]), , drop = FALSE]
    out <- dplyr::left_join(out, at_target, by = id_cols)
  }

  op <- if (type == "diff") `-` else `/`
  for (pair in wave_pairs) {
    out[[paste(type, format_wave(pair[1]), format_wave(pair[2]), sep = "_")]] <-
      op(out[[wave_col_name(abs_col, pair[1])]], out[[wave_col_name(abs_col, pair[2])]])
  }

  rownames(out) <- NULL
  dplyr::as_tibble(out)
}

format_wave <- function(x) format(x, trim = TRUE, scientific = FALSE)

wave_col_name <- function(abs_col, wave) paste0(abs_col, "_", format_wave(wave))
