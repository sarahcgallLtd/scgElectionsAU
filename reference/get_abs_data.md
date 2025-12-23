# Retrieve data from the Australian Bureau of Statistics (ABS) Data API

Downloads data from the ABS Data API (SDMX RESTful web service) for
specified dataflows at SA1 or CED geographic levels. This provides
access to SEIFA indices, Census data, and other ABS datasets without
downloading large DataPack files.

## Usage

``` r
get_abs_data(
  dataflow,
  filter = NULL,
  start_period = NULL,
  end_period = NULL,
  cache = TRUE
)
```

## Arguments

- dataflow:

  Character. The dataflow identifier to query. Common options include:

  - `"ABS_SEIFA2021_SA1"`: SEIFA 2021 indices at SA1 level

  - `"ABS_SEIFA2016_SA1"`: SEIFA 2016 indices at SA1 level

  - `"C21_G01_CED"`: Census 2021 G01 (Selected person characteristics)
    at CED level

  - `"C21_G02_CED"`: Census 2021 G02 (Medians and averages) at CED level

  - `"ABS_CENSUS2011_B01_SA1_SA"`: Census 2011 B01 at SA1 level (SA
    only)

  Use `list_abs_dataflows` to see all available dataflows.

- filter:

  Character or NULL. Optional SDMX filter expression to subset the data.
  Use `"all"` or `NULL` for all data. Filter format depends on the
  dataflow structure - see ABS Data API documentation for details.

- start_period:

  Character or NULL. Start period for time series data (e.g., "2021").

- end_period:

  Character or NULL. End period for time series data (e.g., "2021").

- cache:

  Logical. If TRUE (default), caches the downloaded data for the
  session, making subsequent identical requests instant. Set to FALSE to
  always download fresh data.

## Value

A data frame containing the requested data with columns for each
dimension and the observation values.

## Details

This function queries the ABS Data API at
<https://data.api.abs.gov.au/rest/>. The API uses the SDMX (Statistical
Data and Metadata eXchange) standard, and data is parsed using the
`readsdmx` package.

Key points:

- SA1 and CED level data is available for select datasets (SEIFA, some
  Census tables)

- Not all Census tables are available via API - for full Census coverage
  at SA1 level, use `get_census_data` which downloads from DataPacks

- Large queries (e.g., SEIFA at SA1 level) may take time on first
  request; caching makes subsequent requests instant

Use `clear_cache` to remove cached data when needed.

## Available SA1 Dataflows

- SEIFA 2021 and 2016 indices

- Census 2011 Basic Community Profile tables (SA only)

## Available CED Dataflows

- Census 2021 General Community Profile tables (G01-G62)

## See also

`list_abs_dataflows` to discover available dataflows, `get_census_data`
for full Census DataPack access, `get_boundary_data` for boundary
correspondence files, `clear_cache` to remove cached data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get SEIFA 2021 data for all SA1s
seifa <- get_abs_data("ABS_SEIFA2021_SA1")

# Get Census 2021 G01 data for all CEDs
g01_ced <- get_abs_data("C21_G01_CED")

# Get data with time period filter
seifa_2021 <- get_abs_data("ABS_SEIFA2021_SA1",
                           start_period = "2021",
                           end_period = "2021")

# Second call uses cache - instant!
seifa_2021_again <- get_abs_data("ABS_SEIFA2021_SA1",
                                  start_period = "2021",
                                  end_period = "2021")
} # }
```
