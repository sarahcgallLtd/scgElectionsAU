#' Process Postal Vote Application Data by Date
#'
#' Standardises and transforms Postal Vote Application (PVA) data for a single Australian federal
#' election event into a consistent long-format structure based on application receipt dates. This
#' function aligns column names across election years (2010, 2013, 2016, 2019), pivots date-specific
#' vote counts into a long format, and converts receipt dates to Date objects. For unrecognised
#' election years, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing PVA data for a single election event. Must include:
#'   \itemize{
#'     \item `date` (the date of the election or data snapshot)
#'     \item `event` (the election year, matching the `event` argument)
#'   }
#'   Additional required columns vary by year:
#'   \itemize{
#'     \item 2010: `Enrolment`, and date-specific columns (e.g., "02 Aug 10").
#'     \item 2013: `Enrolment Division`, and date-specific columns (e.g., "20-Aug-13").
#'     \item 2016: `State_Cd`, `PVA_Web_2_Date_Div`, and date-specific columns (e.g., "20160614").
#'     \item 2019: `State_Cd`, `PVA_Web_2_Date_V2_Div`, and date-specific columns (e.g., "20190411").
#'   }
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2010", "2013", "2016", or "2019". Other values result in the data being returned unprocessed.
#'
#' @return A data frame with standardised columns for recognised election years:
#'   \itemize{
#'     \item `date` (the date of the election or data snapshot)
#'     \item `event` (the election year)
#'     \item `StateAb` (state abbreviation, upper case; "ZZZ" for NA in 2013)
#'     \item `DivisionNm` (division name)
#'     \item `DateReceived` (date the PVA was received, as a Date object)
#'     \item `TotalPVAs` (total PVA applications received on the corresponding date)
#'   }
#'   For unrecognised years, the original data frame is returned unchanged.
#'
#' @details
#' This function processes PVA data by:
#' \enumerate{
#'   \item **Standardising column names** across recognised election years using `rename_cols()`:
#'         \itemize{
#'           \item 2010: `Enrolment` to `DivisionNm`.
#'           \item 2013: `Enrolment Division` to `DivisionNm`.
#'           \item 2016: `State_Cd` to `StateAb`, `PVA_Web_2_Date_Div` to `DivisionNm`.
#'           \item 2019: `State_Cd` to `StateAb`, `PVA_Web_2_Date_V2_Div` to `DivisionNm`.
#'         }
#'   \item **Handling missing states**: For 2013, NA in `StateAb` is replaced with "ZZZ".
#'   \item **Filtering rows**: For 2010 and 2013, rows with NA in `DivisionNm` (e.g., notes or totals) are removed.
#'   \item **Removing unnecessary columns**: Drops columns like "TOTAL to date (Inc GPV)" (2010, 2013),
#'         "<>", and "Date out of range" (2019).
#'   \item **Pivoting data**: Uses `pivot_event()` to transform date-specific columns (e.g., "20-Aug-13")
#'         into long format with `DateReceived` and `TotalPVAs`.
#'   \item **Converting dates**: Formats `DateReceived` as a Date object using year-specific formats:
#'         \itemize{
#'           \item 2019: "%Y%m%d" (e.g., "20190411")
#'           \item 2016: "%Y%m%d" (e.g., "20160614")
#'           \item 2013: "%d-%b-%y" (e.g., "20-Aug-13")
#'           \item 2010: "%d %b %y" (e.g., "02 Aug 10")
#'         }
#'   \item **Formatting**: Converts `StateAb` to uppercase.
#'   \item **Unrecognised years**: Returns the data unprocessed with an informative message.
#' }
#' The function assumes the input data frame contains the required columns (`date`, `event`, and
#' year-specific columns) from the AEC past results datasets and that the `event` column matches
#' the `event` argument. The date-specific columns represent daily PVA totals and are pivoted into
#' the `DateReceived` and `TotalPVAs` columns.
#'
#' @examples
#' # Sample 2010 data
#' data_2010 <- data.frame(
#'   date = "2010-08-21",
#'   event = "2010",
#'   StateAb = "VIC",
#'   Enrolment = "Melbourne",
#'   `02 Aug 10` = 50,
#'   `03 Aug 10` = 60
#' )
#' process_pva_date(data_2010, "2010")
#'
#' # Sample invalid year
#' data_2022 <- data.frame(
#'   date = "2022-05-21",
#'   event = "2022",
#'   StateAb = "QLD",
#'   Votes = 90
#' )
#' process_pva_date(data_2022, "2022")
#'
#' @export
process_pva_date <- function(data, event) {
  if (event %in% c("2010", "2013", "2016", "2019")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Step 1: Standardise columns across years
    if (event %in% c("2010", "2013")) {
      if (event == "2010") {
        data <- rename_cols(data, DivisionNm = "Enrolment")

        # Remove `TOTAL to date (Inc GPV)`
        data <- data[, !names(data) == "TOTAL to date (Inc GPV)"]

      } else if (event == "2013") {
        data <- rename_cols(data, DivisionNm = "Enrolment Division")

        # Fill in NAs with ZZZ
        data$StateAb <- ifelse(is.na(data$StateAb), "ZZZ", data$StateAb)

        # Remove `TOTAL to date (Inc GPV)`
        data <- data[, !names(data) == "TOTAL to date"]
      }

      # Filter out rows with NA by DivisionNm (these contain notes and thus are removed)
      data <- data[!is.na(data$DivisionNm),]

    } else if (event %in% c("2016", "2019")) {
      data <- rename_cols(data, StateAb = "State_Cd")

      if (event == "2016") {
        data <- rename_cols(data, DivisionNm = "PVA_Web_2_Date_Div")
        data$Division <- data$PVA_Web_2_Date_Div

      } else if (event == "2019") {
        data <- rename_cols(data, DivisionNm = "PVA_Web_2_Date_V2_Div")

        # Remove `TOTAL to date (Inc GPV)`
        data <- data[, !names(data) %in% c("<>","Date out of range")]
      }

    }

    # Ensure all StateAb are upper case
    data$StateAb <- toupper(data$StateAb)

    # Step 2: Define columns for output
    id_cols <- c("date", "event", "StateAb", "DivisionNm")
    long_cols <- c("DateReceived", "TotalPVAs")
    names_to <- "DateReceived"
    values_to <- "TotalPVAs"

    # Step 3: Pivot date columns into long format
    data <- pivot_event(data, id_cols, long_cols, names_to, values_to)

    # Step 4: Convert Issue Date to date object
    formats <- list(
      "2019" = "%Y%m%d",    # e.g., "2019/04/11"
      "2016" = "%Y%m%d",    # e.g., "2016/06/14"
      "2013" = "%d-%b-%y",    # e.g., "20-Aug-13"
      "2010" = "%d %b %y"     # e.g., "02 Aug 10"
    )
    if (event %in% names(formats)) {
      data$"DateReceived" <- as.Date(data$"DateReceived", format = formats[[event]])
    }

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return processed data
  return(data)
}
