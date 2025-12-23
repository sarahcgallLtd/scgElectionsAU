# A Guide to the ABS API Datasets

  
This guide explores the
[`get_abs_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_abs_data.html)
and
[`list_abs_dataflows`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/list_abs_dataflows.html)
functions in the `scgElectionsAU` package, designed to retrieve data
directly from the Australian Bureau of Statistics (ABS) Data API. These
functions provide access to SEIFA indices, Census data at CED
(Commonwealth Electoral Division) level, and other ABS datasets without
needing to download large DataPack files. See [the ABS Census Datasets
Guide](https://docs.sarahcgall.co.uk/scgElectionsAU/articles/a-guide-to-abs-census-datasets.md)
for SA1-level Census data retrieval.  

### Introduction to the ABS Data API

The Australian Bureau of Statistics provides a [Data
API](https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis/data-api-user-guide)
based on the SDMX (Statistical Data and Metadata eXchange) standard.
This RESTful web service allows programmatic access to a wide range of
ABS datasets without downloading large files.

The
[`get_abs_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_abs_data.html)
function provides a simple interface to query this API, with data parsed
using the `readsdmx` package. The API is particularly useful for:

- **SEIFA indices** at SA1 level (2011, 2016, 2021)
- **Census 2021 data** at CED (Commonwealth Electoral Division) and SED
  (State Electoral Division) levels
- **Census 2011 data** at SA1 level (South Australia only)
- Other ABS statistical datasets

### The `get_abs_data` Function

