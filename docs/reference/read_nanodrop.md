# Read and Process Nanodrop Data

Read and Process Nanodrop Data

## Usage

``` r
read_nanodrop(filepath, max_wv = "850.0", min_wv = "190.0", error = "e")
```

## Arguments

- filepath:

  Path to the input TSV file.

- max_wv:

  Maximum wavelength value as a string. Default is "850.0".

- min_wv:

  Minimum wavelength value as a string. Default is "190.0".

- error:

  Error character to check in the "samps" column. Default is "e".

## Value

A data.table with processed data.
