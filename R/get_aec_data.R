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
  category = c("House", "Senate", "General"),
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

  for (i in seq_along(info$aec_reference)) {
    ref <- info$aec_reference[i]
    event <- info$event[i]
    # =====================================#
    # Construct URL
    url <- construct_url(ref, event, file_name, category)

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
    combined_df <- process_init(combined_df, file_name, category, event)
  }
  # =====================================#
  # RETURN DATA
  return(combined_df)
}

#' Get Internal Election Information
#'
#' Retrieves and filters internal metadata about Australian elections based on a specified date range
#' and election type.
#'
#' @param date_range A list with 'from' and 'to' dates in 'YYYY-MM-DD' format specifying the
#'        period of interest.
#' @param type The type of election, either "Federal Election" or "Referendum".
#'
#' @return A data frame containing filtered election metadata, including columns
#'         such as `date`, `event`, `type`, and `aec_reference`.
#'
#' @details This function accesses the internal `info` dataset from the `scgElectionsAU`
#' package namespace. It filters the data to include only records within the specified `date_range`
#' and matching the given `type`. If the `info` dataset is not available, it stops with an error.
#'
#' @examples
#' \dontrun{
#' info <- get_internal_info(date_range = list(from = "2004-01-01", to = "2022-12-31"),
#'                           type = "Federal Election")
#' }
#'
#' @noRd
#' @keywords internal
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
  info <- info[info$date >= date_range$from & info$date <= date_range$to,]

  # Filter by Type
  info <- info[info$type == type,]

  return(info)
}

# ======================================================================================================================
# PROCESSING
#' Initialise Data Processing
#'
#' Determines and applies the appropriate processing function to election data based
#' on file name, category, and event.
#'
#' @param data The data frame to be processed.
#' @param file_name The name of the file being processed (e.g., "National list of candidates").
#' @param category The category of the data, one of "House", "Senate", or "General".
#' @param event The specific election event (e.g., "2022"), typically a year or identifier.
#'
#' @return The processed data frame if a processing function is applied, or the original
#'         data frame if no processing is required.
#'
#' @details This function uses the `aec_names_fed` dataset from the `scgElectionsAU` package
#' to look up a processing function based on the `file_name`, `category`, and `event`. If
#' exactly one matching function is found, it is applied to the data. If multiple functions
#' match, it stops with an error. If no function is found, it returns the data unchanged
#' with a message indicating no processing was required.
#'
#' @examples
#' \dontrun{
#' processed_data <- process_init(data,
#'                                file_name = "National list of candidates",
#'                                category = "House",
#'                                event = "2022")
#' }
#'
#' @noRd
#' @keywords internal
process_init <- function(data, file_name, category, event) {
  # Get names from the 'aec_names_fed' data available in scgElectionsAU package
  names <- get0("aec_names_fed", envir = asNamespace("scgElectionsAU"))

  # Look up the processing function from the CSV index
  proc_func_name <- names$processing_function[
    names$file_name == file_name &
      names$prefix == category &
      names[[event]] == "Y"  # Check the specific event column
  ]

  # Remove NAs
  proc_func_name <- proc_func_name[is.na(proc_func_name) == FALSE]

  # Proceed if there’s exactly one valid function name
  if (length(proc_func_name) == 1 && !is.na(proc_func_name)) {
    # Get the function name
    proc_func <- tryCatch(
      match.fun(proc_func_name),
      error = function(e) stop(paste("Processing function", proc_func_name, "not found."))
    )

    # Apply the function
    processed_df <- proc_func(data = data)

  } else if (length(proc_func_name) > 1) {
    stop("Multiple processing functions found for this file_name and category.")

  } else {
    message("No processing required. Data returned unprocessed.")
  }

  return(processed_df)
}


#' Processing function for adding Elected Columns
#'
#' This function addresses the issue that the 2004 dataset lacks 'Elected' or 'HistoricElected' columns.
#' It updates the 'HistoricElected' status based on the 'SittingMemberFl' field for the 2004 election,
#' removes the 'SittingMemberFl' column, and adds an 'Elected' column for the 2004 election based on data
#' fetched using the specified prefix to differentiate between House and Senate data. The Senate data uses
#' composite keys for matching, while the House uses direct CandidateID matching.
#'
#' @param data A dataframe containing the national list of candidates.
#'
#' @return A modified dataframe with updated 'HistoricElected' and 'Elected' statuses for 2004 and the
#'         'SittingMemberFl' column removed.
#'
#' @noRd
#' @keywords internal
process_elected <- function(data) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2004 data (Make `SittingMemberFl` = `Elected`)
  data$Elected <- ifelse(data$event == "2004" & !is.na(data$SittingMemberFl), "Y", "N")
  data$HistoricElected <- ifelse(data$event == "2004", NA, data$HistoricElected)

  # Remove `SittingMemberFl` column
  data <- data[, !names(data) %in% "SittingMemberFl"]

  # TODO: Find a way to add HistoricVote for 2004 - which dataset contains this?

  # Return updated data
  return(data)
}


