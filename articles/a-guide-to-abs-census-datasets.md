# A Guide to the ABS Census Datasets

  
This guide explores the
[`get_census_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.html)
function in the `scgElectionsAU` package, designed to retrieve Census
data from the Australian Bureau of Statistics (ABS). The function
simplifies access to Census DataPacks for 2011, 2016, and 2021 at the
Statistical Area Level 1 (SA1) geographic level. Census data provides
comprehensive demographic, social, and economic information that can be
linked to electoral data for analysis of voting patterns. Below, we
detail the function’s parameters, available datasets, usage examples,
and the context of ABS Census data collection.  

### Introduction to ABS Census Data

The Australian Bureau of Statistics (ABS) conducts the Census of
Population and Housing every five years, collecting data on the key
characteristics of people and dwellings in Australia. The Census
provides a comprehensive snapshot of the nation, covering demographics,
education, employment, income, housing, and more. The data is published
through various products including
[DataPacks](https://www.abs.gov.au/census/find-census-data/datapacks),
[Community
Profiles](https://www.abs.gov.au/census/find-census-data/community-profiles),
and
[GeoPackages](https://www.abs.gov.au/census/find-census-data/geopackages).

The
[`get_census_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.html)
function provides access to Census DataPacks at the SA1 geographic
level. SA1s are the smallest geographic unit for which Census data is
publicly released, containing approximately 200-800 people. This
granular level of data is particularly useful for linking Census
demographics to electoral results.

### The `get_census_data` Function

