#' Process Pre-Poll Voting Data
#'
#' Standardises pre-poll voting data for Australian federal elections in 2004, 2007, 2010, and 2013
#' from specific AEC datasets: "First preferences by state by party" (House), "First preferences by
#' group by vote type" (Senate), and "First preferences by state by group by vote type" (Senate).
#' This helper function aligns column names by renaming `PrePollVotes` to `DeclarationPrePollVotes`
#' and `PrePollPercentage` to `DeclarationPrePollPercentage` for consistency across these years. For
#' other election years, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing pre-poll voting data for a single election event. Must include
#'   an `event` column with a single unique value (e.g., "2004", "2007", "2010", "2013"). For processing
#'   years (2004, 2007, 2010, 2013), must include `PrePollVotes` and `PrePollPercentage` columns. A
#'   `date` column is typically present as mandatory metadata.
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2004", "2007", "2010", or "2013". Other values result in the data being returned unprocessed.
#'
#' @return A data frame. For recognised election years (2004, 2007, 2010, 2013), it contains the
#'   standardised columns:
#'   \itemize{
#'     \item `DeclarationPrePollVotes` (number of pre-poll votes, renamed from `PrePollVotes`)
#'     \item `DeclarationPrePollPercentage` (percentage of pre-poll votes, renamed from `PrePollPercentage`)
#'   }
#'   along with all other input columns (e.g., `date`, `event`). For unrecognised years, the original
#'   data frame is returned unchanged.
#'
#' @details
#' This function processes pre-poll voting data by:
#' \enumerate{
#'   \item **Standardising column names**: For 2004, 2007, 2010, and 2013, renames `PrePollVotes` to
#'         `DeclarationPrePollVotes` and `PrePollPercentage` to `DeclarationPrePollPercentage` using
#'         `rename_cols()`.
#'   \item **Unrecognised years**: Returns the data unprocessed with an informative message for years
#'         other than 2004, 2007, 2010, or 2013.
#' }
#' The function assumes the input data frame contains the required columns (`event`, `PrePollVotes`,
#' and `PrePollPercentage`) for the specified processing years, as sourced from the AEC datasets listed.
#'
#' @examples
#' # Sample 2004 data
#' data_2004 <- data.frame(
#'   date = "2004-10-09",
#'   event = "2004",
#'   State = "VIC",
#'   Party = "ALP",
#'   PrePollVotes = 500,
#'   PrePollPercentage = 25.0
#' )
#' process_prepoll(data_2004, "2004")
#'
#' # Sample unprocessed year (e.g., 2016)
#' data_2016 <- data.frame(
#'   date = "2016-07-02",
#'   event = "2016",
#'   State = "NSW",
#'   Party = "LIB",
#'   DeclarationPrePollVotes = 600,
#'   DeclarationPrePollPercentage = 30.0
#' )
#' process_prepoll(data_2016, "2016")
#'
#' @export
process_prepoll <- function(data, event) {
  if (event %in% c("2004", "2007", "2010", "2013")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Amend 2004-2010 data (Make `DeclarationPrePollVotes` = `PrePollVotes` &
    # `DeclarationPrePollPercentage` = `PrePollPercentage`)
    data <- rename_cols(
      data,
      DeclarationPrePollVotes = "PrePollVotes",
      DeclarationPrePollPercentage = "PrePollPercentage"
    )

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return updated data
  return(data)
}