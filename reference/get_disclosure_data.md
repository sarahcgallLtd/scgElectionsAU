# Retrieve Disclosure Data from AEC's Transparency Register

This function downloads and retrieves specific datasets from the
Australian Electoral Commission's (AEC) Transparency Register. The
register contains financial disclosure information from political
entities, including annual returns, election returns, and referendum
returns.

## Usage

``` r
get_disclosure_data(
  file_name = NULL,
  group = NULL,
  type = c("Annual", "Election", "Referendum"),
  cache = TRUE
)
```

## Arguments

- file_name:

  The file name of the data to retrieve. If `file_name` is not
  specified, it defaults to "Donations Made". Must be one of: "Capital
  Contributions", "Debts", "Discretionary Benefits", "Donations Made",
  "Donations Received", "Expenses", "Media Advertisement Details",
  "Receipts", "Return Summary", "Returns".

- group:

  The group of the entity. If not specified, it defaults to "Donor".
  Must be one of: "Associated Entity", "Candidate", "Donor", "Media",
  "MPs", "Other", "Party", "Referendum Entity", "Significant Third
  Party", "Third Party".

- type:

  The type of return. Defaults to "Annual". Must be one of: "Annual",
  "Election", "Referendum".

- cache:

  Logical. If TRUE (default), caches the downloaded data for the
  session, making subsequent identical requests instant. Set to FALSE to
  always download fresh data.

## Value

A data frame containing the requested disclosure data.

## Details

Use `clear_cache` to remove cached data when needed.

## See also

`clear_cache` to remove cached data,
<https://www.aec.gov.au/parties_and_representatives/financial_disclosure/>
for more information on the AEC's financial disclosure scheme.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Retrieve default data: Donations Made by Donors for Annual returns
  data <- get_disclosure_data()

  # Retrieve specific data: Receipts for Parties in Election returns
  data <- get_disclosure_data(file_name = "Receipts", group = "Party", type = "Election")

  # Second identical call uses cache - instant!
  data2 <- get_disclosure_data(file_name = "Receipts", group = "Party", type = "Election")
} # }
```