The
[`get_census_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.html)
function retrieves Census data from ABS DataPacks, downloading and
extracting specific tables from ZIP archives hosted on the ABS website.
Each table contains different Census variables organised by topic.

| Parameter     | Description                                                                                   | Valid Options                |
|---------------|-----------------------------------------------------------------------------------------------|------------------------------|
| `census_year` | The Census year to retrieve data for.                                                         | 2011, 2016, 2021             |
| `table`       | The table identifier to retrieve (e.g., “G01”). See `abs_census_tables` for available tables. | See table descriptions below |

#### Census Profiles

The Census DataPacks contain different profile types depending on the
year:

- **General Community Profile (GCP):** Used for 2016 and 2021 Census.
  Tables are prefixed with “G” (e.g., G01, G02). Contains approximately
  60 tables covering all major Census topics.
- **Basic Community Profile (BCP):** Used for 2011 Census. Tables are
  prefixed with “B” (e.g., B01, B02). Contains approximately 46 tables
  with core Census variables.

#### Table Categories

The tables are organised by topic:

- **Person Characteristics:** Age, sex, marital status, ancestry,
  country of birth, language, religion
- **Education:** School attendance, highest year of school,
  qualifications, field of study
- **Employment:** Labour force status, occupation, industry, hours
  worked, income
- **Family & Household:** Family composition, household composition,
  number of children
- **Housing:** Dwelling structure, tenure, mortgage, rent, bedrooms,
  motor vehicles
- **Health & Assistance:** Long-term health conditions, need for
  assistance, unpaid care

### Data Sources and Collection

The ABS collects Census data through the national Census conducted every
five years. The data is processed, quality-checked, and released
approximately 12-18 months after Census night. DataPacks are made
available in CSV format within ZIP archives, organised by geographic
level.

Key points about the data:

- **Confidentiality:** Small random adjustments are made to cell values
  to protect respondent confidentiality
- **Geographic Structure:** SA1s are the building blocks of the
  Australian Statistical Geography Standard (ASGS), nesting within SA2,
  SA3, SA4, and State/Territory boundaries
- **Comparability:** While many tables are consistent across years, some
  topics are only available in certain Census years (e.g., health
  conditions in 2021 only)

### Looking Up Available Tables

The `abs_census_tables` dataset provides a reference of all available
tables and their descriptions:

#### *Example: Finding Tables*

``` r
# View all available tables
head(abs_census_tables)
#>   table
#> 1   G01
#> 2   G02
#> 3   G03
#> 4   G04
#> 5   G05
#> 6   G06
#>                                                               description
#> 1                                  Selected person characteristics by sex
#> 2                                           Selected medians and averages
#> 3 Place of usual residence by place of enumeration on Census Night by age
#> 4                                                              Age by sex
#> 5                                 Registered marital status by age by sex
#> 6                                     Social marital status by age by sex
#>   census_years
#> 1    2016,2021
#> 2    2016,2021
#> 3    2016,2021
#> 4    2016,2021
#> 5    2016,2021
#> 6    2016,2021

# Find tables related to income
abs_census_tables[grep("income", abs_census_tables$description, ignore.case = TRUE), ]
#>    table
#> 17   G17
#> 32   G32
#> 33   G33
#> 57   G57
#> 58   G58
#> 59   G59
#> 79   B17
#> 90   B28
#> 91   B29
#>                                                                                                  description
#> 17                                                              Total personal income (weekly) by age by sex
#> 32                                                        Total family income (weekly) by family composition
#> 33                                                  Total household income (weekly) by household composition
#> 57      Total family income (weekly) by labour force status of partners for couple families with no children
#> 58 Total family income (weekly) by labour force status of parents/partners for couple families with children
#> 59                     Total family income (weekly) by labour force status of parent for one parent families
#> 79                                                              Total personal income (weekly) by age by sex
#> 90                                                        Total family income (weekly) by family composition
#> 91                                                        Household income (weekly) by household composition
#>    census_years
#> 17    2016,2021
#> 32    2016,2021
#> 33    2016,2021
#> 57    2016,2021
#> 58    2016,2021
#> 59    2016,2021
#> 79         2011
#> 90         2011
#> 91         2011

# Find tables available in 2021
abs_census_tables[grep("2021", abs_census_tables$census_years), ]
#>    table
#> 1    G01
#> 2    G02
#> 3    G03
#> 4    G04
#> 5    G05
#> 6    G06
#> 7    G07
#> 8    G08
#> 9    G09
#> 10   G10
#> 11   G11
#> 12   G12
#> 13   G13
#> 14   G14
#> 15   G15
#> 16   G16
#> 17   G17
#> 18   G18
#> 19   G19
#> 20   G20
#> 21   G21
#> 22   G22
#> 23   G23
#> 24   G24
#> 25   G25
#> 26   G26
#> 27   G27
#> 28   G28
#> 29   G29
#> 30   G30
#> 31   G31
#> 32   G32
#> 33   G33
#> 34   G34
#> 35   G35
#> 36   G36
#> 37   G37
#> 38   G38
#> 39   G39
#> 40   G40
#> 41   G41
#> 42   G42
#> 43   G43
#> 44   G44
#> 45   G45
#> 46   G46
#> 47   G47
#> 48   G48
#> 49   G49
#> 50   G50
#> 51   G51
#> 52   G52
#> 53   G53
#> 54   G54
#> 55   G55
#> 56   G56
#> 57   G57
#> 58   G58
#> 59   G59
#> 60   G60
#> 61   G61
#> 62   G62
#>                                                                                                  description
#> 1                                                                     Selected person characteristics by sex
#> 2                                                                              Selected medians and averages
#> 3                                    Place of usual residence by place of enumeration on Census Night by age
#> 4                                                                                                 Age by sex
#> 5                                                                    Registered marital status by age by sex
#> 6                                                                        Social marital status by age by sex
#> 7                                                                            Indigenous status by age by sex
#> 8                                                                    Ancestry by country of birth of parents
#> 9                                                                   Country of birth of person by age by sex
#> 10                                                             Country of birth of person by year of arrival
#> 11                                                   Proficiency in spoken English by year of arrival by age
#> 12                                     Proficiency in spoken English of parents by age of dependent children
#> 13                                             Language used at home by proficiency in spoken English by sex
#> 14                                                                              Religious affiliation by sex
#> 15                                                            Type of education institution attending by sex
#> 16                                                            Highest year of school completed by age by sex
#> 17                                                              Total personal income (weekly) by age by sex
#> 18                                                           Core activity need for assistance by age by sex
#> 19                                                          Type of long-term health condition by age by sex
#> 20                                               Count of selected long-term health conditions by age by sex
#> 21                                     Type of long-term health condition by selected person characteristics
#> 22                                                            Australian Defence Force service by age by sex
#> 23                                                 Voluntary work for an organisation or group by age by sex
#> 24                                                       Unpaid domestic work: number of hours by age by sex
#> 25       Unpaid assistance to a person with a disability or health condition or due to old age by age by sex
#> 26                                                                           Unpaid child care by age by sex
#> 27                                                                   Relationship in household by age by sex
#> 28                                                                              Number of children ever born
#> 29                                                                                        Family composition
#> 30                           Family composition and country of birth of parents by age of dependent children
#> 31                                                                                           Family blending
#> 32                                                        Total family income (weekly) by family composition
#> 33                                                  Total household income (weekly) by household composition
#> 34                                                                     Number of motor vehicles by dwellings
#> 35                                               Household composition by number of persons usually resident
#> 36                                                                                        Dwelling structure
#> 37                                                            Tenure and landlord type by dwelling structure
#> 38                                                        Mortgage repayment (monthly) by dwelling structure
#> 39                                                        Mortgage repayment (monthly) by family composition
#> 40                                                                            Rent (weekly) by landlord type
#> 41                                                                  Dwelling structure by number of bedrooms
#> 42                                        Dwelling structure by household composition and family composition
#> 43                                      Selected labour force education and migration characteristics by sex
#> 44                                                                Place of usual residence 1 year ago by sex
#> 45                                                               Place of usual residence 5 years ago by sex
#> 46                                                                         Labour force status by age by sex
#> 47                    Labour force status by sex of parents by age of dependent children for couple families
#> 48                 Labour force status by sex of parent by age of dependent children for one parent families
#> 49                                        Highest non-school qualification: level of education by age by sex
#> 50                                            Highest non-school qualification: field of study by age by sex
#> 51                                     Highest non-school qualification: field of study by occupation by sex
#> 52                                 Highest non-school qualification: level of education by occupation by sex
#> 53                     Highest non-school qualification: level of education by industry of employment by sex
#> 54                                                                      Industry of employment by age by sex
#> 55                                                             Industry of employment by hours worked by sex
#> 56                                                                      Industry of employment by occupation
#> 57      Total family income (weekly) by labour force status of partners for couple families with no children
#> 58 Total family income (weekly) by labour force status of parents/partners for couple families with children
#> 59                     Total family income (weekly) by labour force status of parent for one parent families
#> 60                                                                                  Occupation by age by sex
#> 61                                                                         Occupation by hours worked by sex
#> 62                                                                           Method of travel to work by sex
#>    census_years
#> 1     2016,2021
#> 2     2016,2021
#> 3     2016,2021
#> 4     2016,2021
#> 5     2016,2021
#> 6     2016,2021
#> 7     2016,2021
#> 8     2016,2021
#> 9     2016,2021
#> 10    2016,2021
#> 11    2016,2021
#> 12    2016,2021
#> 13    2016,2021
#> 14    2016,2021
#> 15    2016,2021
#> 16    2016,2021
#> 17    2016,2021
#> 18    2016,2021
#> 19         2021
#> 20         2021
#> 21         2021
#> 22         2021
#> 23    2016,2021
#> 24    2016,2021
#> 25    2016,2021
#> 26    2016,2021
#> 27    2016,2021
#> 28    2016,2021
#> 29    2016,2021
#> 30    2016,2021
#> 31    2016,2021
#> 32    2016,2021
#> 33    2016,2021
#> 34    2016,2021
#> 35    2016,2021
#> 36    2016,2021
#> 37    2016,2021
#> 38    2016,2021
#> 39    2016,2021
#> 40    2016,2021
#> 41    2016,2021
#> 42    2016,2021
#> 43    2016,2021
#> 44    2016,2021
#> 45    2016,2021
#> 46    2016,2021
#> 47    2016,2021
#> 48    2016,2021
#> 49    2016,2021
#> 50    2016,2021
#> 51    2016,2021
#> 52    2016,2021
#> 53    2016,2021
#> 54    2016,2021
#> 55    2016,2021
#> 56    2016,2021
#> 57    2016,2021
#> 58    2016,2021
#> 59    2016,2021
#> 60    2016,2021
#> 61    2016,2021
#> 62    2016,2021

# Find 2011 Census tables (B-prefix)
abs_census_tables[grep("^B", abs_census_tables$table), ]
#>     table
#> 63    B01
#> 64    B02
#> 65    B03
#> 66    B04
#> 67    B05
#> 68    B06
#> 69    B07
#> 70    B08
#> 71    B09
#> 72    B10
#> 73    B11
#> 74    B12
#> 75    B13
#> 76    B14
#> 77    B15
#> 78    B16
#> 79    B17
#> 80    B18
#> 81    B19
#> 82    B20
#> 83    B21
#> 84    B22
#> 85    B23
#> 86    B24
#> 87    B25
#> 88    B26
#> 89    B27
#> 90    B28
#> 91    B29
#> 92    B30
#> 93    B31
#> 94    B32
#> 95    B33
#> 96    B34
#> 97    B35
#> 98    B36
#> 99    B37
#> 100   B38
#> 101   B39
#> 102   B40
#> 103   B41
#> 104   B42
#> 105   B43
#> 106   B44
#> 107   B45
#> 108   B46
#>                                                                                 description
#> 63                                                   Selected person characteristics by sex
#> 64                                                            Selected medians and averages
#> 65  Place of usual residence on Census Night by place of usual residence 5 years ago by sex
#> 66                                                                               Age by sex
#> 67                                                  Registered marital status by age by sex
#> 68                                                      Social marital status by age by sex
#> 69                                                          Indigenous status by age by sex
#> 70                                                  Ancestry by country of birth of parents
#> 71                                                 Country of birth of person by age by sex
#> 72                               Country of birth of person by year of arrival in Australia
#> 73            Proficiency in spoken English/language by year of arrival in Australia by sex
#> 74                    Proficiency in spoken English of parents by age of dependent children
#> 75                                                           Language spoken at home by sex
#> 76                                                             Religious affiliation by sex
#> 77                                  Type of educational institution attending by age by sex
#> 78                                           Highest year of school completed by age by sex
#> 79                                             Total personal income (weekly) by age by sex
#> 80                                   Need for assistance with core activities by age by sex
#> 81                                Voluntary work for an organisation or group by age by sex
#> 82                                      Unpaid domestic work: number of hours by age by sex
#> 83                            Unpaid assistance to a person with a disability by age by sex
#> 84                                        Unpaid child care by age of carer by sex of carer
#> 85                                                  Relationship in household by age by sex
#> 86                                            Number of children ever born by age of parent
#> 87                                                                       Family composition
#> 88                                       Family composition and country of birth of parents
#> 89                                                                          Family blending
#> 90                                       Total family income (weekly) by family composition
#> 91                                       Household income (weekly) by household composition
#> 92                                                    Number of motor vehicles by dwellings
#> 93                              Household composition by number of persons usually resident
#> 94                                                                       Dwelling structure
#> 95                                      Tenure type and landlord type by dwelling structure
#> 96                                       Mortgage repayment (monthly) by dwelling structure
#> 97                                       Mortgage repayment (monthly) by family composition
#> 98                                                           Rent (weekly) by landlord type
#> 99                                                 Dwelling structure by number of bedrooms
#> 100                      Dwelling structure by household composition and family composition
#> 101                    Selected labour force education and migration characteristics by sex
#> 102                                                       Labour force status by age by sex
#> 103       Labour force status of parents by age of dependent children by family composition
#> 104                              Non-school qualification: level of education by age by sex
#> 105                                  Non-school qualification: field of study by age by sex
#> 106                           Non-school qualification: field of study by occupation by sex
#> 107                         Non-school qualification: level of education by industry by sex
#> 108                                                    Industry of employment by age by sex
#>     census_years
#> 63          2011
#> 64          2011
#> 65          2011
#> 66          2011
#> 67          2011
#> 68          2011
#> 69          2011
#> 70          2011
#> 71          2011
#> 72          2011
#> 73          2011
#> 74          2011
#> 75          2011
#> 76          2011
#> 77          2011
#> 78          2011
#> 79          2011
#> 80          2011
#> 81          2011
#> 82          2011
#> 83          2011
#> 84          2011
#> 85          2011
#> 86          2011
#> 87          2011
#> 88          2011
#> 89          2011
#> 90          2011
#> 91          2011
#> 92          2011
#> 93          2011
#> 94          2011
#> 95          2011
#> 96          2011
#> 97          2011
#> 98          2011
#> 99          2011
#> 100         2011
#> 101         2011
#> 102         2011
#> 103         2011
#> 104         2011
#> 105         2011
#> 106         2011
#> 107         2011
#> 108         2011
```

  

## Available Tables and Examples

The following sections detail selected tables available for each topic,
including example usage of the `get_census_data` function.

## Person Characteristics

### G01/B01: Selected Person Characteristics by Sex

The `G01` (2016, 2021) or `B01` (2011) table provides a summary of key
person characteristics, including:

- Age distribution (`Age_0_4_yr_M`, `Age_0_4_yr_F`, etc.)
- Country of birth (`Australia_M`, `Australia_F`, `Elsewhere_M`,
  `Elsewhere_F`)
- Indigenous status (`Indigenous_P_Tot_M`, `Indigenous_P_Tot_F`)
- Language spoken at home
- Citizenship and year of arrival

This table is useful for understanding the basic demographic profile of
an area.

#### *Example Usage:*

``` r
g01 <- get_census_data(
  census_year = 2021, # OR 2016
  table = "G01" # OR "B01" (2011)
)
```

#### *Sample Data:*

| SA1_CODE_2021 | Tot_P_M | Tot_P_F | Tot_P_P | Age_0_4_yr_M | Age_0_4_yr_F | Age_0_4_yr_P | Age_5_14_yr_M | Age_5_14_yr_F | Age_5_14_yr_P | Age_15_19_yr_M | Age_15_19_yr_F | Age_15_19_yr_P | Age_20_24_yr_M | Age_20_24_yr_F | Age_20_24_yr_P | Age_25_34_yr_M | Age_25_34_yr_F | Age_25_34_yr_P | Age_35_44_yr_M | Age_35_44_yr_F | Age_35_44_yr_P | Age_45_54_yr_M | Age_45_54_yr_F | Age_45_54_yr_P | Age_55_64_yr_M | Age_55_64_yr_F | Age_55_64_yr_P | Age_65_74_yr_M | Age_65_74_yr_F | Age_65_74_yr_P | Age_75_84_yr_M | Age_75_84_yr_F | Age_75_84_yr_P | Age_85ov_M | Age_85ov_F | Age_85ov_P | Counted_Census_Night_home_M | Counted_Census_Night_home_F | Counted_Census_Night_home_P | Count_Census_Nt_Ewhere_Aust_M | Count_Census_Nt_Ewhere_Aust_F | Count_Census_Nt_Ewhere_Aust_P | Indigenous_psns_Aboriginal_M | Indigenous_psns_Aboriginal_F | Indigenous_psns_Aboriginal_P | Indig_psns_Torres_Strait_Is_M | Indig_psns_Torres_Strait_Is_F | Indig_psns_Torres_Strait_Is_P | Indig_Bth_Abor_Torres_St_Is_M | Indig_Bth_Abor_Torres_St_Is_F | Indig_Bth_Abor_Torres_St_Is_P | Indigenous_P_Tot_M | Indigenous_P_Tot_F | Indigenous_P_Tot_P | Birthplace_Australia_M | Birthplace_Australia_F | Birthplace_Australia_P | Birthplace_Elsewhere_M | Birthplace_Elsewhere_F | Birthplace_Elsewhere_P | Lang_used_home_Eng_only_M | Lang_used_home_Eng_only_F | Lang_used_home_Eng_only_P | Lang_used_home_Oth_Lang_M | Lang_used_home_Oth_Lang_F | Lang_used_home_Oth_Lang_P | Australian_citizen_M | Australian_citizen_F | Australian_citizen_P | Age_psns_att_educ_inst_0_4_M | Age_psns_att_educ_inst_0_4_F | Age_psns_att_educ_inst_0_4_P | Age_psns_att_educ_inst_5_14_M | Age_psns_att_educ_inst_5_14_F | Age_psns_att_educ_inst_5_14_P | Age_psns_att_edu_inst_15_19_M | Age_psns_att_edu_inst_15_19_F | Age_psns_att_edu_inst_15_19_P | Age_psns_att_edu_inst_20_24_M | Age_psns_att_edu_inst_20_24_F | Age_psns_att_edu_inst_20_24_P | Age_psns_att_edu_inst_25_ov_M | Age_psns_att_edu_inst_25_ov_F | Age_psns_att_edu_inst_25_ov_P | High_yr_schl_comp_Yr_12_eq_M | High_yr_schl_comp_Yr_12_eq_F | High_yr_schl_comp_Yr_12_eq_P | High_yr_schl_comp_Yr_11_eq_M | High_yr_schl_comp_Yr_11_eq_F | High_yr_schl_comp_Yr_11_eq_P | High_yr_schl_comp_Yr_10_eq_M | High_yr_schl_comp_Yr_10_eq_F | High_yr_schl_comp_Yr_10_eq_P | High_yr_schl_comp_Yr_9_eq_M | High_yr_schl_comp_Yr_9_eq_F | High_yr_schl_comp_Yr_9_eq_P | High_yr_schl_comp_Yr_8_belw_M | High_yr_schl_comp_Yr_8_belw_F | High_yr_schl_comp_Yr_8_belw_P | High_yr_schl_comp_D_n_g_sch_M | High_yr_schl_comp_D_n_g_sch_F | High_yr_schl_comp_D_n_g_sch_P | Count_psns_occ_priv_dwgs_M | Count_psns_occ_priv_dwgs_F | Count_psns_occ_priv_dwgs_P | Count_Persons_other_dwgs_M | Count_Persons_other_dwgs_F | Count_Persons_other_dwgs_P |
|--------------:|--------:|--------:|--------:|-------------:|-------------:|-------------:|--------------:|--------------:|--------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|---------------:|-----------:|-----------:|-----------:|----------------------------:|----------------------------:|----------------------------:|------------------------------:|------------------------------:|------------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|-------------------:|-------------------:|-------------------:|-----------------------:|-----------------------:|-----------------------:|-----------------------:|-----------------------:|-----------------------:|--------------------------:|--------------------------:|--------------------------:|--------------------------:|--------------------------:|--------------------------:|---------------------:|---------------------:|---------------------:|-----------------------------:|-----------------------------:|-----------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|----------------------------:|----------------------------:|----------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|------------------------------:|---------------------------:|---------------------------:|---------------------------:|---------------------------:|---------------------------:|---------------------------:|
|   10102100701 |     179 |     128 |     305 |            6 |            9 |            7 |            12 |             5 |            18 |             16 |             12 |             23 |              0 |              6 |              3 |             21 |             12 |             36 |             13 |             15 |             30 |             31 |             16 |             49 |             36 |             28 |             57 |             28 |             18 |             48 |             14 |             10 |             22 |          0 |          4 |          5 |                         165 |                         125 |                         283 |                            10 |                             8 |                            22 |                            3 |                            0 |                            7 |                             0 |                             0 |                             0 |                             0 |                             0 |                             0 |                  3 |                  0 |                  7 |                    127 |                     94 |                    219 |                     30 |                     29 |                     56 |                       144 |                       110 |                       252 |                        13 |                        11 |                        23 |                  152 |                  115 |                  262 |                            6 |                            3 |                            7 |                            10 |                             5 |                            19 |                             5 |                             9 |                            15 |                             0 |                             0 |                             0 |                             4 |                             4 |                            12 |                           46 |                           56 |                          106 |                           18 |                            8 |                           32 |                           55 |                           34 |                           87 |                          11 |                           5 |                          16 |                             4 |                             0 |                             8 |                             0 |                             0 |                             0 |                        154 |                        122 |                        275 |                         13 |                         10 |                         26 |

  

### G02/B02: Selected Medians and Averages

The `G02` (2016, 2021) or `B02` (2011) table provides key summary
statistics for each SA1, including:

- Median age (`Median_age_persons`)
- Median household income (`Median_tot_hhd_inc_weekly`)
- Median personal income (`Median_tot_prsnl_inc_weekly`)
- Median mortgage repayment (`Median_mortgage_repay_monthly`)
- Median rent (`Median_rent_weekly`)
- Average household size (`Average_household_size`)
- Average number of bedrooms (`Average_num_psns_per_bedroom`)

This table is particularly useful for socioeconomic analysis and
identifying areas by income levels.

#### *Example Usage:*

``` r
g02 <- get_census_data(
  census_year = 2021,
  table = "G02"
)
```

  

### G04/B04: Age by Sex

The `G04` (2016, 2021) or `B04` (2011) table provides detailed age
breakdowns by sex, with single-year age groups and summary categories:

- Single year of age from 0 to 100+
- Male, Female, and Total counts for each age

This table is useful for detailed demographic analysis and population
pyramids.

#### *Example Usage:*

``` r
g04 <- get_census_data(
  census_year = 2021,
  table = "G04"
)
```

  

### G07/B07: Indigenous Status by Age by Sex

The `G07` (2016, 2021) or `B07` (2011) table provides Indigenous status
by age groups:

- Aboriginal (`Aboriginal_M`, `Aboriginal_F`, `Aboriginal_P`)
- Torres Strait Islander (`Torres_Strait_Islander_M`, etc.)
- Both Aboriginal and Torres Strait Islander
- Non-Indigenous population
- Indigenous status not stated

#### *Example Usage:*

``` r
g07 <- get_census_data(
  census_year = 2021,
  table = "G07"
)
```

  

### G09/B09: Country of Birth by Age by Sex

The `G09` (2016, 2021) or `B09` (2011) table provides country of birth
information:

- Australia-born population
- Major countries of birth (England, New Zealand, China, India, etc.)
- Regional groupings (Oceania, Europe, Asia, Americas, Africa)

#### *Example Usage:*

``` r
g09 <- get_census_data(
  census_year = 2021,
  table = "G09"
)
```

  

### G14/B14: Religious Affiliation by Sex

The `G14` (2016, 2021) or `B14` (2011) table provides religious
affiliation:

- Major Christian denominations (Catholic, Anglican, Uniting Church,
  etc.)
- Other religions (Buddhism, Hinduism, Islam, Judaism, etc.)
- No religion
- Religion not stated

#### *Example Usage:*

``` r
g14 <- get_census_data(
  census_year = 2021,
  table = "G14"
)
```

  

## Education

### G16/B16: Highest Year of School Completed by Age by Sex

The `G16` (2016, 2021) or `B16` (2011) table provides school completion
levels:

- Year 12 or equivalent
- Year 11 or equivalent
- Year 10 or equivalent
- Year 9 or equivalent
- Year 8 or below
- Did not go to school

#### *Example Usage:*

``` r
g16 <- get_census_data(
  census_year = 2021,
  table = "G16"
)
```

  

### G49/B42: Highest Non-School Qualification by Age by Sex

The `G49` (2016, 2021) or `B42` (2011) table provides post-school
qualifications:

- Postgraduate degree
- Graduate diploma/certificate
- Bachelor degree
- Advanced diploma/diploma
- Certificate III/IV
- Certificate I/II

#### *Example Usage:*

``` r
g49 <- get_census_data(
  census_year = 2021,
  table = "G49"
)
```

  

## Employment & Income

### G17/B17: Total Personal Income (Weekly) by Age by Sex

The `G17` (2016, 2021) or `B17` (2011) table provides personal income
distribution:

- Income ranges (Negative/Nil, \$1-\$149, \$150-\$299, … \$3000+)
- By age group and sex
- Not stated/not applicable

#### *Example Usage:*

``` r
g17 <- get_census_data(
  census_year = 2021,
  table = "G17"
)
```

  

### G46/B40: Labour Force Status by Age by Sex

The `G46` (2016, 2021) or `B40` (2011) table provides employment status:

- Employed (full-time, part-time)
- Unemployed (looking for work)
- Not in the labour force

#### *Example Usage:*

``` r
g46 <- get_census_data(
  census_year = 2021,
  table = "G46"
)
```

  

### G60/B46: Occupation by Age by Sex

The `G60` (2016, 2021) table provides occupation categories (ANZSCO
major groups):

- Managers
- Professionals
- Technicians and trades workers
- Community and personal service workers
- Clerical and administrative workers
- Sales workers
- Machinery operators and drivers
- Labourers

Note: 2011 uses table B46 for industry of employment.

#### *Example Usage:*

``` r
g60 <- get_census_data(
  census_year = 2021,
  table = "G60"
)
```

  

## Family & Household

### G29/B25: Family Composition

The `G29` (2016, 2021) or `B25` (2011) table provides family types:

- Couple family with children
- Couple family without children
- One parent family
- Other family types

#### *Example Usage:*

``` r
g29 <- get_census_data(
  census_year = 2021,
  table = "G29"
)
```

  

### G33/B29: Household Income (Weekly) by Household Composition

The `G33` (2016, 2021) or `B29` (2011) table provides household income:

- Income ranges for different household types
- Family households vs. non-family households
- Group households, lone person households

#### *Example Usage:*

``` r
g33 <- get_census_data(
  census_year = 2021,
  table = "G33"
)
```

  

## Housing

### G36/B32: Dwelling Structure

The `G36` (2016, 2021) or `B32` (2011) table provides dwelling types:

- Separate house
- Semi-detached/townhouse
- Flat/apartment (by number of storeys)
- Other dwelling types (caravan, cabin, etc.)

#### *Example Usage:*

``` r
g36 <- get_census_data(
  census_year = 2021,
  table = "G36"
)
```

  

### G37/B33: Tenure Type and Landlord Type by Dwelling Structure

The `G37` (2016, 2021) or `B33` (2011) table provides housing tenure:

- Owned outright
- Owned with a mortgage
- Rented (from real estate agent, state housing authority, private
  landlord, etc.)
- Other tenure types

#### *Example Usage:*

``` r
g37 <- get_census_data(
  census_year = 2021,
  table = "G37"
)
```

  

### G34/B30: Number of Motor Vehicles by Dwellings

The `G34` (2016, 2021) or `B30` (2011) table provides vehicle ownership:

- No motor vehicles
- 1 motor vehicle
- 2 motor vehicles
- 3 or more motor vehicles

#### *Example Usage:*

``` r
g34 <- get_census_data(
  census_year = 2021,
  table = "G34"
)
```

  

## Health & Assistance (2021 Only)

### G19: Type of Long-Term Health Condition by Age by Sex

The `G19` table (2021 only) provides health condition data:

- Arthritis
- Asthma
- Cancer
- Dementia
- Diabetes
- Heart disease
- Kidney disease
- Lung condition
- Mental health condition
- Stroke
- Other long-term health conditions

Note: This table is only available for the 2021 Census.

#### *Example Usage:*

``` r
g19 <- get_census_data(
  census_year = 2021,
  table = "G19"
)
```

  

### G18/B18: Need for Assistance with Core Activities by Age by Sex

The `G18` (2016, 2021) or `B18` (2011) table provides disability
information:

- Has need for assistance
- Does not have need for assistance
- Need for assistance not stated

#### *Example Usage:*

``` r
g18 <- get_census_data(
  census_year = 2021,
  table = "G18"
)
```

  

## Linking Census Data to Electoral Data

Census data at SA1 level can be linked to electoral data using the ABS
boundary correspondence files available through
[`get_boundary_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_boundary_data.html).
The `Votes by SA1` dataset from
[`get_election_data`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_election_data.html)
provides vote counts at SA1 level that can be joined with Census
demographics.

#### *Example: Linking Census to Electoral Data*

``` r
# Get 2021 Census income data
census_income <- get_census_data(census_year = 2021, table = "G02")

# Get SA1 voting data from 2022 election
voting_sa1 <- get_election_data(
  file_name = "Votes by SA1",
  date_range = list(from = "2022-01-01", to = "2023-01-01"),
  category = "Statistics"
)

# Join datasets by SA1 code
# Note: Column names may need adjustment based on actual data structure
merged_data <- merge(
  voting_sa1,
  census_income,
  by.x = "StatisticalAreaID",
  by.y = "SA1_CODE_2021"
)
```

  

## Additional Resources

For more information about ABS Census data:

- [ABS Census Data](https://www.abs.gov.au/census)
- [Census
  DataPacks](https://www.abs.gov.au/census/find-census-data/datapacks)
- [Census
  Dictionary](https://www.abs.gov.au/census/guide-census-data/census-dictionary)
- [Australian Statistical Geography Standard
  (ASGS)](https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3)

  
