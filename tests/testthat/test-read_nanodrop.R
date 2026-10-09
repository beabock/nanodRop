example_path <- function() system.file("extdata", "nanodrop_example.tsv", package = "nanodRop")

# One measurement block in NanoDrop export layout.
block <- function(name, stamp = "5/14/2024 5:04 PM", waves = c(190, 190.5, 850),
                  abs = seq_along(waves) / 10) {
  c(name, stamp, "Wavelength (nm)\t10mm Absorbance",
    "//WLCalib: Shift \t0.22333\t", "//QSpecEnd: ",
    paste0(format(waves, nsmall = 1), "\t", abs))
}

write_export <- function(...) {
  path <- tempfile(fileext = ".tsv")
  writeLines(c(...), path)
  path
}

test_that("reads the bundled export", {
  result <- read_nanodrop(example_path())

  expect_s3_class(result, "data.table")
  expect_named(result, c("samps", "waves", "abs", "measurement", "timestamp"))
  expect_equal(nrow(result), 24 * 1321)
  expect_equal(range(result$waves), c(190, 850))
  expect_false(anyNA(result$abs))
  expect_equal(result[, .N, by = measurement]$N, rep(1321L, 24))
  expect_equal(result$timestamp[1], "5/14/2024 5:04 PM")
})

test_that("matches the bundled ds dataset", {
  result <- read_nanodrop(example_path())
  expect_equal(as.data.frame(result)[c("samps", "waves", "abs")], ds, ignore_attr = TRUE)
})

test_that("skips calibration lines and parses values", {
  result <- read_nanodrop(write_export(block("A", abs = c(0.5, -0.25, 1e-3))))
  expect_equal(result$waves, c(190, 190.5, 850))
  expect_equal(result$abs, c(0.5, -0.25, 1e-3))
})

test_that("sample names ending in 'e' are kept as written", {
  result <- read_nanodrop(write_export(block("Rinse"), block("Blue")))
  expect_equal(unique(result$samps), c("Rinse", "Blue"))
})

test_that("repeated sample names stay separate measurements", {
  result <- read_nanodrop(write_export(block("A"), block("A")))
  expect_equal(nrow(result), 6)
  expect_equal(unique(result$measurement), 1:2)
})

test_that("does not depend on the timestamp format", {
  result <- read_nanodrop(write_export(block("A", "14/05/2024 17:04"), block("B", "2024-05-14 17:05:00")))
  expect_equal(unique(result$samps), c("A", "B"))
  expect_equal(unique(result$timestamp), c("14/05/2024 17:04", "2024-05-14 17:05:00"))
})

test_that("wavelength bounds accept numbers and strings", {
  result <- read_nanodrop(example_path(), min_wv = 200, max_wv = 800)
  expect_equal(range(result$waves), c(200, 800))
  expect_equal(read_nanodrop(example_path(), min_wv = "200.0", max_wv = "800.0"), result)
  expect_error(read_nanodrop(example_path(), min_wv = 800, max_wv = 200), "less than or equal")
  expect_error(read_nanodrop(example_path(), min_wv = "abc"), "single number")
})

test_that("remeasure_suffix replaces originals only when they exist", {
  path <- write_export(block("A", abs = c(1, 1, 1)), block("Rinse"), block("Ae", abs = c(2, 2, 2)))

  result <- read_nanodrop(path, remeasure_suffix = "e")
  expect_equal(unique(result$samps), c("Rinse", "A"))
  expect_equal(result[samps == "A"]$abs, c(2, 2, 2))

  expect_equal(unique(read_nanodrop(path)$samps), c("A", "Rinse", "Ae"))
})

test_that("deprecated `error` argument still works with a warning", {
  path <- write_export(block("A"), block("Ae"))
  expect_warning(result <- read_nanodrop(path, error = "e"), "deprecated")
  expect_equal(unique(result$samps), "A")
})

test_that("reports unusable input clearly", {
  expect_error(read_nanodrop("nonexistent_file.tsv"), "File not found")
  expect_error(read_nanodrop(write_export("190.0\t0.5", "195.0\t0.6")), "No spectra found")
})

test_that("read_nanodrop_dir stacks files with a file column", {
  dir <- tempfile()
  dir.create(dir)
  writeLines(block("A"), file.path(dir, "one.tsv"))
  writeLines(block("B"), file.path(dir, "two.tsv"))
  writeLines("not an export", file.path(dir, "notes.txt"))

  result <- read_nanodrop_dir(dir, min_wv = 190.5)
  expect_named(result, c("file", "samps", "waves", "abs", "measurement", "timestamp"))
  expect_equal(unique(result$file), c("one.tsv", "two.tsv"))
  expect_equal(nrow(result), 4)
  expect_error(read_nanodrop_dir(dir, pattern = "\\.csv$"), "No files")
})
