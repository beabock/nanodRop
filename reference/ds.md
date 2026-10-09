# Example NanoDrop spectra

The bundled example export (`inst/extdata/nanodrop_example.tsv`) as read
by
[`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md):
24 spectra of 1,321 wavelengths each.

## Usage

``` r
ds
```

## Format

A data frame with 31,704 rows and 3 variables:

- samps:

  Sample name (character).

- waves:

  Wavelength in nm, 190 to 850 in 0.5 nm steps (numeric).

- abs:

  Absorbance (numeric).

## Source

`read_nanodrop(system.file("extdata", "nanodrop_example.tsv", package = "nanodRop"))`,
keeping the first three columns.
