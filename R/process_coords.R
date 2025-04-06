#' Process Coordinate Data
#'
#' Fills in missing latitude and longitude values for polling places using a
#' reference set derived from the data.
#'
#' @param data The data frame containing polling place data, with columns
#'        `PollingPlaceID`, `Latitude`, and `Longitude`.
#'
#' @return The data frame with missing `Latitude` and `Longitude`
#'         values filled in where possible.
#'
#' @details This function creates a reference set of unique polling places
#' with non-missing coordinates (`Latitude` and `Longitude`) based on `PollingPlaceID`.
#' It then uses this reference to impute missing coordinate values in the main dataset,
#' ensuring all polling places have location data where available.
#'
#' @examples
#' \dontrun{
#' complete_data <- process_coords(data)
#' }
#'
#' @noRd
#' @keywords internal
process_coords <- function(data, event) {
  message("Processing to ensure all data aligns across all election years.")

  # Create reference dataframe with non-NA coordinates
  ref <- data[!is.na(data$Latitude) & !is.na(data$Longitude), c("PollingPlaceID", "Latitude", "Longitude")]
  ref <- unique(ref)

  # Fill in missing Latitude and Longitude values
  data$Latitude[is.na(data$Latitude)] <- ref$Latitude[match(data$PollingPlaceID[is.na(data$Latitude)], ref$PollingPlaceID)]
  data$Longitude[is.na(data$Longitude)] <- ref$Longitude[match(data$PollingPlaceID[is.na(data$Longitude)], ref$PollingPlaceID)]

  # Return updated data
  return(data)
}