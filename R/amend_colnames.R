#' Standardise Column Names for Consistency
#'
#' This internal helper function renames specific columns in a data frame to ensure consistency across
#' datasets. It checks for predefined column names and renames them to standardised equivalents using
#' the `rename_cols` function. The function is designed to facilitate uniform data processing within
#' the package by aligning column names to a consistent format.
#'
#' @param data A data frame containing columns to be renamed. The function checks for the presence of
#'   specific columns and renames them if found. Columns checked and their corresponding new names include:
#'   \itemize{
#'     \item "State" to "StateAb"
#'     \item "Division" to "DivisionNm"
#'     \item "DivisionId" to "DivisionID"
#'     \item "TransactionId" to "TransactionID"
#'     \item "PPId" to "PollingPlaceID"
#'     \item "PPNm" to "PollingPlaceNm"
#'     \item "PollingPlace" to "PollingPlaceNm"
#'     \item "Party" to "PartyNm"
#'     \item "PartyName" to "PartyNm"
#'     \item "CandidateId" to "CandidateID"
#'     \item "CandidateId1" to "CandidateID1"
#'     \item "CandidateId2" to "CandidateID2"
#'     \item "ToCandidateId" to "ToCandidateID"
#'     \item "FromCandidateId" to "FromCandidateID"
#'     \item "Ticket" to "Group"
#'     \item "GroupAb" to "PartyGroupAb"
#'     \item "GroupNm" to "PartyGroupNm"
#'     \item "SittingMemberFl" to "Elected"
#'     \item "CountNum" to "CountNumber"
#'     \item "DeclarationPrePollVotes" to "PrePollVotes"
#'     \item "DeclarationPrePollPercentage" to "PrePollPercentage"
#'     \item "TransferPercent" to "TransferPercentage"
#'   }
#'
#' @return A data frame with the same structure as the input, but with renamed columns where applicable.
#'   Columns not listed above remain unchanged.
#'
#' @details
#' This function is an internal helper and is not exported. It is used to standardise column names
#' across different datasets to ensure consistency in data processing workflows. The renaming is
#' conditional, only occurring if the specified columns are present in the input data frame.
#'
#' @examples
#' # Sample data with columns to be renamed
#' \dontrun{
#'      data <- data.frame(
#'          State = "VIC",
#'          Division = "Melbourne",
#'          Party = "ALP",
#'          CandidateId1 = 12345
#'      )
#'      amend_colnames(data)
#' }
#'
#' @export
amend_colnames <- function(data) {
  # State ===============================================================#
  if ("State" %in% names(data)) {
    data <- rename_cols(data, StateAb = "State")
  }

  # Division ============================================================#
  if ("Division" %in% names(data)) {
    data <- rename_cols(data, DivisionNm = "Division")
  }

  if ("DivisionId" %in% names(data)) {
    data <- rename_cols(data, DivisionID = "DivisionId")
  }

  # Transaction =========================================================#
  if ("TransactionId" %in% names(data)) {
    data <- rename_cols(data, TransactionID = "TransactionId")
  }

  # Polling Place =======================================================#
  if ("PPId" %in% names(data)) {
    data <- rename_cols(data, PollingPlaceID = "PPId")
  }

  if ("PPNm" %in% names(data)) {
    data <- rename_cols(data, PollingPlaceNm = "PPNm")
  }

  if ("PollingPlace" %in% names(data)) {
    data <- rename_cols(data, PollingPlaceNm = "PollingPlace")
  }

  # Party ================================================================#
  if ("Party" %in% names(data)) {
    data <- rename_cols(data, PartyNm = "Party")
  }

  if ("PartyName" %in% names(data)) {
    data <- rename_cols(data, PartyNm = "PartyName")
  }

  # Candidate =============================================================#
  if ("CandidateId" %in% names(data)) {
    data <- rename_cols(data, CandidateID = "CandidateId")
  }

  if ("CandidateId1" %in% names(data)) {
    data <- rename_cols(data, CandidateID1 = "CandidateId1")
  }

  if ("CandidateId2" %in% names(data)) {
    data <- rename_cols(data, CandidateID2 = "CandidateId2")
  }

  if ("ToCandidateId" %in% names(data)) {
    data <- rename_cols(data, ToCandidateID = "ToCandidateId")
  }

  if ("FromCandidateId" %in% names(data)) {
    data <- rename_cols(data, FromCandidateID = "FromCandidateId")
  }

  # Group =================================================================#
  if ("Ticket" %in% names(data)) {
    data <- rename_cols(data, Group = "Ticket")
  }

  if ("GroupAb" %in% names(data)) {
    data <- rename_cols(data, PartyGroupAb = "GroupAb")
  }

  if ("GroupNm" %in% names(data)) {
    data <- rename_cols(data, PartyGroupNm = "GroupNm")
  }

  # Elected ===============================================================#
  if ("SittingMemberFl" %in% names(data)) {
    data <- rename_cols(data, Elected = "SittingMemberFl")
  }

  # Count =================================================================#
  if ("CountNum" %in% names(data)) {
    data <- rename_cols(data, CountNumber = "CountNum")
  }

  # DeclarationPrePoll =====================================================#
  if ("PrePollVotes" %in% names(data)) {
    data <- rename_cols(data, DeclarationPrePollVotes = "PrePollVotes")
  }

  if ("PrePollPercentage" %in% names(data)) {
    data <- rename_cols(data, DeclarationPrePollPercentage = "PrePollPercentage")
  }

  # Transfer  ==============================================================#
  if ("TransferPercent" %in% names(data)) {
    data <- rename_cols(data, TransferPercentage = "TransferPercent")
  }

  return(data)
}