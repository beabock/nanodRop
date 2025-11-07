# Script to generate sample plots for README.md

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(nanodRop)

# Load example datasets
load("data/ds.rda")
load("data/ds1.rda")

# Plot 1: Absorbance vs Wavelength for ds dataset
png("man/figures/absorbance_vs_wavelength_ds.png", width = 800, height = 600, res = 100)
ds_sample <- ds %>% filter(samps == unique(samps)[1])
plot(ds_sample$waves, ds_sample$abs, type = "l", col = "blue",
     xlab = "Wavelength (nm)", ylab = "Absorbance",
     main = "Absorbance Spectrum - Sample 1 from ds Dataset")
dev.off()

# Plot 2: Absorbance vs Wavelength for ds1 dataset
png("man/figures/absorbance_vs_wavelength_ds1.png", width = 800, height = 600, res = 100)
ds1_sample <- ds1 %>% filter(samps == unique(samps)[1])
plot(ds1_sample$waves, ds1_sample$abs, type = "l", col = "red",
     xlab = "Wavelength (nm)", ylab = "Absorbance",
     main = "Absorbance Spectrum - Sample 1 from ds1 Dataset")
dev.off()

# Plot 3: Parsed wave differences for ds dataset
png("man/figures/parsed_waves_ds.png", width = 800, height = 600, res = 100)
parsed_ds <- parse_waves(ds, wave_pairs = list(c(260, 280), c(400, 500)))
barplot(height = as.numeric(parsed_ds[1, -1]), names.arg = colnames(parsed_ds)[-1],
        col = "lightblue", main = "Peak-to-Valley Differences - ds Dataset",
        ylab = "Difference", xlab = "Wavelength Pairs")
dev.off()

# Plot 4: Parsed wave differences for ds1 dataset
png("man/figures/parsed_waves_ds1.png", width = 800, height = 600, res = 100)
parsed_ds1 <- parse_waves(ds1, wave_pairs = list(c(260, 280), c(400, 500)))
barplot(height = as.numeric(parsed_ds1[1, -1]), names.arg = colnames(parsed_ds1)[-1],
        col = "lightgreen", main = "Peak-to-Valley Differences - ds1 Dataset",
        ylab = "Difference", xlab = "Wavelength Pairs")
dev.off()