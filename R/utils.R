#' Validate Parameters for Internal Function Usage
#'
#' This function performs validation checks on parameters passed to internal functions,
#' ensuring they conform to expected formats and types. It checks for string types,
#' date range correctness, and logical parameter validity.
#'
#' @param ... Named parameters to check, where each parameter's expected type and format
#'        is validated according to predefined rules. This includes checking for string
#'        types for certain parameters, validating date ranges, and ensuring logical parameters
#'        are true binary values.
#'
#' @return Invisible NULL. This function is used for its side effect of stopping if any check fails
#'         with an informative error message, ensuring that parameters are correctly formatted
#'         before proceeding with function execution.
#'
#' @noRd
#' @keywords internal
check_params <- function(...) {
  params <- list(...)

  for (name in names(params)) {
    value <- params[[name]]

    if (!is.null(value)) {
      # Check if parameter is a string
      if (name %in% c("file_name", "type", "category") && !is.character(value)) {
        stop(paste0("`", name, "` must be a string."))
      }

      # Check if parameter is a list with 'from' and 'to' and is formatted as 'YYYY-MM-DD'
      if (name == "date_range") {
        if (!is.list(value) ||
          !"from" %in% names(value) ||
          !"to" %in% names(value)) {
          stop("`date_range` must be a list with 'from' and 'to' keys.")
        }

        # Validate 'from' and 'to' dates are properly formatted as 'YYYY-MM-DD'
        if (!validate_date(value$from) || !validate_date(value$to)) {
          stop("`date_range` values must be valid dates formatted as 'YYYY-MM-DD'.")
        }
      }

      # Check if parameter is a binary TRUE or FALSE
      if (name == "process" && (!is.logical(value) || length(value) != 1)) {
        stop("`process` must be a binary TRUE or FALSE.")
      }
    }
  }
}


#' Validate Date Format 'YYYY-MM-DD'
#'
#' This helper function checks if a given string conforms to the 'YYYY-MM-DD' date format
#' and represents a valid date. It is primarily used internally by other functions
#' to validate date strings in parameter lists.
#'
#' @param date_string A character string representing a date, expected to be in 'YYYY-MM-DD' format.
#'
#' @return A logical value; `TRUE` if the date_string is a valid date formatted correctly,
#'         and `FALSE` otherwise.
#'
#' @noRd
#' @keywords internal
validate_date <- function(date_string) {
  # Attempt to convert the string to a Date object with the specific format
  d <- as.Date(date_string, format = "%Y-%m-%d")
  # Check if the conversion was successful
  return(!is.na(d))
}


#' Check Availability of Specified File in Dataset
#'
#' This utility function checks the availability of a specified file within the 'aec_names_fed' dataset
#' from the 'scgElectionsAU' package. It ensures that the file name, category, and each year (event)
#' requested have corresponding entries marked as available ('Y') in the dataset. This function is
#' intended to be a helper function for `get_aec_data` and is not exported.
#'
#' @param file_name The name of the file to check within the dataset. This should match one of the
#'        entries in the 'file_name' column of the 'aec_names_fed' dataset.
#' @param category The category associated with the file, typically reflecting the data's segmentation
#'        such as 'General', 'House', or 'Senate'. This should match an entry in the 'prefix' column
#'        of the dataset.
#' @param events A character vector of years (events) for which the availability needs verification.
#'        Each year should correspond to a column in the dataset, which should contain 'Y' to
#'        indicate availability.
#'
#' @return Invisible NULL. The function is used for its side effect of stopping if any check fails
#'         with an informative error message.
#'
#' @examples
#' # Assuming that 'aec_names_fed' data and necessary variables are correctly set:
#' check_file_exists("National list of candidates", "House", c("2022", "2016"))
#'
#' @noRd
#' @keywords internal
check_file_exists <- function(
  file_name,
  category,
  events
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

  # Loop through the list of events and check corresponding columns
  for (event in events) {
    # First, ensure the column for the event year exists
    if (!event %in% names(check_df)) {
      stop(paste0("`", file_name, "` does not have data available for the year `", event, "`."))
    }

    # Check if the event year column contains "Y" in check_df
    # Also handle potential NA values in the column data
    if (!all(check_df[[event]] == "Y", na.rm = TRUE)) {
      stop(paste0("`", file_name, "` for the year `", event, "` is not available. Check availability and try again."))
    }
  }
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
  file_name,
  prefix
) {
  base_url <- "https://results.aec.gov.au/"
  area <- ifelse(ref == "12246", "results", "Website")

  # Get names from the 'aec_names_fed' data available in scgElectionsAU package
  names <- get0("aec_names_fed", envir = asNamespace("scgElectionsAU"))

  # Check if names is non-null
  if (is.null(names)) {
    stop("Data 'aec_names_fed' not found in 'scgElectionsAU' package. Contact the package maintainer.")
  }

  # Filter by file_name and prefix
  filtered_names <- names[names$file_name == file_name & names$prefix == prefix,]

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

  return(url)
}
