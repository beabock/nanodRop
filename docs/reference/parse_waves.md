# parse_waves

Parse wavelength differences for spectral analysis

## Usage

``` r
parse_waves(
  dataset,
  samps_col = "samps",
  waves_col = "waves",
  abs_col = "abs",
  wave_pairs = list(c(300, 400), c(542, 644))
)
```

## Arguments

- dataset:

  the dataset being used. must be run through read_nanodrop()

- samps_col:

  Column name for samples (default "samps")

- waves_col:

  Column name for wavelengths (default "waves")

- abs_col:

  Column name for absorbance (default "abs")

- wave_pairs:

  List of wavelength pairs to analyze (default: c(300,400) and
  c(542,644))

## Value

final_combined

## Examples

``` r
test <- parse_waves(dataset = ds1)
```
