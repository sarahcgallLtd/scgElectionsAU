#' Process Overseas Voting Data
#'
#' Standardises column names and calculates total votes for overseas voting data from the 2013, 2019,
#' and 2022 Australian federal elections. This function aligns disparate column names across election
#' years to a consistent format and computes the total votes as the sum of postal and pre-poll votes.
#' If an unrecognised election year is provided, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing overseas voting data. Must include an `event` column indicating
#'   the election event (e.g., "2013 Federal Election", "2019 Federal Election", "2022 Federal Election",
#'   "2023 Referendum", "2024 Federal Election") and, for recognised years, year-specific columns
#'   for state, division, overseas post, and vote counts.
#' @param event A character string specifying the election event to process. Recognised values are
#'   "2013 Federal Election", "2019 Federal Election", "2022 Federal Election", "2023 Referendum", or
#'   "2025 Federal Election". Other values will result in the data being returned unprocessed.
#'
#' @return A data frame. For recognised election years ("2013", "2019", "2022", "2023", "2025"), it contains standardised
#'   columns:
#'   \itemize{
#'     \item `date` (if present in input)
#'     \item `event` (the election event)
#'     \item `StateAb` (state abbreviation, standardised using [amend_names()] for 2013 and 2019)
#'     \item `DivisionNm` (division name)
#'     \item `OverseasPost` (name of the overseas voting post)
#'     \item `PrePollVotes` (pre-poll vote count)
#'     \item `PostalVotes` (postal vote count)
#'     \item `TotalVotes` (sum of `PrePollVotes` and `PostalVotes`, with NA handling)
#'   }
#'   Rows with missing `StateAb` values (e.g., totals) are removed for 2013 data. For unrecognised
#'   election years, the original data frame is returned unchanged.
#'
#' @details
#' This function processes overseas voting data by:
#' \enumerate{
#'   \item Standardising column names to a consistent set across recognised election years using `rename_cols()`.
#'   \item For 2013 data: Removing unnecessary columns (`pp_sort_nm`, `Total`) and rows with NA in `StateAb`.
#'   \item Converting full state names to abbreviations using [amend_names()] for 2013 and 2019 data.
#'   \item Calculating `TotalVotes` as the sum of `PostalVotes` and `PrePollVotes`, treating NA as 0.
#'   \item For unrecognised years: Returning the data unprocessed with an informative message.
#' }
#' The function assumes the input data frame contains the required columns for the specified `event` year
#' when it is "2013", "2019", "2022", or "2025", though column names may vary as per the original datasets.
#'
#' @examples
#' # Sample 2013 data
#' data_2013 <- data.frame(
#'   event = "2013 Federal Election",
#'   StateAb = c("NSW", "VIC", NA),
#'   DivisionNm = c("Sydney", "Melbourne", "Total"),
#'   pp_nm = c("London", "Paris", "All"),
#'   `Pre-poll Votes` = c(100, 150, 250),
#'   `Postal Votes` = c(50, 75, 125),
#'   pp_sort_nm = c("LON", "PAR", "ALL"),
#'   Total = c(150, 225, 375),
#'   check.names = FALSE
#' )
#' process_overseas(data_2013, "2013 Federal Election")
#'
#' # Sample invalid year
#' data_2026 <- data.frame(event = "2026 Federal Election", StateAb = "QLD", Votes = 100)
#' process_overseas(data_2026, "2026 Federal Election")
#'
#' @seealso \code{\link{amend_names}}) for state name standardisation.
#'
#' @export
process_overseas <- function(
  data,
  event
) {
  # Check only 2013, 2019, 2022, and 2025 election years are passed
  if (event %in% c("2013 Federal Election", "2019 Federal Election", "2022 Federal Election", "2023 Referendum",
                   "2025 Federal Election")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Standardise columns to goal 8 column data frame
    if (event == "2013 Federal Election") {
      # Rename columns
      data <- rename_cols(data,
        OverseasPost = "pp_nm",
        PostalVotes = "Postal Votes",
        PrePollVotes = "Pre-poll Votes"
      )

      # Remove `pp_sort_nm` and `Total` from dataset
      data <- data[, !names(data) %in% c("pp_sort_nm", "Total"), drop = FALSE]

      # Filter out rows with NA by StateAb (these contain row totals and thus are removed)
      data <- data[!is.na(data$StateAb),]

      # Amend State Names to StateAb
      data <- amend_names(data, "StateAb", "state_to_abbr")

    } else if (event == "2019 Federal Election") {
      # Rename columns
      data <- rename_cols(data,
        OverseasPost = "Diplomatic Post\r\n(Nb. Colombo did not operate due to security issues)",
        PostalVotes = "Postal Votes Received",
        PrePollVotes = "Pre-Poll Votes Issued"
      )

      # Amend State Names to StateAb
      data <- amend_names(data, "StateAb", "state_to_abbr")

    } else if (event == "2022 Federal Election") {
      # Rename  columns
      data <- rename_cols(data,
        OverseasPost = "Overseas Post",
        PostalVotes = "Postal Vote Envelopes Received at Post",
        PrePollVotes = "Pre-Poll (in-person) Votes"
      )
    } else if (event == "2023 Referendum") {
      # Rename  columns
      data <- rename_cols(data,
        OverseasPost = "Overseas Post",
        PostalVotes = "Postal Vote Envelopes Received at Post",
        PrePollVotes = "Pre-Poll (in-person) Votes Issued at Post"
      )
    } else if (event == "2025 Federal Election") {
      # Rename  columns
      data <- rename_cols(data,
        OverseasPost = "Overseas Voting Centre",
        PostalVotes = "Postal Vote Envelopes Received at Post",
        PrePollVotes = "Pre-Poll (in-person) Votes Issued at Post",
        TotalVotes = "Grand Total"
      )
    }

    if (event != "2025 Federal Election") {
      # Calculate Total with NA handling
      data$`TotalVotes` <- rowSums(data[, c("PostalVotes", "PrePollVotes")], na.rm = TRUE)
    }

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return data
  return(data)
}