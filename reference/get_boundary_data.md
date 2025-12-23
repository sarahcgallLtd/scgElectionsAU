# Retrieve Australian Bureau of Statistics (ABS) boundary data

Downloads and processes ABS boundary data (allocation or correspondence
files) for a specified reference year and geographic level from the
scgElectionsAU package. For the special case of 2011 SA1 correspondence
data, it handles multiple sheets from an Excel file and performs
additional data cleaning.

## Usage

``` r
get_boundary_data(
  ref_date,
  level = c("CED", "SED", "POA", "SA1", "MB"),
  type = c("allocation", "correspondence"),
  cache = TRUE
)
```

## Arguments

- ref_date:

  Numeric. The reference year for the boundary data. Must be between
  2011 and 2024, inclusive.

- level:

  Character. The geographic level of the boundary data. One of "CED"
  (Commonwealth Electoral Division), "SED" (State Electoral Division),
  "POA" (Postal Area), "SA1" (Statistical Area Level 1), or "MB" (Mesh
  Block). Defaults to "CED".

- type:

  Character. The type of boundary data. One of "allocation" or
  "correspondence". Defaults to "allocation".

- cache:

  Logical. If TRUE (default), caches the downloaded and processed data
  for the session, making subsequent identical requests instant. Set to
  FALSE to always download fresh data.

## Value

A data frame containing the boundary data for the specified parameters.
If multiple files are downloaded, they are combined into a single data
frame, provided they have identical column structures. For the 2011 SA1
correspondence data, additional cleaning is performed to ensure data
consistency.

## Details

This function retrieves boundary data by accessing the
`abs_boundary_index` dataset in the `scgElectionsAU` package, filtering
it based on the provided `ref_date`, `level`, and `type`. It then
downloads the corresponding files from the URLs listed in the index
using
[`scgUtils::get_file()`](https://rdrr.io/pkg/scgUtils/man/get_file.html).
If multiple files are retrieved, they are combined into a single data
frame using `rbind`. For the special case where `ref_date = 2011`,
`level = "SA1"`, and `type = "correspondence"`, the function downloads
multiple sheets from an Excel file (sheets 4 to 7), corrects a known
column name typo ("SA1_7DIGICODE_2011" to "SA1_7DIGITCODE_2011"), and
performs additional data cleaning steps, such as renaming columns (e.g.,
"CD_CODE_2006...2" to "CD_CODE_2006"), removing redundant columns (e.g.,
"CD_CODE_2006...1"), and removing rows with all NA values. The function
includes validation checks to ensure the parameters are valid and that
the downloaded data can be combined.

Use `clear_cache` to remove cached data when needed.

## See also

`clear_cache` to remove cached data

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve 2024 CED allocation data
ced_data <- get_boundary_data(ref_date = 2024, level = "CED", type = "allocation")

# Retrieve 2021 SA1 correspondence data (from 2016 to 2021)
sa1_data <- get_boundary_data(ref_date = 2021, level = "SA1", type = "correspondence")

# Retrieve 2011 SA1 correspondence data (special case)
sa1_2011_data <- get_boundary_data(ref_date = 2011, level = "SA1", type = "correspondence")

# Second call uses cache - instant!
sa1_2011_data2 <- get_boundary_data(ref_date = 2011, level = "SA1", type = "correspondence")
} # }
```
