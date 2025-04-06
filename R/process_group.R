#' Process Senate Group Voting Data
#'
#' Standardises Senate election data for Australian federal elections in 2004, 2007, 2010, 2013, 2016,
#' and 2019 from the AEC datasets "First preferences by state by vote type" and "First preferences by
#' division by vote type". This helper function aligns column names by renaming `Ticket` to `Group`
#' for consistency across these years. If the `SittingMemberFl` column is present, it applies the
#' [process_elected()] function for additional processing. For other election years, the data is
#' returned unprocessed with a message.
#'
#' @param data A data frame containing Senate voting data for a single election event. Must include
#'   an `event` column with a single unique value (e.g., "2004", "2007", "2010", "2013", "2016", "2019").
#'   For processing years (2004-2019), must include the `Ticket` column. A `date` column is typically
#'   present as mandatory metadata. If `SittingMemberFl` is present, it will be processed by
#'   [process_elected()].
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2004", "2007", "2010", "2013", "2016", or "2019". Other values result in the data being returned
#'   unprocessed.
#'
#' @return A data frame. For recognised election years (2004-2019), it contains the standardised column:
#'   \itemize{
#'     \item `Group` (group or ticket identifier, renamed from `Ticket`)
#'   }
#'   along with all other input columns (e.g., `date`, `event`). If `SittingMemberFl` is present, it also
#'   includes the `Elected` column as processed by [process_elected()]. For unrecognised years, the
#'   original data frame is returned unchanged.
#'
#' @details
#' This function processes Senate voting data by:
#' \enumerate{
#'   \item **Standardising column names**: For 2004, 2007, 2010, 2013, 2016, and 2019, renames `Ticket`
#'         to `Group` using `rename_cols()`.
#'   \item **Optional elected processing**: If `SittingMemberFl` is present in the data, applies
#'         [process_elected()] to standardise it to an `Elected` column with "Y" or "N" values (specific
#'         to 2004 logic in [process_elected()]).
#'   \item **Unrecognised years**: Returns the data unprocessed with an informative message for years
#'         other than 2004, 2007, 2010, 2013, 2016, or 2019.
#' }
#' The function assumes the input data frame contains the required columns (`event` and `Ticket`) for
#' the specified processing years, as sourced from the AEC Senate datasets listed.
#'
#' @examples
#' # Sample 2004 data without SittingMemberFl
#' data_2004 <- data.frame(
#'   date = "2004-10-09",
#'   event = "2004",
#'   State = "VIC",
#'   Ticket = "A"
#' )
#' process_group(data_2004, "2004")
#'
#' # Sample 2010 data with SittingMemberFl
#' data_2010 <- data.frame(
#'   date = "2010-08-21",
#'   event = "2010",
#'   State = "NSW",
#'   Ticket = "B",
#'   SittingMemberFl = "Y"
#' )
#' process_group(data_2010, "2010")
#'
#' # Sample unprocessed year (e.g., 2022)
#' data_2022 <- data.frame(
#'   date = "2022-05-21",
#'   event = "2022",
#'   State = "QLD",
#'   Group = "C"
#' )
#' process_group(data_2022, "2022")
#'
#' @seealso \code{\link{process_elected}}) for elected candidate processing.
#'
#' @export
process_group <- function(data, event) {
  if (event %in% c("2004", "2007", "2010", "2013", "2016", "2019")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Amend 2004-2010 data (Make `Group` = `Ticket`)
    data <- rename_cols(data, Group = "Ticket")

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  if ("SittingMemberFl" %in% colnames(data)) {
    data <- process_elected(data, event)
  }

  # Return updated data
  return(data)
}