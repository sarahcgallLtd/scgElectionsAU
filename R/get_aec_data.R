#' @include utils.R
NULL
#' Download and Process AEC Data
#'
#' This function is designed to download and process data from the Australian Electoral Commission
#' (AEC) based on specified criteria. It utilises several internal helper functions to validate
#' input parameters, construct URLs, and check file availability before downloading and processing the data.
#'
#' @param file_name The name of the file to download, which is used to construct the download URL
#'        and to filter internal metadata for validations.
#' @param date_range A list containing the 'from' and 'to' dates defining the period for which data
#'        is required. Dates should be formatted as 'YYYY-MM-DD'.
#' @param type The type of election or event to filter the data, possible values are
#'        'Federal Election' and 'Referendum'.
#' @param category The category of the data to be downloaded, possible options are 'House', 'Senate',
#'        and 'General'.
#' @param process A logical flag indicating whether additional processing steps (like standardising
#'        column names) should be performed on the downloaded data. Defaults to FALSE.
#'
#' @return A data frame combining all downloaded data, supplemented with relevant information from
#'         internal metadata, and optionally processed for standardisation.
#'
#' @examples
#' \dontrun{
#' get_aec_data(
#'   file_name = "National list of candidates",
#'   date_range = list(from = "2022-01-01", to = "2023-01-01"),
#'   type = "Federal Election",
#'   category = "House",
#'   process = FALSE
#' )
#' }
#'
#' @importFrom scgUtils get_file
#' @export
get_aec_data <- function(
  file_name,
  date_range = list(from = "2022-01-01", to = "2023-01-01"),
  type = c("Federal Election", "Referendum"),
  category = c("House","Senate","General"),
  process = FALSE
) {
  # =====================================#
  # CHECK PARAMS
  type <- match.arg(type)
  category <- match.arg(category)

  check_params(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category,
    process = process
  )

  # =====================================#
  # GET AND PROCESS INTERNAL DATA
  info <- get_internal_info(date_range, type)

  # Get list of events
  events <- as.character(info$event)

  # Check if events has 1 or more event
  if (length(events) == 0) {
    stop("Check that the `date_range` captures election periods between 2004 and 2022, inclusively.")
  }

  # =====================================#
  # CHECK THAT THE FILE EXISTS
  check_file_exists(file_name, category, events)

  # =====================================#
  # GET DATA AND COMBINE TO ONE DF
  # Initliase an empty df to store all data
  combined_df <- data.frame()

  for (ref in info$aec_reference) {
    # =====================================#
    # Construct URL
    url <- construct_url(ref, file_name, category)

    # =====================================#
    # GET DATA FILE FROM URL
    message(paste0("Downloading `", file_name, "` from ", url))
    tmp_df <- scgUtils::get_file(url, source = "web", row_no = 1)

    # =====================================#
    # PREPARE INFO DATA
    # Filter info by AEC Reference
    tmp_info <- info[info$aec_reference == ref,]
    message(paste0("Successfully downloaded `", file_name, "` for the ", tmp_info$event, " ", tmp_info$type))

    # Select necessary columns only
    tmp_info <- tmp_info[, !(names(tmp_info) %in% c("aec_reference", "type"))]

    # =====================================#
    # APPEND DATA
    # Append info data to downloaded data and fill
    tmp_df <- cbind(tmp_info, tmp_df)

    # Append to the combined DataFrame
    combined_df <- try_combine(combined_df, tmp_df)
  }

  # =====================================#
  # PROCESS DATA
  if (process) {
    # Process data, e.g., standardise column names across all years
    combined_df <- switch(
      file_name,
      # Processing functions:
      "National list of candidates" = process_candidates(data=combined_df, prefix=category),

      # Default return if none of the cases match
      combined_df
    )
  }

  return(combined_df)
}


get_internal_info <- function(
  date_range,
  type
) {
  # Get internal info data
  info <- get0("info", envir = asNamespace("scgElectionsAU"))

  if (is.null(info)) {
    stop("Info data not available in 'scgElectionsAU' namespace.")
  }

  # Filter info by date range provided
  info <- info[info$date >= date_range$from & info$date <= date_range$to, ]

  # Filter by Type
  info <- info[info$type == type, ]

  return(info)
}

# ======================================================================================================================
# PROCESSING
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
