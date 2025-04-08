#' Process Party Representation Data for House of Representatives
#'
#' Standardises "Party representation" data for the House of Representatives from Australian federal
#' elections in 2004, 2007, and 2010. This helper function aligns column names by renaming `Total` to
#' `National` and `LastElectionTotal` to `LastElection` for consistency across these years. For other
#' election years, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing "Party representation" data for a single election event from
#'   the House of Representatives. Must include an `event` column with a single unique value (e.g.,
#'   "2004", "2007", "2010"). For processing years (2004, 2007, 2010), must include `Total` and
#'   `LastElectionTotal` columns. A `date` column is typically present as mandatory metadata.
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2004", "2007", or "2010". Other values result in the data being returned unprocessed.
#'
#' @return A data frame. For recognised election years (2004, 2007, 2010), it contains the standardised
#'   columns:
#'   \itemize{
#'     \item `National` (total party representation, renamed from `Total`)
#'     \item `LastElection` (party representation from the last election, renamed from `LastElectionTotal`)
#'   }
#'   along with all other input columns (e.g., `date`, `event`). For unrecognised years, the original
#'   data frame is returned unchanged.
#'
#' @details
#' This function processes "Party representation" data by:
#' \enumerate{
#'   \item **Standardising column names**: For 2004, 2007, and 2010, renames `Total` to `National` and
#'         `LastElectionTotal` to `LastElection` using `rename_cols()`.
#'   \item **Unrecognised years**: Returns the data unprocessed with an informative message for years
#'         other than 2004, 2007, or 2010.
#' }
#' The function assumes the input data frame contains the required columns (`event`, `Total`, and
#' `LastElectionTotal`) for the specified processing years, as sourced from the AEC "Party representation"
#' dataset for the House of Representatives.
#'
#' @examples
#' # Sample 2004 data
#' data_2004 <- data.frame(
#'   date = "2004-10-09",
#'   event = "2004",
#'   Party = "ALP",
#'   Total = 60,
#'   LastElectionTotal = 65
#' )
#' process_reps(data_2004, "2004")
#'
#' # Sample unprocessed year (e.g., 2013)
#' data_2013 <- data.frame(
#'   date = "2013-09-07",
#'   event = "2013",
#'   Party = "LIB",
#'   National = 90,
#'   LastElection = 72
#' )
#' process_reps(data_2013, "2013")
#'
#' @export
process_reps <- function(data, event) {
  if (event %in% c("2004", "2007", "2010")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Amend 2004-2010 data (Make `National` = `Total` & `LastElection` = `LastElectionTotal`)
    data <- rename_cols(data, National = "Total", LastElection = "LastElectionTotal")

    # Remove PartyAb column
    data <- data[, !names(data) == "PartyAb", drop = FALSE]

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return updated data
  return(data)
}