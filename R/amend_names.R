#' Amend Names in a Data Frame Column
#'
#' Standardises names in a specified column of a data frame based on predefined conversion mappings.
#' Currently supports converting Australian state names to abbreviations and vice versa. The conversion
#' mappings are sourced from the internal `name_conversions` dataset within the `scgElectionsAU` package.
#' Matching is performed case-insensitively to accommodate variations like "TAS" vs "Tas" or "Victoria" vs "VICTORIA".
#'
#' @param data A data frame containing the column to be amended.
#' @param column_name A character string specifying the name of the column in `data` to amend.
#' @param conversion_type A character string specifying the type of conversion to perform. Must be one of:
#'   \code{"state_to_abbr"} (converts state names to abbreviations) or
#'   \code{"abbr_to_state"} (converts abbreviations to state names).
#'   Defaults to \code{"state_to_abbr"}.
#'
#' @return A data frame identical to `data`, with the specified `column_name` amended according to the
#'   chosen `conversion_type`. Unmatched values remain unchanged. The output retains the original case
#'   of the standardised values as defined in the `name_conversions` dataset.
#'
#' @details
#' This function relies on the internal `name_conversions` dataset, which contains mappings for
#' standardising names. It uses a lookup table approach to replace original values with their
#' standardised equivalents. Matching is case-insensitive, achieved by converting both the input column
#' and the conversion table's original values to uppercase during comparison. If a value in the specified
#' column does not match any original value in the conversion table (ignoring case), it is preserved as-is.
#'
#' @examples
#' # Sample data frame with mixed case
#' df <- data.frame(
#'   state = c("NEW SOUTH WALES", "victoria", "Unknown"),
#'   value = c(10, 20, 30)
#' )
#'
#' # Convert state names to abbreviations
#' amend_names(df, "state", "state_to_abbr")
#'
#' # Convert abbreviations with mixed case
#' df_abbr <- data.frame(
#'   state = c("nsw", "Vic", "tas"),
#'   value = c(10, 20, 30)
#' )
#' amend_names(df_abbr, "state", "abbr_to_state")
#'
#' @rdname amend_names
#' @export
amend_names <- function(
  data,
  column_name,
  conversion_type = c("state_to_abbr", "abbr_to_state")
) {
  # Get internal name_conversions data
  conversions <- get0("name_conversions", envir = asNamespace("scgElectionsAU"))

  # Check if data is available
  if (is.null(conversions)) stop("Internal data 'name_conversions' not found. Contact package administrator.")

  # Filter conversions for the specified type
  conv_subset <- conversions[conversions$type == conversion_type, ]

  # Check if conversion type is valid
  if (nrow(conv_subset) == 0) stop("Invalid conversion_type specified.")

  # Create a named vector for lookup (preserving original standardised values)
  lookup <- stats::setNames(conv_subset$standardised, toupper(conv_subset$original))

  # Perform the conversion with case-insensitive matching
  data[[column_name]] <- ifelse(
    toupper(data[[column_name]]) %in% names(lookup),
    lookup[toupper(data[[column_name]])],
    data[[column_name]]
  )

  return(data)
}