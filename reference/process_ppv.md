# Process Pre-Poll Voting Centre Data

Standardises and transforms Pre-Poll Voting Centre (PPVC) data for a
single Australian federal election event into a consistent long-format
structure. This function aligns column names across election years
(2010, 2013, 2016, 2019, 2022, 2025), pivots date-specific vote counts
into a long format (except for 2022-25), and converts issue dates to
Date objects. For unrecognised election years, the data is returned
unprocessed with a message.

## Usage

``` r
process_ppv(data, event)
```

## Arguments

- data:

  A data frame containing PPVC data for a single election event. Must
  include an `event` column with a single unique value (e.g., "2010",
  "2013", "2016", "2019", "2022", "2025"). Additional required columns
  vary by year: `State`, `Division`, and date-specific vote columns for
  2010; `State`, `Division`, `m_pp_nm` for 2013; `m_state_ab`,
  `m_div_nm`, `m_pp_nm` for 2016 and 2019; `State`, `Division`, `PPVC`,
  `Issue Date`, `Total Votes` for 2022. A `date` column is optional.

- event:

  A character string specifying the election event to process.
  Recognised values are "2010 Federal Election", "2013 Federal
  Election", "2016 Federal Election", "2019 Federal Election", or "2022
  Federal Election". Other values result in the data being returned
  unprocessed.

## Value

A data frame with standardised columns for recognised election years:

- `date` (if present in the input)

- `event` (the election event)

- `StateAb` (state abbreviation)

- `DivisionNm` (division name)

- `PollingPlaceNm` (polling place name; included for 2013, 2016, 2019,
  and 2022 only)

- `IssueDate` (date of vote issuance as a Date object)

- `TotalVotes` (total votes issued on the corresponding issue date)

For 2010–2019, the data is pivoted from wide to long format using
date-specific vote columns. For 2022, the data retains its original
structure with renamed columns. For unrecognised years, the original
data frame is returned unchanged.

## Details

This function processes PPVC data by:

1.  Standardising column names across recognised election years using
    `rename_cols()`:

    - 2010: `Division` to `DivisionNm`.

    - 2013: “Division`to`DivisionNm\`, \`m_pp_nm\` to
      \`PollingPlaceNm\`.

    - 2016 and 2019: \`m_state_ab\` to \`StateAb\`, \`m_div_nm\` to
      \`DivisionNm\`, \`m_pp_nm\` to \`PollingPlaceNm\`.

    - 2022-25: \`Division\` to \`DivisionNm\`, \`PPVC\` to
      \`PollingPlaceNm\`, \`Issue Date\` to \`IssueDate\`, \`Total
      Votes\` to \`TotalVotes\`.

2.  For 2010: Filtering out rows with NA in \`DivisionNm\` (e.g., notes
    or totals).

3.  For 2010–2019: Pivoting date-specific vote columns into long format
    with \`pivot_event()\`, creating \`IssueDate\` and \`TotalVotes\`
    columns.

4.  For 2022-25: Selecting standardised columns without pivoting.

5.  Converting \`IssueDate\` to a Date object using year-specific
    formats:

    - 2025: "%d/%m/%Y" (e.g., "03/05/2025")

    - 2022: "%d/%m/%y" (e.g., "09/05/22")

    - 2019: "%d/%m/%Y" (e.g., "29/04/2019")

    - 2016: "%Y-%m-%d" (e.g., "2016-06-14")

    - 2013: "%d/%m/%Y" (e.g., "20/08/2013")

    - 2010: "%d %b %y" (e.g., "02 Aug 10")

6.  For unrecognised years: Returning the data unprocessed with an
    informative message.

The function assumes the input data frame contains the required columns
for the specified \`event\` year and that the \`event\` column has a
single unique value matching the \`event\` argument.

## Examples

``` r
# Sample 2013 data (wide format)
data_2013 <- data.frame(
  date = 2013-09-07,
  event = "2013 Federal Election",
  StateAb = "NSW",
  DivisionNm = "Sydney",
  m_pp_nm = "Sydney PPVC",
  `20/08/2013` = 100,
  `21/08/2013` = 150,
  check.names = FALSE
)
process_ppv(data_2013, "2013 Federal Election")
#> Processing `2013 Federal Election` data to ensure all columns align across all elections.
#>   date                 event StateAb DivisionNm PollingPlaceNm
#> 1 1997 2013 Federal Election     NSW     Sydney    Sydney PPVC
#> 2 1997 2013 Federal Election     NSW     Sydney    Sydney PPVC
#>    IssueDate TotalPPVs
#> 1 2013-08-20       100
#> 2 2013-08-21       150

# Sample 2022 data (long format)
data_2022 <- data.frame(
  date = 2022-05-21,
  event = "2022 Federal Election",
  StateAb = "VIC",
  DivisionNm = "Melbourne",
  PPVC = "Melbourne PPVC",
  `Issue Date` = "09/05/22",
  `Total Votes` = 200,
  check.names = FALSE
)
process_ppv(data_2022, "2022 Federal Election")
#> Processing `2022 Federal Election` data to ensure all columns align across all elections.
#>   date                 event StateAb DivisionNm PollingPlaceNm
#> 1 1996 2022 Federal Election     VIC  Melbourne Melbourne PPVC
#>    IssueDate TotalPPVs
#> 1 2022-05-09       200

# Sample invalid year
data_2024 <- data.frame(event = "2024 Federal Election", StateAb = "QLD", Votes = 100)
process_ppv(data_2024, "2024 Federal Election")
#> No processing required for `2024 Federal Election`. Data returned unprocessed.
#>                   event StateAb Votes
#> 1 2024 Federal Election     QLD   100
```
