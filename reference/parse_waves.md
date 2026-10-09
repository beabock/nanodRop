# Compare absorbance at pairs of wavelengths

For each sample measurement, extracts the absorbance at the wavelengths
in `wave_pairs` and computes the difference (`A1 - A2`) or ratio
(`A1 / A2`) for each pair, e.g. the A260/A280 purity ratio.

## Usage

``` r
parse_waves(
  dataset,
  samps_col = "samps",
  waves_col = "waves",
  abs_col = "abs",
  wave_pairs = list(c(300, 400), c(542, 644)),
  type = c("diff", "ratio"),
  tol = 1e-06,
  id_cols = NULL
)
```

## Arguments

- dataset:

  A long data frame of spectra, such as the output of
  [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md).

- samps_col, waves_col, abs_col:

  Names of the sample, wavelength and absorbance columns.

- wave_pairs:

  List of length-2 numeric vectors giving the wavelength pairs to
  compare. The defaults (300/400 and 542/644 nm) come from the dye work
  this package was first written for; set your own for other analyses.

- type:

  `"diff"` for `A1 - A2` or `"ratio"` for `A1 / A2`.

- tol:

  Wavelengths within `tol` nm of a requested wavelength count as a
  match, which guards against floating point mismatches.

- id_cols:

  Columns that identify one spectrum. By default, `samps_col` plus
  `file` and `measurement` when present, so repeated measurements of the
  same sample stay separate.

## Value

A tibble with one row per spectrum: the `id_cols`, an
`<abs_col>_<wavelength>` column for each requested wavelength, and a
`diff_<w1>_<w2>` or `ratio_<w1>_<w2>` column for each pair. Wavelengths
missing from a spectrum give `NA`.

## Examples

``` r
parse_waves(ds)
#> # A tibble: 24 × 7
#>    samps abs_300 abs_400 abs_542 abs_644 diff_300_400 diff_542_644
#>    <chr>   <dbl>   <dbl>   <dbl>   <dbl>        <dbl>        <dbl>
#>  1 6 1      2.58   0.93    0.652   0.546         1.65        0.106
#>  2 6 2      2.70   0.968   0.686   0.578         1.73        0.108
#>  3 7 1      1.87   0.352   0.16    0.102         1.51        0.058
#>  4 7 2      2.26   0.722   0.499   0.402         1.53        0.097
#>  5 8 1      2.68   0.756   0.517   0.43          1.93        0.087
#>  6 8 2      2.79   0.709   0.404   0.341         2.08        0.063
#>  7 9 1     16.2   13.6     2.79    1.28          2.61        1.51 
#>  8 9 2     16.5   21.8    14.2    12.9          -5.23        1.28 
#>  9 9 3     15.6    9.31    4.52    3.71          6.30        0.813
#> 10 10 1    12.1    2.77    0.618   0.251         9.29        0.367
#> # ℹ 14 more rows

# Nucleic acid purity ratios
parse_waves(ds, wave_pairs = list(c(260, 280), c(260, 230)), type = "ratio")
#> # A tibble: 24 × 6
#>    samps abs_260 abs_280 abs_230 ratio_260_280 ratio_260_230
#>    <chr>   <dbl>   <dbl>   <dbl>         <dbl>         <dbl>
#>  1 6 1      3.39    3.13    4.88          1.08         0.695
#>  2 6 2      3.49    3.24    5.03          1.08         0.694
#>  3 7 1      2.54    2.37    3.93          1.08         0.647
#>  4 7 2      2.90    2.74    4.28          1.06         0.678
#>  5 8 1      3.53    3.29    5.31          1.07         0.664
#>  6 8 2      3.70    3.45    5.65          1.07         0.656
#>  7 9 1     12.0    10.8     4.72          1.11         2.54 
#>  8 9 2     12.4    11.1     4.42          1.11         2.80 
#>  9 9 3     11.1     9.67    2.26          1.15         4.90 
#> 10 10 1    16.8    14.9    23.6           1.13         0.712
#> # ℹ 14 more rows
```
