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
#' @param cache Logical. If TRUE (default), caches the downloaded data for the session,
#'   making subsequent identical requests instant. Set to FALSE to always download fresh data.
#'
#' @return A data frame containing the requested disclosure data.
#'
#' @details
#' Use \code{clear_cache} to remove cached data when needed.
#'
#' @examples
#' \dontrun{
#'   # Retrieve default data: Donations Made by Donors for Annual returns
#'   data <- get_disclosure_data()
#'
#'   # Retrieve specific data: Receipts for Parties in Election returns
#'   data <- get_disclosure_data(file_name = "Receipts", group = "Party", type = "Election")
#'
#'   # Second identical call uses cache - instant!
#'   data2 <- get_disclosure_data(file_name = "Receipts", group = "Party", type = "Election")
#' }
#'
#' @seealso \code{clear_cache} to remove cached data,
#'   \url{https://www.aec.gov.au/parties_and_representatives/financial_disclosure/} for more
#'   information on the AEC's financial disclosure scheme.
#'
#' @importFrom scgUtils get_file
#' @export
get_disclosure_data <- function(
  file_name = NULL,
  group = NULL,
  type = c("Annual", "Election", "Referendum"),
  cache = TRUE
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
  # CHECK CACHE
  if (cache) {
    cache_key <- paste("disclosure", file_name, group, type, sep = "|")
    cached_data <- get_disclosure_cache(cache_key)
    if (!is.null(cached_data)) {
      message("Using cached disclosure data for `", file_name, "`...")
      return(cached_data)
    }
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
  # CACHE AND RETURN DATA
  if (cache) {
    set_disclosure_cache(cache_key, tmp_df)
  }

  return(tmp_df)
}


# ======================================================================================================================
# CACHING FUNCTIONS

# Package-level environment to store cached disclosure data
.disclosure_cache <- new.env(parent = emptyenv())


#' Get cached disclosure data
#'
#' Retrieves data from the disclosure cache if it exists.
#'
#' @param cache_key The cache key to look up.
#'
#' @return The cached data frame, or NULL if not found.
#'
#' @noRd
#' @keywords internal
get_disclosure_cache <- function(cache_key) {
  if (exists(cache_key, envir = .disclosure_cache)) {
    return(get(cache_key, envir = .disclosure_cache))
  }
  return(NULL)
}


#' Store disclosure data in cache
#'
#' Saves data to the disclosure cache.
#'
#' @param cache_key The cache key to store under.
#' @param data The data frame to cache.
#'
#' @return Invisible NULL.
#'
#' @noRd
#' @keywords internal
set_disclosure_cache <- function(cache_key, data) {
  assign(cache_key, data, envir = .disclosure_cache)
  invisible(NULL)
}