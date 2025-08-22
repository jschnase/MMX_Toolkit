# phenologytools

Minimal R package of utilities for eBird-driven breeding-season phenology analysis.

## Installation

```r
# install.packages("devtools")
devtools::install_local("phenologytools")  # from local folder
# or build docs then install
devtools::document("phenologytools")
devtools::install("phenologytools")
```

## Usage

```r
library(phenologytools)

# Example workflow (adapt to your data)
# df <- get_records("path/to/ebd_species.csv")
# ph <- extract_phenology(df)
# p  <- plot_phenology(ph$data, ph$start, ph$median, ph$end, title = "Cassin's Sparrow")
# print(p)
```
