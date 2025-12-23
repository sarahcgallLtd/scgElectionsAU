# ABS Census Table Descriptions

A dataset containing the table numbers and descriptions for ABS Census
DataPack tables. This can be used to look up what data each table
contains before downloading with `get_census_data`.

## Usage

``` r
abs_census_tables
```

## Format

A data frame with 108 rows and 3 variables:

- table:

  Character. The table identifier (e.g., "G01", "B01"). Tables with
  G-prefix are from the General Community Profile (2016, 2021). Tables
  with B-prefix are from the Basic Community Profile (2011).

- description:

  Character. A description of the table contents.

- census_years:

  Character. Comma-separated list of Census years where this table is
  available (e.g., "2016,2021" or "2011").

## Source

Australian Bureau of Statistics Census DataPacks
<https://www.abs.gov.au/census/find-census-data/datapacks>

## Details

The ABS Census DataPacks contain pre-defined tables of Census data at
SA1 geographic level. The table numbering differs between Census years:

- **2021 and 2016**: Use General Community Profile (GCP) tables with
  G-prefix (G01 through G62)

- **2011**: Uses Basic Community Profile (BCP) tables with B-prefix (B01
  through B46)

Note that some tables are only available in certain Census years. For
example, tables G19-G22 (health conditions and defence force service)
are only available in the 2021 Census.

## See also

`get_census_data` to download Census data

## Examples

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
