# Convert 11-digit SA1 Maincode to 7-digit SA1 Code

This function takes a data frame containing an 11-digit SA1 Maincode and
converts it to the corresponding 7-digit SA1 Code as specified by the
Australian Bureau of Statistics ((as per ABS documentation:
https://www.abs.gov.au/ausstats/abs@.nsf/Latestproducts/7CAFD05E79EB6F81CA257801000C64CD?opendocument)).
The 7-digit code is created by concatenating the first digit and the
last six digits of the 11-digit maincode.

## Usage

``` r
amend_maincode(data, column_name)
```

## Arguments

- data:

  A data frame containing the SA1 Maincode column.

- column_name:

  A string specifying the name of the column in `data` that contains the
  11-digit SA1 Maincode.

## Value

The input data frame with an additional column named 'SA1_CODE_YYYY',
where 'YYYY' is extracted from the end of `column_name`, containing the
7-digit SA1 Code as a string value.

## Examples

``` r
# Assuming a data frame df with a column 'SA1_MAINCODE_2016' containing character strings
df <- data.frame(SA1_MAINCODE_2016 = c("12345678901", "23456789012"))
amended_df <- amend_maincode(df, "SA1_MAINCODE_2016")
# amended_df will have a new column 'SA1_CODE_2016' with values 1678901, 2789012, etc.
```
