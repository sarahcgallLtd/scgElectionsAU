# Process Polling Place Coordinates

Updates missing or invalid coordinate data for polling places in the
"Polling place" dataset from Australian federal elections. This helper
function fills in missing (`NA`) or zero-valued latitude and longitude
coordinates by matching `PollingPlaceID` with an internal coordinate
dataset (`coords`) stored in the `scgElectionsAU` package namespace. The
function processes data for any specified election year, ensuring
alignment with known polling place locations.

## Usage

``` r
process_coords(data, event)
```

## Arguments

- data:

  A data frame containing polling place data for a single election
  event. Must include:

  - `event` (the election event, e.g., "2004 Federal Election", "2010
    Federal Election")

  - `PollingPlaceID` (unique identifier for polling places)

  - `Latitude` (latitude coordinate, potentially NA or 0)

  - `Longitude` (longitude coordinate, potentially NA or 0)

  A `date` column is typically present as mandatory metadata.

- event:

  A character string specifying the election event (e.g., "2004 Federal
  Election", "2010 Federal Election"). Used for logging purposes only;
  processing occurs for all years.

## Value

A data frame identical to the input, with updated columns:

- `Latitude` (updated with non-NA, non-zero values from the internal
  `coords` dataset where matches are found)

- `Longitude` (updated with non-NA, non-zero values from the internal
  `coords` dataset where matches are found)

Unmatched or already valid coordinates remain unchanged.

## Details

This function processes polling place coordinates by:

1.  **Retrieving internal data**: Accesses the `coords` dataset from the
    `scgElectionsAU` package namespace, which contains known
    `PollingPlaceID`, `Latitude`, and `Longitude` values.

2.  **Matching polling places**: Uses `PollingPlaceID` to match rows in
    the input data with the internal `coords` dataset.

3.  **Updating coordinates**: Replaces `NA` or zero values in `Latitude`
    and `Longitude` with corresponding values from `coords` where
    matches exist.

4.  **Logging**: Outputs a message indicating the election year being
    processed, though processing applies universally regardless of year.

The function assumes the input data frame contains the required columns
(`event`, `PollingPlaceID`, `Latitude`, and `Longitude`) as sourced from
the AEC "Polling place" dataset, and that the internal `coords` dataset
is available and correctly formatted within the package namespace.

## Examples

``` r
# Sample data with missing coordinates
data_2010 <- data.frame(
  date = "2010-08-21",
  event = "2010 Federal Election",
  PollingPlaceID = c(93925.0, 11877.0),
  Latitude = c(NA, 0),
  Longitude = c(0, NA)
)
process_coords(data_2010, "2010 Federal Election")
#> Filling in missing coordinates for `2010 Federal Election` data, where possible.
#>         date                 event PollingPlaceID  Latitude Longitude
#> 1 2010-08-21 2010 Federal Election          93925 -35.23895  149.0691
#> 2 2010-08-21 2010 Federal Election          11877 -35.43119  149.0830

# Sample data with some valid coordinates
data_2013 <- data.frame(
  date = "2013-09-07",
  event = "2013 Federal Election",
  PollingPlaceID = c(93925.0, 11877.0),
  Latitude = c(-37.81, -33.87),
  Longitude = c(144.96, 151.21)
)
process_coords(data_2013, "2013 Federal Election")
#> Filling in missing coordinates for `2013 Federal Election` data, where possible.
#>         date                 event PollingPlaceID Latitude Longitude
#> 1 2013-09-07 2013 Federal Election          93925   -37.81    144.96
#> 2 2013-09-07 2013 Federal Election          11877   -33.87    151.21
```
