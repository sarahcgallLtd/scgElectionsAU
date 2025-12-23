# Process Election Data by Census Collection District

Standardises column names in election data across the 2013, 2016, 2019,
and 2022 Australian federal elections to ensure consistency. This
function adjusts year-specific column names to a common set, including
renaming vote counts and statistical area identifiers, and removes
redundant columns. If an unrecognised election year is provided, the
data is returned unprocessed with a message.

## Usage

``` r
process_ccd(data, event)
```

## Arguments

- data:

  A data frame containing election data with an `event` column
  indicating the election year (e.g., "2013", "2016", "2019", "2022")
  and year-specific columns such as `state_ab`, `div_nm`, `pp_id`,
  `pp_nm`, and vote or area identifiers (e.g., `votes`, `count`,
  `ccd_id`, `SA1_id`).

- event:

  A character string specifying the election event to process.
  Recognised values are "2013 Federal Election", "2016 Federal
  Election", "2019 Federal Election", or "2022 Federal Election". Other
  values result in the data being returned unprocessed.

## Value

A data frame. For recognised election events ("2013 Federal Election",
"2016 Federal Election", "2019 Federal Election", "2022 Federal
Election", "2023 Referendum"), it contains standardised columns:

- `date` (if present in the input)

- `event` (the election event)

- `StateAb` (state abbreviation)

- `DivisionNm` (division name)

- `StatisticalAreaID` (statistical area identifier; refers to 2011 ASGC
  for 2013–2016, 2016 ASGC for 2019–2022)

- `PollingPlaceID` (polling place identifier)

- `PollingPlaceNm` (polling place name)

- `Count` (indicative count of votes cast per statistical area)

The `year` column, if present, is removed as it is redundant with
`event`. For unrecognised election years, the original data frame is
returned unchanged.

## Details

This function processes election data by:

1.  Applying base column renaming common to all recognised years using
    `rename_cols()` (e.g., `state_ab` to `StateAb`, `div_nm` to
    `DivisionNm`).

2.  Removing the `year` column, as the `event` column already provides
    this information.

3.  For 2013: Renaming `ccd_id` to `StatisticalAreaID` and `count` to
    `Count`.

4.  For 2016 and 2019: Renaming `SA1_id` to `StatisticalAreaID` and
    `votes` to `Count`.

5.  For 2022: Renaming `ccd_id` to `StatisticalAreaID` and `votes` to
    `Count`.

6.  For unrecognised years: Returning the data unprocessed with an
    informative message.

The function assumes the input data frame contains the required columns
for the specified `event` year, though column names may vary as per the
original datasets. Note that `StatisticalAreaID` reflects different
Australian Statistical Geography Standards (ASGC) depending on the year:
2011 ASGC for 2013 and 2016, 2016 ASGC for 2019 and 2022.

## Examples

``` r
# Sample 2013 data
data_2013 <- data.frame(
  event = "2013 Federal Election",
  state_ab = "NSW",
  div_nm = "Sydney",
  pp_id = 101,
  pp_nm = "Sydney Town Hall",
  ccd_id = "12345",
  count = 500,
  year = 2013
)
process_ccd(data_2013, "2013 Federal Election")
#> Processing `2013 Federal Election` data to ensure all columns align across all elections.
#>                   event StateAb DivisionNm PollingPlaceID
#> 1 2013 Federal Election     NSW     Sydney            101
#>     PollingPlaceNm StatisticalAreaID Count
#> 1 Sydney Town Hall             12345   500

# Sample 2019 data
data_2019 <- data.frame(
  event = "2019 Federal Election",
  state_ab = "VIC",
  div_nm = "Melbourne",
  pp_id = 102,
  pp_nm = "Melbourne Central",
  SA1_id = "67890",
  votes = 600
)
process_ccd(data_2019, "2019 Federal Election")
#> Processing `2019 Federal Election` data to ensure all columns align across all elections.
#>                   event StateAb DivisionNm PollingPlaceID
#> 1 2019 Federal Election     VIC  Melbourne            102
#>      PollingPlaceNm StatisticalAreaID Count
#> 1 Melbourne Central             67890   600

# Sample invalid year
data_2021 <- data.frame(event = "2021 Federal Election", state_ab = "QLD", votes = 100)
process_ccd(data_2021, "2021 Federal Election")
#> No processing required for `2021 Federal Election`. Data returned unprocessed.
#>                   event state_ab votes
#> 1 2021 Federal Election      QLD   100
```
