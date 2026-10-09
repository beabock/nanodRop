#' Read a NanoDrop One spectral export
#'
#' Parses a UV-Vis spectral `.tsv` file exported by a NanoDrop One into a long
#' table with one row per sample measurement and wavelength.
#'
#' An export consists of one block per measurement: a sample name line, a
#' timestamp line, a `Wavelength (nm)` header line, optional `//` calibration
#' lines, and then tab-separated wavelength/absorbance pairs. Blocks are located
#' by their header line, so the parser does not depend on the date format or
#' locale of the instrument.
#'
#' Every block becomes its own `measurement`, so measuring the same sample name
#' twice yields two measurements rather than silently merging them.
#'
#' @param filepath Path to the exported `.tsv` file.
#' @param min_wv,max_wv Optional numeric wavelength bounds (inclusive). `NULL`
#'   (the default) keeps the full measured range.
#' @param remeasure_suffix Optional suffix that marks a re-measurement, e.g.
#'   `"e"`. When set, a sample named `"A"` followed by one named `"Ae"` is
#'   treated as a replacement: the `"A"` measurements are dropped and `"Ae"` is
#'   renamed to `"A"`. Names ending in the suffix with no matching original
#'   (e.g. `"Rinse"` with no `"Rins"`) are left alone. `NULL` (the default)
#'   disables this.
#' @param error Deprecated; use `remeasure_suffix`.
#'
#' @return A [data.table::data.table()] with columns:
#'   \describe{
#'     \item{samps}{Sample name (character).}
#'     \item{waves}{Wavelength in nm (numeric).}
#'     \item{abs}{Absorbance (numeric).}
#'     \item{measurement}{Position of the measurement block in the file (integer).}
#'     \item{timestamp}{Timestamp line as written by the instrument (character).}
#'   }
#' @seealso [read_nanodrop_dir()] to read every export in a folder.
#' @export
#' @examples
#' path <- system.file("extdata", "nanodrop_example.tsv", package = "nanodRop")
#' spectra <- read_nanodrop(path)
#' head(spectra)
#'
#' # Restrict to the visible range
#' visible <- read_nanodrop(path, min_wv = 400, max_wv = 700)
read_nanodrop <- function(filepath, min_wv = NULL, max_wv = NULL,
                          remeasure_suffix = NULL, error) {
  if (!missing(error)) {
    warning("`error` is deprecated; use `remeasure_suffix` instead.", call. = FALSE)
    remeasure_suffix <- error
  }
  if (!file.exists(filepath)) {
    stop("File not found: ", filepath, call. = FALSE)
  }
  min_wv <- check_bound(min_wv, "min_wv")
  max_wv <- check_bound(max_wv, "max_wv")
  if (!is.null(min_wv) && !is.null(max_wv) && min_wv > max_wv) {
    stop("`min_wv` must be less than or equal to `max_wv`.", call. = FALSE)
  }

  lines <- readLines(filepath, warn = FALSE)
  headers <- grep("^\\s*Wavelength", lines)
  if (length(headers) == 0) {
    stop("No spectra found in ", basename(filepath),
         ": expected 'Wavelength (nm)' header lines from a NanoDrop UV-Vis export.",
         call. = FALSE)
  }

  # Each block's data runs from its header to just before the next block's
  # sample name line (two lines above the next header).
  ends <- c(headers[-1] - 3L, length(lines))
  names <- trimws(ifelse(headers > 2, lines[pmax(headers - 2L, 1L)], NA_character_))
  stamps <- trimws(ifelse(headers > 1, lines[pmax(headers - 1L, 1L)], NA_character_))

  blocks <- lapply(seq_along(headers), function(i) {
    body <- lines[seq.int(headers[i] + 1L, length.out = max(ends[i] - headers[i], 0L))]
    body <- body[!startsWith(trimws(body), "//")]
    fields <- strsplit(body, "\t", fixed = TRUE)
    waves <- suppressWarnings(as.numeric(vapply(fields, `[`, "", 1L)))
    abs <- suppressWarnings(as.numeric(vapply(fields, `[`, "", 2L)))
    keep <- !is.na(waves)
    data.table::data.table(
      samps = rep(names[i], sum(keep)),
      waves = waves[keep],
      abs = abs[keep],
      measurement = rep(i, sum(keep)),
      timestamp = rep(stamps[i], sum(keep))
    )
  })

  if (!is.null(remeasure_suffix)) {
    resolved <- resolve_remeasures(names, remeasure_suffix)
    for (i in which(resolved$names != names)) {
      data.table::set(blocks[[i]], j = "samps", value = rep(resolved$names[i], nrow(blocks[[i]])))
    }
    blocks <- blocks[!resolved$drop]
  }

  out <- data.table::rbindlist(blocks)
  if (!is.null(min_wv)) out <- out[out$waves >= min_wv]
  if (!is.null(max_wv)) out <- out[out$waves <= max_wv]
  out
}

#' Read every NanoDrop export in a folder
#'
#' Applies [read_nanodrop()] to each matching file and stacks the results,
#' adding a `file` column with each file's path relative to `path`.
#'
#' @param path Directory containing exports.
#' @param pattern Regular expression for file names to read.
#' @param recursive Whether to search subdirectories.
#' @param ... Passed on to [read_nanodrop()].
#'
#' @return A [data.table::data.table()] with a `file` column followed by the
#'   columns returned by [read_nanodrop()].
#' @export
#' @examples
#' folder <- system.file("extdata", package = "nanodRop")
#' spectra <- read_nanodrop_dir(folder)
#' unique(spectra$file)
read_nanodrop_dir <- function(path, pattern = "\\.tsv$", recursive = FALSE, ...) {
  files <- list.files(path, pattern = pattern, recursive = recursive)
  if (length(files) == 0) {
    stop("No files matching '", pattern, "' found in ", path, call. = FALSE)
  }
  spectra <- lapply(file.path(path, files), read_nanodrop, ...)
  names(spectra) <- files
  data.table::rbindlist(spectra, idcol = "file")
}

check_bound <- function(x, arg) {
  if (is.null(x)) return(NULL)
  value <- suppressWarnings(as.numeric(x))
  if (length(value) != 1 || is.na(value)) {
    stop("`", arg, "` must be a single number.", call. = FALSE)
  }
  value
}

# Flags originals that were re-measured for dropping and renames their
# re-measurements to the original name.
resolve_remeasures <- function(names, suffix) {
  is_re <- !is.na(names) & endsWith(names, suffix) & nchar(names) > nchar(suffix)
  base <- substr(names, 1L, nchar(names) - nchar(suffix))
  replaced <- intersect(base[is_re], names[!is_re])
  drop <- !is_re & names %in% replaced
  renamed <- is_re & base %in% replaced
  names[renamed] <- base[renamed]
  list(names = names, drop = drop)
}
