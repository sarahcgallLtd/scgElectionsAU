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
  category = c("House", "Senate", "General", "Statistics"),
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
  check_df <- check_file_exists(file_name, category)

  # =====================================#
  # GET DATA AND COMBINE TO ONE DF
  # Initliase an empty df to store all data
  combined_df <- data.frame()

  for (i in seq_along(info$aec_reference)) {
    ref <- info$aec_reference[i]
    event <- info$event[i]

    # Check if data is available for this event
    if (!any(check_df[[event]] == "Y", na.rm = TRUE)) {
      message(paste0("Skipping `", file_name, "` for the year `", event, "` as it is not available."))
      next
    }

    # =====================================#
    # Construct URL
    url <- construct_url(ref, event, file_name, category, type)

    # =====================================#
    # GET DATA FILE FROM URL
    message(paste0("Downloading `", file_name, "` from ", url))
    row_no <- ifelse(category == "Statistics", 0, 1)
    tmp_df <- suppressMessages(
      scgUtils::get_file(url, source = "web", row_no = row_no)
    )

    # =====================================#
    # PREPARE INFO DATA
    # Filter info by AEC Reference
    tmp_info <- info[info$aec_reference == ref,]
    message(paste0("Successfully downloaded `", file_name, "` for the ", tmp_info$event, " ", tmp_info$type))

    # Select necessary columns only
    tmp_info <- tmp_info[, (names(tmp_info) %in% c("date", "event"))]

    # =====================================#
    # APPEND DATA
    # Append info data to downloaded data and fill
    tmp_df <- cbind(tmp_info, tmp_df)

    # Preprocess Postal Votes
    if (file_name %in% c("Postal vote applications by date", "Postal vote applications by party")) {
      tmp_df <- preprocess_pva(tmp_df, file_name)
    }

    # Process if PPVC data + TRUE
    if (process & (file_name == "Pre-poll votes" || grepl("^Postal vote applications", file_name))) {
      tmp_df <- process_ppvpva(tmp_df, file_name)
    }

    # Append to the combined DataFrame
    combined_df <- try_combine(combined_df, tmp_df)
  }

  # Reset row names
  rownames(combined_df) <- NULL

  if (nrow(combined_df) == 0) {
    stop(paste0("No data was available for `", file_name, "` with the parameters used. Check the date range and try again."))
  }

  # =====================================#
  # PROCESS DATA
  if (process & (file_name != "Pre-poll votes" && !grepl("^Postal vote applications", file_name))) {
    combined_df <- process_init(combined_df, file_name, category, event)
  }
  # =====================================#
  # RETURN DATA
  return(combined_df)
}


# ======================================================================================================================
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


#' Check File and Category in AEC Dataset
#'
#' This internal function verifies the existence of a specified `file_name` and `category` in the
#' 'aec_names_fed' dataset from the 'scgElectionsAU' package. It ensures that the `file_name` is
#' present and that there is at least one corresponding entry for the given `category`. If the
#' checks pass, it returns a subset of the dataset for further use, such as checking
#' event-specific availability in `get_aec_data`. This function is a helper for `get_aec_data`
#' and is not exported.
#'
#' @param file_name The name of the file to check, corresponding to the 'file_name' column in
#'        'aec_names_fed'.
#' @param category The category (e.g., 'General', 'House', 'Senate') to check, corresponding to
#'        the 'prefix' column in 'aec_names_fed'.
#'
#' @return A data frame subset of 'aec_names_fed' filtered by the specified `file_name` and
#'         `category`. This subset can be used to verify availability for specific events (years)
#'         in `get_aec_data`.
#'
#' @examples
#' dontrun{
#'   check_df <- check_file_exists("National list of candidates", "House")
#'   # Use check_df in get_aec_data to check event-specific availability
#' }
#'
#' @noRd
#' @keywords internal
check_file_exists <- function(
  file_name,
  category
) {
  # Get names from the 'aec_names_fed' data available in scgElectionsAU package
  names <- get0("aec_names_fed", envir = asNamespace("scgElectionsAU"))

  # Check if 'names' data is available
  if (is.null(names)) {
    stop("Data 'aec_names_fed' not found in 'scgElectionsAU' package. Contact the package maintainer.")
  }

  # Check if file_name exists
  if (!all(file_name %in% names$file_name)) {
    stop(paste0("`", file_name, "` does not exist. Check the `file_name` and try again."))
  }

  # Check that the corresponding category for the file_name exists
  check_df <- names[names$file_name == file_name & names$prefix == category,]
  if (!all(category %in% check_df$prefix)) {
    stop(paste0("`", file_name, "` for the `", category, "` category ", "does not exist. Check that the `category` is one of only 'General', 'House', or 'Senate' and try again."))
  }

  return(check_df)
}


