#' Retrieve Disclosure Data from AEC's Transparency Register
#'
#' This function downloads and retrieves specific datasets from the Australian Electoral Commission's (AEC)
#' Transparency Register. The register contains financial disclosure information from political entities,
#' including annual returns, election returns, and referendum returns.
#'
#' @param file_name The file name of the data to retrieve. If \code{file_name} is not specified, it defaults to
#'   "Donations Made". Must be one of: "Capital Contributions", "Debts", "Discretionary Benefits",
#'   "Donations Made", "Donations Received", "Expenses", "Media Advertisement Details", "Receipts",
#'   "Return Summary", "Returns".
#' @param group The group of the entity. If not specified, it defaults to "Donor". Must be one of:
#'   "Associated Entity", "Candidate", "Donor", "Media", "MPs", "Other", "Party", "Referendum Entity",
#'   "Significant Third Party", "Third Party".
#' @param type The type of return. Defaults to "Annual". Must be one of: "Annual", "Election", "Referendum".
#'
#' @return A data frame containing the requested disclosure data.
#'
#' @examples
#' \dontrun{
#'   # Retrieve default data: Donations Made by Donors for Annual returns
#'   data <- get_disclosure_data()
#'
#'   # Retrieve specific data: Receipts for Parties in Election returns
#'   data <- get_disclosure_data(file_name = "Receipts", group = "Party", type = "Election")
#' }
#'
#' @seealso \url{https://www.aec.gov.au/parties_and_representatives/financial_disclosure/} for more
#'   information on the AEC's financial disclosure scheme.
#'
#' @importFrom scgUtils get_file
#' @export
get_disclosure_data <- function(
  file_name = NULL,
  group = NULL,
  type = c("Annual", "Election", "Referendum")
) {
  # =====================================#
  # CHECK PARAMS
  # If NULL, set default
  type <- match.arg(type)

  # Define valid file_name and group options
  valid_file_names <- c("Capital Contributions", "Debts", "Discretionary Benefits", "Donations Made",
                        "Donations Received", "Expenses", "Media Advertisement Details", "Receipts",
                        "Return Summary", "Returns")
  valid_groups <- c("Associated Entity", "Candidate", "Donor", "Media", "MPs", "Other",
                    "Party", "Referendum Entity", "Significant Third Party", "Third Party")

  # If type is NULL or empty, set defaults
  if (is.null(file_name) || length(file_name) == 0) {
    file_name <- "Donations Made"
  }
  if (is.null(group) || length(group) == 0) {
    group <- "Donor"
  }

  # Validate that all provided file_names and groups are valid
  if (!all(file_name %in% valid_file_names)) {
    invalid_file_names <- file_name[!file_name %in% valid_file_names]
    stop("Invalid file_name provided: ", paste(invalid_file_names, collapse = ", "),
         ". Must be one of: ", paste(valid_file_names, collapse = ", "), ".")
  }
  if (!all(group %in% valid_groups)) {
    invalid_groups <- group[!group %in% valid_groups]
    stop("Invalid group provided: ", paste(invalid_groups, collapse = ", "),
         ". Must be one of: ", paste(valid_groups, collapse = ", "), ".")
  }

  # =====================================#
  # FILTER AND CHECK FILE EXISTS
  # Get index from the 'aec_disclosure_index' data available in scgElectionsAU package
  index <- get0(x = "aec_disclosure_index", envir = asNamespace("scgElectionsAU"))

  # Check if 'names' data is available
  if (is.null(index)) {
    stop(paste0("Data 'aec_elections_index' not found in 'scgElectionsAU' package. Contact the package maintainer."))
  }

  # Filter index by type, group, and file_name
  index <- index[index$type == type &
                   index$group == group &
                   index$file_name == file_name,]

  # Check if index has 1 or more rows
  if (nrow(index) == 0) {
    stop("File does not exist. Check the parameters and try again. For more information go to https://docs.sarahcgall.co.uk/scgElectionsAU/articles/a-guide-to-aec-disclosure-datasets")
  }

  # =====================================#
  # CONSTRUCT URL AND GET FILE
  base_url <- "https://transparency.aec.gov.au/Download/"
  url <- paste0(base_url, index$prefix)
  name <- paste0(index$download_name, index$file_type)

  # Download the file
  message(paste0("Downloading `", name, "` from ", url))
  tmp_df <- suppressMessages(
    scgUtils::get_file(url, source = "web", file_name = name, file_type = "zip")
  )

  # =====================================#
  # RETURN DATA
  return(tmp_df)
}