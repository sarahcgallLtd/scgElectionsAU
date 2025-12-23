# Process Postal Vote Application Data by Party

Standardises and transforms Postal Vote Application (PVA) data for a
single Australian federal election event into a consistent structure.
This function aligns column names across election years (2010, 2013,
2016, 2019), calculates totals for Australian Electoral Commission (AEC)
applications (online and paper) and combined AEC-plus-party
applications, and ensures a uniform set of columns. For unrecognised
election years, the data is returned unprocessed with a message.

## Usage

``` r
process_pva_party(data, event)
```

## Arguments

- data:

  A data frame containing PVA data for a single election event. Must
  include an `event` column with a single unique value (e.g., "2010
  Federal Election", "2013 Federal Election", "2016 Federal Election",
  "2019 Federal Election"). Additional required columns vary by year:

  - 2010: `Enrolment`, and party-specific columns (e.g., `Labor`,
    `Liberal`, `AEC`).

  - 2013: `Enrolment Division`, and additional party columns (e.g.,
    `Liberal-National`).

  - 2016 and 2019: `State_Cd`, `PVA_Web_1_Party_Div`, and AEC-specific
    columns (e.g., `AEC - OPVA`).

  A `date` column is optional.

- event:

  A character string specifying the election event to process.
  Recognised values are "2010 Federal Election", "2013 Federal
  Election", "2016 Federal Election", or "2019 Federal Election". Other
  values result in the data being returned unprocessed.

## Value

A data frame with standardised columns for recognised election years:

- `date` (the date of the election or data snapshot)

- `event` (the election event)

- `StateAb` (state abbreviation, upper case; "ZZZ" for NA in 2013)

- `DivisionNm` (division name)

- `GPV` (general postal voter applications; included for 2013, 2016,
  2019 only)

- `AEC (Online)` (AEC online applications; included for 2013, 2016, 2019
  only)

- `AEC (Paper)` (AEC paper applications; included for 2013, 2016, 2019
  only)

- `AEC (Total)` (sum of AEC online and paper applications; all years)

- `Total (AEC + Parties)` (sum of AEC total and party applications; all
  years except 2010)

- `ALP` (Australian Labor Party applications; all years)

- `CLP` (Country Liberal Party applications; all years)

- `DEM` (Australian Democrats applications; 2019 only)

- `GRN` (Greens applications; 2010, 2013, 2016 only)

- `LIB` (Liberal Party applications; all years)

- `LNP` (Liberal National Party applications; 2013, 2016, 2019 only)

- `NAT` (National Party applications; all years)

- `OTH` (Other party applications; all years)

For unrecognised years, the original data frame is returned unchanged.

## Details

This function processes PVA data by:

1.  **Standardising column names** across recognised election years
    using `rename_cols()`:

    - 2010: `Enrolment` to `DivisionNm`, party names (e.g., `Labor` to
      `ALP`).

    - 2013: `Enrolment Division` to `DivisionNm`, additional party names
      (e.g., `Liberal-National` to `LNP`).

    - 2016 and 2019: `State_Cd` to `StateAb`, `PVA_Web_1_Party_Div` to
      `DivisionNm`, AEC columns (e.g., `AEC - OPVA` to `AEC (Online)`).

2.  **Handling missing states**: For 2013, NA in `StateAb` is replaced
    with "ZZZ".

3.  **Filtering rows**: For 2010 and 2013, rows with NA in `DivisionNm`
    (e.g., notes or totals) are removed.

4.  **Calculating totals**: For 2013, 2016, and 2019:

    - `AEC (Total)` is the sum of `AEC (Online)` and `AEC (Paper)`.

    - `Total (AEC + Parties)` is the sum of `AEC (Total)` and all party
      columns present.

5.  **Column selection**: Selects and reorders columns to a consistent
    set, retaining only those present in the data.

6.  **Formatting**: Converts `StateAb` to uppercase.

7.  **Unrecognised years**: Returns the data unprocessed with an
    informative message.

The function assumes the input data frame contains the required columns
for the specified `event` year and that the `event` column matches the
`event` argument.

## Examples

``` r
if (FALSE) { # \dontrun{
# Sample 2010 data
data_2010 <- data.frame(
  date = "2010-08-21",
  event = "2010 Federal Election",
  StateAb = "VIC",
  Enrolment = "Melbourne",
  Labor = 120,
  Liberal = 180,
  AEC = 60
)
process_pva_party(data_2010, "2010 Federal Election")

# Sample 2013 data with NA in State
data_2013 <- data.frame(
  date = "2013-08-21",
  event = "2013 Federal Election",
  StateAb = NSW,
  `Enrolment Division` = "Sydney",
  `Liberal-National` = 150,
  `AEC - OPVA` = 25,
  `AEC - Paper` = 15,
  check.names = FALSE
)
process_pva_party(data_2013, "2013 Federal Election")

# Sample invalid year
data_2022 <- data.frame(event = "2022 Federal Election", StateAb = "QLD", Votes = 90)
process_pva_party(data_2022, "2022 Federal Election")
} # }
```