#' Construct AEC Data Download URL
#'
#' This function constructs a URL for downloading files from the Australian Electoral Commission.
#' It is designed as a helper function for `get_aec_data()` and uses specific lookup data from
#' the 'scgElectionsAU' package. It forms URLs based on a reference ID, file name, and prefix
#' associated with the data to be downloaded.
#'
#' @param ref A character string specifying the reference ID associated with the election year
#'        or event. Different areas ('results' or 'Website') of the AEC website are used based
#'        on the value of `ref`. Each `ref` corresponds to an election year.
#' @param event A
#' @param file_name A character string specifying the name of the file to download, as recorded
#'        in the `aec_names_fed` dataset. This corresponds to a particular type of election data.
#' @param prefix A character string specifying the prefix that categorises the file within
#'        the AEC structure, used to correctly format the download URL. E.g., House, Senate, of
#'        General.
#'
#' @return A character string containing the fully constructed URL for the data file.
#'
#' @details This function accesses the 'aec_names_fed' dataset stored within the 'scgElectionsAU'
#'          package environment. It filters this dataset based on the `file_name` and `prefix`
#'          provided, constructs a URL, and ensures that exactly one entry matches the given
#'          parameters to prevent errors in URL construction. Error handling is robust, providing
#'          clear messages for potential issues such as missing data or multiple matching entries.
#'
#' @examples
#' # Assuming 'aec_names_fed' and the necessary variables are properly defined:
#' construct_url("27966", "National list of candidates", "House")
#'
#' @noRd
#' @keywords internal
construct_url <- function(
  ref,
  event,
  file_name,
  prefix,
  type
) {
  if (prefix == "Statistics") {

    # Get url from the 'info' data available in scgElectionsAU package
    info <- get0("info", envir = asNamespace("scgElectionsAU"))

    # Set the key based on pattern matching
    key <- if (grepl("^Postal vote applications", file_name)) {
      "Postal vote applications"
    } else {
      file_name
    }

    url <- switch(key,
                  "Postal vote applications" = {
                    info$postal[info$event == event &
                                  info$type == type]
                  },
                  "Pre-poll votes" = {
                    info$prepoll[info$event == event &
                                   info$type == type]
                  },
                  "Votes by SA1" = {
                    info$votes[info$event == event &
                                 info$type == type]
                  },
                  "Overseas" = {
                    info$overseas[info$event == event &
                                    info$type == type]
                  }
    )
  } else {
    base_url <- "https://results.aec.gov.au/"
    area <- ifelse(ref == "12246", "results", "Website")

    # Get names from the 'aec_names_fed' data available in scgElectionsAU package
    names <- get0("aec_names_fed", envir = asNamespace("scgElectionsAU"))

    # Check if names is non-null
    if (is.null(names)) {
      stop("Data 'aec_names_fed' not found in 'scgElectionsAU' package. Contact the package maintainer.")
    }

    # Filter by file_name, prefix, and event availability
    filtered_names <- names[names$file_name == file_name &
                              names$prefix == prefix &
                              names[[event]] == "Y",]

    # Check if any entries are found
    if (nrow(filtered_names) == 0) {
      stop("No entries found for specified file_name and prefix.")
    }

    # Assuming only one entry should be found for each unique file_name and prefix combination
    if (nrow(filtered_names) > 1) {
      stop("Multiple entries found for specified file_name and prefix. Expected only one.")
    }

    # Construct URL
    url <- paste0(base_url, ref, "/", area, "/", filtered_names$download_folder, "/",
                  filtered_names$prefix, filtered_names$download_name, "Download-", ref,
                  filtered_names$file_type)
  }

  return(url)
}

