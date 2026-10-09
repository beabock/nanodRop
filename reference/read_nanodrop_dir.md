# Read every NanoDrop export in a folder

Applies
[`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md)
to each matching file and stacks the results, adding a `file` column
with each file's path relative to `path`.

## Usage

``` r
read_nanodrop_dir(path, pattern = "\\.tsv$", recursive = FALSE, ...)
```

## Arguments

- path:

  Directory containing exports.

- pattern:

  Regular expression for file names to read.

- recursive:

  Whether to search subdirectories.

- ...:

  Passed on to
  [`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md).

## Value

A
[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
with a `file` column followed by the columns returned by
[`read_nanodrop()`](https://beabock.github.io/nanodRop/reference/read_nanodrop.md).

## Examples

``` r
folder <- system.file("extdata", package = "nanodRop")
spectra <- read_nanodrop_dir(folder)
unique(spectra$file)
#> [1] "nanodrop_example.tsv"
```
