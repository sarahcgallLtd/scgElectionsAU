#' Process Election Data by Census Collection District
#'
#' Standardises column names in election data across the 2013, 2016, 2019, and 2022 Australian federal
#' elections to ensure consistency. This function adjusts year-specific column names to a common set,
#' including renaming vote counts and statistical area identifiers, and removes redundant columns.
#' If an unrecognised election year is provided, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing election data with an `event` column indicating the election
#'   year (e.g., "2013", "2016", "2019", "2022") and year-specific columns such as `state_ab`,
#'   `div_nm`, `pp_id`, `pp_nm`, and vote or area identifiers (e.g., `votes`, `count`, `ccd_id`, `SA1_id`).
#' @param event A character string specifying the election event to process. Recognised values are
#'   "2013 Federal Election", "2016 Federal Election", "2019 Federal Election", or "2022 Federal
#'   Election". Other values result in the data being returned unprocessed.
#'
#' @return A data frame. For recognised election events ("2013 Federal Election", "2016 Federal
#'   Election", "2019 Federal Election", "2022 Federal Election", "2023 Referendum"), it contains
#'   standardised columns:
#'   \itemize{
#'     \item `date` (if present in the input)
#'     \item `event` (the election event)
#'     \item `StateAb` (state abbreviation)
#'     \item `DivisionNm` (division name)
#'     \item `StatisticalAreaID` (statistical area identifier; refers to 2011 ASGC for 2013–2016,
#'           2016 ASGC for 2019–2022)
#'     \item `PollingPlaceID` (polling place identifier)
#'     \item `PollingPlaceNm` (polling place name)
#'     \item `Count` (indicative count of votes cast per statistical area)
#'   }
#'   The `year` column, if present, is removed as it is redundant with `event`. For unrecognised election
#'   years, the original data frame is returned unchanged.
#'
#' @details
#' This function processes election data by:
#' \enumerate{
#'   \item Applying base column renaming common to all recognised years using `rename_cols()`
#'         (e.g., `state_ab` to `StateAb`, `div_nm` to `DivisionNm`).
#'   \item Removing the `year` column, as the `event` column already provides this information.
#'   \item For 2013: Renaming `ccd_id` to `StatisticalAreaID` and `count` to `Count`.
#'   \item For 2016 and 2019: Renaming `SA1_id` to `StatisticalAreaID` and `votes` to `Count`.
#'   \item For 2022: Renaming `ccd_id` to `StatisticalAreaID` and `votes` to `Count`.
#'   \item For unrecognised years: Returning the data unprocessed with an informative message.
#' }
#' The function assumes the input data frame contains the required columns for the specified `event`
#' year, though column names may vary as per the original datasets. Note that `StatisticalAreaID`
#' reflects different Australian Statistical Geography Standards (ASGC) depending on the year:
#' 2011 ASGC for 2013 and 2016, 2016 ASGC for 2019 and 2022.
#'
#' @examples
#' # Sample 2013 data
#' data_2013 <- data.frame(
#'   event = "2013 Federal Election",
#'   state_ab = "NSW",
#'   div_nm = "Sydney",
#'   pp_id = 101,
#'   pp_nm = "Sydney Town Hall",
#'   ccd_id = "12345",
#'   count = 500,
#'   year = 2013
#' )
#' process_ccd(data_2013, "2013 Federal Election")
#'
#' # Sample 2019 data
#' data_2019 <- data.frame(
#'   event = "2019 Federal Election",
#'   state_ab = "VIC",
#'   div_nm = "Melbourne",
#'   pp_id = 102,
#'   pp_nm = "Melbourne Central",
#'   SA1_id = "67890",
#'   votes = 600
#' )
#' process_ccd(data_2019, "2019 Federal Election")
#'
#' # Sample invalid year
#' data_2021 <- data.frame(event = "2021 Federal Election", state_ab = "QLD", votes = 100)
#' process_ccd(data_2021, "2021 Federal Election")
#'
#' @export
process_ccd <- function(data, event) {
  if (event %in% c("2013 Federal Election", "2016 Federal Election", "2019 Federal Election",
                   "2022 Federal Election", "2023 Referendum")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Base renaming for all years
    data <- rename_cols(data,
                        StateAb = "state_ab",
                        DivisionNm = "div_nm",
                        PollingPlaceID = "pp_id",
                        PollingPlaceNm = "pp_nm"
    )

    # Remove year column (`event` provides this information already)
    data <- data[, !names(data) == "year", drop = FALSE]

    if (event == "2013 Federal Election") {
      # Rename  columns
      data <- rename_cols(data, StatisticalAreaID = "ccd_id", Count = "count")

    } else if (event %in% c("2016 Federal Election", "2019 Federal Election")) {
      # Rename  columns
      data <- rename_cols(data, StatisticalAreaID = "SA1_id", Count = "votes")

    } else if (event %in% c("2022 Federal Election","2023 Referendum")) {
      # Rename  columns
      data <- rename_cols(data, StatisticalAreaID = "ccd_id", Count = "votes")

    }
  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return updated data
  return(data)
}