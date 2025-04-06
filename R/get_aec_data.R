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
    # ADD META DATA
    # Append info data to downloaded data and fill
    tmp_df <- cbind(tmp_info, tmp_df)

    # =====================================#
    # PROCESS DATA
    # Preprocess Postal Votes
    if (file_name %in% c("Postal vote applications by date", "Postal vote applications by party")) {
      tmp_df <- preprocess_pva(tmp_df, file_name)
    }

    # Process Data if process param = TRUE
    if (process) {
      tmp_df <- process_init(tmp_df, file_name, category, event)
    }

    # =====================================#
    # APPEND DATA
    # Append to the combined DataFrame
    combined_df <- try_combine(combined_df, tmp_df)
  }

  # Reset row names
  rownames(combined_df) <- NULL

  if (nrow(combined_df) == 0) {
    stop(paste0("No data was available for `", file_name, "` with the parameters used. Check the date range and try again."))
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
    data <- proc_func(data = data, event = event)

  } else if (length(proc_func_name) > 1) {
    stop("Multiple processing functions found for this file_name and category.")

  } else {
    message("No processing required. Data returned unprocessed.")
  }

  return(data)
}
