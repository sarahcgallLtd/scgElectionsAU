#' Process Pre-Poll Voting Centre Data
#'
#' Standardises and transforms Pre-Poll Voting Centre (PPVC) data
#' for a single Australian federal election event into a consistent long-format structure. This
#' function aligns column names across election years (2010, 2013, 2016, 2019, 2022), pivots date-specific
#' vote counts into a long format (except for 2022), and converts issue dates to Date objects. For
#' unrecognised election years, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing PPVC data for a single election event. Must include
#'   an `event` column with a single unique value (e.g., "2010", "2013", "2016", "2019", "2022").
#'   Additional required columns vary by year: `State`, `Division`, and date-specific vote columns
#'   for 2010; `State`, `Division`, `m_pp_nm` for 2013; `m_state_ab`, `m_div_nm`, `m_pp_nm` for
#'   2016 and 2019; `State`, `Division`, `PPVC`, `Issue Date`, `Total Votes` for 2022. A `date`
#'   column is optional.
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2010", "2013", "2016", "2019", or "2022". Other values result in the data being returned
#'   unprocessed.
#'
#' @return A data frame with standardised columns for recognised election years:
#'   \itemize{
#'     \item `date` (if present in the input)
#'     \item `event` (the election year)
#'     \item `StateAb` (state abbreviation)
#'     \item `DivisionNm` (division name)
#'     \item `PollingPlaceNm` (polling place name; included for 2013, 2016, 2019, and 2022 only)
#'     \item `IssueDate` (date of vote issuance as a Date object)
#'     \item `TotalVotes` (total votes issued on the corresponding issue date)
#'   }
#'   For 2010–2019, the data is pivoted from wide to long format using date-specific vote columns.
#'   For 2022, the data retains its original structure with renamed columns. For unrecognised years,
#'   the original data frame is returned unchanged.
#'
#' @details
#' This function processes PPVC data by:
#' \enumerate{
#'   \item Standardising column names across recognised election years using `rename_cols()`:
#'         \itemize{
#'           \item 2010: `Division` to `DivisionNm`.
#'           \item 2013: ``Division` to `DivisionNm`, `m_pp_nm` to `PollingPlaceNm`.
#'           \item 2016 and 2019: `m_state_ab` to `StateAb`, `m_div_nm` to `DivisionNm`, `m_pp_nm` to `PollingPlaceNm`.
#'           \item 2022: `Division` to `DivisionNm`, `PPVC` to `PollingPlaceNm`,
#'                 `Issue Date` to `IssueDate`, `Total Votes` to `TotalVotes`.
#'         }
#'   \item For 2010: Filtering out rows with NA in `DivisionNm` (e.g., notes or totals).
#'   \item For 2010–2019: Pivoting date-specific vote columns into long format with `pivot_event()`,
#'         creating `IssueDate` and `TotalVotes` columns.
#'   \item For 2022: Selecting standardised columns without pivoting.
#'   \item Converting `IssueDate` to a Date object using year-specific formats:
#'         \itemize{
#'           \item 2022: "%d/%m/%y" (e.g., "09/05/22")
#'           \item 2019: "%d/%m/%Y" (e.g., "29/04/2019")
#'           \item 2016: "%Y-%m-%d" (e.g., "2016-06-14")
#'           \item 2013: "%d/%m/%Y" (e.g., "20/08/2013")
#'           \item 2010: "%d %b %y" (e.g., "02 Aug 10")
#'         }
#'   \item For unrecognised years: Returning the data unprocessed with an informative message.
#' }
#' The function assumes the input data frame contains the required columns for the specified `event`
#' year and that the `event` column has a single unique value matching the `event` argument.
#'
#' @examples
#' # Sample 2013 data (wide format)
#' data_2013 <- data.frame(
#'   date = 2013-09-07,
#'   event = "2013",
#'   StateAb = "New South Wales",
#'   DivisionNm = "Sydney",
#'   m_pp_nm = "Sydney PPVC",
#'   `20/08/2013` = 100,
#'   `21/08/2013` = 150,
#'   check.names = FALSE
#' )
#' process_ppv(data_2013, "2013")
#'
#' # Sample 2022 data (long format)
#' data_2022 <- data.frame(
#'   date = 2022-05-21,
#'   event = "2022",
#'   StateAb = "Victoria",
#'   DivisionNm = "Melbourne",
#'   PPVC = "Melbourne PPVC",
#'   `Issue Date` = "09/05/22",
#'   `Total Votes` = 200,
#'   check.names = FALSE
#' )
#' process_ppv(data_2022, "2022")
#'
#' # Sample invalid year
#' data_2025 <- data.frame(event = "2025", StateAb = "Queensland", Votes = 100)
#' process_ppv(data_2025, "2025")
#'
#' @export
process_ppv <- function(data, event) {
  if (event %in% c("2010", "2013", "2016", "2019", "2022")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Step 1: Standardise columns across years
    if (event == "2010") {
      # Filter out rows with NA by DivisionAb (these contain notes and thus are removed)
      data <- data[!is.na(data$DivisionNm),]

    } else if (event == "2013") {
      data <- rename_cols(data, PollingPlaceNm = "m_pp_nm")

    } else if (event %in% c("2016", "2019")) {
      data <- rename_cols(
        data,
        StateAb = "m_state_ab",
        DivisionNm = "m_div_nm",
        PollingPlaceNm = "m_pp_nm"
      )
    } else if (event == "2022") {
      data <- rename_cols(
        data,
        PollingPlaceNm = "PPVC",
        IssueDate = "Issue Date",
        TotalPPVs = "Total Votes",
      )
    }

    # Step 2: Define columns for output
    id_cols <- c("date", "event", "StateAb", "DivisionNm")
    if (event != "2010") id_cols <- c(id_cols, "PollingPlaceNm")
    long_cols <- c("IssueDate", "TotalPPVs")
    names_to <- "IssueDate"
    values_to <- "TotalPPVs"

    # Step 3: Process based on event year
    if (event == "2022") {
      # For 2022: Select identifier and long-format columns
      data <- data[, c(id_cols, long_cols), drop = FALSE]
    } else {
      # For other years, pivot date columns into long format
      data <- pivot_event(data, id_cols, long_cols, names_to, values_to)
    }

    # Step 4: Convert Issue Date to date object
    formats <- list(
      "2022" = "%d/%m/%y",    # e.g., "09/05/22"
      "2019" = "%d/%m/%Y",    # e.g., "29/04/2019"
      "2016" = "%Y-%m-%d",    # e.g., "2016-06-14"
      "2013" = "%d/%m/%Y",    # e.g., "20/08/2013"
      "2010" = "%d %b %y"     # e.g., "02 Aug 10"
    )
    if (event %in% names(formats)) {
      data$"IssueDate" <- as.Date(data$"IssueDate", format = formats[[event]])
    }

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return processed data
  return(data)

}
