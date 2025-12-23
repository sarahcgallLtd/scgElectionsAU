# List available ABS dataflows

Retrieves a list of all available dataflows from the ABS Data API.
Optionally filters to show only dataflows containing SA1 or CED level
data.

## Usage

``` r
list_abs_dataflows(filter = NULL, pattern = NULL)
```

## Arguments

- filter:

  Character or NULL. Filter to apply:

  - `NULL`: Return all dataflows

  - `"SA1"`: Return only dataflows with SA1 level data

  - `"CED"`: Return only dataflows with CED level data

  - `"census"`: Return only Census-related dataflows

- pattern:

  Character or NULL. Additional regex pattern to filter dataflow names.

## Value

A data frame with columns:

- `id`: Dataflow identifier to use with `get_abs_data`

- `name`: Human-readable description

## See also

`get_abs_data` to fetch data from a dataflow

## Examples

``` r
if (FALSE) { # \dontrun{
# List all dataflows
all_flows <- list_abs_dataflows()

# List only SA1 level dataflows
sa1_flows <- list_abs_dataflows("SA1")

# List only CED level dataflows
ced_flows <- list_abs_dataflows("CED")

# Search for SEIFA dataflows
seifa_flows <- list_abs_dataflows(pattern = "SEIFA")
} # }
```
