#' Process Postal Vote Application Data by Party
#'
#' Standardises and transforms Postal Vote Application (PVA) data for a single Australian federal
#' election event into a consistent structure. This function aligns column names across election
#' years (2010, 2013, 2016, 2019), calculates totals for Australian Electoral Commission (AEC)
#' applications (online and paper) and combined AEC-plus-party applications, and ensures a uniform
#' set of columns. For unrecognised election years, the data is returned unprocessed with a message.
#'
#' @param data A data frame containing PVA data for a single election event. Must include an `event`
#'   column with a single unique value (e.g., "2010", "2013", "2016", "2019"). Additional required
#'   columns vary by year:
#'   \itemize{
#'     \item 2010: `Enrolment`, and party-specific columns (e.g., `Labor`, `Liberal`, `AEC`).
#'     \item 2013: `Enrolment Division`, and additional party columns (e.g., `Liberal-National`).
#'     \item 2016 and 2019: `State_Cd`, `PVA_Web_1_Party_Div`, and AEC-specific columns (e.g., `AEC - OPVA`).
#'   }
#'   A `date` column is optional.
#' @param event A character string specifying the election year to process. Recognised values are
#'   "2010", "2013", "2016", or "2019". Other values result in the data being returned unprocessed.
#'
#' @return A data frame with standardised columns for recognised election years:
#'   \itemize{
#'     \item `date` (the date of the election or data snapshot)
#'     \item `event` (the election year)
#'     \item `StateAb` (state abbreviation, upper case; "ZZZ" for NA in 2013)
#'     \item `DivisionNm` (division name)
#'     \item `GPV` (general postal voter applications; included for 2013, 2016, 2019 only)
#'     \item `AEC (Online)` (AEC online applications; included for 2013, 2016, 2019 only)
#'     \item `AEC (Paper)` (AEC paper applications; included for 2013, 2016, 2019 only)
#'     \item `AEC (Total)` (sum of AEC online and paper applications; all years)
#'     \item `Total (AEC + Parties)` (sum of AEC total and party applications; all years except 2010)
#'     \item `ALP` (Australian Labor Party applications; all years)
#'     \item `CLP` (Country Liberal Party applications; all years)
#'     \item `DEM` (Australian Democrats applications; 2019 only)
#'     \item `GRN` (Greens applications; 2010, 2013, 2016 only)
#'     \item `LIB` (Liberal Party applications; all years)
#'     \item `LNP` (Liberal National Party applications; 2013, 2016, 2019 only)
#'     \item `NAT` (National Party applications; all years)
#'     \item `OTH` (Other party applications; all years)
#'   }
#'   For unrecognised years, the original data frame is returned unchanged.
#'
#' @details
#' This function processes PVA data by:
#'   1. **Standardising column names** across recognised election years using `rename_cols()`:
#'      - 2010: `Enrolment` to `DivisionNm`, party names (e.g., `Labor` to `ALP`).
#'      - 2013: `Enrolment Division` to `DivisionNm`, additional party names (e.g., `Liberal-National` to `LNP`).
#'      - 2016 and 2019: `State_Cd` to `StateAb`, `PVA_Web_1_Party_Div` to `DivisionNm`, AEC columns (e.g., `AEC - OPVA` to `AEC (Online)`).
#'   2. **Handling missing states**: For 2013, NA in `StateAb` is replaced with "ZZZ".
#'   3. **Filtering rows**: For 2010 and 2013, rows with NA in `DivisionNm` (e.g., notes or totals) are removed.
#'   4. **Calculating totals**: For 2013, 2016, and 2019:
#'      - `AEC (Total)` is the sum of `AEC (Online)` and `AEC (Paper)`.
#'      - `Total (AEC + Parties)` is the sum of `AEC (Total)` and all party columns present.
#'   5. **Column selection**: Selects and reorders columns to a consistent set, retaining only those present in the data.
#'   6. **Formatting**: Converts `StateAb` to uppercase.
#'   7. **Unrecognised years**: Returns the data unprocessed with an informative message.
#'
#'   The function assumes the input data frame contains the required columns for the specified `event`
#'   year and that the `event` column matches the `event` argument.
#'
#' @examples
#' \dontrun{
#' # Sample 2010 data
#' data_2010 <- data.frame(
#'   date = "2010-08-21",
#'   event = "2010",
#'   StateAb = "VIC",
#'   Enrolment = "Melbourne",
#'   Labor = 120,
#'   Liberal = 180,
#'   AEC = 60
#' )
#' process_pva_party(data_2010, "2010")
#'
#' # Sample 2013 data with NA in State
#' data_2013 <- data.frame(
#'   date = "2013-08-21",
#'   event = "2013",
#'   StateAb = NSW,
#'   `Enrolment Division` = "Sydney",
#'   `Liberal-National` = 150,
#'   `AEC - OPVA` = 25,
#'   `AEC - Paper` = 15,
#'   check.names = FALSE
#' )
#' process_pva_party(data_2013, "2013")
#'
#' # Sample invalid year
#' data_2022 <- data.frame(event = "2022", StateAb = "QLD", Votes = 90)
#' process_pva_party(data_2022, "2022")
#' }
#'
#' @export
process_pva_party <- function(data, event) {
  if (event %in% c("2010", "2013", "2016", "2019")) {
    message(paste0("Processing `", event, "` data to ensure all columns align across all elections."))

    # Step 1: Standardise columns across years
    # Amend State and Division Metadata
    if (event %in% c("2010", "2013")) {
      data <- rename_cols(
        data,
        ALP = "Labor",
        CLP = "Country Liberal",
        GRN = "Greens",
        LIB = "Liberal",
        NAT = "National",
        OTH = "Other Party"
      )

      if (event == "2010") {
        data <- rename_cols(
          data,
          DivisionNm = "Enrolment",
          `AEC (Total)` = "AEC",
          `Total (AEC + Parties)` = "Sum of AEC and Parties"
        )

      } else if (event == "2013") {
        data <- rename_cols(
          data,
          DivisionNm = "Enrolment Division",
          LNP = "Liberal-National"
        )

        # Fill in NAs with ZZZ
        data$StateAb <- ifelse(is.na(data$StateAb), "ZZZ", data$StateAb)
      }

      # Filter out rows with NA by DivisionNm (these contain notes and thus are removed)
      data <- data[!is.na(data$DivisionNm),]

    } else if (event %in% c("2016", "2019")) {
      data <- rename_cols(
        data,
        StateAb = "State_Cd",
        DivisionNm = "PVA_Web_1_Party_Div",
        `AEC (Online)` = "AEC - OPVA",
        `AEC (Paper)` = "AEC - Paper"
      )
    }

    if (event != "2010") {
      # Create Total column for Online + Paper
      data$`AEC (Total)` <- rowSums(data[, c("AEC (Online)", "AEC (Paper)")], na.rm = TRUE)

      cols_to_sum <- c("AEC (Total)", "GPV", "ALP", "CLP", "DEM", "GRN", "LIB", "LNP", "NAT", "OTH")
      data$`Total (AEC + Parties)` <- rowSums(data[, cols_to_sum[cols_to_sum %in% names(data)]], na.rm = TRUE)
    }

    # Keep selected columns and reorder
    columns_to_keep <- c("date", "event", "StateAb", "DivisionNm", "GPV",
                         "AEC (Online)", "AEC (Paper)", "AEC (Total)", "Total (AEC + Parties)",
                         "ALP", "CLP", "DEM", "GRN", "LIB", "LNP", "NAT", "OTH")
    data <- data[, columns_to_keep[columns_to_keep %in% names(data)], drop = FALSE]

    # Ensure all StateAb are upper case
    data$StateAb <- toupper(data$StateAb)

  } else {
    message(paste0("No processing required for `", event, "`. Data returned unprocessed."))
  }

  # Return processed data
  return(data)

}
