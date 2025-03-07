#' Processing function for National List of Candidates
#'
#' This function addresses the issue that the 2004 dataset lacks 'Elected' or 'HistoricElected' columns.
#' It updates the 'HistoricElected' status based on the 'SittingMemberFl' field for the 2004 election,
#' removes the 'SittingMemberFl' column, and adds an 'Elected' column for the 2004 election based on data
#' fetched using the specified prefix to differentiate between House and Senate data. The Senate data uses
#' composite keys for matching, while the House uses direct CandidateID matching.
#'
#' @param data A dataframe containing the national list of candidates.
#' @param prefix A character string indicating whether the data pertains to the "House" or "Senate".
#'               This affects which file is fetched for cross-referencing elected members.
#'
#' @return A modified dataframe with updated 'HistoricElected' and 'Elected' statuses for 2004 and the
#'         'SittingMemberFl' column removed.
#'
#' @noRd
process_candidates <- function(
  data,
  prefix
) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2004 data (Make `SittingMemberFl` = `HistoricElected`)
  data$HistoricElected <- ifelse(data$event == "2004" & !is.na(data$SittingMemberFl), "Y", "N")

  print("Processing data to ensure all columns align across all elections.")

  # Remove `SittingMemberFl` column
  data <- data[, !names(data) %in% "SittingMemberFl"]

  # Create a logical vector to select rows where the year is 2004
  update_index <- data$event == "2004"

  # Add Elected column for 2004 election
  file_name <- ifelse(prefix == "House", "Members elected", "Senators elected")
  url <- construct_url(ref = "12246", file_name = file_name, prefix)
  tmp_df <- scgUtils::get_file(url, source = "web", row_no = 1)

  if (prefix == "Senate") {
    # Create composite keys in both data and tmp_df for matching
    data$CompositeKey <- with(data, paste(PartyAb, StateAb, GivenNm, Surname, sep = "_"))
    tmp_df$CompositeKey <- with(tmp_df, paste(PartyAb, StateAb, GivenNm, Surname, sep = "_"))

    # Match using the composite key
    tmp_df <- tmp_df$CompositeKey

    # Update the Elected column based on whether the CandidateID is in the elected_ids_2004
    data$Elected[update_index] <- ifelse(data$CompositeKey[update_index] %in% tmp_df, "Y", "N")

  } else {
    # Create a vector of CandidateIDs from the 2004 elected members
    tmp_df <- tmp_df$CandidateID

    # Update the Elected column based on whether the CandidateID is in the elected_ids_2004
    data$Elected[update_index] <- ifelse(data$CandidateID[update_index] %in% tmp_df, "Y", "N")
  }

  # Clean up added composite key column if it exists
  if ("CompositeKey" %in% names(data)) data$CompositeKey <- NULL

  # Return updated data
  return(data)
}

