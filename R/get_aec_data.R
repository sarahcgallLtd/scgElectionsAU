#' @include utils.R
NULL
#' Download and Process AEC Data
#'
#' This function downloads and processes data from the Australian Electoral Commission (AEC) based
#' on user-specified criteria such as file name, date range, election type, and data category. It
#' retrieves raw data files from the AEC, optionally applies standardisation processes (e.g., column
#' name consistency), and returns a combined data frame for analysis. The function is designed to
#' handle various types of election-related datasets, including federal elections, referendums,
#' by-elections, and the AEC disclosure/transparency register.
#'
#' @param file_name A character string specifying the name of the AEC dataset to retrieve (e.g.,
#'        "National list of candidates"). This name must match entries in the internal index datasets.
#' @param date_range A list with two elements, \code{"from"} and \code{"to"}, specifying the start
#'        and end dates (in "YYYY-MM-DD" format) for the election events to include. Defaults to
#'        \code{list(from = "2022-01-01", to = "2025-01-01")}.
#' @param type A character string specifying the type of election or event. Must be one of:
#'        "Federal Election", "Referendum", "By-Election", or "Disclosure". Defaults to the first option.
#' @param category A character string specifying the category of the data. Must be one of: "House",
#'        "Senate", "Referendum", "General", or "Statistics". Defaults to the first option.
#' @param process A logical value indicating whether to apply additional processing to the downloaded
#'        data, such as standardizing column names. Defaults to \code{TRUE}.
#'
#' @return A data frame containing the combined AEC data for the specified criteria. The data frame
#'         includes metadata columns (e.g., \code{date}, \code{event}) and is optionally processed
#'         for consistency if \code{process = TRUE}. If no data is available for the given parameters,
#'         the function stops with an informative error message.
#'
#' @details
#' The \code{get_aec_data} function automates the retrieval and processing of AEC datasets by:
#' \enumerate{
#'   \item Validating input parameters to ensure correctness.
#'   \item Retrieving internal metadata about election events within the specified \code{date_range}
#'         and matching the \code{type}.
#'   \item Checking the availability of the requested \code{file_name} and \code{category} in the
#'         internal index datasets.
#'   \item Constructing download URLs and retrieving the raw data files from the AEC website.
#'   \item Optionally preprocessing postal vote data and standardizing column names.
#'   \item Combining data from multiple election events into a single data frame.
#' }
#' The function relies on internal helper functions (e.g., \code{check_params}, \code{construct_url},
#' \code{preprocess_pva}) and datasets (e.g., \code{info}, \code{aec_elections_index}) within the
#' \code{scgElectionsAU} package. It also uses \code{scgUtils::get_file} for downloading files.
#' The function is designed to be robust, providing clear messages and errors to guide users through
#' the data retrieval process.
#'
#' @examples
#' \dontrun{
#'   # Retrieve and process the national list of candidates for House elections in 2022
#'   data <- get_aec_data(
#'     file_name = "National list of candidates",
#'     date_range = list(from = "2022-01-01", to = "2023-01-01"),
#'     type = "Federal Election",
#'     category = "House",
#'     process = FALSE
#'   )
#'   head(data)
#' }
#'
#' @importFrom scgUtils get_file
#' @export
get_aec_data <- function(
  file_name,
  date_range = list(from = "2022-01-01", to = "2025-01-01"),
  type = NULL,
  category = c("House", "Senate", "Referendum", "General", "Statistics"),
  process = TRUE
) {
  # =====================================#
  # CHECK PARAMS
  # Define valid type options
  valid_types <- c("Federal Election", "Referendum", "By-Election")

  # If type is NULL or empty, default to the first option
  if (is.null(type) || length(type) == 0) {
    type <- valid_types[1]  # Default to "Federal Election"
  }

  # Validate that all provided types are valid
  if (!all(type %in% valid_types)) {
    invalid_types <- type[!type %in% valid_types]
    stop("Invalid type(s) provided: ", paste(invalid_types, collapse = ", "),
         ". Must be one of: ", paste(valid_types, collapse = ", "), ".")
  }

  category <- match.arg(category)

  check_params(
    file_name = file_name,
    date_range = date_range,
    category = category,
    process = process
  )

  # =====================================#
  # GET AND PROCESS INTERNAL DATA
  info <- get_internal_info(date_range, type)

  # Get index from the 'aec_elections_index' data available in scgElectionsAU package
  index <- get0(x = "aec_elections_index", envir = asNamespace("scgElectionsAU"))

  # Check if 'names' data is available
  if (is.null(index)) {
    stop(paste0("Data 'aec_elections_index' not found in 'scgElectionsAU' package. Contact the package maintainer."))
  }
  # Get list of events
  events <- as.character(info$event)

  # Check if events has 1 or more event
  if (length(events) == 0) {
    stop("Check that the `date_range` captures election periods between 2004 and 2022, inclusively.")
  }

  # =====================================#
  # CHECK THAT THE FILE EXISTS
  check_df <- check_file_exists(file_name, category, index)

  # =====================================#
  # GET DATA AND COMBINE TO ONE DF
  # Initliase an empty df to store all data
  combined_df <- data.frame()

  for (i in seq_along(info$aec_reference)) {
    ref <- info$aec_reference[i]
    event <- info$event[i]

    # Check if event is a valid column in check_df
    if (!(event %in% names(check_df))) {
      message(paste0("Skipping `", file_name, "` for the event `", event, "` as it is not a valid column in check_df."))
      next
    }

    # Filter check_df for this event
    filtered_check_df <- check_df[check_df[[event]] == "Y",]

    # If no data is available for this event, skip
    if (nrow(filtered_check_df) == 0) {
      message(paste0("Skipping `", file_name, "` for the year `", event, "` as it is not available."))
      next
    }

    # Initialise a list to store data frames for this event
    event_dfs <- list()

    # Download files based on the number of rows in filtered_check_df
    for (j in seq_len(nrow(filtered_check_df))) {
      row <- filtered_check_df[j,]
      file_type <- row$file_type  # Get the file_type from the row

      # =====================================#
      # Construct URL
      url <- construct_url(ref, event, file_name, category, type, file_type, index)

      # =====================================#
      # GET DATA FILE FROM URL
      # Set row_no (header row) based on category
      row_no <- ifelse(category == "Statistics", 0, 1)

      # Download the file
      message(paste0("Downloading `", file_name, "` from ", url))
      tmp_df <- suppressMessages(
        scgUtils::get_file(url, source = "web", row_no = row_no)
      )

      # Store the data frame
      event_dfs[[j]] <- tmp_df
    }

    # Combine all data frames for this event
    if (length(event_dfs) > 1) {
      event_df <- do.call(rbind, event_dfs)
    } else {
      event_df <- event_dfs[[1]]
    }

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
    event_df <- cbind(tmp_info, event_df)

    # =====================================#
    # PROCESS DATA
    # Preprocess Postal Votes
    if (file_name %in% c("Postal vote applications by date", "Postal vote applications by party")) {
      event_df <- preprocess_pva(event_df, file_name)
    }

    # Preprocess Referendum Polling places
    # Fix rows 7256 and 7277 which are problematic
    if (file_name == "Polling places" & event == "2023 Referendum") {
      # Define the problematic rows
      problematic_rows <- c(7256, 7277)
      message("Fixing parsing errors in the AEC's file")

      # Loop through each problematic row
      for (row in problematic_rows) {
        # Move the value in "PremisesStateAb" to "PremisesSuburb"
        event_df$PremisesSuburb[row] <- event_df$PremisesStateAb[row]

        # Move the value in "PremisesPostCode" to "PremisesStateAb"
        event_df$PremisesStateAb[row] <- event_df$PremisesPostCode[row]

        # Move the value in "Latitude" to "PremisesPostCode"
        event_df$PremisesPostCode[row] <- event_df$Latitude[row]

        # Split (identified by ",") value in "Longitude" with the first number
        # in "Latitude" and the second in "Longitude"
        split_values <- strsplit(event_df$Longitude[row], ",")
        if (length(split_values[[1]]) == 2) {
          event_df$Latitude[row] <- split_values[[1]][1]  # First part to Latitude
          event_df$Longitude[row] <- split_values[[1]][2] # Second part to Longitude
        } else {
          warning(paste("Could not split Longitude in row", row, "- unexpected format"))
        }
      }

      # Make "Longitude" numeric
      event_df$Longitude <- as.numeric(event_df$Longitude)

    }

    # Process Data if process param = TRUE
    if (process) {
      event_df <- amend_colnames(event_df)
      event_df <- process_init(event_df, file_name, category, event, index)

      # Correct by-election issue
      if (event == "2018 Braddon By-Election" & (file_name == "Postal vote applications by date" ||
        file_name == "Postal vote applications by party" ||
        file_name == "Pre-poll votes")) {
        event_df$event <- ifelse(event_df$DivisionNm == "Fremantle", "2018 Fremantle By-Election", event_df$event)
        event_df$event <- ifelse(event_df$DivisionNm == "Longman", "2018 Longman By-Election", event_df$event)
        event_df$event <- ifelse(event_df$DivisionNm == "Mayo", "2018 Mayo By-Election", event_df$event)
        event_df$event <- ifelse(event_df$DivisionNm == "Perth", "2018 Perth By-Election", event_df$event)
        event_df$event <- ifelse(event_df$StateAb == "ZZZ", "2018 Super Saturday By-Elections", event_df$event)
      }
    }


    # =====================================#
    # APPEND DATA
    # Append to the combined DataFrame
    combined_df <- try_combine(combined_df, event_df)
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
#' Retrieves and filters internal metadata about Australian elections from the `info` dataset in the
#' `scgElectionsAU` package, based on a specified date range and election type.
#'
#' @param date_range A list with two elements: 'from' and 'to', specifying the start and end dates
#'        in 'YYYY-MM-DD' format for the period of interest.
#' @param type A character string specifying the type of election, either "Federal Election" or
#'        "Referendum".
#'
#' @return A data frame containing a subset of the `info` dataset, filtered to include only records
#'         within the specified `date_range` and matching the given `type`. The data frame includes
#'         columns such as `date`, `event`, `type`, and `aec_reference`.
#'
#' @details This function accesses the internal `info` dataset from the `scgElectionsAU` package
#'          namespace. It filters the data to include only records where the `date` is within the
#'          specified `date_range` and the `type` matches the provided `type`. If the `info` dataset
#'          is not available, the function stops with an error. The function assumes that the `info`
#'          dataset contains columns `date` and `type`, among others, and uses these for filtering.
#'          It is designed to be used within other functions in the package, such as `get_aec_data`,
#'          to retrieve relevant election metadata.
#'
#' @examples
#' \dontrun{
#'   info <- get_internal_info(date_range = list(from = "2004-01-01", to = "2022-12-31"),
#'                             type = "Federal Election")
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
  info <- info[info$type %in% type,]

  return(info)
}


#' Check File and Category in AEC Dataset Index
#'
#' This internal function verifies that a specified `file_name` and `category` combination exists
#' in the provided `index` data frame, which is typically the `aec_elections_index` dataset from
#' the `scgElectionsAU` package. It ensures that the `file_name` is present and that there is at
#' least one corresponding entry for the given `category` (which corresponds to the `prefix`
#' column in `index`). If the checks pass, it returns a subset of `index` filtered by
#' `file_name` and `category` for further use, such as verifying event-specific availability in
#' `get_aec_data`.
#'
#' @param file_name A character string specifying the name of the file to check, corresponding
#'   to the 'file_name' column in `index`.
#' @param category A character string specifying the category (e.g., 'General', 'House', 'Referendum',
#'   'Senate') to check, corresponding to the 'prefix' column in `index`.
#' @param index A data frame containing the index of available files, typically
#'   `aec_elections_index` from the `scgElectionsAU` package. Must include at least the columns
#'   'file_name' and 'prefix'.
#'
#' @return A data frame subset of `index` filtered by the specified `file_name` and `category`.
#'   This subset can be used to verify availability for specific events (years) in `get_aec_data`.
#'
#' @details This function is a helper for `get_aec_data` and is not exported. It performs two main
#'   checks:
#'   \enumerate{
#'     \item Ensures that the specified `file_name` exists in the `index` data frame.
#'     \item Ensures that there is at least one entry in `index` where both `file_name` and
#'       `category` (as 'prefix') match.
#'   }
#'   If either check fails, the function stops with an informative error message. If both checks
#'   pass, it returns the filtered subset of `index` for further processing.
#'
#' @examples
#' \dontrun{
#'   check_df <- check_file_exists(file_name = "National list of candidates",
#'                                 category = "House",
#'                                 index = aec_elections_index)
#'   # Use check_df in get_aec_data to check event-specific availability
#' }
#'
#' @noRd
#' @keywords internal
check_file_exists <- function(
  file_name,
  category,
  index
) {
  # Check if file_index exists
  if (!all(file_name %in% index$file_name)) {
    stop(paste0("`", file_name, "` does not exist. Check the `file_name` and try again."))
  }

  # Check that the corresponding category for the file_name exists
  check_df <- index[index$file_name == file_name & index$prefix == category,]
  if (!all(category %in% check_df$prefix)) {
    stop(paste0("`", file_name, "` for the `", category, "` category ", "does not exist. Check that the `category` is one of only 'General', 'House', 'Referendum', or 'Senate' and try again."))
  }

  return(check_df)
}


#' Construct AEC Data Download URL
#'
#' This internal helper function constructs a URL for downloading files from the Australian Electoral
#' Commission (AEC). It supports `get_aec_data()` by generating URLs based on a reference ID, election
#' event, file name, prefix, and additional parameters, using lookup data from the `scgElectionsAU`
#' package. The function handles two distinct URL construction methods depending on the `prefix` value:
#' one for "Statistics" files and another for all other file types.
#'
#' @param ref A character string specifying the reference ID associated with the election year or
#'   event. This ID determines the base path on the AEC website, with "results" used for `ref == "12246"`
#'   and "Website" for all other values.
#' @param event A character string specifying the specific election event (e.g., "2022"), typically a
#'   year or identifier, used to filter data in both "Statistics" and non-"Statistics" cases.
#' @param file_name A character string specifying the name of the file to download, as recorded in
#'   the `aec_elections_index` dataset. This identifies the specific election data file.
#' @param prefix A character string categorizing the file within the AEC structure (e.g., "House",
#'   "Senate", "General", or "Statistics"). This determines the URL construction method.
#' @param type A character string specifying the type of statistics data (e.g., "party", "date"),
#'   used only when `prefix` is "Statistics" to select the appropriate URL from the `info` dataset.
#' @param file_type A character string specifying the file format (e.g., ".csv", ".xml"), used in
#'   URL construction for non-"Statistics" files.
#' @param index A data frame (typically `aec_elections_index` from the `scgElectionsAU` package)
#'   containing metadata to map `file_name`, `prefix`, `file_type`, and `event` to URL components.
#'
#' @return A character string containing the fully constructed URL for the data file.
#'
#' @details
#' The function constructs URLs in two ways based on the `prefix`:
#' - **When `prefix` is "Statistics"**:
#'   - Retrieves the URL from the `info` dataset within the `scgElectionsAU` package.
#'   - A `key` is derived from `file_name` via pattern matching (e.g., "Postal vote applications"
#'     for files starting with that phrase, otherwise `file_name` itself).
#'   - The URL is selected using a `switch` statement based on the `key`, filtered by `event` and
#'     `type` (e.g., `info$postal[info$event == event & info$type == type]`).
#' - **For all other `prefix` values**:
#'   - Constructs the URL using a base URL ("https://results.aec.gov.au/"), `ref`, an `area`
#'     ("results" or "Website" based on `ref`), and components from the `index` dataset.
#'   - Filters the `index` by `file_name`, `prefix`, `file_type`, and the `event` column (e.g.,
#'     `index[[event]] == "Y"`).
#'   - Expects exactly one matching row in the filtered `index`; stops with an error if zero or
#'     multiple matches are found.
#'
#' The function assumes that the `info` and `index` datasets are available and correctly formatted
#' within the `scgElectionsAU` package. It includes error handling to ensure a single, valid match
#' for non-"Statistics" files.
#'
#' @examples
#' \dontrun{
#'   # Example for a "Statistics" file
#'   construct_url(ref = "27966",
#'                 event = "2022",
#'                 file_name = "Postal vote applications by party",
#'                 prefix = "Statistics",
#'                 type = "party",
#'                 file_type = ".csv",
#'                 index = aec_elections_index)
#'
#'   # Example for a non-"Statistics" file
#'   construct_url(ref = "27966",
#'                 event = "2022",
#'                 file_name = "National list of candidates",
#'                 prefix = "House",
#'                 type = NULL,  # Not applicable
#'                 file_type = ".csv",
#'                 index = aec_elections_index)
#' }
#'
#' @noRd
#' @keywords internal
construct_url <- function(
  ref,
  event,
  file_name,
  prefix,
  type,
  file_type,
  index
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
                                  info$type %in% type]
                  },
                  "Pre-poll votes" = {
                    info$prepoll[info$event == event &
                                   info$type %in% type]
                  },
                  "Votes by SA1" = {
                    info$votes[info$event == event &
                                 info$type %in% type]
                  },
                  "Overseas" = {
                    info$overseas[info$event == event &
                                    info$type %in% type]
                  }
    )
  } else {
    base_url <- "https://results.aec.gov.au/"
    area <- ifelse(ref == "12246", "results", "Website")

    # Filter by file_name, prefix, and event availability
    filtered_index <- index[index$file_name == file_name &
                              index$prefix == prefix &
                              index$file_type == file_type &
                              index[[event]] == "Y",]

    # Expect exactly one row
    if (nrow(filtered_index) != 1) {
      stop(paste("Expected exactly one entry for file_name, prefix, and file_type, but found", nrow(filtered_index)))
    }

    # Construct URL
    url <- paste0(base_url, ref, "/", area, "/", filtered_index$download_folder, "/",
                  filtered_index$prefix, filtered_index$download_name, "Download-", ref,
                  filtered_index$file_type)
  }

  return(url)
}

