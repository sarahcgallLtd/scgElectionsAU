# A Guide to the ABS's Boundary Datasets

  
This guide explores the
[`get_boundary_data`](https://docs.sarahcgallLtd.co.uk/scgElectionsAU/reference/get_boundary_data.html)
and
[`prepare_boundaries`](https://docs.sarahcgallLtd.co.uk/scgElectionsAU/reference/prepare_boundaries.html)
function. These functions simplify retrieving boundary datasets from the
Australian Bureau of Statistics (ABS) including correspondence tables
and allocation files with specific boundary types like Commonwealth
Electoral Divisions (CED), State Electoral Divisions (SED), and Postal
Areas (POA). These datasets enable users to align election results
across changing boundaries and integrate demographic data, supporting
research into voting trends and voter demographics. Below, we detail the
function’s parameters, available datasets, practical usage examples, and
the context of ABS boundary data.  

### Introduction to ABS Boundary Datasets

The ABS provides boundary datasets as part of the Australian Statistical
Geography Standard (ASGS), a framework for collecting and disseminating
statistical data across geographic areas (ABS ASGS). These datasets are
essential for electoral analysis, as electoral boundaries, such as CEDs,
change periodically due to population shifts and redistributions. The
`get_boundary_data` function streamlines access to these datasets,
allowing users to retrieve correspondence tables for converting data
between Census years, allocation tables for mapping smaller areas to
larger ones, and specific boundary definitions for electoral and postal
areas. This guide explains how to use these datasets effectively, their
importance in electoral studies, and how to handle nuances like boundary
changes over time.

### Why Boundary Datasets Matter

Electoral boundaries evolve, making it challenging to compare election
results across different years. For example, a division’s boundaries in
2013 may differ significantly from those in 2025. Correspondence tables
help adjust historical election results to current boundaries, enabling
consistent trend analysis. Allocation tables map smaller areas, like
Statistical Area Level 1 (SA1) or Mesh Blocks (MB), to larger electoral
divisions, facilitating data aggregation or mapping. Additionally,
datasets like POA allocations allow for converting election data to
postal codes, useful for campaign targeting. By integrating these
datasets with Australian Electoral Commission (AEC) election data,
researchers can analyse voting patterns alongside demographic factors
like income or education from the Census.

### The `get_boundary_data` Function

The `get_boundary_data` function retrieves ABS boundary datasets,
leveraging internal metadata to map parameters to specific files. It
downloads data from ABS servers, typically in Excel or CSV format, and
returns a data frame. Users can specify the dataset by reference date
(`ref_date`), geographic level (`level`), and data type (`type`), with
options to retrieve raw or processed data. This function is particularly
useful for aligning AEC election data, often provided at the SA1 level,
with electoral boundaries that may be defined using MBs or other units.

| Parameters | Description                  | Default      | Valid Options                                                                  |
|------------|------------------------------|--------------|--------------------------------------------------------------------------------|
| `ref_date` | Year of the boundary dataset | None         | 2011, 2013, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2024 (varies by `level`) |
| `level`    | Geographic or boundary level | “CED”        | “SA1”, “MB”, “CED”, “SED”, “POA”                                               |
| `type`     | Type of dataset              | “allocation” | “correspondence”, “allocation”                                                 |

#### Dataset Types

- **Correspondence Tables:** Convert data between different boundary
  sets or Census years (e.g., 2011 SA1 to 2016 SA1), providing
  proportional allocations based on population or area overlap.
- **Allocation Tables:** Assign smaller geographic units (e.g., SA1, MB)
  to larger ones (e.g., CED, SED), indicating which larger area each
  smaller unit belongs to.

  

#### Key Considerations

- **Boundary Changes:** CEDs and SEDs switched from SA1-based to
  MB-based allocations in 2021, requiring MB to SA1 allocation tables
  for consistency with AEC data.
- **Supplementary Data:** For accurate 2022 and 2025 election analyses,
  incorporate AEC redistribution data for Victoria, Western Australia,
  and the Northern Territory.
- **Data Availability:** Not all years are available for all boundary
  types; verify availability below.

### Understanding Correspondence and Allocation Tables

#### Correspondence Tables

Correspondence tables facilitate data conversion between different
geographic boundaries or between the same boundary type across Census
years. They provide ratios indicating how much of one area overlaps with
another. For electoral analysis, these tables are critical for adjusting
historical election results to current boundaries. For example, to
compare 2013 election results with 2016 boundaries, you need the 2011
SA1 correspondence table to convert 2006 Collection Districts (CD) to
2011 SA1s, aligning with 2013 CEDs.

*Use Case:* Convert 2016 election results from 2011 SA1s to 2021 SA1s to
match 2024 CED boundaries for trend analysis.

#### Allocation Tables

Allocation tables assign smaller geographic units to larger ones, such
as mapping SA1s to CEDs or MBs to SEDs. These tables are essential for
aggregating election data or determining which electoral division a
specific area belongs to. For instance, an SA1 to CED allocation table
lists which CED each SA1 is part of, based on its geographic centroid or
majority overlap.

*Use Case:* Identify all SA1s within a specific CED to analyse
demographic characteristics using Census data.

### Available Datasets and Examples

The following sections detail the datasets available through
`get_boundary_data`, including their coverage, key columns, and
practical usage usage examples. Each section includes sample data to
illustrate the dataset’s structure.

## Main Structure and Greater Capital City Statistical Areas

### Correspondence Tables

Correspondence tables convert data between Census years, enabling
alignment of election results with changing statistical areas. They are
available for SA1 and MB levels, covering transitions like 2006 CD to
2011 SA1, 2011 SA1 to 2016 SA1, and 2016 SA1 to 2021 SA1.

*Usage:* Adjust historical election results to current boundaries or
align Census data with electoral divisions.

- *2013 Election results*: the AEC provides count data per 2006 CD,
  meaning the 2011 SA1 correspondence table is needed to convert from
  2006 CDs to 2011 SA1s and thus to be in line with the 2011 Census data
  and the ABS’s 2013 CEDs.
- *2016 Election results*: the AEC provides count data per 2011 SA1,
  meaning the 2016 SA1 correspondence table is needed to convert from
  2011 SA1s to 2016 SA1s and thus to be in line with the 2016 Census
  data and the ABS’s 2016 CEDs.
- *2019 and 2022 Election results*: the AEC provides count data per 2016
  SA1, meaning the 2021 SA1 correspondence table is needed to convert
  from 2016 SA1s to 2021 SA1s and thus to be in line with the most
  recent Census and to be able to convert election results into the
  ABS’s 2024 CEDs (current boundaries used for the 2025 election).

#### *Example Usage (2006 CD -\> 2011 SA1):*

``` r
df <- get_boundary_data(
  ref_date = 2011,
  level = "SA1",
  type = "correspondence"
)
```

#### *Sample Data (2006 CD -\> 2011 SA1):*

|     | CD_CODE_2006 | SA1_7DIGITCODE_2011 | SA1_MAINCODE_2011 | RATIO_FROM_TO |
|:----|-------------:|--------------------:|------------------:|--------------:|
| 2   |      1010101 |             1117908 |       10902117908 |     0.5789474 |

#### *Example Usage (2011 -\> 2016):*

``` r
df <- get_boundary_data(
  ref_date = 2016,
  level = "SA1", # OR "MB"
  type = "correspondence"
)
```

#### *Sample Data (2011 SA1 -\> 2016 SA1):*

|     | SA1_MAINCODE_2011 | SA1_7DIGITCODE_2011 | SA1_MAINCODE_2016 | SA1_7DIGITCODE_2016 | RATIO_FROM_TO |
|:----|:------------------|--------------------:|------------------:|--------------------:|--------------:|
| 2   | 10101100101       |             1100101 |       10105153965 |             1153965 |             1 |

#### *Sample Data (2011 MB -\> 2016 MB):*

|     | MB_CODE_2011 | MB_CODE_2016 | RATIO_FROM_TO |
|:----|-------------:|-------------:|--------------:|
| 2   |  80000010000 |  80000010000 |             1 |

#### *Example Usage (2016 -\> 2021):*

``` r
df <- get_boundary_data(
  ref_date = 2021,
  level = "SA1", # OR "MB"
  type = "correspondence"
)
```

#### *Sample Data (2016 SA1 -\> 2021 SA1):*

| SA1_MAINCODE_2016 | SA1_CODE_2021 | RATIO_FROM_TO | INDIV_TO_REGION_QLTY_INDICATOR | OVERALL_QUALITY_INDICATOR | BMOS_NULL_FLAG |
|------------------:|:--------------|--------------:|:-------------------------------|:--------------------------|---------------:|
|       10102100701 | 10102100701   |             1 | Good                           | Good                      |              0 |

#### *Sample Data (2016 MB -\> 2021 MB):*

| MB_CODE_2016 | MB_CODE_2021 | RATIO_FROM_TO | INDIV_TO_REGION_QLTY_INDICATOR | OVERALL_QUALITY_INDICATOR | BMOS_NULL_FLAG |
|-------------:|:-------------|--------------:|:-------------------------------|:--------------------------|---------------:|
|  10000009499 | 10000009499  |             1 | Good                           | Good                      |              0 |

  

### Allocation

Allocation tables map smaller geographic units (SA1, MB) to larger ones,
such as SA1 to STATE or MB to SA1, facilitating data aggregation and
boundary identification.

#### *Example Usage:*

``` r
df <- get_boundary_data(
  ref_date = 2021, # OR 2011, 2016
  level = "MB", # OR "SA1"
  type = "allocation" # = default
)
```

#### *Sample Data (2021 MB):*

| MB_CODE_2021 | MB_CATEGORY_2021 | CHANGE_FLAG_2021 | CHANGE_LABEL_2021 | SA1_CODE_2021 | SA2_CODE_2021 | SA2_NAME_2021 | SA3_CODE_2021 | SA3_NAME_2021 | SA4_CODE_2021 | SA4_NAME_2021 | GCCSA_CODE_2021 | GCCSA_NAME_2021 | STATE_CODE_2021 | STATE_NAME_2021 | AUS_CODE_2021 | AUS_NAME_2021 | AREA_ALBERS_SQKM | ASGS_LOCI_URI_2021                                         |
|:-------------|:-----------------|-----------------:|:------------------|:--------------|:--------------|:--------------|:--------------|:--------------|:--------------|:--------------|:----------------|:----------------|:----------------|:----------------|:--------------|:--------------|-----------------:|:-----------------------------------------------------------|
| 10000010000  | Residential      |                0 | No change         | 10901117207   | 109011172     | Albury - East | 10901         | Albury        | 109           | Murray        | 1RNSW           | Rest of NSW     | 1               | New South Wales | AUS           | Australia     |           0.0209 | <http://linked.data.gov.au/dataset/asgsed3/MB/10000010000> |

#### *Sample Data (2021 SA1):*

| SA1_CODE_2021 | CHANGE_FLAG_2021 | CHANGE_LABEL_2021 | SA2_CODE_2021 | SA2_NAME_2021 | SA3_CODE_2021 | SA3_NAME_2021 | SA4_CODE_2021 | SA4_NAME_2021  | GCCSA_CODE_2021 | GCCSA_NAME_2021 | STATE_CODE_2021 | STATE_NAME_2021 | AUS_CODE_2021 | AUS_NAME_2021 | AREA_ALBERS_SQKM | ASGS_LOCI_URI_2021                                          |
|:--------------|-----------------:|:------------------|:--------------|:--------------|:--------------|:--------------|:--------------|:---------------|:----------------|:----------------|:----------------|:----------------|:--------------|:--------------|-----------------:|:------------------------------------------------------------|
| 10102100701   |                0 | No change         | 101021007     | Braidwood     | 10102         | Queanbeyan    | 101           | Capital Region | 1RNSW           | Rest of NSW     | 1               | New South Wales | AUS           | Australia     |         362.8727 | <http://linked.data.gov.au/dataset/asgsed3/SA1/10102100701> |

  

## Non ABS Structures

Non-ABS Structures include CED, SED, and POA, which are approximations
of official boundaries used for statistical purposes.

### CED

CEDs are ABS approximations of AEC federal electoral boundaries, used
for the House of Representatives. Prior to 2021, CEDs were constructed
from SA1s; since 2021, they use MBs, requiring MB to SA1 allocation
tables for consistency with AEC data.

***CED Release Notes:***

| Year | Release Date    | Details                                                                                                                                                                                                                 |
|------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2011 | July 2011       | Aligned with 2011 Census boundaries.                                                                                                                                                                                    |
| 2013 | July 2012       | Included SA redistribution (13 March 2012). Used for 2013 Federal Election (7 September 2013).                                                                                                                          |
| 2016 | July 2016       | Aligned with 2016 Census boundaries. Used for 2016 Federal Election (2 July 2016).                                                                                                                                      |
| 2017 | 31 October 2017 | Included redistributions in NSW (25 February 2016), WA (19 January 2016), ACT (28 January 2016).                                                                                                                        |
| 2018 | 20 August 2018  | Included redistributions in Qld (27 March 2018), Vic (13 July 2018), ACT (13 July 2018), SA (20 July 2018), NT (27 March 2018), Tas (14 November 2017). Used for 2019 Federal Election (18 May 2019).                   |
| 2021 | 20 July 2021    | Aligned with 2021 Census boundaries, switched to MB-based allocations. Used for 2022 Federal Election (21 May 2022). Excludes Vic (26 July 2021) and WA (2 August 2021) redistributions.                                |
| 2024 | December 2024   | Included redistributions in NSW (27 November 2024), Vic (26 July 2021, 27 November 2024), WA (2 August 2021, 27 November 2024). Used for 2025 Federal Election (3 May 2025). Excludes NT redistribution (26 March 2025) |

#### *Example Usage:*

``` r
df <- get_boundary_data(
  ref_date = 2024, # OR 2011, 2013, 2016, 2017, 2018, 2021
  level = "CED" # = default
)
```

#### *Sample Data (2024):*

| MB_CODE_2021 | CED_CODE_2024 | CED_NAME_2024 | STATE_CODE_2021 | STATE_NAME_2021 | AUS_CODE_2021 | AUS_NAME_2021 | AREA_ALBERS_SQKM | ASGS_LOCI_URI_2021                                          |
|:-------------|:--------------|:--------------|:----------------|:----------------|:--------------|:--------------|-----------------:|:------------------------------------------------------------|
| 10396560000  | 101           | Banks         | 1               | New South Wales | AUS           | Australia     |           0.0257 | <https://linked.data.gov.au/dataset/asgsed3/MB/10396560000> |

#### *Sample Data (2018):*

| SA1_MAINCODE_2016 | CED_CODE_2018 | CED_NAME_2018 | STATE_CODE_2016 | STATE_NAME_2016 | AREA_ALBERS_SQKM |
|------------------:|--------------:|:--------------|----------------:|:----------------|-----------------:|
|       11904137920 |           101 | Banks         |               1 | New South Wales |           0.0452 |

***Supplementary Data:*** For accurate 2022 and 2025 election analyses,
incorporate AEC redistribution data:

- *2022 Election:* Use Vic (Vic Redistribution) and WA (WA
  Redistribution) SA1 to CED mappings to update the 2021 CED product.
- *2025 Election:* Use NT (NT Redistribution) SA1 to CED mappings to
  update the 2024 CED product until the 2025 CEDs are released (22 July
  2025).

To retrieve these datasets, use the `get_file` in the `scgUtils`
package:

``` r
url <- "https://www.aec.gov.au/redistributions/2021/vic/final-report/files/vic-by-SA2-and-SA1.xlsx"
Vic <- scgUtils::get_file(url, source = "web")
```

| SA1 code (2016 SA1s) | New electoral division from 26 July 2021 | Old electoral division as at 15 July 2020 | SA2 Name (2016 SA2s) | Actual enrolment 15/7/2020 | Projected enrolment 26/1/2025 |
|:---------------------|:-----------------------------------------|:------------------------------------------|:---------------------|---------------------------:|------------------------------:|
| 2100101              | Ballarat                                 | Ballarat                                  | Alfredton            |                        306 |                           390 |

``` r
url <- "https://www.aec.gov.au/redistributions/2021/wa/final-report/files/wa-by-SA2-and-SA1.xlsx"
WA <- scgUtils::get_file(url, source = "web")
```

| SA1 code (2016 SA1s) | New electoral division from 2 August 2021 | Old electoral division as at 15 July 2020 | SA2 Name (2016 SA2s) | Actual enrolment 15/7/2020 | Projected enrolment 2/2/2025 |
|:---------------------|:------------------------------------------|:------------------------------------------|:---------------------|---------------------------:|-----------------------------:|
| 5118501              | Brand                                     | Brand                                     | Baldivis             |                          1 |                            1 |

``` r
url <- "https://www.aec.gov.au/redistributions/2024/nt/final-report/files/Northern-Territory-electoral-divisions-SA1-and-SA2.xlsx"
NT <- scgUtils::get_file(url, source = "web")
```

| New Electoral Division from 4 March 2025 | Old electoral division as at Thursday 22 February 2024 | Statistical Area Level 2 (SA2) Name (2021 SA2s) | Statistical Area Level 1 (SA1) Code (7-digit) (2021 SA1s) | Actual enrolments Thursday 22 February 2024 | Projected enrolment Monday 4 September 2028 |
|:-----------------------------------------|:-------------------------------------------------------|:------------------------------------------------|:----------------------------------------------------------|--------------------------------------------:|--------------------------------------------:|
| LINGIARI                                 | LINGIARI                                               | Berrimah                                        | 7101203                                                   |                                         159 |                                         226 |

  

### SED

SEDs are ABS approximations of state and territory legislative
boundaries, used for state elections. Prior to 2021, SEDs were allocated
from SA1s; since 2021, they use MBs.

*Usage:* Analyse federal election results with state election results.

#### *Example Usage:*

``` r
df <- get_boundary_data(
  ref_date = 2024, # OR 2011, 2016, 2017, 2018, 2019, 2020, 2021, 2022
  level = "SED"
)
```

#### *Sample Data (2024):*

| MB_CODE_2021 | SED_CODE_2024 | SED_NAME_2024 | STATE_CODE_2021 | STATE_NAME_2021 | AUS_CODE_2021 | AUS_NAME_2021 | AREA_ALBERS_SQKM | ASGS_LOCI_URI_2021                                          |
|:-------------|:--------------|:--------------|:----------------|:----------------|:--------------|:--------------|-----------------:|:------------------------------------------------------------|
| 10000260000  | 10001         | Albury        | 1               | New South Wales | AUS           | Australia     |            0.014 | <https://linked.data.gov.au/dataset/asgsed3/MB/10000260000> |

#### *Sample Data (2019):*

| SA1_MAINCODE_2016 | SED_CODE_2019 | SED_NAME_2019 | STATE_CODE_2016 | STATE_NAME_2016 | AREA_ALBERS_SQKM |
|------------------:|--------------:|:--------------|----------------:|:----------------|-----------------:|
|       10102100701 |         10031 | Goulburn      |               1 | New South Wales |         362.8727 |

  

### POA

POAs are ABS approximations of Australia Post postcodes, useful for
converting election data to postal codes for campaign targeting or
social media analysis.

*Usage*: Map election results to postcodes for targeted analysis.

*Note:* Prior to 2016, POAs were allocated from 2011 SA1s; since 2016,
they use MBs, requiring MB to SA1 allocation tables for consistency.

#### *Example Usage:*

``` r
df <- get_boundary_data(
  ref_date = 2021, # OR 2011, 2016
  level = "POA"
)
```

#### *Sample Data (2021):*

| MB_CODE_2021 | POA_CODE_2021 | POA_NAME_2021 | AUS_CODE_2021 | AUS_NAME_2021 | AREA_ALBERS_SQKM | ASGS_LOCI_URI_2021                                         |
|:-------------|:--------------|:--------------|:--------------|:--------------|-----------------:|:-----------------------------------------------------------|
| 70034860000  | 0800          | 0800          | AUS           | Australia     |           0.0434 | <http://linked.data.gov.au/dataset/asgsed3/MB/70034860000> |

#### *Sample Data (2011):*

| SA1_MAINCODE_2011 | POA_CODE_2011 | POA_NAME_2011 | AREA_ALBERS_SQKM |
|------------------:|--------------:|:--------------|-----------------:|
|       70101100206 |           800 | 0800          |        0.4481936 |

## The `prepare_boundaries` Function

While `get_boundary_data` retrieves individual ABS boundary files, the
`prepare_boundaries` function automates the complex process of building
correspondence tables between election events and target boundaries. It
handles:

- Chaining multiple correspondence files across ASGS editions
- Merging with allocation tables for CED, POA, or SA1 targets
- Applying redistribution adjustments for recent elections (Vic/WA 2021,
  NT 2024)

This function is essential for comparing election results across
different boundary configurations or linking election data to Census
demographics.

| Parameters   | Description                                      | Default                 | Valid Options                                                                                                                                  |
|--------------|--------------------------------------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `event`      | Source election whose results you want to re-map | “2025 Federal Election” | “2025 Federal Election”, “2023 Referendum”, “2022 Federal Election”, “2019 Federal Election”, “2016 Federal Election”, “2013 Federal Election” |
| `compare_to` | Target boundaries to map to                      | “2025 Federal Election” | Elections, Census SA1s, or Postcodes (see below)                                                                                               |
| `process`    | Remove geographic units with invalid ratios      | TRUE                    | TRUE, FALSE                                                                                                                                    |

#### Source Event Base Geographies

Each election event uses a specific ABS geographic base for its
SA1/CD-level results:

| Event                 | Base Geography                       | Notes             |
|-----------------------|--------------------------------------|-------------------|
| 2013 Federal Election | 2006 Census Collector Districts (CD) | Pre-SA1 geography |
| 2016 Federal Election | 2011 SA1                             | ASGS Edition 1    |
| 2019 Federal Election | 2016 SA1                             | ASGS Edition 2    |
| 2022 Federal Election | 2016 SA1                             | ASGS Edition 2    |
| 2023 Referendum       | 2016 SA1                             | ASGS Edition 2    |
| 2025 Federal Election | 2021 SA1                             | ASGS Edition 3    |

#### Valid Target Options

| Target Type       | Options                                                                                                                     | Description                                          |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| Federal Elections | “2013 Federal Election”, “2016 Federal Election”, “2019 Federal Election”, “2022 Federal Election”, “2025 Federal Election” | Maps to CED boundaries used for that election        |
| Referendum        | “2023 Referendum”                                                                                                           | Maps to CED boundaries used for the Voice referendum |
| Census SA1        | “2011 Census”, “2016 Census”, “2021 Census”                                                                                 | Maps to SA1 boundaries for that Census year          |
| Postcodes         | “2011 Postcodes”, “2016 Postcodes”, “2021 Postcodes”                                                                        | Maps to Postal Areas (POA) for that year             |

**Important:** You cannot map an event to boundaries from an earlier
ASGS edition. For example, you cannot map the 2025 Federal Election (SA1
2021) to 2016 Census boundaries.

  

### Use Case 1: Comparing Elections Over Time

The most common use case is comparing election results across different
elections, which requires mapping historical results to current
boundaries (or vice versa).

#### Mapping to Current (2025) Boundaries

To analyse how voting patterns have changed over time using consistent
2025 electoral boundaries:

``` r
df <- prepare_boundaries(
  event = "2022 Federal Election", # OR "2019 Federal Election", "2016 Federal Election", "2013 Federal Election", "2023 Referendum"
  compare_to = "2025 Federal Election"
)
```

| SA1_CODE_2021 | SA1_MAINCODE_2016 | RATIO_16SA1_21SA1 | SA1_7DIGITCODE_2016 | CED_NAME_2024 | SA1_7DIGITCODE_2021 |
|:--------------|------------------:|------------------:|:--------------------|:--------------|:--------------------|
| 10102100701   |       10102100701 |                 1 | 1100701             | Eden-Monaro   | 1100701             |
| 10102100702   |       10102100702 |                 1 | 1100702             | Eden-Monaro   | 1100702             |
| 10102100703   |       10102100703 |                 1 | 1100703             | Eden-Monaro   | 1100703             |

*Use cases:*

- Compare election results from any previous election using the same
  2025 electoral boundaries
- Track voting trends across multiple elections (e.g., 2019, 2022, 2025)
  on consistent boundaries
- Analyse relationship between Voice referendum voting and 2025 election
  results
- Long-term trend analysis from 2013 to 2025 (chains through CD 2006 →
  SA1 2011 → SA1 2016 → SA1 2021)

#### Mapping to Historical Boundaries (2022 and earlier)

These mappings are useful for historical research, redistribution impact
studies, or aligning with data published using older boundary
definitions.

``` r
df <- prepare_boundaries(
  event = "2016 Federal Election", # OR "2013 Federal Election"
  compare_to = "2022 Federal Election" # OR "2023 Referendum", "2019 Federal Election", "2016 Federal Election", "2013 Federal Election"
)
```

| SA1_MAINCODE_2016 | SA1_7DIGITCODE_2016 | SA1_MAINCODE_2011 | SA1_7DIGITCODE_2011 | RATIO_11SA1_16SA1 | CED_NAME_2018 |
|------------------:|:--------------------|:------------------|--------------------:|------------------:|:--------------|
|       10102100701 | 1100701             | 10102100701       |             1100701 |         1.0000000 | Hume          |
|       10102100702 | 1100702             | 10102100702       |             1100702 |         1.0000000 | Eden-Monaro   |
|       10102100702 | 1100702             | 10102100710       |             1100710 |         0.0062026 | Eden-Monaro   |

*Use cases:*

- **Historical research:** Analyse elections in their original boundary
  context for academic studies
- **Census alignment:** Link to Census data published with
  period-specific CED approximations
- **Redistribution impact analysis:** Compare how votes would count
  under old vs new boundaries
- **Media archives:** Recreate historical election maps or validate old
  publications
- **State election comparisons:** Align federal results with state
  electoral boundaries from the same era

*Notes:*

- The 2022 election and 2023 referendum used identical boundaries (2021
  CEDs with Vic/WA adjustments)
- See the Valid Combinations Reference table below for all supported
  event/boundary combinations

  

### Use Case 2: Linking to Census Demographics

Map election results to Census SA1 boundaries to analyse voting patterns
alongside demographic data like income, education, or age profiles.

#### Mapping to Current (2021) Census

``` r
df <- prepare_boundaries(
  event = "2022 Federal Election", # OR "2025 Federal Election", "2019 Federal Election", "2016 Federal Election", "2013 Federal Election"
  compare_to = "2021 Census"
)
```

| SA1_MAINCODE_2016 | SA1_CODE_2021 | RATIO_16SA1_21SA1 | SA1_7DIGITCODE_2016 |
|------------------:|:--------------|------------------:|:--------------------|
|       10102100701 | 10102100701   |                 1 | 1100701             |
|       10102100702 | 10102100702   |                 1 | 1100702             |
|       10102100703 | 10102100703   |                 1 | 1100703             |

*Use cases:*

- Link any election results to current Census demographics (income,
  education, age profiles, etc.)
- 2025 election results already use 2021 SA1s (direct mapping)
- Earlier elections require correspondence chains (e.g., 2013 chains
  through CD 2006 → SA1 2011 → SA1 2016 → SA1 2021)

#### Mapping to Historical Census (2016/2011)

``` r
df <- prepare_boundaries(
  event = "2019 Federal Election", # OR "2022 Federal Election", "2016 Federal Election", "2013 Federal Election"
  compare_to = "2016 Census" # OR "2011 Census"
)
```

| SA1_MAINCODE_2016 | SA1_7DIGITCODE_2016 |
|------------------:|--------------------:|
|       10102100701 |             1100701 |
|       10102100702 |             1100702 |
|       10102100703 |             1100703 |

*Use cases:*

- **Period-matched analysis:** Link elections to the Census closest in
  time (e.g., 2019 election with 2016 Census demographics)
- **Longitudinal studies:** Track demographic shifts by comparing
  elections against their contemporaneous Census
- **Historical research:** Reproduce analyses as they would have been
  done at the time
- **Direct mappings:** 2019/2022 elections already use 2016 SA1s; 2016
  election uses 2011 SA1s

*Note:* Cannot map 2025 election to 2016/2011 Census (earlier ASGS
editions). See Valid Combinations Reference table below.

  

### Use Case 3: Mapping to Postcodes

Map election results to Postal Areas (POA) for campaign targeting,
social media analysis, or linking to postcode-based datasets.

#### Mapping to Current (2021) Postcodes

``` r
df <- prepare_boundaries(
  event = "2022 Federal Election", # OR "2025 Federal Election", "2019 Federal Election", "2016 Federal Election", "2013 Federal Election"
  compare_to = "2021 Postcodes"
)
```

| SA1_CODE_2021 | SA1_MAINCODE_2016 | RATIO_16SA1_21SA1 | SA1_7DIGITCODE_2016 | POA_NAME_2021 |
|:--------------|------------------:|------------------:|:--------------------|:--------------|
| 10102100701   |       10102100701 |                 1 | 1100701             | 2580          |
| 10102100702   |       10102100702 |                 1 | 1100702             | 2622          |
| 10102100703   |       10102100703 |                 1 | 1100703             | 2622          |

*Use cases:*

- **Campaign targeting:** Convert election results to postcodes for
  direct mail or advertising campaigns
- **Social media analysis:** Link voting patterns to postcode-based
  social media demographics
- **Commercial data integration:** Join election results with
  postcode-based datasets (e.g., consumer behaviour, property data)
- **Service planning:** Analyse voting patterns by postcode for
  government or NGO service delivery planning

#### Mapping to Historical Postcodes (2016/2011)

``` r
df <- prepare_boundaries(
  event = "2016 Federal Election", # OR "2019 Federal Election", "2013 Federal Election"
  compare_to = "2016 Postcodes" # OR "2011 Postcodes"
)
```

| SA1_MAINCODE_2016 | SA1_MAINCODE_2011 | SA1_7DIGITCODE_2011 | SA1_7DIGITCODE_2016 | RATIO_11SA1_16SA1 | POA_NAME_2016 |
|------------------:|:------------------|--------------------:|--------------------:|------------------:|:--------------|
|       10102100701 | 10102100701       |             1100701 |             1100701 |                 1 | 2580          |
|       10102100701 | 10102100701       |             1100701 |             1100701 |                 1 | 2622          |
|       10102100702 | 10102100702       |             1100702 |             1100702 |                 1 | 2622          |

*Use cases:*

- **Historical commercial data:** Link elections to postcode-based
  datasets from that period
- **Postcode boundary changes:** Some postcodes have been split, merged,
  or renamed over time
- **Archival research:** Reproduce analyses using postcode definitions
  as they existed at the time

*Note:* Cannot map 2025 election to 2016/2011 Postcodes (earlier ASGS
editions). See Valid Combinations Reference table below.

  

### Valid Combinations Reference

The following table summarises all valid `event` and `compare_to`
combinations. An ✓ indicates a valid combination; an ✗ indicates the
combination is not supported (typically because it would require mapping
to an earlier ASGS edition).

| Event ↓ / Compare to →    | 2013 Election | 2016 Election | 2019 Election | 2022 Election | 2023 Referendum | 2025 Election | 2011 Census | 2016 Census | 2021 Census | 2011 POA | 2016 POA | 2021 POA |
|---------------------------|:-------------:|:-------------:|:-------------:|:-------------:|:---------------:|:-------------:|:-----------:|:-----------:|:-----------:|:--------:|:--------:|:--------:|
| **2013 Federal Election** |       ✓       |       ✓       |       ✓       |       ✓       |        ✓        |       ✓       |      ✓      |      ✓      |      ✓      |    ✓     |    ✓     |    ✓     |
| **2016 Federal Election** |       ✗       |       ✓       |       ✓       |       ✓       |        ✓        |       ✓       |      ✓      |      ✓      |      ✓      |    ✓     |    ✓     |    ✓     |
| **2019 Federal Election** |       ✗       |       ✗       |       ✓       |       ✓       |        ✓        |       ✓       |      ✗      |      ✓      |      ✓      |    ✗     |    ✓     |    ✓     |
| **2022 Federal Election** |       ✗       |       ✗       |       ✓       |       ✓       |        ✓        |       ✓       |      ✗      |      ✓      |      ✓      |    ✗     |    ✓     |    ✓     |
| **2023 Referendum**       |       ✗       |       ✗       |       ✓       |       ✓       |        ✓        |       ✓       |      ✗      |      ✓      |      ✓      |    ✗     |    ✓     |    ✓     |
| **2025 Federal Election** |       ✗       |       ✗       |       ✗       |       ✗       |        ✗        |       ✓       |      ✗      |      ✗      |      ✓      |    ✗     |    ✗     |    ✓     |
