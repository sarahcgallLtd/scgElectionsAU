% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/amend_colnames.R
\name{amend_colnames}
\alias{amend_colnames}
\title{Standardise Column Names for Consistency}
\usage{
amend_colnames(data)
}
\arguments{
\item{data}{A data frame containing columns to be renamed. The function checks for the presence of
specific columns and renames them if found. Columns checked and their corresponding new names include:
\itemize{
\item "State" to "StateAb"
\item "Division" to "DivisionNm"
\item "DivisionId" to "DivisionID"
\item "DivisionName" to "DivisionNm"
\item "TransactionId" to "TransactionID"
\item "PollingPlaceId" to "PollingPlaceID"
\item "PPId" to "PollingPlaceID"
\item "PPNm" to "PollingPlaceNm"
\item "PollingPlace" to "PollingPlaceNm"
\item "Party" to "PartyNm"
\item "PartyName" to "PartyNm"
\item "CandidateId" to "CandidateID"
\item "CandidateId1" to "CandidateID1"
\item "CandidateId2" to "CandidateID2"
\item "ToCandidateId" to "ToCandidateID"
\item "FromCandidateId" to "FromCandidateID"
\item "Ticket" to "Group"
\item "GroupAb" to "PartyGroupAb"
\item "GroupNm" to "PartyGroupNm"
\item "SittingMemberFl" to "Elected"
\item "CountNum" to "CountNumber"
\item "DeclarationPrePollVotes" to "PrePollVotes"
\item "DeclarationPrePollPercentage" to "PrePollPercentage"
\item "TransferPercent" to "TransferPercentage"
\item "Valid PVAs Received" to "Valid Applications Received"
\item "Valid Apps Received" to "Valid Applications Received"
\item "PVCs Returned" to "Postal Votes Returned"
\item "RATIO" to "RATIO_FROM_TO"
}}
}
\value{
A data frame with the same structure as the input, but with renamed columns where applicable.
Columns not listed above remain unchanged.
}
\description{
This internal helper function renames specific columns in a data frame to ensure consistency across
datasets. It checks for predefined column names and renames them to standardised equivalents using
the \code{rename_cols} function. The function is designed to facilitate uniform data processing within
the package by aligning column names to a consistent format.
}
\details{
This function is an internal helper and is not exported. It is used to standardise column names
across different datasets to ensure consistency in data processing workflows. The renaming is
conditional, only occurring if the specified columns are present in the input data frame.
}
\examples{
# Sample data with columns to be renamed
\dontrun{
     data <- data.frame(
         State = "VIC",
         Division = "Melbourne",
         Party = "ALP",
         CandidateId1 = 12345
     )
     amend_colnames(data)
}

}
