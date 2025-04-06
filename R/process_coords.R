#' Process Polling Place Coordinates
#'
#' Updates missing or invalid coordinate data for polling places in the "Polling place" dataset from
#' Australian federal elections. This helper function fills in missing (`NA`) or zero-valued latitude
#' and longitude coordinates by matching `PollingPlaceID` with an internal coordinate dataset
#' (`coords`) stored in the `scgElectionsAU` package namespace. The function processes data for any
#' specified election year, ensuring alignment with known polling place locations.
#'
#' @param data A data frame containing polling place data for a single election event. Must include:
#'   \itemize{
#'     \item `event` (the election year, e.g., "2004", "2010")
#'     \item `PollingPlaceID` (unique identifier for polling places)
#'     \item `Latitude` (latitude coordinate, potentially NA or 0)
#'     \item `Longitude` (longitude coordinate, potentially NA or 0)
#'   }
#'   A `date` column is typically present as mandatory metadata.
#' @param event A character string specifying the election year (e.g., "2004", "2010"). Used for
#'   logging purposes only; processing occurs for all years.
#'
#' @return A data frame identical to the input, with updated columns:
#'   \itemize{
#'     \item `Latitude` (updated with non-NA, non-zero values from the internal `coords` dataset where matches are found)
#'     \item `Longitude` (updated with non-NA, non-zero values from the internal `coords` dataset where matches are found)
#'   }
#'   Unmatched or already valid coordinates remain unchanged.
#'
#' @details
#' This function processes polling place coordinates by:
#' \enumerate{
#'   \item **Retrieving internal data**: Accesses the `coords` dataset from the `scgElectionsAU` package
#'         namespace, which contains known `PollingPlaceID`, `Latitude`, and `Longitude` values.
#'   \item **Matching polling places**: Uses `PollingPlaceID` to match rows in the input data with the
#'         internal `coords` dataset.
#'   \item **Updating coordinates**: Replaces `NA` or zero values in `Latitude` and `Longitude` with
#'         corresponding values from `coords` where matches exist.
#'   \item **Logging**: Outputs a message indicating the election year being processed, though processing
#'         applies universally regardless of year.
#' }
#' The function assumes the input data frame contains the required columns (`event`, `PollingPlaceID`,
#' `Latitude`, and `Longitude`) as sourced from the AEC "Polling place" dataset, and that the internal
#' `coords` dataset is available and correctly formatted within the package namespace.
#'
#' @examples
#' # Sample data with missing coordinates
#' data_2010 <- data.frame(
#'   date = "2010-08-21",
#'   event = "2010",
#'   PollingPlaceID = c("PP001", "PP002"),
#'   Latitude = c(NA, 0),
#'   Longitude = c(0, NA)
#' )
#' process_coords(data_2010, "2010")
#'
#' # Sample data with some valid coordinates
#' data_2013 <- data.frame(
#'   date = "2013-09-07",
#'   event = "2013",
#'   PollingPlaceID = c("PP003", "PP004"),
#'   Latitude = c(-37.8, NA),
#'   Longitude = c(144.9, 0)
#' )
#' process_coords(data_2013, "2013")
#'
#' @export
process_coords <- function(data, event) {
  message(paste0("Filling in missing coordinates for `", event, "` data, where possible."))

  # Get internal coordinate data
  coords <- get0("coords", envir = asNamespace("scgElectionsAU"))

  # Match PollingPlaceID and replace missing coordinates
  match_idx <- match(data$PollingPlaceID, coords$PollingPlaceID)

  # Replace NA or 0 Latitude values where there's a match
  na_lat <- is.na(data$Latitude) | data$Latitude == 0
  data$Latitude[na_lat] <- coords$Latitude[match_idx][na_lat]

  # Replace NA or 0 Longitude values where there's a match
  na_lon <- is.na(data$Longitude) | data$Longitude == 0
  data$Longitude[na_lon] <- coords$Longitude[match_idx][na_lon]

  # Return updated data
  return(data)
}