# ======================================================================================================================
#' Preprocess Postal Vote Application Data
#'
#' @param data A data frame containing postal vote application data.
#' @param file_name A character string specifying the type of data file, either
#'   "Postal vote applications by party" or "Postal vote applications by date".
#'
#' @return A data frame with columns filtered based on the specified file type.
#'
#' @noRd
#' @keywords internal
preprocess_pva <- function(data, file_name) {
  if (file_name == "Postal vote applications by party") {
    # Keep columns
    data <- data[, names(data) %in% c("date", "event", "State_Cd", "State", "PVA_Web_1_Party_Div", "Enrolment Division",
                                      "Division", "Enrolment",
                                      "AEC - OPVA", "AEC - Paper", "AEC (Online)", "AEC (Paper)", "AEC",
                                      "ALP", "CLP", "DEM", "GPV", "GRN", "LIB", "LNP", "NAT", "OTH",
                                      "Country Liberal", "Greens", "Labor", "Liberal", "Liberal-National",
                                      "National", "Other Party", "Sum of AEC and Parties")]

  } else if (file_name == "Postal vote applications by date") {
    # Remove columns
    data <- data[, !names(data) %in% c("PVA_Web_1_Party_Div", "AEC - OPVA", "AEC - Paper", "AEC (Online)", "AEC (Paper)",
                                       "AEC", "ALP", "CLP", "DEM", "GPV", "GRN", "LIB", "LNP", "NAT", "OTH",
                                       "Sum of AEC and Parties",
                                       "Country Liberal", "Greens", "Labor", "Liberal", "Liberal-National",
                                       "National", "Other Party")]
    # Remove columns that contain three dots anywhere in the name
    data <- data[, !grepl("^\\.\\.\\.", names(data))]

  }

  return(data)
}

