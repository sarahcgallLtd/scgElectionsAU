#' Convert 11-digit SA1 Maincode to 7-digit SA1 Code
#'
#' This function takes a data frame containing an 11-digit SA1 Maincode and converts it to the
#' corresponding 7-digit SA1 Code as specified by the Australian Bureau of Statistics ((as per
#' ABS documentation: https://www.abs.gov.au/ausstats/abs@.nsf/Latestproducts/7CAFD05E79EB6F81CA257801000C64CD?opendocument)).
#' The 7-digit code is created by concatenating the first digit and the last six digits of the
#' 11-digit maincode.
#'
#' @param data A data frame containing the SA1 Maincode column.
#' @param column_name A string specifying the name of the column in `data` that contains
#'   the 11-digit SA1 Maincode.
#'
#' @return The input data frame with an additional column named 'SA1_CODE_YYYY', where 'YYYY'
#'   is extracted from the end of `column_name`, containing the 7-digit SA1 Code as a string value.
#'
#' @examples
#' # Assuming a data frame df with a column 'SA1_MAINCODE_2016' containing character strings
#' df <- data.frame(SA1_MAINCODE_2016 = c("12345678901", "23456789012"))
#' amended_df <- amend_maincode(df, "SA1_MAINCODE_2016")
#' # amended_df will have a new column 'SA1_CODE_2016' with values 1678901, 2789012, etc.
#'
#' @importFrom stringr str_extract
#' @export
amend_maincode <- function(
  data,
  column_name
) {
  # Check if the column exists
  if (!column_name %in% names(data)) {
    stop(paste0("Column `", column_name, "` does not exist in the data frame."))
  }

  # Create new column name
  colname <- paste0("SA1_7DIGITCODE_", stringr::str_extract(column_name, "\\d{4}$"))

  # Initialise column
  data[[colname]] <- NA

  # Extract 7-digit code from maincode
  data[[colname]] <- ifelse(!is.na(data[[column_name]]),
                            paste0(stringr::str_extract(data[[column_name]], "^\\d{1}"),
                                     stringr::str_extract(data[[column_name]],"\\d{6}$")),
                            data[[colname]])

  # Ensure character string
  data[[colname]] <- as.character(data[[colname]])

  # Return data
  return(data)
}