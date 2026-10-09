# Read a NanoDrop One spectral export

Parses a UV-Vis spectral `.tsv` file exported by a NanoDrop One into a
long table with one row per sample measurement and wavelength.

## Usage

``` r
read_nanodrop(
  filepath,
  min_wv = NULL,
  max_wv = NULL,
  remeasure_suffix = NULL,
  error
)
```

## Arguments

- filepath:

  Path to the exported `.tsv` file.

- min_wv, max_wv:

  Optional numeric wavelength bounds (inclusive). `NULL` (the default)
  keeps the full measured range.

- remeasure_suffix:

  Optional suffix that marks a re-measurement, e.g. `"e"`. When set, a
  sample named `"A"` followed by one named `"Ae"` is treated as a
  replacement: the `"A"` measurements are dropped and `"Ae"` is renamed
  to `"A"`. Names ending in the suffix with no matching original (e.g.
  `"Rinse"` with no `"Rins"`) are left alone. `NULL` (the default)
  disables this.

- error:

  Deprecated; use `remeasure_suffix`.

## Value

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
with columns:

- samps:

  Sample name (character).

- waves:

  Wavelength in nm (numeric).

- abs:

  Absorbance (numeric).

- measurement:

  Position of the measurement block in the file (integer).

- timestamp:

  Timestamp line as written by the instrument (character).

## Details

An export consists of one block per measurement: a sample name line, a
timestamp line, a `Wavelength (nm)` header line, optional `//`
calibration lines, and then tab-separated wavelength/absorbance pairs.
Blocks are located by their header line, so the parser does not depend
on the date format or locale of the instrument.

Every block becomes its own `measurement`, so measuring the same sample
name twice yields two measurements rather than silently merging them.

## See also

[`read_nanodrop_dir()`](https://beabock.github.io/nanodRop/reference/read_nanodrop_dir.md)
to read every export in a folder.

## Examples

``` r
path <- system.file("extdata", "nanodrop_example.tsv", package = "nanodRop")
spectra <- read_nanodrop(path)
head(spectra)
#>     samps waves    abs measurement         timestamp
#>    <char> <num>  <num>       <int>            <char>
#> 1:    6 1 190.0 10.666           1 5/14/2024 5:04 PM
#> 2:    6 1 190.5 10.782           1 5/14/2024 5:04 PM
#> 3:    6 1 191.0 10.853           1 5/14/2024 5:04 PM
#> 4:    6 1 191.5 10.877           1 5/14/2024 5:04 PM
#> 5:    6 1 192.0 10.866           1 5/14/2024 5:04 PM
#> 6:    6 1 192.5 11.105           1 5/14/2024 5:04 PM

# Restrict to the visible range
visible <- read_nanodrop(path, min_wv = 400, max_wv = 700)
```
