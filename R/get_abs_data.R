#' Retrieve data from the Australian Bureau of Statistics (ABS) Data API
#'
#' Downloads data from the ABS Data API (SDMX RESTful web service) for specified
#' dataflows at SA1 or CED geographic levels. This provides access to SEIFA indices,
#' Census data, and other ABS datasets without downloading large DataPack files.
#'
#' @param dataflow Character. The dataflow identifier to query. Common options include:
#'   \itemize{
#'     \item \code{"ABS_SEIFA2021_SA1"}: SEIFA 2021 indices at SA1 level
#'     \item \code{"ABS_SEIFA2016_SA1"}: SEIFA 2016 indices at SA1 level
#'     \item \code{"C21_G01_CED"}: Census 2021 G01 (Selected person characteristics) at CED level
#'     \item \code{"C21_G02_CED"}: Census 2021 G02 (Medians and averages) at CED level
#'     \item \code{"ABS_CENSUS2011_B01_SA1_SA"}: Census 2011 B01 at SA1 level (SA only)
#'   }
#'   Use \code{list_abs_dataflows} to see all available dataflows.
#' @param filter Character or NULL. Optional SDMX filter expression to subset the data.
#'   Use \code{"all"} or \code{NULL} for all data. Filter format depends on the dataflow
#'   structure - see ABS Data API documentation for details.
#' @param start_period Character or NULL. Start period for time series data (e.g., "2021").
#' @param end_period Character or NULL. End period for time series data (e.g., "2021").
#' @param cache Logical. If TRUE (default), caches the downloaded data for the session,
#'   making subsequent identical requests instant. Set to FALSE to always download fresh data.
#'
#' @return A data frame containing the requested data with columns for each dimension
#'   and the observation values.
#'
#' @details
#' This function queries the ABS Data API at \url{https://data.api.abs.gov.au/rest/}.
#' The API uses the SDMX (Statistical Data and Metadata eXchange) standard, and data
#' is parsed using the \code{readsdmx} package.
#'
#' Key points:
#' \itemize{
#'   \item SA1 and CED level data is available for select datasets (SEIFA, some Census tables)
#'   \item Not all Census tables are available via API - for full Census coverage at SA1 level,
#'     use \code{get_census_data} which downloads from DataPacks
#'   \item Large queries (e.g., SEIFA at SA1 level) may take time on first request;
#'     caching makes subsequent requests instant
#' }
#'
#' Use \code{clear_cache} to remove cached data when needed.
#'
#' @section Available SA1 Dataflows:
#' \itemize{
#'   \item SEIFA 2021 and 2016 indices
#'   \item Census 2011 Basic Community Profile tables (SA only)
#' }
#'
#' @section Available CED Dataflows:
#' \itemize{
#'   \item Census 2021 General Community Profile tables (G01-G62)
#' }
#'
#' @examples
#' \dontrun{
#' # Get SEIFA 2021 data for all SA1s
#' seifa <- get_abs_data("ABS_SEIFA2021_SA1")
#'
#' # Get Census 2021 G01 data for all CEDs
#' g01_ced <- get_abs_data("C21_G01_CED")
#'
#' # Get data with time period filter
#' seifa_2021 <- get_abs_data("ABS_SEIFA2021_SA1",
#'                            start_period = "2021",
#'                            end_period = "2021")
#'
#' # Second call uses cache - instant!
#' seifa_2021_again <- get_abs_data("ABS_SEIFA2021_SA1",
#'                                   start_period = "2021",
#'                                   end_period = "2021")
#' }
#'
#' @seealso \code{list_abs_dataflows} to discover available dataflows,
#'   \code{get_census_data} for full Census DataPack access,
#'   \code{get_boundary_data} for boundary correspondence files,
#'   \code{clear_cache} to remove cached data
#'
#' @importFrom readsdmx read_sdmx
#' @export
get_abs_data <- function(
    dataflow,
    filter = NULL,
    start_period = NULL,
    end_period = NULL,
    cache = TRUE
) {
  # =====================================#
  # CHECK PARAMS
  if (missing(dataflow) || !is.character(dataflow) || length(dataflow) != 1) {
    stop("dataflow must be provided as a single character string")
  }

  # =====================================#
  # CHECK CACHE
  # Normalise filter for cache key

  filter_part <- if (is.null(filter) || filter == "all") "all" else filter

  if (cache) {
    cache_key <- paste("abs", dataflow, filter_part,
                       ifelse(is.null(start_period), "", start_period),
                       ifelse(is.null(end_period), "", end_period),
                       sep = "|")
    cached_data <- get_abs_cache(cache_key)
    if (!is.null(cached_data)) {
      message("Using cached ABS API data for `", dataflow, "`...")
      return(cached_data)
    }
  }

  # =====================================#
  # BUILD URL
  base_url <- "https://data.api.abs.gov.au/rest/data/"

  # Construct full URL
  url <- paste0(base_url, dataflow, "/", filter_part)

  # Add query parameters for time period
  query_params <- c()
  if (!is.null(start_period)) {
    query_params <- c(query_params, paste0("startPeriod=", start_period))
  }
  if (!is.null(end_period)) {
    query_params <- c(query_params, paste0("endPeriod=", end_period))
  }

  if (length(query_params) > 0) {
    url <- paste0(url, "?", paste(query_params, collapse = "&"))
  }

  # =====================================#
  # FETCH AND PARSE DATA USING readsdmx
  message("Fetching data from ABS API: ", dataflow, "...")

  result <- tryCatch({
    suppressWarnings(readsdmx::read_sdmx(url))
  }, error = function(e) {
    msg <- conditionMessage(e)
    if (grepl("404|not found", msg, ignore.case = TRUE)) {
      stop("Dataflow '", dataflow, "' not found. Use list_abs_dataflows() to see available options.")
    } else if (grepl("400|invalid", msg, ignore.case = TRUE)) {
      stop("Invalid request. Check the filter expression and parameters.")
    } else {
      stop("Failed to fetch data from ABS API: ", msg)
    }
  })

  # Check for empty result
  if (is.null(result) || nrow(result) == 0) {
    message("No data found for the specified query.")
    return(data.frame())
  }

  message("Successfully retrieved ", nrow(result), " observations from ", dataflow)

  # =====================================#
  # CACHE AND RETURN DATA
  if (cache) {
    set_abs_cache(cache_key, result)
  }

  return(result)
}


