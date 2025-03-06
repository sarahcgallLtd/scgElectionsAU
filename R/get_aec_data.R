#' @include utils.R
NULL
#' Download and Process AEC Data
#'
#' This function is designed to download and process data from the Australian Electoral Commission
#' (AEC) based on specified criteria. It utilises several internal helper functions to validate
#' input parameters, construct URLs, and check file availability before downloading and processing the data.
#'
#' @param file_name The name of the file to download, which is used to construct the download URL
#'        and to filter internal metadata for validations.
#' @param date_range A list containing the 'from' and 'to' dates defining the period for which data
#'        is required. Dates should be formatted as 'YYYY-MM-DD'.
#' @param type The type of election or event to filter the data, possible values are
#'        'Federal Election' and 'Referendum'.
#' @param category The category of the data to be downloaded, possible options are 'House', 'Senate',
#'        and 'General'.
#' @param process A logical flag indicating whether additional processing steps (like standardising
#'        column names) should be performed on the downloaded data. Defaults to FALSE.
#'
#' @return A data frame combining all downloaded data, supplemented with relevant information from
#'         internal metadata, and optionally processed for standardisation.
#'
#' @examples
#' \dontrun{
#' get_aec_data(
#'   file_name = "National list of candidates",
#'   date_range = list(from = "2022-01-01", to = "2023-01-01"),
#'   type = "Federal Election",
#'   category = "House",
#'   process = FALSE
#' )
#' }
#'
#' @import dplyr
#' @importFrom scgUtils get_file
#' @export
get_aec_data <- function(
  file_name,
  date_range = list(from = "2022-01-01", to = "2023-01-01"),
  type = c("Federal Election", "Referendum"),
  category = c("House","Senate","General"),
  process = FALSE
) {
  # =====================================#
  # CHECK PARAMS
  type <- match.arg(type)
  category <- match.arg(category)

  check_params(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category,
    process = process
  )

  # =====================================#
  # GET AND PROCESS INTERNAL DATA
  # Get internal info data
  info <- get0("info", envir = asNamespace("scgElectionsAU"))

  if (is.null(info)) {
    stop("Info data not available in 'scgElectionsAU' namespace.")
  }

  # Filter info by date range provided
  info <- info[info$date >= date_range$from & info$date <= date_range$to, ]

  # Filter by Type
  info <- info[info$type == type, ]

  # Get list of events
  events <- as.character(info$event)

  # Check if events has 1 or more event
  if (length(events) == 0) {
    stop("Check that the `date_range` captures election periods between 2004 and 2022, inclusively.")
  }

  # =====================================#
  # CHECK THAT THE FILE EXISTS
  check_file_exists(file_name, category, events)

  # =====================================#
  # GET DATA AND COMBINE TO ONE DF
  # Initliase an empty df to store all data
  combined_df <- data.frame()

  for (ref in info$aec_reference) {
    # =====================================#
    # Construct URL
    url <- construct_url(ref, file_name, category)

    # =====================================#
    # GET DATA FILE FROM URL
    print(paste0("Downloading `", file_name, "` from ", url))
    tmp_df <- scgUtils::get_file(url, source = "web", row_no = 1)

    # =====================================#
    # PREPARE INFO DATA
    # Filter info by AEC Reference
    tmp_info <- info[info$aec_reference == ref,]
    print(paste0("Successfully downloaded `", file_name, "` for the ", tmp_info$event, " ", tmp_info$type))

    # Select necessary columns only
    tmp_info <- tmp_info[, !(names(tmp_info) %in% c("aec_reference", "type"))]

    # =====================================#
    # APPEND DATA
    # Append info data to downloaded data and fill
    tmp_df <- cbind(tmp_info, tmp_df)

    # Append to the combined DataFrame
    combined_df <- dplyr::bind_rows(combined_df, tmp_df)
  }

  # =====================================#
  # PROCESS DATA
  if (process) {
    # file dependent logic to come (this section will standardise column names across all years)
  }

  return(combined_df)
}
