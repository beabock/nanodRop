# Changelog

## nanodRop 0.2.0

### Bug fixes

- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md)
  no longer strips a trailing “e” from every sample name ending in “e”
  (e.g. “Rinse” became “Rins”).
- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md)
  no longer merges measurements that share a sample name.
- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md)
  no longer returns `NA` sample names when the instrument writes
  timestamps in a format other than US 12-hour time. Blocks are now
  found by their `Wavelength (nm)` header line.
- [`parse_waves()`](https://beabock.github.io/nanodRop/reference/parse_waves.md)
  matches wavelengths with a tolerance (`tol`) instead of exact floating
  point equality.

### Changes

- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md)
  returns two new columns: `measurement` (block number in the file) and
  `timestamp`.
- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md):
  `min_wv` and `max_wv` take numbers and default to `NULL` (keep the
  full range). Strings such as `"190.0"` still work.
- [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md):
  re-measurement handling is now opt-in through `remeasure_suffix`, and
  only renames a sample when the original is also present. **This
  changes the default:** set `remeasure_suffix = "e"` to get the old
  behaviour. The `error` argument is deprecated.
- New
  [`read_nanodrop_dir()`](https://beabock.github.io/nanodRop/reference/read_nanodrop_dir.md)
  reads every export in a folder.
- [`parse_waves()`](https://beabock.github.io/nanodRop/reference/parse_waves.md)
  gains `type = "ratio"` (e.g. A260/A280), `tol`, and `id_cols`. By
  default it now keeps repeated measurements separate. Absorbance
  columns come before the difference/ratio columns in the output.
- Removed the `magrittr`, `purrr`, `readr`, `rlang`, `stringr` and
  `tidyr` dependencies.
- Corrected documentation for `ds` and `ds1`.

## nanodRop 0.1.0

- Initial release with
  [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md),
  [`parse_waves()`](https://beabock.github.io/nanodRop/reference/parse_waves.md)
  and the example datasets `ds` and `ds1`.