# ======================================================================================================================
#' Preprocess Postal Vote Application Data
#'
#' This internal helper function preprocesses postal vote application data based on the specified
#' file type. For "Postal vote applications by party", it retains columns related to state, division,
#' AEC applications, and party-specific data. For "Postal vote applications by date", it removes
#' columns related to party-specific data and any columns with names starting with three dots ("...").
#' The function is used within the package to prepare data for further processing.
#'
#' @param data A data frame containing postal vote application data. The specific columns present
#'   depend on the file type specified in `file_name`.
#' @param file_name A character string specifying the type of data file. Must be either
#'   "Postal vote applications by party" or "Postal vote applications by date". Determines which
#'   columns are retained or removed.
#'
#' @return A data frame with columns filtered based on the specified file type. For
#'   "Postal vote applications by party", it includes columns related to state, division, AEC
#'   applications, and party-specific data. For "Postal vote applications by date", it excludes
#'   party-specific columns and any columns with names starting with three dots ("...").
#'
#' @details
#' The function assumes that the input data frame contains the columns it attempts to keep or remove,
#' based on the file type. If a column is not present, it is simply ignored. This function is part of
#' the internal processing pipeline for postal vote data and is not intended for direct use by package
#' users.
#'
#' @noRd
#' @keywords internal
preprocess_pva <- function(data, file_name) {
  if (file_name == "Postal vote applications by party") {
    # Keep columns
    data <- data[, names(data) %in% c("date", "event", "State_Cd", "State", "PVA_Web_1_Party_Div", "PVA_Web_1_Party.Div",
                                      "Enrolment Division", "Division", "Enrolment", "AEC - PAPER", "Paper",
                                      "AEC - OPVA", "AEC - Paper", "AEC (Online)", "AEC (Paper)", "AEC",
                                      "ALP", "CLP", "DEM", "GPV", "GRN", "LIB", "LNP", "NAT", "OTH",
                                      "Country Liberal", "Greens", "Labor", "Liberal", "Liberal-National",
                                      "National", "Other Party", "Sum of AEC and Parties")]

  } else if (file_name == "Postal vote applications by date") {
    # Remove columns
    data <- data[, !names(data) %in% c("PVA_Web_1_Party_Div", "PVA_Web_1_Party.Div", "AEC - PAPER", "AEC - OPVA",
                                       "AEC - Paper", "AEC (Online)", "AEC (Paper)", "Paper",
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
#' @param index A data frame or dataset that maps combinations of `file_name`, `category`, and
#'   `event` to specific processing functions. Typically, this is the `aec_elections_index` dataset
#'   from the `scgElectionsAU` package.
#'
#' @return The processed data frame if a processing function is applied, or the original
#'         data frame if no processing is required.
#'
#' @details This function uses the provided `index` dataset to look up a processing function based
#' on the `file_name`, `category`, and `event`. The `index` is expected to have columns for
#' `file_name`, `prefix` (matching `category`), and a column for each `event` (e.g., "2004", "2010")
#' with values like "Y" indicating applicability. If exactly one matching function is found for the
#' given `file_name`, `category`, and `event`, it is applied to the data. If multiple functions match,
#' the function stops with an error. If no function is found, the data is returned unchanged with a
#' message indicating no processing was required.
#'
#' @examples
#' \dontrun{
#' # Assuming aec_elections_index is loaded
#' processed_data <- process_init(data = my_data,
#'                                file_name = "National list of candidates",
#'                                category = "House",
#'                                event = "2022",
#'                                index = aec_elections_index)
#' }
#'
#' @noRd
#' @keywords internal
process_init <- function(data, file_name, category, event, index) {
  # Look up the processing function from the CSV index
  proc_func_index <- index$processing_function[
    index$file_name == file_name &
      index$prefix == category &
      index[[event]] == "Y"  # Check the specific event column
  ]

  # Remove NAs
  proc_func_index <- proc_func_index[is.na(proc_func_index) == FALSE]

  # Proceed if there’s exactly one valid function name
  if (length(proc_func_index) == 1 && !is.na(proc_func_index)) {
    # Get the function name
    proc_func <- tryCatch(
      match.fun(proc_func_index),
      error = function(e) stop(paste("Processing function", proc_func_index, "not found."))
    )

    # Apply the function
    data <- proc_func(data = data, event = event)

  } else if (length(proc_func_index) > 1) {
    stop("Multiple processing functions found for this file_name and category.")

  }

  return(data)
}

