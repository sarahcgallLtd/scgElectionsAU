# Standardise Column Names for Consistency

This internal helper function renames specific columns in a data frame
to ensure consistency across datasets. It checks for predefined column
names and renames them to standardised equivalents using the
`rename_cols` function. The function is designed to facilitate uniform
data processing within the package by aligning column names to a
consistent format.

## Usage

``` r
amend_colnames(data)
```

## Arguments

- data:

  A data frame containing columns to be renamed. The function checks for
  the presence of specific columns and renames them if found. Columns
  checked and their corresponding new names include:

  - "State" to "StateAb"

  - "Division" to "DivisionNm"

  - "DivisionId" to "DivisionID"

  - "DivisionName" to "DivisionNm"

  - "TransactionId" to "TransactionID"

  - "PollingPlaceId" to "PollingPlaceID"

  - "PPId" to "PollingPlaceID"

  - "PPNm" to "PollingPlaceNm"

  - "PollingPlace" to "PollingPlaceNm"

  - "Party" to "PartyNm"

  - "PartyName" to "PartyNm"

  - "CandidateId" to "CandidateID"

  - "CandidateId1" to "CandidateID1"

  - "CandidateId2" to "CandidateID2"

  - "ToCandidateId" to "ToCandidateID"

  - "FromCandidateId" to "FromCandidateID"

  - "Ticket" to "Group"

  - "GroupAb" to "PartyGroupAb"

  - "GroupNm" to "PartyGroupNm"

  - "SittingMemberFl" to "Elected"

  - "CountNum" to "CountNumber"

  - "DeclarationPrePollVotes" to "PrePollVotes"

  - "DeclarationPrePollPercentage" to "PrePollPercentage"

  - "TransferPercent" to "TransferPercentage"

  - "Valid PVAs Received" to "Valid Applications Received"

  - "Valid Apps Received" to "Valid Applications Received"

  - "PVCs Returned" to "Postal Votes Returned"

  - "RATIO" to "RATIO_FROM_TO"

## Value

A data frame with the same structure as the input, but with renamed
columns where applicable. Columns not listed above remain unchanged.

## Details

This function is an internal helper and is not exported. It is used to
standardise column names across different datasets to ensure consistency
in data processing workflows. The renaming is conditional, only
occurring if the specified columns are present in the input data frame.

## Examples

``` r
# Sample data with columns to be renamed
if (FALSE) { # \dontrun{
     data <- data.frame(
         State = "VIC",
         Division = "Melbourne",
         Party = "ALP",
         CandidateId1 = 12345
     )
     amend_colnames(data)
} # }
```