#' Process PPVC + PVA Data for a Single Event
#'
#' Processes Pre-Poll Voting Centre (PPVC) and Postal Vote APplication (PVA) data for a single election event,
#' standardising columns across years and transforming the data into a long
#' format with properly formatted dates.
#'
#' @param data A data frame with PPVC data for one election event. Must include
#' an 'event' column with a single unique value (e.g., "2013", "2016", "2019", "2022").
#' Additional required columns vary by event year.
#' @param file_name The name of the file downloaded
#'
#' @return A data frame with standardised columns: 'date', 'event', 'State',
#' 'Division', 'PPVC', 'Issue Date', and 'Total Votes'. 'Issue Date' is a Date object.
#'
#' @noRd
#' @keywords internal
process_ppvpva <- function(data, file_name) {
  # Ensure data is for a single event
  event <- unique(data$event)
  if (length(event) != 1) {
    stop("Data should contain only one event.")
  }
  event <- event[1]  # Extract the single event value

  if (file_name == "Pre-poll votes") {
    # Step 1: Standardise columns across years
    # Amend 2016-2019 data (Make `State` = `m_state_ab` and `Division` = `m_div_nm`)
    if (event %in% c("2016", "2019")) {
      data$State <- data$m_state_ab
      data$Division <- data$m_div_nm
    }

    # Ensure PPVC column exists
    if (!"PPVC" %in% names(data)) {
      data$PPVC <- NA
    }

    # For 2013, 2016, 2019: Set PPVC from m_pp_nm
    if (event %in% c("2013", "2016", "2019")) {
      data$PPVC <- data$m_pp_nm
    }

    # Remove `m_` columns
    data <- data[, !names(data) %in% c("m_state_ab", "m_div_nm", "m_pp_nm")]

    # Step 2: Define columns for output
    id_cols <- c("date", "event", "State", "Division", "PPVC")
    long_cols <- c("Issue Date", "Total Votes")
    names_to <- "Issue Date"
    values_to <- "Total Votes"

    # Step 3: Process based on event year
    if (event == "2022") {
      # For 2022: Select identifier and long-format columns
      data <- data[, c(id_cols, long_cols), drop = FALSE]
    } else {
      # For other years, pivot date columns into long format
      data <- pivot_event(data, id_cols, long_cols, names_to, values_to)
    }

    # Step 4: Convert Issue Date to date object
    formats <- list(
      "2022" = "%d/%m/%y",    # e.g., "09/05/22"
      "2019" = "%d/%m/%Y",    # e.g., "29/04/2019"
      "2016" = "%Y-%m-%d",    # e.g., "2016-06-14"
      "2013" = "%d/%m/%Y",    # e.g., "20/08/2013"
      "2010" = "%d %b %y"     # e.g., "02 Aug 10"
    )
    if (event %in% names(formats)) {
      data$"Issue Date" <- as.Date(data$"Issue Date", format = formats[[event]])
    }

  } else if (grepl("^Postal vote applications", file_name)) {
    # Step 1: Standardise columns across years
    # Amend State and Division Metadata

    if (event %in% c("2016", "2019")) {
      data$State <- data$State_Cd
      if (file_name == "Postal vote applications by party") {
        data$Division <- data$PVA_Web_1_Party_Div
      } else {
        if (event == "2016") {
          data$Division <- data$PVA_Web_2_Date_Div
        } else if (event == "2019") {
          data$Division <- data$PVA_Web_2_Date_V2_Div
        }
      }


    } else if (event == "2013") {
      data$State <- ifelse(data$`Enrolment Division` %in% c("To be Determined*", "Withdrawn, Duplicate, Rejected"),
                           "ZZZ", data$State)
      data$Division <- ifelse(data$State != "ZZZ", toupper(data$`Enrolment Division`), data$`Enrolment Division`)

    } else if (event == "2010") {
      data$Division <- data$Enrolment

    }

    data$State <- toupper(data$State)

    # Remove columns
    data <- data[, !names(data) %in% c("State_Cd", "PVA_Web_1_Party_Div", "Enrolment Division", "Enrolment",
                                       "PVA_Web_2_Date_Div", "PVA_Web_2_Date_V2_Div", "TOTAL to date",
                                       "TOTAL to date (Inc GPV)")]

    # Filter out total row in 2013
    data <- data[!is.na(data$Division),]

    if (file_name == "Postal vote applications by party") {
      if (event %in% c("2016", "2019")) {
        data$`AEC (Online)` <- data$`AEC - OPVA`
        data$`AEC (Paper)` <- data$`AEC - Paper`
      } else if (event == "2010") {
        data$`AEC (Total)` <- data$AEC
      }

      if (event %in% c("2013", "2016", "2019")) {
        data$`AEC (Total)` <- data$`AEC (Online)` + data$`AEC (Paper)`
      }

      if (event %in% c("2010", "2013")) {
        data$ALP <- data$Labor
        data$CLP <- data$`Country Liberal`
        data$GRN <- data$Greens
        data$LIB <- data$Liberal
        data$LNP <- data$`Liberal-National`
        data$NAT <- data$National
        data$OTH <- data$`Other Party`
      }

      if (event %in% c("2010", "2013", "2016")) {
        data$DEM <- NA
      }

      if (event == "2010") {
        data$GVP <- NA
      }

      if (event != "2010") {
        cols_to_sum <- c("AEC (Total)", "GPV", "ALP", "CLP", "DEM", "GRN", "LIB", "LNP", "NAT", "OTH")
        data$`Sum of AEC and Parties` <- rowSums(data[, cols_to_sum[cols_to_sum %in% names(data)]], na.rm = TRUE)
      }

      # Keep selected columns and reorder
      columns_to_keep <- c("date", "event", "State", "Division", "Sum of AEC and Parties",
                           "AEC (Total)", "AEC (Online)", "AEC (Paper)", "GPV",
                           "ALP", "CLP", "DEM", "GRN", "LIB", "LNP", "NAT", "OTH")
      data <- data[, columns_to_keep[columns_to_keep %in% names(data)], drop = FALSE]

    } else if (file_name == "Postal vote applications by date") {

    }
    # Step 2: Define columns for output
    id_cols <- c("date", "event", "State", "Division")
    long_cols <- c("Date Received", "Total PVAs")
    names_to <- "Date Received"
    values_to <- "Total PVAs"

    # Step 3: Pivot date columns into long format
    data <- pivot_event(data, id_cols, long_cols, names_to, values_to)

    # Step 4: Convert Issue Date to date object
    formats <- list(
      "2019" = "%Y%m%d",    # e.g., "2019/04/11"
      "2016" = "%Y%m%d",    # e.g., "2016/06/14"
      "2013" = "%d-%b-%y",    # e.g., "20-Aug-13"
      "2010" = "%d %b %y"     # e.g., "02 Aug 10"
    )
    if (event %in% names(formats)) {
      data$"Date Received" <- as.Date(data$"Date Received", format = formats[[event]])
    }
  }

  # Return processed data
  return(data)

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
  if (unique(data$event == "2004")) {
    message("Processing data to ensure all columns align across all elections.")

    # Amend 2004 data (Make `SittingMemberFl` = `Elected`)
    data$Elected <- ifelse(data$event == "2004" & !is.na(data$SittingMemberFl), "Y", "N")
    data$HistoricElected <- ifelse(data$event == "2004", NA, data$HistoricElected)

    # Remove `SittingMemberFl` column
    data <- data[, !names(data) %in% "SittingMemberFl"]

    # TODO: Find a way to add HistoricVote for 2004 - which dataset contains this?

  } else {
    message("No processing required. Data returned unprocessed.")
  }

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
  if (unique(data$event %in% c("2004", "2007", "2010"))) {
    message("Processing data to ensure all columns align across all elections.")

    # Amend 2004-2010 data (Make `National` = `Total` & `LastElection` = `LastElectionTotal`)
    data$National <- ifelse(data$event %in% c("2004", "2007", "2010") & !is.na(data$Total),
                            data$Total, data$National)
    data$LastElection <- ifelse(data$event %in% c("2004", "2007", "2010") & !is.na(data$LastElectionTotal),
                                data$LastElectionTotal, data$LastElection)

    # Remove `Total`, `LastElectionTotal` and `PartyAb` columns
    data <- data[, !names(data) %in% c("Total", "LastElectionTotal", "PartyAb")]

  } else {
    message("No processing required. Data returned unprocessed.")
  }

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
  if (unique(data$event) %in% c("2004", "2007", "2010", "2013")) {
    message("Processing data to ensure all columns align across all elections.")

    # Amend 2004-2010 data (Make `DeclarationPrePollVotes` = `PrePollVotes` & `DeclarationPrePollPercentage` = `PrePollPercentage`)
    data$DeclarationPrePollVotes <- ifelse(data$event %in% c("2004", "2007", "2010", "2013") & !is.na(data$PrePollVotes),
                                           data$PrePollVotes, data$DeclarationPrePollVotes)
    data$DeclarationPrePollPercentage <- ifelse(data$event %in% c("2004", "2007", "2010", "2013") & !is.na(data$PrePollPercentage),
                                                data$PrePollPercentage, data$DeclarationPrePollPercentage)

    # Remove `PrePollVotes` and `PrePollPercentage` columns
    data <- data[, !names(data) %in% c("PrePollVotes", "PrePollPercentage")]

  } else {
    message("No processing required. Data returned unprocessed.")
  }

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
  if (unique(data$event %in% c("2004", "2007", "2010", "2013", "2016", "2019"))) {
    message("Processing data to ensure all columns align across all elections.")

    # Amend 2004-2010 data (Make `Group` = `Ticket`)
    data$Group <- ifelse(data$event %in% c("2004", "2007", "2010", "2013", "2016", "2019") & !is.na(data$Ticket),
                         data$Ticket, data$Group)

    # Remove `Ticket` column
    data <- data[, !names(data) %in% "Ticket"]

  } else {
    message("No processing required. Data returned unprocessed.")
  }

  if ("SittingMemberFl" %in% colnames(data)) {
    data <- process_elected(data)
  }

  # Return updated data
  return(data)
}

