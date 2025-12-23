#' Retrieve Australian Bureau of Statistics (ABS) Census data
#'
#' Downloads and processes ABS Census DataPack files for a specified Census year
#' and table number. Census DataPacks contain comprehensive demographic, social,
#' and economic data at SA1 geographic level for all of Australia.
#'
#' @param census_year Numeric. The Census year. Must be one of 2011, 2016, or 2021.
#' @param table Character. The table number to retrieve (e.g., "G01", "G02").
#'   See \code{abs_census_table} for a list of available tables and their descriptions.
#' @param cache Logical. If TRUE (default), caches the downloaded DataPack ZIP file
#'   for the session, making subsequent requests for other tables from the same
#'   Census year much faster. Set to FALSE to always download fresh.
#'
#' @return A data frame containing the Census data for the specified table at SA1 level.
#'
#' @details
#' This function retrieves Census data from ABS DataPacks, which are ZIP archives containing
#' CSV files with Census data at SA1 geographic level. The function:
#' \enumerate{
#'   \item Validates input parameters
#'   \item Downloads the DataPack ZIP (or uses cached version if available)
#'   \item Extracts the specified table from the ZIP archive
#' }
#'
#' Note that:
#' \itemize{
#'   \item 2021 and 2016 Census use General Community Profile (GCP) tables (G01, G02, etc.)
#'   \item 2011 Census uses Basic Community Profile (BCP) tables (B01, B02, etc.)
#'   \item DataPacks are large (100-400MB), so the first download takes time
#'   \item With \code{cache = TRUE}, subsequent table requests are fast
#'   \item Use \code{clear_cache} to remove cached files if needed
#' }
#'
#' @examples
#' \dontrun{
#' # Retrieve table G01 (Selected Person Characteristics) for 2021
#' # First call downloads the DataPack (~380MB)
#' g01 <- get_census_data(census_year = 2021, table = "G01")
#'
#' # Second call uses cached ZIP - much faster!
#' g02 <- get_census_data(census_year = 2021, table = "G02")
#'
#' # Retrieve 2016 Census data
#' g01_2016 <- get_census_data(census_year = 2016, table = "G01")
#'
#' # Retrieve 2011 Census data (uses B prefix)
#' b01_2011 <- get_census_data(census_year = 2011, table = "B01")
#'
#' # Clear cached files when done (optional - clears automatically when session ends)
#' clear_cache()
#' }
#'
#' @seealso \code{abs_census_tables} for table descriptions,
#'   \code{clear_cache} to remove cached files,
#'   \code{get_boundary_data} for boundary correspondence files
#'
#' @export
get_census_data <- function(
  census_year,
  table,
  cache = TRUE
) {
  # =====================================#
  # CHECK PARAMS

  # Validate census_year
  valid_years <- c(2011, 2016, 2021)
  if (!is.numeric(census_year) || !census_year %in% valid_years) {
    stop("census_year must be one of: ", paste(valid_years, collapse = ", "))
  }

  # Validate table
  if (missing(table) || is.null(table) || !is.character(table)) {
    stop("table must be provided as a character string (e.g., 'G01')")
  }

  # =====================================#
  # BUILD URL AND FILE NAME
  # URL patterns for each Census year
  url <- switch(
    as.character(census_year),
    "2021" = "https://www.abs.gov.au/census/find-census-data/datapacks/download/2021_GCP_SA1_for_AUS_short-header.zip",
    "2016" = "https://www.abs.gov.au/census/find-census-data/datapacks/download/2016_GCP_SA1_for_AUS_short-header.zip",
    "2011" = "https://www.abs.gov.au/census/find-census-data/datapacks/download/2011_BCP_SA1_for_AUST_short-header.zip"
  )

  # Normalise table input (handle G01, G1, g01, etc.)
  table_upper <- toupper(table)
  # Ensure format like G01 (with leading zero if needed)
  if (grepl("^[A-Z][0-9]$", table_upper)) {
    table_upper <- paste0(substr(table_upper, 1, 1), "0", substr(table_upper, 2, 2))
  }

  # =====================================#
  # DOWNLOAD OR USE CACHED ZIP
  cache_dir <- get_census_cache_dir()
  zip_file <- file.path(cache_dir, paste0("census_", census_year, "_datapack.zip"))

  if (cache && file.exists(zip_file)) {
    message("Using cached ", census_year, " Census DataPack...")
  } else {
    message("Downloading ", census_year, " Census DataPack (this may take a few minutes)...")
    tryCatch({
      utils::download.file(url, zip_file, mode = "wb", quiet = TRUE)
    }, error = function(e) {
      stop("Failed to download Census DataPack: ", e$message)
    })
    message("Download complete.")
  }

  # =====================================#
  # EXTRACT TABLE FROM ZIP
  # List files in ZIP and find the matching table
  zip_contents <- utils::unzip(zip_file, list = TRUE)

  # Build pattern to match the file (handles varying directory names)
  file_pattern <- build_census_file_pattern(census_year, table_upper)
  matching_files <- zip_contents$Name[grepl(file_pattern, zip_contents$Name, ignore.case = TRUE)]

  if (length(matching_files) == 0) {
    if (!cache) unlink(zip_file)
    stop("Table '", table, "' not found in the ", census_year, " Census DataPack.\n",
         "Note: 2021/2016 use G-prefix tables (G01, G02, etc.), ",
         "2011 uses B-prefix tables (B01, B02, etc.).")
  }

  target_file <- matching_files[1]
  message("Extracting table ", table_upper, "...")

  # Extract the specific file to temp directory
  temp_dir <- tempdir()
  utils::unzip(zip_file, files = target_file, exdir = temp_dir, overwrite = TRUE)
  extracted_path <- file.path(temp_dir, target_file)

  # Read the CSV file
  data <- utils::read.csv(extracted_path, stringsAsFactors = FALSE, check.names = FALSE)

  # Clean up extracted file (but keep cached ZIP)
  unlink(extracted_path)

  # If not caching, remove the ZIP
 if (!cache) unlink(zip_file)

  message("Successfully retrieved ", census_year, " Census table ", table_upper,
          " (", nrow(data), " rows, ", ncol(data), " columns)")

  return(data)
}