The
[`get_abs_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_abs_data.html)
function retrieves data from the ABS Data API by specifying a dataflow
identifier.

| Parameter      | Description                                     | Example Values                     |
|----------------|-------------------------------------------------|------------------------------------|
| `dataflow`     | The dataflow identifier to query.               | “ABS_SEIFA2021_SA1”, “C21_G01_CED” |
| `filter`       | Optional SDMX filter expression to subset data. | NULL, “all”                        |
| `start_period` | Optional start period for time series data.     | “2021”                             |
| `end_period`   | Optional end period for time series data.       | “2021”                             |

### The `list_abs_dataflows` Function

The
[`list_abs_dataflows`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/list_abs_dataflows.html)
function helps discover available dataflows from the ABS API.

| Parameter | Description                                        | Valid Options                |
|-----------|----------------------------------------------------|------------------------------|
| `filter`  | Filter dataflows by geographic level or type.      | NULL, “SA1”, “CED”, “census” |
| `pattern` | Additional regex pattern to search dataflow names. | “SEIFA”, “income”, etc.      |

#### *Example: Finding Available Dataflows*

``` r
# List all SA1-level dataflows
sa1_flows <- list_abs_dataflows("SA1")
head(sa1_flows)
#>                            id
#> 162 ABS_CENSUS2011_B01_SA1_SA
#> 165 ABS_CENSUS2011_B02_SA1_SA
#> 168 ABS_CENSUS2011_B03_SA1_SA
#> 171 ABS_CENSUS2011_B04_SA1_SA
#> 174 ABS_CENSUS2011_B05_SA1_SA
#> 177 ABS_CENSUS2011_B06_SA1_SA
#>                                                             name
#> 162                 B01 Selected Person Characteristics (SA1 SA)
#> 165                   B02 Selected Medians and Averages (SA1 SA)
#> 168 B03 Place of Usual Residence on Census Night by Sex (SA1 SA)
#> 171                                      B04 Age by Sex (SA1 SA)
#> 174         B05 Registered Marital Status by Age by Sex (SA1 SA)
#> 177             B06 Social Marital Status by Age by Sex (SA1 SA)

# List all CED-level dataflows
ced_flows <- list_abs_dataflows("CED")
head(ced_flows)
#>                        id
#> 386       ABS_LABOUR_ACCT
#> 387 ABS_LABOUR_ACCT_UNBAL
#> 475           C21_G01_CED
#> 481           C21_G01_SED
#> 484           C21_G02_CED
#> 490           C21_G02_SED
#>                                                                                                                name
#> 386                       Labour Account Australia, Annual Balanced: Subdivision, Division and Total All Industries
#> 387                                               Labour Account Australia, Annual Unbalanced: Total All Industries
#> 475 Census 2021, G01 Selected person characteristics by sex, Commonwealth Electoral Divisions (CED 2021 boundaries)
#> 481        Census 2021, G01 Selected person characteristics by sex, State Electoral Divisions (SED 2021 boundaries)
#> 484          Census 2021, G02 Selected medians and averages, Commonwealth Electoral Divisions (CED 2021 boundaries)
#> 490                 Census 2021, G02 Selected medians and averages, State Electoral Divisions (SED 2021 boundaries)

# Search for SEIFA dataflows
seifa_flows <- list_abs_dataflows(pattern = "SEIFA")
print(seifa_flows)
#>                     id                                       name
#> 410  ABS_SEIFA2016_LGA  SEIFA 2016 by Local Government Area (LGA)
#> 411  ABS_SEIFA2016_POA             SEIFA 2016 by Postal Area Code
#> 412  ABS_SEIFA2016_SA1     SEIFA 2016 by Statistical Area 1 (SA1)
#> 413  ABS_SEIFA2016_SA2           SEIFA 2016 by Statistical Area 2
#> 414  ABS_SEIFA2016_SSC            SEIFA 2016 by State Suburb Code
#> 415  ABS_SEIFA2021_LGA  SEIFA 2021 by Local Government Area (LGA)
#> 416  ABS_SEIFA2021_POA       SEIFA 2021 by Postal Area Code (POA)
#> 417  ABS_SEIFA2021_SA1     SEIFA 2021 by Statistical Area 1 (SA1)
#> 418  ABS_SEIFA2021_SA2     SEIFA 2021 by Statistical Area 2 (SA2)
#> 419  ABS_SEIFA2021_SAL SEIFA 2021 by Suburbs and Localities (SAL)
#> 420      ABS_SEIFA_LGA  SEIFA 2011 by Local Government Area (LGA)
#> 421      ABS_SEIFA_SA2     SEIFA 2011 by Statistical Area 2 (SA2)
#> 422      ABS_SEIFA_SLA SEIFA 2011 by Statistical Local Area (SLA)
#> 1211         SEIFA_POA       SEIFA 2011 by Postal Area Code (POA)
#> 1212         SEIFA_SA1     SEIFA 2011 by Statistical Area 1 (SA1)
#> 1213         SEIFA_SSC      SEIFA 2011 by State Suburb Code (SSC)
```

  

### API vs DataPacks: When to Use Each

The ABS provides data through two main channels, each with advantages:

| Feature          | API (`get_abs_data`)          | DataPacks (`get_census_data`) |
|------------------|-------------------------------|-------------------------------|
| **Data Format**  | Direct API query              | Download ZIP file             |
| **Speed**        | Fast for small queries        | Initial download slow, cached |
| **SA1 Coverage** | Limited (SEIFA, 2011 SA only) | Complete (all tables)         |
| **CED Coverage** | Complete (Census 2021)        | Not available                 |
| **Best For**     | CED-level Census, SEIFA       | Full SA1-level Census         |

**Recommendation:** \* Use
[`get_abs_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_abs_data.md)
for CED-level Census data and SEIFA indices \* Use
[`get_census_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.md)
for comprehensive SA1-level Census data

  

## SEIFA (Socio-Economic Indexes for Areas)

SEIFA is a suite of four indexes that summarise different aspects of
socio-economic conditions. Each index ranks areas from most
disadvantaged to most advantaged based on Census data.

### Available SEIFA Dataflows

| Dataflow ID         | Description        | Geographic Level |
|---------------------|--------------------|------------------|
| `ABS_SEIFA2021_SA1` | SEIFA 2021 indices | SA1              |
| `ABS_SEIFA2016_SA1` | SEIFA 2016 indices | SA1              |
| `SEIFA_SA1`         | SEIFA 2011 indices | SA1              |

### SEIFA Index Types

The SEIFA data includes four different indexes:

- **IRSD (Index of Relative Socio-economic Disadvantage):** Summarises
  variables related to disadvantage only (e.g., low income,
  unemployment, no qualifications)
- **IRSAD (Index of Relative Socio-economic Advantage and
  Disadvantage):** Summarises variables related to both advantage and
  disadvantage
- **IER (Index of Economic Resources):** Summarises variables related to
  economic resources (income, housing costs, assets)
- **IEO (Index of Education and Occupation):** Summarises variables
  related to education and occupation

### SEIFA Measures

Each index provides several measures:

- **SCORE:** The actual index score (mean of 1000, standard deviation of
  100)
- **RWSR:** Rank within State/Territory
- **RWAR:** Rank within Australia
- **RWSP:** Percentile within State/Territory
- **RWAP:** Percentile within Australia
- **RWSD:** Decile within State/Territory
- **RWAD:** Decile within Australia
- **URP:** Usual Resident Population

#### *Example: Retrieving SEIFA 2021 Data*

``` r
# Get SEIFA 2021 data for all SA1s
# Note: This is a large dataset and may take time
seifa_2021 <- get_abs_data("ABS_SEIFA2021_SA1")
```

| INDEX_TYPE | MEASURE | OBS_STATUS | ObsDimension | ObsValue |   SEIFA_SA1 | UNIT_MEASURE |
|:-----------|:--------|:-----------|-------------:|---------:|------------:|:-------------|
| IEO        | URP     | NA         |         2021 |      152 | 10402108614 | PSNS         |
| IEO        | RWAD    | NA         |         2021 |        7 | 40104101425 | RANK_DC      |
| IRSAD      | RWSD    | NA         |         2021 |       10 | 20804119401 | RANK_DC      |
| IRSAD      | SCORE   | NA         |         2021 |     1162 | 20902120502 | SCORE        |

``` r
# Filter for IRSD scores only
irsd_scores <- seifa_2021[seifa_2021$INDEX_TYPE == "IRSD" &
                           seifa_2021$MEASURE == "SCORE", ]
```

| INDEX_TYPE | MEASURE | OBS_STATUS | ObsDimension | ObsValue |   SEIFA_SA1 | UNIT_MEASURE |
|:-----------|:--------|:-----------|-------------:|---------:|------------:|:-------------|
| IRSD       | SCORE   | NA         |         2021 |      980 | 11102121517 | SCORE        |
| IRSD       | SCORE   | NA         |         2021 |     1053 | 40304108006 | SCORE        |
| IRSD       | SCORE   | NA         |         2021 |      992 | 30907125329 | SCORE        |
| IRSD       | SCORE   | NA         |         2021 |       NA | 60401107706 | SCORE        |

  

## Census 2021 at CED Level

The ABS API provides Census 2021 data at Commonwealth Electoral Division
(CED) level through a comprehensive set of tables. This is particularly
useful for analysing demographic characteristics of federal electorates.

### Available Census 2021 CED Dataflows

The Census 2021 CED dataflows follow the naming pattern `C21_G##_CED`,
where `##` is the table number (01-62). Key tables include:

| Dataflow ID   | Table | Description                                  |
|---------------|-------|----------------------------------------------|
| `C21_G01_CED` | G01   | Selected person characteristics by sex       |
| `C21_G02_CED` | G02   | Selected medians and averages                |
| `C21_G04_CED` | G04   | Age by sex                                   |
| `C21_G07_CED` | G07   | Indigenous status by age by sex              |
| `C21_G09_CED` | G09   | Country of birth by age by sex               |
| `C21_G14_CED` | G14   | Religious affiliation by sex                 |
| `C21_G17_CED` | G17   | Total personal income (weekly) by age by sex |
| `C21_G19_CED` | G19   | Long-term health conditions by age by sex    |
| `C21_G46_CED` | G46   | Labour force status by age by sex            |

Note: State Electoral Division (SED) data is also available using the
pattern `C21_G##_SED`.

#### *Example: Retrieving Census 2021 CED Data*

``` r
# Get G01 (Selected Person Characteristics) for all CEDs
g01_ced <- get_abs_data("C21_G01_CED")
```

#### *Sample Data:*

| ObsDimension | ObsValue | PCHAR | REGION | REGION_TYPE | SEXP | STATE |
|-------------:|---------:|:------|-------:|:------------|-----:|------:|
|         2021 |    78145 | P_1   |    143 | CED         |    2 |     1 |
|         2021 |        0 | P_1   |    197 | CED         |    1 |     1 |
|         2021 |    89519 | P_1   |    310 | CED         |    2 |     3 |
|         2021 |    75739 | P_1   |    316 | CED         |    1 |     3 |

  

### Understanding CED Data Structure

The CED data includes several dimension columns:

- **REGION:** The CED code (numeric identifier)
- **REGION_TYPE:** Always “CED” for these dataflows
- **STATE:** State/Territory code (1=NSW, 2=VIC, 3=QLD, etc.)
- **ObsDimension:** The time period (e.g., 2021)
- **ObsValue:** The data value
- Other dimensions vary by table (e.g., SEXP for sex, PCHAR for person
  characteristics)

  

## Census 2011 at SA1 Level (South Australia)

The ABS API provides Census 2011 Basic Community Profile (BCP) tables at
SA1 level, but only for South Australia. These follow the naming pattern
`ABS_CENSUS2011_B##_SA1_SA`.

### Available Census 2011 SA1 Dataflows

| Dataflow ID                 | Table | Description                     |
|-----------------------------|-------|---------------------------------|
| `ABS_CENSUS2011_B01_SA1_SA` | B01   | Selected person characteristics |
| `ABS_CENSUS2011_B02_SA1_SA` | B02   | Selected medians and averages   |
| `ABS_CENSUS2011_B04_SA1_SA` | B04   | Age by sex                      |
| `ABS_CENSUS2011_B07_SA1_SA` | B07   | Indigenous status by age by sex |
| …                           | …     | (Tables B01-B46 available)      |

**Note:** For complete SA1-level Census data across all states, use
[`get_census_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.html)
instead.

#### *Example: Retrieving Census 2011 SA1 Data*

``` r
# Get B01 (Selected Person Characteristics) for SA1s in South Australia
b01_sa1 <- get_abs_data("ABS_CENSUS2011_B01_SA1_SA")
```

  

## Performance Considerations

### Large Datasets

Some dataflows contain large amounts of data:

- **SEIFA SA1 datasets:** ~60,000 SA1s x 4 indexes x 8 measures = ~1.9
  million rows
- **CED datasets:** ~151 CEDs x variables = typically 1,000-10,000 rows

For large SA1-level queries, the API may timeout. In these cases:

1.  Use the `filter` parameter to subset data
2.  Use
    [`get_census_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.html)
    for comprehensive SA1 Census data

### Filtering Data

The `filter` parameter accepts SDMX filter expressions. The exact format
depends on the dataflow structure.

``` r
# Example: Filter by specific dimension values
# Note: Filter syntax varies by dataflow
data <- get_abs_data("C21_G02_CED", filter = "all")
```

  

## Quick Reference: Common Use Cases

### Get SEIFA Scores for SA1s

``` r
# SEIFA 2021
seifa_2021 <- get_abs_data("ABS_SEIFA2021_SA1")

# SEIFA 2016
seifa_2016 <- get_abs_data("ABS_SEIFA2016_SA1")
```

### Get Census Demographics for Electorates

``` r
# Age and sex distribution
age_sex <- get_abs_data("C21_G04_CED")

# Indigenous status
indigenous <- get_abs_data("C21_G07_CED")

# Country of birth
birthplace <- get_abs_data("C21_G09_CED")

# Religious affiliation
religion <- get_abs_data("C21_G14_CED")
```

### Get Socioeconomic Data for Electorates

``` r
# Medians and averages (income, rent, mortgage)
medians <- get_abs_data("C21_G02_CED")

# Personal income distribution
income <- get_abs_data("C21_G17_CED")

# Labour force status
employment <- get_abs_data("C21_G46_CED")
```

  

## Additional Resources

For more information about the ABS Data API:

- [ABS Data API User
  Guide](https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis/data-api-user-guide)
- [SDMX Standard](https://sdmx.org/)
- [readsdmx R Package](https://github.com/mdequeljoe/readsdmx)

For Census data documentation:

- [Census 2021
  Dictionary](https://www.abs.gov.au/census/guide-census-data/census-dictionary/2021)
- [SEIFA Technical
  Paper](https://www.abs.gov.au/statistics/people/people-and-communities/socio-economic-indexes-areas-seifa-australia/latest-release)
- [Australian Statistical Geography Standard
  (ASGS)](https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3)

  