#' Process Representative Data
#'
#' Standardises column names for representative election data from older
#' elections (2004-2010).
#'
#' @param data The data frame containing representative election data, with
#'        columns such as `event`, `Total`, `LastElectionTotal`, and `PartyAb`.
#'
#' @return The data frame with standardised column names (`National` and `LastElection`)
#'         and unnecessary columns removed.
#'
#' @details For elections in 2004, 2007, and 2010, this function maps `Total` to
#' `National` and `LastElectionTotal` to `LastElection` where `Total` and `LastElectionTotal`
#' are not NA. It then removes the `Total`, `LastElectionTotal`, and `PartyAb` columns to
#' align the data with newer election formats.
#'
#' @examples
#' \dontrun{
#' standardised_data <- process_reps(data)
#' }
#'
#' @noRd
#' @keywords internal
process_reps <- function(data) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2004-2010 data (Make `National` = `Total` & `LastElection` = `LastElectionTotal`)
  data$National <- ifelse(data$event %in% c("2004", "2007", "2010") & !is.na(data$Total),
                          data$Total, data$National)
  data$LastElection <- ifelse(data$event %in% c("2004", "2007", "2010") & !is.na(data$LastElectionTotal),
                              data$LastElectionTotal, data$LastElection)

  # Remove `Total`, `LastElectionTotal` and `PartyAb` columns
  data <- data[, !names(data) %in% c("Total", "LastElectionTotal", "PartyAb")]

  # Return updated data
  return(data)
}


#' Process Coordinate Data
#'
#' Fills in missing latitude and longitude values for polling places using a
#' reference set derived from the data.
#'
#' @param data The data frame containing polling place data, with columns
#'        `PollingPlaceID`, `Latitude`, and `Longitude`.
#'
#' @return The data frame with missing `Latitude` and `Longitude`
#'         values filled in where possible.
#'
#' @details This function creates a reference set of unique polling places
#' with non-missing coordinates (`Latitude` and `Longitude`) based on `PollingPlaceID`.
#' It then uses this reference to impute missing coordinate values in the main dataset,
#' ensuring all polling places have location data where available.
#'
#' @examples
#' \dontrun{
#' complete_data <- process_coords(data)
#' }
#'
#' @noRd
#' @keywords internal
process_coords <- function(data) {
  message("Processing to ensure all data aligns across all election years.")

  # Create reference dataframe with non-NA coordinates
  ref <- data[!is.na(data$Latitude) & !is.na(data$Longitude), c("PollingPlaceID", "Latitude", "Longitude")]
  ref <- unique(ref)

  # Fill in missing Latitude and Longitude values
  data$Latitude[is.na(data$Latitude)] <- ref$Latitude[match(data$PollingPlaceID[is.na(data$Latitude)], ref$PollingPlaceID)]
  data$Longitude[is.na(data$Longitude)] <- ref$Longitude[match(data$PollingPlaceID[is.na(data$Longitude)], ref$PollingPlaceID)]

  # Return updated data
  return(data)
}


#' Process Pre-Poll Data
#'
#' Standardises column names for pre-poll voting data from elections
#' between 2004 and 2013.
#'
#' @param data The data frame containing pre-poll voting data, with columns
#'        such as `event`, `PrePollVotes`, and `PrePollPercentage`.
#'
#' @return The data frame with standardised column names (`DeclarationPrePollVotes`
#'         and `DeclarationPrePollPercentage`) and original columns removed.
#'
#' @details For elections in 2004, 2007, 2010, and 2013, this function maps
#' `PrePollVotes` to `DeclarationPrePollVotes` and `PrePollPercentage` to
#' `DeclarationPrePollPercentage` where the original columns are not NA. It then
#' removes `PrePollVotes` and `PrePollPercentage` to align with newer data formats.
#'
#' @examples
#' \dontrun{
#' standardised_data <- process_prepoll(data)
#' }
#'
#' @noRd
#' @keywords internal
process_prepoll <- function(data) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2004-2010 data (Make `DeclarationPrePollVotes` = `PrePollVotes` & `DeclarationPrePollPercentage` = `PrePollPercentage`)
  data$DeclarationPrePollVotes <- ifelse(data$event %in% c("2004", "2007", "2010", "2013") & !is.na(data$PrePollVotes),
                                         data$PrePollVotes, data$DeclarationPrePollVotes)
  data$DeclarationPrePollPercentage <- ifelse(data$event %in% c("2004", "2007", "2010", "2013") & !is.na(data$PrePollPercentage),
                                              data$PrePollPercentage, data$DeclarationPrePollPercentage)

  # Remove `PrePollVotes` and `PrePollPercentage` columns
  data <- data[, !names(data) %in% c("PrePollVotes", "PrePollPercentage")]

  # Return updated data
  return(data)
}


#' Process Group Data
#'
#' Standardises group or ticket information for elections from 2004 to 2019.
#'
#' @param data The data frame containing group or ticket data, with columns
#'        such as `event`, `Ticket`, and optionally `SittingMemberFl`.
#'
#' @return The data frame with standardised `Group` column and `Ticket`
#'         column removed, and elected status processed if applicable.
#'
#' @details For elections in 2004, 2007, 2010, 2013, 2016, and 2019, this function
#' maps `Ticket` to `Group` where `Ticket` is not NA and removes the `Ticket` column.
#' If a `SittingMemberFl` column is present, it calls `process_elected` to handle elected
#' status, ensuring compatibility across election years.
#'
#' @examples
#' \dontrun{
#' standardised_data <- process_group(data)
#' }
#'
#' @noRd
#' @keywords internal
process_group <- function(data) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2004-2010 data (Make `Group` = `Ticket`)
  data$Group <- ifelse(data$event %in% c("2004", "2007", "2010", "2013", "2016", "2019") & !is.na(data$Ticket),
                       data$Ticket, data$Group)

  # Remove `Ticket` column
  data <- data[, !names(data) %in% "Ticket"]

  if ("SittingMemberFl" %in% colnames(data)) {
    data <- process_elected(data)
  }

  # Return updated data
  return(data)
}