#' Helper Function to Get Census Cache Directory
#'
#' Returns the path to the directory used for caching Census DataPack ZIP files.
#' Creates the directory if it doesn't exist.
#'
#' @return Character string with the path to the cache directory.
#'
#' @noRd
#' @keywords internal
get_census_cache_dir <- function() {
  cache_dir <- file.path(tempdir(), "scgElectionsAU_census_cache")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  return(cache_dir)
}


#' Helper Function to Build Census File Pattern for Matching
#'
#' Constructs a regex pattern to match Census table files within a DataPack ZIP,
#' accounting for varying directory structures.
#'
#' @param census_year Numeric. The Census year (2011, 2016, or 2021).
#' @param table Character. The table identifier (e.g., "G01").
#'
#' @return Character string with regex pattern to match the file.
#'
#' @noRd
#' @keywords internal
build_census_file_pattern <- function(census_year, table) {
  # File naming conventions (all use AUST):
  # 2021: 2021Census_G01_AUST_SA1.csv
  # 2016: 2016Census_G01_AUST_SA1.csv
  # 2011: 2011Census_B01_AUST_SA1_short.csv

  if (census_year == 2011) {
    # Match pattern like: */2011Census_B01_AUST_SA1_short.csv
    pattern <- paste0(census_year, "Census_", table, "_AUST_SA1_short\\.csv$")
  } else {
    # Match pattern like: */2021Census_G01_AUST_SA1.csv
    pattern <- paste0(census_year, "Census_", table, "_AUST_SA1\\.csv$")
  }

  return(pattern)
}
