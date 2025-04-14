#' Process Election Data for Elected Candidates
#'
#' Standardises election data related to elected candidates for a single Australian federal election
#' event. This function aligns column names across datasets, specifically processing the 2004 election
#' year by standardising the `Elected` column with "Y" or "N"
#' values. For all other election years, the data is returned unprocessed with a message. Applies to
#' datasets including "National list of candidates" (House and Senate), "First preferences by candidate
#' by vote type" (House only), "Two candidate preferred by candidate by vote type" (House only),
#' "Two candidate preferred by candidate by polling place" (House only), and "Distribution of preferences
#' by candidate by division" (House only).
#'
#' @param data A data frame containing election data for a single election event. Must include an
#'   `event` column with a single unique value (e.g., "2004"). Additional columns depend on the specific dataset.
#' @param event A character string specifying the election event to process. Currently, only "2004 Federal Election" is
#'   processed; other values result in the data being returned unprocessed.
#'
#' @return A data frame. For the 2004 Federal Election, it contains the standardised column:
#'   \itemize{
#'     \item `Elected` (indicates if the candidate was elected, with values "Y" for yes or "N" for no)
#'   }
#'   along with all other input columns. For unrecognised years, the original data frame is returned
#'   unchanged.
#'
#' @details
#' This function processes election data by:
#' \enumerate{
#'   \item **Formatting**: Converts `Elected` values to "Y" (elected) or "N" (not elected), replacing NA with "N".
#'   \item **Unrecognised years**: Returns the data unprocessed with an informative message for years other than
#' the 2004 Federal Election.
#' }
#' The function assumes the input data frame contains the required columns for the specified `event`
#' year and dataset, with processing currently implemented only for the 2004 Federal Election. Future enhancements may
#' include adding `HistoricVote` data for the 2004 Federal Election (pending identification of the source dataset).
#'
#' @examples
#' # Sample 2004 data
#' data_2004 <- data.frame(
#'   date = "2004-10-09",
#'   event = "2004 Federal Election",
#'   CandidateID = 123,
#'   Elected = "#"
#' )
#' process_elected(data_2004, "2004 Federal Election")
#'
#' # Sample unprocessed year (e.g., 2010)
#' data_2010 <- data.frame(
#'   date = "2010-08-21",
#'   event = "2010 Federal Election",
#'   CandidateID = 456,
#'   Elected = "Y"
#' )
#' process_elected(data_2010, "2010 Federal Election")
#'
#' @export
process_elected <- function(data, event) {
  if (event == "2004 Federal Election") {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Amend Elected column
    data$Elected <- ifelse(!is.na(data$Elected), "Y", "N")

    # TODO: Find a way to add HistoricVote for 2004 - which dataset contains this?

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed.\n"))
  }

  # Return updated data
  return(data)
}
