#' Example NanoDrop spectra
#'
#' The bundled example export (`inst/extdata/nanodrop_example.tsv`) as read by
#' [read_nanodrop()]: 24 spectra of 1,321 wavelengths each.
#'
#' @format A data frame with 31,704 rows and 3 variables:
#' \describe{
#'   \item{samps}{Sample name (character).}
#'   \item{waves}{Wavelength in nm, 190 to 850 in 0.5 nm steps (numeric).}
#'   \item{abs}{Absorbance (numeric).}
#' }
#' @source `read_nanodrop(system.file("extdata", "nanodrop_example.tsv", package = "nanodRop"))`,
#'   keeping the first three columns.
"ds"


#' Second example set of NanoDrop spectra
#'
#' Spectra of 11 samples from a separate NanoDrop session, 1,321 wavelengths
#' each.
#'
#' @format A data.table with 14,531 rows and 4 variables:
#' \describe{
#'   \item{samps}{Sample name (character).}
#'   \item{waves}{Wavelength in nm (numeric).}
#'   \item{abs}{Absorbance (numeric).}
#'   \item{n}{Session label; `"sn1"` for every row (character).}
#' }
#' @source NanoDrop One measurements by the package author.
"ds1"
