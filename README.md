scgElectionsAU <a href="https://sarahcgallLtd.github.io/scgElectionsAU/"><img src="man/figures/logo.png" align="right" height="138" alt="" /></a>
================
<!-- badges: start -->
[![Release](https://img.shields.io/badge/Release-development%20version%200&#46;0&#46;1-1c75bc)](https://github.com/sarahcgallLtd/scgElectionsAU/blob/master/NEWS.md)
[![R-CMD-check](https://github.com/sarahcgallLtd/scgElectionsAU/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sarahcgallLtd/scgElectionsAU/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/sarahcgallLtd/scgElectionsAU/graph/badge.svg?token=Oni4LxeKWN)](https://codecov.io/gh/sarahcgallLtd/scgElectionsAU)
<!-- badges: end -->

## Overview

`scgElectionsAU` is an R package providing comprehensive data and tools for analysing Australia’s federal election 
results from 2004 to 2022. It offers a unique insight into the dynamics of the electoral process in Australia, 
presented through a variety of datasets and functions.

#### Datasets Included:

* [`get_aec_data`](https://sarahcgallLtd.github.io/scgElectionsAU/reference/et_aec_data.html): download and process data from the Australian Electoral Commission (AEC).

## Installation

To install the development version of `scgElectionsAU`, use:

``` r
devtools::install_github("sarahcgallLtd/scgElectionsAU")
```

## Usage
`scgElectionsAU` includes several helper functions to enhance data analysis:


Example usage:
``` r
library(scgElectionsAU)

# Load a dataset
df <- get_aec_data(
  file_name = "National list of candidates",
  date_range = list(from = "2022-01-01", to = "2025-01-01"), # for elections between 2022 and 2025 (default)
  type = "Federal Election", # Default (other options: "Referendum" and "Federal By-Election")
  category = "House", # Default (other options: "Senate", "Referendum", "General", or "Statistics")
  process = TRUE # default (can turn off automated processing by selecting FALSE)
)


```

Explore detailed examples and dataset descriptions in the 
[package documentation](https://sarahcgallLtd.github.io/scgElectionsAU/reference/index.html).

## Data Sources and Disclaimer
#### Data Sources
The datasets in the `scgElectionsAU` package are meticulously curated from the official results sourced from the [Australian Electoral Commission](https://www.aec.gov.au/).
These datasets offer a comprehensive view of Australia's electoral outcomes and are crucial for in-depth analysis and research in political science, electoral studies, and related fields.

#### Disclaimer
While the utmost care has been taken to ensure the accuracy and reliability of the data, the Australian Electoral Commission 
was not involved in the development of this package and thus does not bear responsibility for any errors or omissions in the datasets. 
Users of `scgElectionsAU` should note that the package's creators have independently compiled, processed, and presented the data. 
Any discrepancies or inaccuracies found within the datasets do not reflect on the official records maintained by the Electoral Commission.

#### Currency of Data
The data included in this package are up-to-date as of 2 March 2025. Users should be aware that subsequent electoral 
events or data revisions by the Electoral Commission after this date may not be reflected in the current version of `scgElectionsAU`.

## Future Additions and Updates
Planned future additions include by-election and referendum results and enhanced datasets like `results_by_booths`. 
Upcoming functional updates will focus on visualising election results specific to Australia and making boundary
adjustments for better comparative analysis.

## Feedback and Contributions
Suggestions and contributions are welcome. For any proposed additions, amendments, or feedback, please [create an issue](https://github.com/sarahcgallLtd/scgElectionsAU/issues).

## Related Packages
Check out [`scgUtils`](https://sarahcgallLtd.github.io/scgUtils) for additional functions and visualisation tools.