#' Process Election Data
#'
#' This function standardises election data columns across different years by:
#' - Setting `votes` to `count` for the 2013 election.
#' - Setting `ccd_id` to `SA1_id` for the 2016 and 2019 elections.
#' - Removing the `SA1_id` and `count` columns.
#'
#' @param data A data frame with election data, including columns `event`, `votes`,
#'        `count`, `ccd_id`, and `SA1_id`. The `event` column should specify the
#'        election year as a string (e.g., "2013").
#'
#' @return The processed data frame with adjusted `votes` and `ccd_id` columns and
#'         without `SA1_id` and `count`.
#'
#' @noRd
#' @keywords internal
process_ccd <- function(data) {
  if (unique(data$event %in% c("2013", "2016", "2019"))) {
    message("Processing data to ensure all columns align across all elections.")
    if (unique(data$event == "2013")) {
      # Amend 2013 data (Make `votes` = `count`)
      data$votes <- ifelse(data$event == "2013", data$count, data$votes)

    } else if (unique(data$event %in% c("2016", "2019"))) {
      # Amend 2016-2019 data (Make `ccd_id` = `SA1_id`)
      data$ccd_id <- ifelse(data$event %in% c("2016", "2019"), data$SA1_id, data$ccd_id)
    }

    # Remove `SA1_id` and `count` columns
    data <- data[, !names(data) %in% c("SA1_id", "count")]
  } else {
    message("No processing required. Data returned unprocessed.")
  }

  # Return updated data
  return(data)
}


