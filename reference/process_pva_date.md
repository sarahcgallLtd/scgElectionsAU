# Process Postal Vote Application Data by Date

Standardises and transforms Postal Vote Application (PVA) data for a
single Australian federal election event into a consistent long-format
structure based on application receipt dates. This function aligns
column names across election years (2010, 2013, 2016, 2019), pivots
date-specific vote counts into a long format, and converts receipt dates
to Date objects. For unrecognised election years, the data is returned
unprocessed with a message.

## Usage

``` r
process_pva_date(data, event)
```

## Arguments

- data:

  A data frame containing PVA data for a single election event. Must
  include:

  - `date` (the date of the election or data snapshot)

  - `event` (the election event, matching the `event` argument)

  Additional required columns vary by year:

  - 2010: `Enrolment`, and date-specific columns (e.g., "02 Aug 10").

  - 2013: `Enrolment Division`, and date-specific columns (e.g.,
    "20-Aug-13").

  - 2016: `State_Cd`, `PVA_Web_2_Date_Div`, and date-specific columns
    (e.g., "20160614").

  - 2019: `State_Cd`, `PVA_Web_2_Date_V2_Div`, and date-specific columns
    (e.g., "20190411").

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

- `DateReceived` (date the PVA was received, as a Date object)

- `TotalPVAs` (total PVA applications received on the corresponding
  date)

For unrecognised years, the original data frame is returned unchanged.

## Details

This function processes PVA data by:

1.  **Standardising column names** across recognised election years
    using `rename_cols()`:

    - 2010: `Enrolment` to `DivisionNm`.

    - 2013: `Enrolment Division` to `DivisionNm`.

    - 2016: `State_Cd` to `StateAb`, `PVA_Web_2_Date_Div` to
      `DivisionNm`.

    - 2019: `State_Cd` to `StateAb`, `PVA_Web_2_Date_V2_Div` to
      `DivisionNm`.

2.  **Handling missing states**: For 2013, NA in `StateAb` is replaced
    with "ZZZ".

3.  **Filtering rows**: For 2010 and 2013, rows with NA in `DivisionNm`
    (e.g., notes or totals) are removed.

4.  **Removing unnecessary columns**: Drops columns like "TOTAL to date
    (Inc GPV)" (2010, 2013), "\<\>", and "Date out of range" (2019).

5.  **Pivoting data**: Uses `pivot_event()` to transform date-specific
    columns (e.g., "20-Aug-13") into long format with `DateReceived` and
    `TotalPVAs`.

6.  **Converting dates**: Formats `DateReceived` as a Date object using
    year-specific formats:

    - 2019: "%Y%m%d" (e.g., "20190411")

    - 2016: "%Y%m%d" (e.g., "20160614")

    - 2013: "%d-%b-%y" (e.g., "20-Aug-13")

    - 2010: "%d %b %y" (e.g., "02 Aug 10")

7.  **Formatting**: Converts `StateAb` to uppercase.

8.  **Unrecognised years**: Returns the data unprocessed with an
    informative message.

The function assumes the input data frame contains the required columns
(`date`, `event`, and year-specific columns) from the AEC past results
datasets and that the `event` column matches the `event` argument. The
date-specific columns represent daily PVA totals and are pivoted into
the `DateReceived` and `TotalPVAs` columns.

## Examples

``` r
# Sample 2010 data
data_2010 <- data.frame(
  date = "2010-08-21",
  event = "2010 Federal Election",
  StateAb = "VIC",
  Enrolment = "Melbourne",
  `02 Aug 10` = 50,
  `03 Aug 10` = 60
)
process_pva_date(data_2010, "2010 Federal Election")
#> Processing `2010 Federal Election` data to ensure all columns align across all elections.
#> [1] date         event        StateAb      DivisionNm   DateReceived
#> [6] TotalPVAs   
#> <0 rows> (or 0-length row.names)

# Sample invalid year
data_2022 <- data.frame(
  date = "2022-05-21",
  event = "2022 Federal Election",
  StateAb = "QLD",
  Votes = 90
)
process_pva_date(data_2022, "2022 Federal Election")
#> No processing required for `2022 Federal Election`. Data returned unprocessed.
#>         date                 event StateAb Votes
#> 1 2022-05-21 2022 Federal Election     QLD    90
```
