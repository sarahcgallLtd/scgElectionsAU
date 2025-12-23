# Process Election Data for Elected Candidates

Standardises election data related to elected candidates for a single
Australian federal election event. This function aligns column names
across datasets, specifically processing the 2004 election year by
standardising the `Elected` column with "Y" or "N" values. For all other
election years, the data is returned unprocessed with a message. Applies
to datasets including "National list of candidates" (House and Senate),
"First preferences by candidate by vote type" (House only), "Two
candidate preferred by candidate by vote type" (House only), "Two
candidate preferred by candidate by polling place" (House only), and
"Distribution of preferences by candidate by division" (House only).

## Usage

``` r
process_elected(data, event)
```

## Arguments

- data:

  A data frame containing election data for a single election event.
  Must include an `event` column with a single unique value (e.g.,
  "2004"). Additional columns depend on the specific dataset.

- event:

  A character string specifying the election event to process.
  Currently, only "2004 Federal Election" is processed; other values
  result in the data being returned unprocessed.

## Value

A data frame. For the 2004 Federal Election, it contains the
standardised column:

- `Elected` (indicates if the candidate was elected, with values "Y" for
  yes or "N" for no)

along with all other input columns. For unrecognised years, the original
data frame is returned unchanged.

## Details

This function processes election data by:

1.  **Formatting**: Converts `Elected` values to "Y" (elected) or "N"
    (not elected), replacing NA with "N".

2.  **Unrecognised years**: Returns the data unprocessed with an
    informative message for years other than the 2004 Federal Election.

The function assumes the input data frame contains the required columns
for the specified `event` year and dataset, with processing currently
implemented only for the 2004 Federal Election. Future enhancements may
include adding `HistoricVote` data for the 2004 Federal Election
(pending identification of the source dataset).

## Examples

``` r
# Sample 2004 data
data_2004 <- data.frame(
  date = "2004-10-09",
  event = "2004 Federal Election",
  CandidateID = 123,
  Elected = "#"
)
process_elected(data_2004, "2004 Federal Election")
#> Processing `2004 Federal Election` data to ensure all columns align across all elections.
#>         date                 event CandidateID Elected
#> 1 2004-10-09 2004 Federal Election         123       Y

# Sample unprocessed year (e.g., 2010)
data_2010 <- data.frame(
  date = "2010-08-21",
  event = "2010 Federal Election",
  CandidateID = 456,
  Elected = "Y"
)
process_elected(data_2010, "2010 Federal Election")
#> No processing required for `2010 Federal Election`. Data returned unprocessed.
#>         date                 event CandidateID Elected
#> 1 2010-08-21 2010 Federal Election         456       Y
```
