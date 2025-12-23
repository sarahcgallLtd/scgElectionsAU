# Retrieve Australian Bureau of Statistics (ABS) Census data

Downloads and processes ABS Census DataPack files for a specified Census
year and table number. Census DataPacks contain comprehensive
demographic, social, and economic data at SA1 geographic level for all
of Australia.

## Usage

``` r
get_census_data(census_year, table, cache = TRUE)
```

## Arguments

- census_year:

  Numeric. The Census year. Must be one of 2011, 2016, or 2021.

- table:

  Character. The table number to retrieve (e.g., "G01", "G02"). See
  `abs_census_table` for a list of available tables and their
  descriptions.

- cache:

  Logical. If TRUE (default), caches the downloaded DataPack ZIP file
  for the session, making subsequent requests for other tables from the
  same Census year much faster. Set to FALSE to always download fresh.

## Value

A data frame containing the Census data for the specified table at SA1
level.

## Details

This function retrieves Census data from ABS DataPacks, which are ZIP
archives containing CSV files with Census data at SA1 geographic level.
The function:

1.  Validates input parameters

2.  Downloads the DataPack ZIP (or uses cached version if available)

3.  Extracts the specified table from the ZIP archive

Note that:

- 2021 and 2016 Census use General Community Profile (GCP) tables (G01,
  G02, etc.)

- 2011 Census uses Basic Community Profile (BCP) tables (B01, B02, etc.)

- DataPacks are large (100-400MB), so the first download takes time

- With `cache = TRUE`, subsequent table requests are fast

- Use `clear_cache` to remove cached files if needed

## See also

`abs_census_tables` for table descriptions, `clear_cache` to remove
cached files, `get_boundary_data` for boundary correspondence files

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve table G01 (Selected Person Characteristics) for 2021
# First call downloads the DataPack (~380MB)
g01 <- get_census_data(census_year = 2021, table = "G01")

# Second call uses cached ZIP - much faster!
g02 <- get_census_data(census_year = 2021, table = "G02")

# Retrieve 2016 Census data
g01_2016 <- get_census_data(census_year = 2016, table = "G01")

# Retrieve 2011 Census data (uses B prefix)
b01_2011 <- get_census_data(census_year = 2011, table = "B01")

# Clear cached files when done (optional - clears automatically when session ends)
clear_cache()
} # }
```
