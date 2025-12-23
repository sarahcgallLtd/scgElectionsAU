# Process Party Representation Data for House of Representatives

Standardises "Party representation" data for the House of
Representatives from Australian federal elections in 2004, 2007, and
2010. This helper function aligns column names by renaming `Total` to
`National` and `LastElectionTotal` to `LastElection` for consistency
across these years. For other election years, the data is returned
unprocessed with a message.

## Usage

``` r
process_reps(data, event)
```

## Arguments

- data:

  A data frame containing "Party representation" data for a single
  election event from the House of Representatives. Must include an
  `event` column with a single unique value (e.g., "2004 Federal
  Election", "2007 Federal Election", "2010 Federal Election"). For
  processing years (2004, 2007, 2010), must include `Total` and
  `LastElectionTotal` columns. A `date` column is typically present as
  mandatory metadata.

- event:

  A character string specifying the election event to process.
  Recognised values are "2004 Federal Election", "2007 Federal
  Election", or "2010 Federal Election". Other values result in the data
  being returned unprocessed.

## Value

A data frame. For recognised election federal years (2004, 2007, 2010),
it contains the standardised columns:

- `National` (total party representation, renamed from `Total`)

- `LastElection` (party representation from the last election, renamed
  from `LastElectionTotal`)

along with all other input columns (e.g., `date`, `event`). For
unrecognised years, the original data frame is returned unchanged.

## Details

This function processes "Party representation" data by:

1.  **Standardising column names**: For 2004, 2007, and 2010, renames
    `Total` to `National` and `LastElectionTotal` to `LastElection`
    using `rename_cols()`.

2.  **Unrecognised years**: Returns the data unprocessed with an
    informative message for years other than 2004, 2007, or 2010.

The function assumes the input data frame contains the required columns
(`event`, `Total`, and `LastElectionTotal`) for the specified processing
years, as sourced from the AEC "Party representation" dataset for the
House of Representatives.

## Examples

``` r
# Sample 2004 data
data_2004 <- data.frame(
  date = "2004-10-09",
  event = "2004 Federal Election",
  PartyNm = "ALP",
  Total = 60,
  LastElectionTotal = 65
)
process_reps(data_2004, "2004 Federal Election")
#> Processing `2004 Federal Election` data to ensure all columns align across all elections.
#>         date                 event PartyNm National LastElection
#> 1 2004-10-09 2004 Federal Election     ALP       60           65

# Sample unprocessed year (e.g., 2013)
data_2013 <- data.frame(
  date = "2013-09-07",
  event = "2013 Federal Election",
  PartyNm = "LIB",
  National = 90,
  LastElection = 72
)
process_reps(data_2013, "2013 Federal Election")
#> No processing required for `2013 Federal Election`. Data returned unprocessed.
#>         date                 event PartyNm National LastElection
#> 1 2013-09-07 2013 Federal Election     LIB       90           72
```