# ======================================================================================================================
# CACHING FUNCTIONS

# Package-level environment to store cached ABS API data
.abs_cache <- new.env(parent = emptyenv())


#' Helper Function to Get Cached ABS API Data
#'
#' Retrieves data from the ABS API cache if it exists.
#'
#' @param cache_key The cache key to look up.
#'
#' @return The cached data frame, or NULL if not found.
#'
#' @noRd
#' @keywords internal
get_abs_cache <- function(cache_key) {
  if (exists(cache_key, envir = .abs_cache)) {
    return(get(cache_key, envir = .abs_cache))
  }
  return(NULL)
}


#' Helper Function to Store ABS API Data in Cache
#'
#' Saves data to the ABS API cache.
#'
#' @param cache_key The cache key to store under.
#' @param data The data frame to cache.
#'
#' @return Invisible NULL.
#'
#' @noRd
#' @keywords internal
set_abs_cache <- function(cache_key, data) {
  assign(cache_key, data, envir = .abs_cache)
  invisible(NULL)
}


#' List available ABS dataflows
#'
#' Retrieves a list of all available dataflows from the ABS Data API.
#' Optionally filters to show only dataflows containing SA1 or CED level data.
#'
#' @param filter Character or NULL. Filter to apply:
#'   \itemize{
#'     \item \code{NULL}: Return all dataflows
#'     \item \code{"SA1"}: Return only dataflows with SA1 level data
#'     \item \code{"CED"}: Return only dataflows with CED level data
#'     \item \code{"census"}: Return only Census-related dataflows
#'   }
#' @param pattern Character or NULL. Additional regex pattern to filter dataflow names.
#'
#' @return A data frame with columns:
#'   \itemize{
#'     \item \code{id}: Dataflow identifier to use with \code{get_abs_data}
#'     \item \code{name}: Human-readable description
#'   }
#'
#' @examples
#' \dontrun{
#' # List all dataflows
#' all_flows <- list_abs_dataflows()
#'
#' # List only SA1 level dataflows
#' sa1_flows <- list_abs_dataflows("SA1")
#'
#' # List only CED level dataflows
#' ced_flows <- list_abs_dataflows("CED")
#'
#' # Search for SEIFA dataflows
#' seifa_flows <- list_abs_dataflows(pattern = "SEIFA")
#' }
#'
#' @seealso \code{get_abs_data} to fetch data from a dataflow
#'
#' @importFrom xml2 read_xml xml_find_all xml_attr xml_find_first xml_text
#' @export
list_abs_dataflows <- function(filter = NULL, pattern = NULL) {
  # Fetch dataflow list from API
  url <- "https://data.api.abs.gov.au/rest/dataflow/ABS?detail=allstubs"

  message("Fetching available dataflows from ABS API...")

  # Download and parse XML
  doc <- tryCatch({
    xml2::read_xml(url)
  }, error = function(e) {
    stop("Failed to retrieve dataflow list from ABS API: ", e$message)
  })

  # Define namespaces
  ns <- c(
    structure = "http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure",
    common = "http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
  )

  # Extract dataflow information
  dataflow_nodes <- xml2::xml_find_all(doc, ".//structure:Dataflow", ns)

  if (length(dataflow_nodes) == 0) {
    stop("No dataflows found in API response")
  }

  ids <- xml2::xml_attr(dataflow_nodes, "id")
  names <- sapply(dataflow_nodes, function(node) {
    name_node <- xml2::xml_find_first(node, ".//common:Name", ns)
    if (!is.na(name_node)) {
      xml2::xml_text(name_node)
    } else {
      NA_character_
    }
  })

  result <- data.frame(
    id = ids,
    name = names,
    stringsAsFactors = FALSE
  )

  # Apply filter
  if (!is.null(filter)) {
    filter <- toupper(filter)
    if (filter == "SA1") {
      result <- result[grepl("SA1", result$id, ignore.case = TRUE) |
                         grepl("SA1", result$name, ignore.case = TRUE), ]
    } else if (filter == "CED") {
      result <- result[grepl("CED", result$id, ignore.case = TRUE) |
                         grepl("CED|Electoral", result$name, ignore.case = TRUE), ]
    } else if (filter == "CENSUS") {
      result <- result[grepl("CENSUS|^C[0-9]{2}_", result$id, ignore.case = TRUE) |
                         grepl("Census", result$name, ignore.case = TRUE), ]
    }
  }

  # Apply pattern filter
  if (!is.null(pattern)) {
    result <- result[grepl(pattern, result$id, ignore.case = TRUE) |
                       grepl(pattern, result$name, ignore.case = TRUE), ]
  }

  message("Found ", nrow(result), " dataflows")

  return(result)
}
