# scgElectionsAU

## Overview

`scgElectionsAU` is an R package providing comprehensive data and tools
for analysing Australia’s federal election results from 2004 to 2025. It
offers a unique insight into the dynamics of the electoral process in
Australia, presented through a variety of datasets and functions.

#### Datasets Included:

- [`get_election_data`](https://sarahcgallLtd.github.io/scgElectionsAU/reference/get_election_data.html):
  download and process election data from the Australian Electoral
  Commission (AEC). See full guide
  [here](https://docs.sarahcgall.co.uk/scgElectionsAU/articles/a-guide-to-aec-election-datasets).
- [`get_disclosure_data`](https://sarahcgallLtd.github.io/scgElectionsAU/reference/get_disclosure_data.html):
  download disclosure/financial data from the AEC’s Transparency
  Register. See full guide
  [here](https://docs.sarahcgall.co.uk/scgElectionsAU/articles/a-guide-to-aec-disclosure-datasets).
- [`get_boundary_data`](https://sarahcgallLtd.github.io/scgElectionsAU/reference/get_boundary_data.html):
  download boundary data from the Australian Bureau of Statistics (ABS).
  See full guide
  [here](https://docs.sarahcgall.co.uk/scgElectionsAU/articles/a-guide-to-abs-boundary-datasets).

## Installation

To install the development version of `scgElectionsAU`, use:

``` r
devtools::install_github("sarahcgallLtd/scgElectionsAU")
```

## Usage

`scgElectionsAU` includes several helper functions to enhance data
analysis:

Example usage:

``` r
library(scgElectionsAU)

# Load a dataset
df <- get_election_data(
  file_name = "National list of candidates",
  date_range = list(from = "2022-01-01", to = "2025-01-01"), # for elections between 2022 and 2025 (default)
  type = "Federal Election", # Default (other options: "Referendum", or "By-Election")
  category = "House", # Default (other options: "Senate", "Referendum", "General", or "Statistics")
  process = TRUE # Default (can turn off automated processing by selecting FALSE)
)
```

Explore detailed examples and dataset descriptions in the [package
documentation](https://sarahcgallLtd.github.io/scgElectionsAU/reference/index.html).

## Data Sources and Disclaimer

#### Data Sources

The datasets in the `scgElectionsAU` package are meticulously curated
from the official results sourced from the [Australian Electoral
Commission](https://www.aec.gov.au/) and [Australian Bureau of
Statistics](https://abs.gov.au/). These datasets offer a comprehensive
view of Australia’s electoral outcomes and are crucial for in-depth
analysis and research in political science, electoral studies, and
related fields.

#### Disclaimer

While the utmost care has been taken to ensure the accuracy and
reliability of the data, the Australian Electoral Commission was not
involved in the development of this package and thus does not bear
responsibility for any errors or omissions in the datasets. Users of
`scgElectionsAU` should note that the package’s creators have
independently compiled, processed, and presented the data. Any
discrepancies or inaccuracies found within the datasets do not reflect
on the official records maintained by the Electoral Commission.

#### Currency of Data

The data included in this package are up-to-date as of 2 March 2025.
Users should be aware that subsequent electoral events or data revisions
by the Electoral Commission after this date may not be reflected in the
current version of `scgElectionsAU`.

## Future Additions and Updates

Upcoming functional updates will focus on visualising election results
specific to Australia and making boundary adjustments for better
comparative analysis.

## Feedback and Contributions

Suggestions and contributions are welcome. For any proposed additions,
amendments, or feedback, please [create an
issue](https://github.com/sarahcgallLtd/scgElectionsAU/issues).

## Related Packages

Check out [`scgUtils`](https://sarahcgallLtd.github.io/scgUtils) for
additional functions and visualisation tools.
