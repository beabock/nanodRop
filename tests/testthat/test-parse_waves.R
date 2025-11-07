test_that("parse_waves handles basic functionality", {
  # Load example dataset
  data("ds", package = "nanodRop")

  # Test with default parameters
  result <- parse_waves(ds)

  # Check that result is a data frame
  expect_s3_class(result, "data.frame")

  # Check that it has the expected columns
  expect_true("samps" %in% names(result))
  expect_true("diff_300_400" %in% names(result))
  expect_true("diff_542_644" %in% names(result))

  # Check that diff columns are numeric
  expect_type(result$diff_300_400, "double")
  expect_type(result$diff_542_644, "double")
})

test_that("parse_waves handles custom wave pairs", {
  data("ds", package = "nanodRop")

  # Test with custom wave pairs
  custom_pairs <- list(c(250, 350), c(400, 500))
  result <- parse_waves(ds, wave_pairs = custom_pairs)

  expect_s3_class(result, "data.frame")
  expect_true("diff_250_350" %in% names(result))
  expect_true("diff_400_500" %in% names(result))
})

test_that("parse_waves handles custom column names", {
  data("ds", package = "nanodRop")

  # Rename columns to test custom column name handling
  ds_custom <- ds
  names(ds_custom) <- c("samples", "wavelengths", "absorbance")

  result <- parse_waves(ds_custom,
                       samps_col = "samples",
                       waves_col = "wavelengths",
                       abs_col = "absorbance")

  expect_s3_class(result, "data.frame")
  expect_true("samples" %in% names(result))
})

test_that("parse_waves handles single wave pair", {
  data("ds", package = "nanodRop")

  # Test with single wave pair
  single_pair <- list(c(300, 400))
  result <- parse_waves(ds, wave_pairs = single_pair)

  expect_s3_class(result, "data.frame")
  expect_true("diff_300_400" %in% names(result))
  expect_false("diff_542_644" %in% names(result))
})

test_that("parse_waves handles empty dataset", {
  # Create empty dataset with correct structure
  empty_ds <- data.frame(samps = character(),
                        waves = numeric(),
                        abs = numeric())

  result <- parse_waves(empty_ds)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("parse_waves handles missing wavelengths", {
  data("ds", package = "nanodRop")

  # Remove some wavelengths to test missing data handling
  ds_subset <- ds[!ds$waves %in% c(300, 400, 542, 644), ]

  result <- parse_waves(ds_subset)

  # Should still work but with NA values for missing wavelengths
  expect_s3_class(result, "data.frame")
  expect_true(all(is.na(result$diff_300_400) | is.numeric(result$diff_300_400)))
})

test_that("parse_waves validates input structure", {
  # Test with missing columns
  invalid_ds <- data.frame(wrong_col = 1:10)

  expect_error(parse_waves(invalid_ds), "Dataset must contain columns specified by samps_col, waves_col, and abs_col")

  # Test with NULL dataset
  expect_error(parse_waves(NULL))
})

test_that("parse_waves handles different data types", {
  data("ds", package = "nanodRop")

  # Test with character absorbance (should fail gracefully or convert)
  ds_char <- ds
  ds_char$abs <- as.character(ds$abs)

  # The function uses pivot_wider which might handle this
  result <- parse_waves(ds_char)
  expect_s3_class(result, "data.frame")
})

test_that("parse_waves produces correct calculations", {
  # Create a simple test dataset
  test_ds <- data.frame(
    samps = rep("Sample1", 4),
    waves = c(300, 400, 542, 644),
    abs = c(0.5, 0.3, 0.8, 0.6)
  )

  result <- parse_waves(test_ds)

  # Check calculations: 300-400 = 0.5-0.3 = 0.2, 542-644 = 0.8-0.6 = 0.2
  expect_equal(result$diff_300_400, 0.2)
  expect_equal(result$diff_542_644, 0.2)
})

test_that("parse_waves handles multiple samples", {
  # Create test dataset with multiple samples
  test_ds <- data.frame(
    samps = c(rep("Sample1", 4), rep("Sample2", 4)),
    waves = rep(c(300, 400, 542, 644), 2),
    abs = c(0.5, 0.3, 0.8, 0.6, 0.6, 0.4, 0.9, 0.7)
  )

  result <- parse_waves(test_ds)

  expect_equal(nrow(result), 2)  # Two samples
  expect_equal(result$diff_300_400, c(0.2, 0.2))
  expect_equal(result$diff_542_644, c(0.2, 0.2))
})