#' Process Overseas Voting Data
#'
#' Standardises column names and calculates total votes for overseas
#' voting data across different election years.
#'
#' @param data A data frame containing overseas voting data with an 'event'
#'        column indicating the election year (e.g., "2013", "2019", "2022"),
#'        and other columns specific to each year.
#'
#' @return A processed data frame with standardised columns 'Overseas Post',
#'         'Pre-Poll Votes', 'Postal Votes', and 'Total', unnecessary columns
#'         removed, and rows where 'State' is NA filtered out.
#'
#' @noRd
#' @keywords internal
process_overseas <- function(data) {
  message("Processing data to ensure all columns align across all elections.")

  # Amend 2019 and 2013 data to match Overseas Post
  data$`Overseas Post` <- ifelse(
    data$event == "2019",
    data$`Diplomatic Post\r\n(Nb. Colombo did not operate due to security issues)`,
    data$`Overseas Post`
  )
  data$`Overseas Post` <- ifelse(
    data$event == "2013",
    data$`pp_nm`,
    data$`Overseas Post`
  )

  # Ensure Pre-Poll Votes and Postal Votes columns exists
  if (!"Pre-Poll Votes" %in% names(data)) {
    data$`Pre-Poll Votes` <- NA
  }
  if (!"Postal Votes" %in% names(data)) {
    data$`Postal Votes` <- NA
  }

  # Amend Postal Votes
  data$`Postal Votes` <- ifelse(data$event == "2022", data$`Postal Vote Envelopes Received at Post`, data$`Postal Votes`)
  data$`Postal Votes` <- ifelse(data$event == "2019", data$`Postal Votes Received`, data$`Postal Votes`)

  # Amend Pre-Poll Votes
  data$`Pre-Poll Votes` <- ifelse(data$event == "2022", data$`Pre-Poll (in-person) Votes`, data$`Pre-Poll Votes`)
  data$`Pre-Poll Votes` <- ifelse(data$event == "2019", data$`Pre-Poll Votes Issued`, data$`Pre-Poll Votes`)
  data$`Pre-Poll Votes` <- ifelse(data$event == "2013", data$`Pre-poll Votes`, data$`Pre-Poll Votes`)

  # Remove columns
  data <- data[, !names(data) %in% c("Diplomatic Post\r\n(Nb. Colombo did not operate due to security issues)",
                                     "pp_sort_nm", "pp_nm", "Pre-Poll (in-person) Votes",
                                     "Postal Vote Envelopes Received at Post", "Postal Votes Received",
                                     "Pre-Poll Votes Issued", "Pre-poll Votes", "Total")]

  # Add Total Column
  data$`Total` <- data$`Postal Votes` + data$`Pre-Poll Votes`

  # Filter out total row in 2013
  data <- data[!is.na(data$State),]

  # Return updated data
  return(data)

}
