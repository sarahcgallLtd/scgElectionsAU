# Process Overseas Voting Data

Standardises column names and calculates total votes for overseas voting
data from the 2013, 2019, and 2022 Australian federal elections. This
function aligns disparate column names across election years to a
consistent format and computes the total votes as the sum of postal and
pre-poll votes. If an unrecognised election year is provided, the data
is returned unprocessed with a message.

## Usage

``` r
process_overseas(data, event)
```

## Arguments

- data:

  A data frame containing overseas voting data. Must include an `event`
  column indicating the election event (e.g., "2013 Federal Election",
  "2019 Federal Election", "2022 Federal Election", "2023 Referendum",
  "2024 Federal Election") and, for recognised years, year-specific
  columns for state, division, overseas post, and vote counts.

- event:

  A character string specifying the election event to process.
  Recognised values are "2013 Federal Election", "2019 Federal
  Election", "2022 Federal Election", "2023 Referendum", or "2025
  Federal Election". Other values will result in the data being returned
  unprocessed.

## Value

A data frame. For recognised election years ("2013", "2019", "2022",
"2023", "2025"), it contains standardised columns:

- `date` (if present in input)

- `event` (the election event)

- `StateAb` (state abbreviation, standardised using
  [`amend_names()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_names.md)
  for 2013 and 2019)

- `DivisionNm` (division name)

- `OverseasPost` (name of the overseas voting post)

- `PrePollVotes` (pre-poll vote count)

- `PostalVotes` (postal vote count)

- `TotalVotes` (sum of `PrePollVotes` and `PostalVotes`, with NA
  handling)

Rows with missing `StateAb` values (e.g., totals) are removed for 2013
data. For unrecognised election years, the original data frame is
returned unchanged.

## Details

This function processes overseas voting data by:

1.  Standardising column names to a consistent set across recognised
    election years using `rename_cols()`.

2.  For 2013 data: Removing unnecessary columns (`pp_sort_nm`, `Total`)
    and rows with NA in `StateAb`.

3.  Converting full state names to abbreviations using
    [`amend_names()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_names.md)
    for 2013 and 2019 data.

4.  Calculating `TotalVotes` as the sum of `PostalVotes` and
    `PrePollVotes`, treating NA as 0.

5.  For unrecognised years: Returning the data unprocessed with an
    informative message.

The function assumes the input data frame contains the required columns
for the specified `event` year when it is "2013", "2019", "2022", or
"2025", though column names may vary as per the original datasets.

## See also

[`amend_names`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_names.md))
for state name standardisation.

## Examples

``` r
# Sample 2013 data
data_2013 <- data.frame(
  event = "2013 Federal Election",
  StateAb = c("NSW", "VIC", NA),
  DivisionNm = c("Sydney", "Melbourne", "Total"),
  pp_nm = c("London", "Paris", "All"),
  `Pre-poll Votes` = c(100, 150, 250),
  `Postal Votes` = c(50, 75, 125),
  pp_sort_nm = c("LON", "PAR", "ALL"),
  Total = c(150, 225, 375),
  check.names = FALSE
)
process_overseas(data_2013, "2013 Federal Election")
#> Processing `2013 Federal Election` data to ensure all columns align across all elections.
#>                   event StateAb DivisionNm OverseasPost PrePollVotes
#> 1 2013 Federal Election     NSW     Sydney       London          100
#> 2 2013 Federal Election     VIC  Melbourne        Paris          150
#>   PostalVotes TotalVotes
#> 1          50        150
#> 2          75        225

# Sample invalid year
data_2026 <- data.frame(event = "2026 Federal Election", StateAb = "QLD", Votes = 100)
process_overseas(data_2026, "2026 Federal Election")
#> No processing required for `2026 Federal Election`. Data returned unprocessed.
#>                   event StateAb Votes
#> 1 2026 Federal Election     QLD   100
```
