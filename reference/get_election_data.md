# Download and Process AEC Data

This function downloads and processes data from the Australian Electoral
Commission (AEC) based on user-specified criteria such as file name,
date range, election type, and data category. It retrieves raw data
files from the AEC, optionally applies standardisation processes (e.g.,
column name consistency), and returns a combined data frame for
analysis. The function is designed to handle various types of
election-related datasets, including federal elections, referendums, and
by-elections.

## Usage

``` r
get_election_data(
  file_name,
  date_range = list(from = "2025-01-01", to = "2026-01-01"),
  type = NULL,
  category = c("House", "Senate", "Referendum", "General", "Statistics"),
  process = TRUE,
  cache = TRUE
)
```

## Arguments

- file_name:

  A character string specifying the name of the AEC dataset to retrieve
  (e.g., "National list of candidates"). This name must match entries in
  the internal index datasets.

- date_range:

  A list with two elements, `"from"` and `"to"`, specifying the start
  and end dates (in "YYYY-MM-DD" format) for the election events to
  include. Defaults to `list(from = "2022-01-01", to = "2025-01-01")`.

- type:

  A character string specifying the type of election or event. Must be
  one of: "Federal Election", "Referendum", "By-Election", or
  "Disclosure". Defaults to the first option.

- category:

  A character string specifying the category of the data. Must be one
  of: "House", "Senate", "Referendum", "General", or "Statistics".
  Defaults to the first option.

- process:

  A logical value indicating whether to apply additional processing to
  the downloaded data, such as standardizing column names. Defaults to
  `TRUE`.

- cache:

  Logical. If TRUE (default), caches the downloaded and processed data
  for the session, making subsequent identical requests instant. Set to
  FALSE to always download fresh data.

## Value

A data frame containing the combined AEC data for the specified
criteria. The data frame includes metadata columns (e.g., `date`,
`event`) and is optionally processed for consistency if
`process = TRUE`. If no data is available for the given parameters, the
function stops with an informative error message.

## Details

The `get_election_data` function automates the retrieval and processing
of AEC datasets by:

1.  Validating input parameters to ensure correctness.

2.  Checking if the data is already cached (if `cache = TRUE`).

3.  Retrieving internal metadata about election events within the
    specified `date_range` and matching the `type`.

4.  Checking the availability of the requested `file_name` and
    `category` in the internal index datasets.

5.  Constructing download URLs and retrieving the raw data files from
    the AEC website.

6.  Optionally preprocessing postal vote data and standardizing column
    names.

7.  Combining data from multiple election events into a single data
    frame.

8.  Caching the result for future identical requests (if
    `cache = TRUE`).

The function relies on internal helper functions (e.g., `check_params`,
`construct_url`, `preprocess_pva`) and datasets (e.g., `info`,
`aec_elections_index`) within the `scgElectionsAU` package. It also uses
[`scgUtils::get_file`](https://rdrr.io/pkg/scgUtils/man/get_file.html)
for downloading files. The function is designed to be robust, providing
clear messages and errors to guide users through the data retrieval
process.

Use `clear_cache` to remove cached data when needed.

## See also

`clear_cache` to remove cached data

## Examples

``` r
if (FALSE) { # \dontrun{
  # Retrieve and process the national list of candidates for House elections in 2022
  # First call downloads from AEC
  data <- get_election_data(
    file_name = "National list of candidates",
    date_range = list(from = "2022-01-01", to = "2023-01-01"),
    type = "Federal Election",
    category = "House",
    process = FALSE
  )

  # Second identical call uses cache - instant!
  data2 <- get_election_data(
    file_name = "National list of candidates",
    date_range = list(from = "2022-01-01", to = "2023-01-01"),
    type = "Federal Election",
    category = "House",
    process = FALSE
  )

  # Clear cache when done (optional - clears automatically when session ends)
  clear_cache()
} # }
```
