# A Guide to the AEC's Disclosure Datasets

  
The AEC Transparency Register is a vital tool for understanding the
financial landscape of Australian politics, offering detailed insights
into the financial activities of political entities such as political
parties, candidates, donors, and third parties. Governed by the
Commonwealth Electoral Act 1918, the register aims to enhance
transparency by making public the financial dealings that may influence
the electoral process. This guide introduces the Transparency Register,
explains the datasets available through the
[`get_disclosure_data`](https://sarahcgallLtd.github.io/scgElectionsAU/reference/get_disclosure_data.html)
function from the `scgElectionsAU` package, and provides context on the
legislative framework, including upcoming changes.  

### Understanding the Transparency Register

The Transparency Register, hosted by the Australian Electoral Commission
(AEC), is a comprehensive database that compiles financial disclosure
information submitted by various political entities. These entities
include registered political parties, significant third parties,
associated entities, members of parliament, senators, donors, and others
involved in electoral processes. The register’s primary purpose is to
inform the public and allow scrutiny of financial activities that could
impact elections, as mandated by Part XX of the Commonwealth Electoral
Act 1918 ([AEC Financial
Disclosure](https://www.aec.gov.au/parties_and_representatives/financial_disclosure/)).

The register organises data into three main types of returns:

- **Annual Returns**: These cover financial activities for a financial
  year (July 1 to June 30), including donations, expenditures, debts,
  and other financial details. They are published on the first business
  day of February each year ([AEC Annual
  Returns](https://www.aec.gov.au/Parties_and_Representatives/annual-returns.htm)).
- **Election Returns**: These pertain to federal elections or
  by-elections, detailing donations and electoral expenditures specific
  to those events. They are published 24 weeks after polling day.
- **Referendum Returns**: These relate to referendums, capturing
  financial information such as donations and expenditures, published 24
  weeks after voting day ([AEC Transparency
  Register](https://transparency.aec.gov.au/)).

The Transparency Register faced a temporary outage on 15 May 2024 due to
a privacy issue involving the publication of candidates’ postal
addresses. An external review led to eight recommendations, all accepted
by the AEC, to improve data handling ([AEC Transparency
FAQs](https://www.aec.gov.au/FAQs/transparency-register.htm)). The AEC
made the necessary changes to the register, which is now back online
without any sensitive information.

### The `get_disclosure_data` Function

The [`get_disclosure_data`](NA) function, simplifies access to the
Transparency Register’s datasets. The function takes three parameters:

- **`type`**: Specifies the return type (`Annual`, `Election`,
  `Referendum`), defaulting to `Annual`.
- **`group`**: Indicates the entity category, such as `Donor`, `Party`,
  `Candidate`, or `Third Party`, defaulting to `Donor` if not provided.
- **`file_name`**: Denotes the specific dataset, such as
  `Donations Made` or `Returns`, defaulting to `Donations Made` if not
  specified.

The function validates inputs against predefined options and retrieves
data from zipped folders on the AEC’s Transparency Register download
page ([AEC Downloads](https://transparency.aec.gov.au/Download)). Not
all combinations of `type`, `group`, and `file_name` are valid; the
function checks for valid datasets using an internal index
(`aec_disclosure_index`) within the `scgElectionsAU` package.

### Dataset Descriptions

The Transparency Register offers various datasets, each corresponding to
a specific aspect of financial disclosure. Below is a summary of the
datasets accessible via the `get_disclosure_data` function, organized by
their `file_name`:

| **Dataset**                     | **Description**                                                                                                                          |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| **Capital Contributions**       | Details contributions to the entity’s capital, often relevant for associated entities or parties.                                        |
| **Debts**                       | Lists outstanding debts as of the end of the financial year, including creditor details and amounts.                                     |
| **Discretionary Benefits**      | Records benefits received from the Commonwealth, State, or Territory, such as grants or subsidies.                                       |
| **Donations Made**              | Provides details of donations given by the entity to political parties, candidates, or others, including recipient, amount, and date.    |
| **Donations Received**          | Lists donations received by the entity, often used for electoral expenditure or further donations, including donor, amount, and date.    |
| **Expenses**                    | Covers expenditures, typically electoral, incurred by entities like candidates or third parties, detailing purpose and amount.           |
| **Media Advertisement Details** | Contains information on media advertisements, such as those for election or referendum campaigns, including medium and cost.             |
| **Receipts**                    | Comprehensive list of all receipts, including donations and other income, with details like source and amount.                           |
| **Return Summary**              | Summarizes key financial figures from the return, such as total receipts and payments.                                                   |
| **Returns**                     | The complete financial return, including total receipts, payments, debts, donations, and discretionary benefits, as required by the AEC. |

These datasets are available for different `group`s and `type`s, as
outlined in the examples below. For instance, `Donations Made` by a
`Donor` in an `Annual` return lists their contributions to political
entities, while `Returns` for a `Party` includes all required financial
disclosures.

### Legislative Context

The datasets are governed by the Commonwealth Electoral Act 1918, which
mandates financial disclosure to maintain electoral integrity. For the
2023–24 financial year, the disclosure threshold was \$16,300, indexed
annually on July 1 ([AEC Media
Release](https://www.aec.gov.au/media/2025/02-03.htm)). Entities must
lodge returns through the AEC’s eReturns portal, with annual returns due
by October 20 (or November 17 for MPs and Senators) and
election/referendum returns due 24 weeks after the event.

Significant reforms to the funding and disclosure scheme are scheduled
for July 1, 2026, and will not affect the 2025 federal election returns.
These changes include:

- Reducing the disclosure threshold to \$5,000, indexed post-election.
- Introducing expedited disclosure for donations over \$5,000 (e.g.,
  within 7 days during election periods).
- Implementing donation caps (e.g., \$50,000 annually per recipient) and
  expenditure caps (e.g., \$90 million for parties federally).
- Requiring federal accounts for electoral expenditure and donations.
- Shifting to a calendar-year reporting period and replacing election
  returns with expedited disclosures ([AEC Legislative
  Changes](https://www.aec.gov.au/news/disclosure-legislative-changes.htm)).

Minor amendments, such as changes to registration processes, will take
effect on February 21, 2025, but are unlikely to impact dataset
structures significantly.

### Available Datasets and Examples

The following sections detail the datasets available for each return
type, including example usage of the `get_disclosure_data` function and
sample data. These examples demonstrate how to retrieve and explore the
data, helping users analyse political financial activities.

## Annual

### Donations

#### *Example Usage (Made):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Made",
  group = "Donor",
  type = "Annual"
)
```

#### *Sample Data (Made):*

| Financial Year | Donor Name                  | Donation Made To                                   | Date       | Value |
|:---------------|:----------------------------|:---------------------------------------------------|:-----------|------:|
| 2023-24        | Australian Energy Producers | Australian Labor Party (Western Australian Branch) | 31/07/2023 |  5500 |

#### *Example Usage (Received):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Received",
  group = "Donor", # OR "Third Party"
  type = "Annual"
)
```

#### *Sample Data (Received - Donor):*

| Financial Year | Name                    | Donation Received From | Date       | Value |
|:---------------|:------------------------|:-----------------------|:-----------|------:|
| 2023-24        | Climate 200 Pty Limited | Stuart Argue           | 11/07/2023 |   200 |

#### *Sample Data (Received - Third Party):*

| Financial Year | Name              | Donation Received From | Date       | Value |
|:---------------|:------------------|:-----------------------|:-----------|------:|
| 2021-22        | SEARCH Foundation | JJ Fiasson             | 19/04/2022 | 23100 |

  

### Returns

#### *Example Usage:*

``` r
df <- get_disclosure_data(
  file_name = "Returns",
  group = "Associated Entity", # OR "Donor", "MPs", "Party", "Significant Third Party", "Third Party"
  type = "Annual"
)
```

#### *Sample Data (Associated Entity):*

| Financial Year | Name                    | Lodged on behalf of | AssociatedParties                    | Total Receipts | Total Payments | Total Debts | Discretionary Benefits | Capital Contributions |
|:---------------|:------------------------|:--------------------|:-------------------------------------|---------------:|---------------:|------------:|-----------------------:|----------------------:|
| 2023-24        | 1973 Foundation Pty Ltd | NA                  | Australian Labor Party (ACT Branch); |        8003471 |        3408057 |     4277719 |                      0 |                     0 |

#### *Sample Data (Donor):*

| Financial Year | Name                        | Lodged on behalf of | Total Donations Made | Total Donations Received |
|:---------------|:----------------------------|:--------------------|---------------------:|-------------------------:|
| 2023-24        | Australian Energy Producers | NA                  |               171888 |                        0 |

#### *Sample Data (MPs):*

| Financial Year | Return Type                               | Name               | Total Donations Received | Number of Donors |
|:---------------|:------------------------------------------|:-------------------|-------------------------:|-----------------:|
| 2023-24        | Member of House of Representatives Return | Dr Helen Haines MP |                    58318 |              176 |

#### *Sample Data (Party):*

| Financial Year | Name                 | Party Group | Total Receipts | Total Payments | Total Debts | Total Discretionary Benefits |
|:---------------|:---------------------|:------------|---------------:|---------------:|------------:|-----------------------------:|
| 2023-24        | Animal Justice Party | NA          |        1186307 |         741013 |      129470 |                            0 |

#### *Sample Data (Significant Third Party):*

| Financial Year | Return Type                    | ClientFileId | Name                 | ABN | ACN | Lodged on behalf of | Total Receipts | Total Payments | Total Debts | Total Discretionary Benefits | Electoral Expenditure |
|:---------------|:-------------------------------|-------------:|:---------------------|:----|:----|:--------------------|---------------:|---------------:|------------:|-----------------------------:|----------------------:|
| 2023-24        | Significant Third Party Return |        42742 | 1 in 50 Incorporated | NA  | NA  | NA                  |              0 |              0 |           0 |                            0 |                     0 |

#### *Sample Data (Third Party):*

| Financial Year | ClientFileId | Name                  | ABN            | ACN | Total Expenditure | Electoral Expenditure Cat. 1 | Electoral Expenditure Cat. 2 | Electoral Expenditure Cat. 3 | Electoral Expenditure Cat. 4 | Electoral Expenditure Cat. 5 | Total Gifts Received | ClientType |
|:---------------|-------------:|:----------------------|:---------------|:----|------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|---------------------:|:-----------|
| 2023-24        |        45075 | ABC Friends NSW & ACT | 54 530 872 593 | NA  |                 0 |                           NA |                           NA |                           NA |                           NA |                           NA |                    0 | thirdparty |

  

### Other

#### *Example Usage:*

``` r
df <- get_disclosure_data(
  file_name = "Capital Contributions", # OR "Debts", "Discretionary Benefits", "Receipts"
  group = "Other",
  type = "Annual"
)
```

#### *Sample Data (Capital Contributions):*

| Financial Year | Return Type              | Name                                               | Contributor                                        | Value |
|:---------------|:-------------------------|:---------------------------------------------------|:---------------------------------------------------|------:|
| 2019-20        | Associated Entity Return | Independent Education Union of Australia WA Branch | Australian Labor Party (Western Australian Branch) | 52419 |

#### *Sample Data (Debts):*

| Financial Year | Return Type              | Name                    | Creditor Name                     | Amount owed | Financial or Non-financial institution |
|:---------------|:-------------------------|:------------------------|:----------------------------------|------------:|:---------------------------------------|
| 2023-24        | Associated Entity Return | 1973 Foundation Pty Ltd | Australian Labor Party ACT Branch |     4267719 | Non-financial                          |

#### *Sample Data (Discretionary Benefits):*

| Financial Year | Return Type                    | Name                               | Received From                         | Date | Value |
|:---------------|:-------------------------------|:-----------------------------------|:--------------------------------------|:-----|------:|
| 2023-24        | Significant Third Party Return | Australian Council of Trade Unions | Department of Foreign Affairs & Trade | NA   |   883 |

#### *Sample Data (Receipts):*

| Financial Year | Return Type                    | Recipient Name    | Received From              | Receipt Type  |  Value |
|:---------------|:-------------------------------|:------------------|:---------------------------|:--------------|-------:|
| 2023-24        | Significant Third Party Return | Advance Australia | Australian Taxation Office | Other Receipt | 189572 |

  

## Election

### Donations

#### *Example Usage (Made):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Made",
  group = "Donor", # OR "Candidate", "Third Party"
  type = "Election"
)
```

#### *Sample Data (Made - Donor):*

| Event                 | Donor Code | Donor Name             | Donated To | Donated To Date Of Gift | Donated To Gift Value |
|:----------------------|:-----------|:-----------------------|:-----------|:------------------------|----------------------:|
| 2025 Federal Election | 51277      | ACY Securities Pty Ltd | YIN Andy   | 18/02/2025              |                  2400 |

#### *Sample Data (Made - Candidate):*

| Event                 | Return Type (Candidate/Senate Group) | Name                           | Donor Name           | Date Of Gift | Gift Value |
|:----------------------|:-------------------------------------|:-------------------------------|:---------------------|:-------------|-----------:|
| 2025 Federal Election | Candidate                            | ADAMSON AGARS Imelda Charlotte | WOLFENDALE Drew Rhys | 04/04/2025   |        250 |

#### *Sample Data (Made - Third Party):*

| Event                 | Third Party Code | Third Party Name | Client ID | Name                 | Date Of Donation | Donation Value |
|:----------------------|:-----------------|:-----------------|:----------|:---------------------|:-----------------|---------------:|
| 2004 Federal Election | S1820            | AAMI             | 14657     | FERGUSON Martin John | 01/05/2004       |           3000 |

#### *Example Usage (Received):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Received",
  group = "Donor", # OR "Third Party"
  type = "Election"
)
```

#### *Sample Data (Received - Donor):*

| Event                 | Donor Code | Donor Name              | Gift From Name                                 | Gift From Date Of Gift | Gift From Gift Value |
|:----------------------|-----------:|:------------------------|:-----------------------------------------------|:-----------------------|---------------------:|
| 2025 Federal Election |      40367 | Climate 200 Pty Limited | Aibu Pty Ltd ATF The Gomura-Elkan Family Trust | 06/02/2025             |                10000 |

#### *Sample Data (Received - Third Party):*

| Event                 | Third Party Code | Third Party Name                                         | Donor Id | Donor Name | Date Of Gift | Gift Value |
|:----------------------|:-----------------|:---------------------------------------------------------|---------:|:-----------|:-------------|-----------:|
| 2004 Federal Election | T886             | Australian Conservation Foundation Inc (incl. SA Office) |     3750 | Bill Peine | 18/12/2003   |     610000 |

  

### Expenses

#### *Example Usage:*

``` r
df <- get_disclosure_data(
  file_name = "Expenses",
  group = "Candidate", # OR "Third Party"
  type = "Election"
)
```

#### *Sample Data (Candidate):*

| Event                 | Return Type (Candidate/Senate Group) | Name              | Total Electoral Expenditure | Broadcasting Cost | Publishing Cost | Display Ad Cost | Direct Mailing | Campaign Material Costs | Opinion Polls |
|:----------------------|:-------------------------------------|:------------------|----------------------------:|------------------:|----------------:|----------------:|---------------:|------------------------:|--------------:|
| 2025 Federal Election | Candidate                            | ABBOTT Lisa Marie |                           0 |                 0 |               0 |               0 |              0 |                       0 |             0 |

#### *Sample Data (Candidate):*

| Event                 | Third Party Code | Third Party Name | Broadcasting Cost | Publishing Cost | Display Ad Cost | Direct Mailing | Campaign Material Costs | Opinion Polls |
|:----------------------|:-----------------|:-----------------|------------------:|----------------:|----------------:|---------------:|------------------------:|--------------:|
| 2004 Federal Election | T983             | ABARE            |                 0 |               0 |               0 |              0 |                       0 |             0 |

  

### Returns

#### *Example Usage (Returns):*

``` r
df <- get_disclosure_data(
  file_name = "Returns",
  group = "Donor", # OR "Media"
  type = "Election"
)
```

#### *Sample Data (Returns):*

| Event                 | Donor Code | Donor Name             | Total Donations Made | Total Donations Received |
|:----------------------|:-----------|:-----------------------|---------------------:|-------------------------:|
| 2025 Federal Election | 51277      | ACY Securities Pty Ltd |                52400 |                        0 |

#### *Sample Data (Returns):*

| Event                 | Media ID | Name  | Business Name | Return Type | Total Amount |
|:----------------------|---------:|:------|:--------------|:------------|-------------:|
| 2004 Federal Election |     5097 | 1 ART | Artsound FM   | Broadcaster |            0 |

#### *Example Usage (Return Summary):*

``` r
df <- get_disclosure_data(
  file_name = "Return Summary",
  group = "Candidate",
  type = "Election"
)
```

#### *Sample Data (Return Summary):*

| Event                 | Return Type (Candidate/Senate Group) | Name              | Party ID | Party Name                  | Electorate Name | Electorate State | Nil Return | Amendment No | Total Gift Value | Number Of Donors | Total Electoral Expenditure | Discretionary Benefits Received |
|:----------------------|:-------------------------------------|:------------------|---------:|:----------------------------|:----------------|:-----------------|:-----------|-------------:|-----------------:|-----------------:|----------------------------:|--------------------------------:|
| 2025 Federal Election | Candidate                            | ABBOTT Lisa Marie |    27916 | Legalise Cannabis Australia | Dunkley         | VIC              | Y          |            0 |                0 |                0 |                           0 |                               0 |

  

### Other

#### *Example Usage (Discretionary Benefits):*

``` r
df <- get_disclosure_data(
  file_name = "Discretionary Benefits",
  group = "Candidate",
  type = "Election"
)
```

#### *Sample Data (Discretionary Benefits):*

| Event                   | Return Type (Candidate/Senate Group) | Name                      | Discretionary Benefits Received From                  | Date       | Amount |
|:------------------------|:-------------------------------------|:--------------------------|:------------------------------------------------------|:-----------|-------:|
| Eden-Monaro by-election | Candidate                            | STADTMILLER Matthew Peter | Department of Infrastructure and Regional Development | 05/09/2019 |  12100 |

#### *Example Usage (Media Advertisement Details):*

``` r
df <- get_disclosure_data(
  file_name = "Media Advertisement Details",
  group = "Other",
  type = "Election"
)
```

#### *Sample Data (Media Advertisement Details):*

| Event                 | Media ID | Name              | Business Name                    | Return Type | Advertiser                           | Advertiser Type | Date Run   | Amount |
|:----------------------|---------:|:------------------|:---------------------------------|:------------|:-------------------------------------|:----------------|:-----------|-------:|
| 2004 Federal Election |     4134 | 100.3FM (2NEB-FM) | New England Broadcasters Pty Ltd | Broadcaster | National Party of Australia - N.S.W. | Party           | 27/09/2004 |   1689 |

  

## Referendum

### Donations

#### *Example Usage (Made):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Made",
  group = "Donor",
  type = "Referendum"
)
```

#### *Sample Data (Made):*

| Event           | Donor Name     | Donated to name        | Date                   | Value |
|:----------------|:---------------|:-----------------------|:-----------------------|------:|
| 2023 Referendum | Aarnja Limited | Kimberley Land Council | 24/08/2023 12:00:00 AM | 1e+05 |

#### *Example Usage (Received):*

``` r
df <- get_disclosure_data(
  file_name = "Donations Received",
  group = "Referendum Entity",
  type = "Referendum"
)
```

#### *Sample Data (Received):*

| Event           | Name       | Donor name        | Date                   | Value |
|:----------------|:-----------|:------------------|:-----------------------|------:|
| 2023 Referendum | Jabree Ltd | MaiTri Foundation | 27/06/2023 12:00:00 AM | 54000 |

### Returns

#### *Example Usage:*

``` r
df <- get_disclosure_data(
  file_name = "Returns",
  group = "Donor", # OR "Referendum Entity"
  type = "Referendum"
)
```

#### *Sample Data (Donor):*

| Event           | Event ID | Name           | ClientFileID | ABN         | ACN | Total donations made |
|:----------------|---------:|:---------------|-------------:|:------------|:----|---------------------:|
| 2023 Referendum |    29581 | Aarnja Limited |        47503 | 74159924900 | NA  |                1e+05 |

#### *Sample Data (Referendum Entity):*

| Event           | Event ID | Name            | ClientFileID | ABN         | ACN | Total donations received | Total number of donors | Total referendum expenditure |
|:----------------|---------:|:----------------|-------------:|:------------|:----|-------------------------:|-----------------------:|-----------------------------:|
| 2023 Referendum |    29581 | Advance Aus Ltd |        47334 | 55628503702 | NA  |                  1320089 |                   9400 |                     10439901 |
