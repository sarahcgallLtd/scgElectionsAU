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


#' Combine Two Data Frames Robustly
#'
#' This utility function attempts to combine two data frames by rows even if
#' there are data type mismatches between the corresponding columns of the two data frames.
#' It handles errors specifically related to combining columns with different data types
#' by converting the problematic column(s) to numeric, assuming that non-numeric characters
#' can be coerced to NA or are actual numbers.
#'
#' @param df1 The first data frame to combine.
#' @param df2 The second data frame to combine.
#'
#' @return A data frame that is the row binding of `df1` and `df2`, after potentially
#' converting data types of mismatched columns to numeric.
#'
#' @details If `bind_rows` fails due to a data type mismatch, the function
#' identifies the problematic column from the error message, converts it to numeric
#' in both data frames, and retries the combination. This process is recursive
#' until no more type mismatch errors occur.
#'
#' @examples
#' df1 <- data.frame(LastElection = c("2010", "2011", "-"))
#' df2 <- data.frame(LastElection = c(2012, 2013, 2014))
#' try_combine(df1, df2)
#'
#' @note This function is not exported and intended for internal use only.
#' It assumes that all mismatches should be resolved by converting character
#' to numeric, which may not be appropriate for all cases.
#'
#' @importFrom dplyr bind_rows
#' @importFrom stringr str_detect str_extract
#'
#' @noRd
try_combine <- function(df1, df2) {
  tryCatch({
    # Try to combine the data frames
    combined_df <- dplyr::bind_rows(df1, df2)
    return(combined_df)
  }, error = function(e) {
    # Catch the error and extract the column name causing the issue
    message <- conditionMessage(e)
    if (stringr::str_detect(message, "Can't combine")) {
      col_name <- stringr::str_extract(message, "(?<=\\$)[^`]+")
      message(paste("Attempting to fix columns:", paste(col_name, collapse = ", ")))

      # Convert the problematic column to numeric, replacing non-numeric characters
      df1[[col_name]] <- as.numeric(as.character(df1[[col_name]]))
      df2[[col_name]] <- as.numeric(as.character(df2[[col_name]]))

      # Recursively call try_combine to try again
      return(try_combine(df1, df2))
    } else {
      stop("Unhandled error:", message)
    }
  })
}


#' Pivot Event Data to Long Format
#'
#' This internal utility function transforms a dataframe from wide to long format,
#' focusing on columns that represent dates and their associated values (e.g., vote totals).
#' It allows dynamic specification of identifier columns and custom naming of the output
#' columns for dates and values, making it adaptable for use within various functions.
#' This function is not exported and is intended for internal package use.
#'
#' @param df A dataframe containing the data to be transformed. It should include
#'        identifier columns and columns to be pivoted (typically date columns with values).
#' @param id_cols A character vector of column names that serve as identifiers
#'        (e.g., "Division", "State"). These columns are preserved in the long format.
#' @param long_cols A character vector of column names that should be excluded from
#'        pivoting but are not directly used in the current implementation. Included
#'        for clarity and potential future extensions (e.g., additional metadata columns).
#' @param names_to A string specifying the name of the output column that will
#'        contain the pivoted date values (default is "Issue Date").
#' @param values_to A string specifying the name of the output column that will
#'        contain the values associated with each date (default is "Total Votes").
#'
#' @return A dataframe in long format where each row corresponds to a unique combination
#'         of identifier columns and a date, with the associated value for that date.
#'         The date and value columns are named according to `date_col_name` and
#'         `value_col_name`, respectively.
#'
#' @examples
#' \dontrun{
#'   # Sample data
#'   df <- data.frame(
#'     Division = c("Div1", "Div2"),
#'     State = c("State1", "State2"),
#'     `2020-01-01` = c(100, 200),
#'     `2020-01-02` = c(150, 250),
#'     check.names = FALSE
#'   )
#'
#'   # Pivot with default column names
#'   long_df <- pivot_event(df, id_cols = c("Division", "State"), long_cols = NULL)
#'   print(long_df)
#'
#'   # Pivot with custom column names
#'   long_df_custom <- pivot_event(
#'     df,
#'     id_cols = c("Division", "State"),
#'     long_cols = NULL,
#'     names_to = "EventDate",
#'     values_to = "VoteCount"
#'   )
#'   print(long_df_custom)
#' }
#'
#' @noRd
#' @keywords internal
pivot_event <- function(
  df,
  id_cols,
  long_cols,
  names_to = "Issue Date",
  values_to = "Total Votes"
) {
  # Identify date columns (all columns not in id_cols or long_cols)
  date_cols <- setdiff(names(df), c(id_cols, long_cols))
  long_list <- list()

  # For each row, create long-format entries
  for (i in 1:nrow(df)) {
    row <- df[i,]
    for (date_col in date_cols) {
      # Skip NA values to avoid unnecessary rows (remove this condition if NAs are desired)
      if (!is.na(row[[date_col]])) {
        long_row <- data.frame(
          row[id_cols],
          stats::setNames(list(date_col), names_to),
          stats::setNames(list(row[[date_col]]), values_to),
          check.names = FALSE # Preserve spaces
        )
        long_list[[length(long_list) + 1]] <- long_row
      }
    }
  }

  # Combine into a single dataframe
  long_df <- do.call(rbind, long_list)
  return(long_df)
}
