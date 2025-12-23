# Package index

## Prepare Data

Functions for preparing datasets, ready for analysis.

- [`prepare_boundaries()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/prepare_boundaries.md)
  : Prepare Boundary Correspondence for Cross-Election Comparison

### Get Data

Functions for retrieving election datasets, boundary correspondence and
allocation tables, census data, and disclosure data.

- [`get_abs_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_abs_data.md)
  : Retrieve data from the Australian Bureau of Statistics (ABS) Data
  API
- [`get_boundary_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_boundary_data.md)
  : Retrieve Australian Bureau of Statistics (ABS) boundary data
- [`get_census_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_census_data.md)
  : Retrieve Australian Bureau of Statistics (ABS) Census data
- [`get_disclosure_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_disclosure_data.md)
  : Retrieve Disclosure Data from AEC's Transparency Register
- [`get_election_data()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/get_election_data.md)
  : Download and Process AEC Data
- [`list_abs_dataflows()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/list_abs_dataflows.md)
  : List available ABS dataflows

### Process Data

Functions for processing AEC raw data. These primarily are used for
standardising names and data across datasets and different event types.

- [`amend_colnames()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_colnames.md)
  : Standardise Column Names for Consistency
- [`amend_maincode()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_maincode.md)
  : Convert 11-digit SA1 Maincode to 7-digit SA1 Code
- [`amend_names()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/amend_names.md)
  : Amend Names in a Data Frame Column
- [`process_ccd()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_ccd.md)
  : Process Election Data by Census Collection District
- [`process_coords()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_coords.md)
  : Process Polling Place Coordinates
- [`process_elected()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_elected.md)
  : Process Election Data for Elected Candidates
- [`process_overseas()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_overseas.md)
  : Process Overseas Voting Data
- [`process_ppv()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_ppv.md)
  : Process Pre-Poll Voting Centre Data
- [`process_pva_date()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_pva_date.md)
  : Process Postal Vote Application Data by Date
- [`process_pva_party()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_pva_party.md)
  : Process Postal Vote Application Data by Party
- [`process_reps()`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/process_reps.md)
  : Process Party Representation Data for House of Representatives

### Get Data

Functions for reviewing which data can be accessed through APIs or other
functions.

- [`abs_census_tables`](https://docs.sarahcgall.co.uk/scgElectionsAU/reference/abs_census_tables.md)
  : ABS Census Table Descriptions
