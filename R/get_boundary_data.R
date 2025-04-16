#' Retrieve Australian Bureau of Statistics (ABS) boundary data
#'
#' Downloads and processes ABS boundary data (allocation or correspondence files)
#' for a specified reference year and geographic level from the scgElectionsAU package.
#'
#' @param ref_date Numeric. The reference year for the boundary data. Must be between 2011 and 2024, inclusive.
#' @param level Character. The geographic level of the boundary data. One of "CED" (Commonwealth Electoral Division),
#'   "SA1" (Statistical Area Level 1), "MB" (Mesh Block), or "POA" (Postal Area). Defaults to "CED".
#' @param type Character. The type of boundary data. One of "allocation" or "correspondence". Defaults to "allocation".
#'
#' @return A data frame containing the boundary data for the specified parameters. If multiple files are downloaded,
#'   they are combined into a single data frame, provided they have identical column structures.
#'
#' @details
#' This function retrieves boundary data by accessing the `abs_boundary_index` dataset in the `scgElectionsAU` package,
#' filtering it based on the provided `ref_date`, `level`, and `type`. It then downloads the corresponding files from
#' the URLs listed in the index using `scgUtils::get_file()`. If multiple files are retrieved, they are combined into
#' a single data frame using `rbind`. The function includes validation checks to ensure the parameters are valid and
#' that the downloaded data can be combined.
#'
#' @examples
#' \dontrun{
#' # Retrieve 2021 CED allocation data
#' ced_data <- get_boundary_data(ref_date = 2021, level = "CED", type = "allocation")
#'
#' # Retrieve 2016 SA1 correspondence data
#' sa1_data <- get_boundary_data(ref_date = 2016, level = "SA1", type = "correspondence")
#' }
#'
#' @export
get_boundary_data <- function(
  ref_date,
  level = c("CED", "SA1", "MB", "POA"),
  type = c("allocation", "correspondence")
) {
  # =====================================#
  # CHECK PARAMS
  level <- match.arg(level)
  type <- match.arg(type)

  # Validate ref_date
  if (!is.numeric(ref_date) || ref_date < 2011 || ref_date > 2024) {
    stop("ref_date must be a number between 2011 and 2024")
  }

  # =====================================#
  # GET AND PROCESS INTERNAL DATA
  # Get index from the 'abs_boundary_index' data available in scgElectionsAU package
  index <- get0(x = "abs_boundary_index", envir = asNamespace("scgElectionsAU"))

  # Check if 'names' data is available
  if (is.null(index)) {
    stop(paste0("Data 'abs_boundary_index' not found in 'scgElectionsAU' package. Contact the package maintainer."))
  }

  # Filter index by level, type, and ref_date
  index <- index[index$level == level & index$type == type & index$ref_date == ref_date, ]

  # Get list of urls
  urls <- as.character(index$url)

  # Check if index has 1 or more urls
  if (length(urls) == 0) {
    stop("No data found for the specified parameters. Check that the `ref_date` captures years between 2011 and 2024, inclusively.")
  }

  # =====================================#
  # GET DATA FILES FROM URLs
  # Initliase an empty df to store all data
  df_list <- list()
  for (i in seq_along(urls)) {
    message(paste0("Downloading boundary file from: ", urls[i]))
    # Download the file
    tmp_df <- suppressMessages(
      scgUtils::get_file(urls[i], source = "web")
    )

    # Append to the combined DataFrame
    df_list[[i]] <- tmp_df
  }

  message(paste0("Successfully downloaded ", ref_date, " ", level, " boundary file(s). Structure: ", index$Notes[1]))
  # If only one file, return it directly
  if (length(df_list) == 1) {
    return(df_list[[1]])
  }

  # Check if all data frames have the same columns
  first_cols <- names(df_list[[1]])
  if (!all(sapply(df_list[-1], function(df) identical(names(df), first_cols)))) {
    stop("Data frames have different columns and cannot be combined.")
  }

  # Combine the data frames using base R
  message("Combining files into one single file.")
  combined_df <- do.call(rbind, df_list)
  return(combined_df)

}