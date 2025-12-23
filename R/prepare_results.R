# These are results built on SA1s for the purpose of either standardising boundaries across elections,
# converting results into different levels, or comparing results to other data like the ABS Census data.
#
# The data first retrieves the SA1 vote statistics which provides an indicative calculation of House of
# Representative votes cast per SA1 for federal elections and referendums between 2013 and present. This
# dataset provides the State, Division, SA1, Polling Place, and Count.
#
# Next, the vote type data are retrieved. These contain the number of ordinary, absent, provisional, delcaration pre-poll,
# postal, and total votes by polling place. This permits the declaration votes (absent, provisional, pre-poll,
# and postal) votes to be appended to the dataset, for the full analysis of results.
#
# This data is then joined by any dataset containing polling place-level data, including voters,
# first preferences by candidates, two candidate preferred by candidate, two party preferred,
# distribution of preferences, and two candidate preferred flow of preferences.

# Levels available:
# - State (AEC original data)
# - Division (AEC original data)
# - PP = Polling Place (AEC original data)
# - SA1 (ABS data)
# - CED (ABS data - required to )
# - POA (ABS data)
# TEST:
prepare_results <- function(
  dataset = c("FP", "TCP", "TPP", "DistPref", "TCPFlowPref", "TPPFlowPref", "Votes"), # NB "Votes" is a Referendum-specific option and "TPPFlowPref" onlt available at the State level
  event = c("2025 Federal Election", "2023 Referendum", "2022 Federal Election", "2019 Federal Election",
            "2016 Federal Election", "2013 Federal Election"),
  level = c("SA1", "PP", "Division", "CED", "POA", "State"),
  boundary = "latest",
  exclude_informal = TRUE,
  split_by_type = TRUE
) {
  # =====================================#
  # CHECK PARAMS
  dataset <- match.arg(dataset)
  event <- match.arg(event)
  level <- match.arg(level)
  boundary <- validate_params(dataset, event, level, boundary)

  # =====================================#
  # PREPARE PARAMETERS
  # Convert user-input parameters (dataset, event, level, boundary) into internal
  # parameters needed for data retrieval (file names, date ranges, boundary years)
  data_params <- resolve_data_params(dataset, event, level)
  file_name <- data_params$file_name
  date_range <- data_params$date_range
  type <- data_params$type
  category <- data_params$category
  vote <- data_params$vote
  level_source <- data_params$level_source
  needs_processing <- data_params$needs_processing
  boundary_params <- resolve_boundary_params(event, level, boundary)
  compare_to <- boundary_params$compare_to

  # =====================================#
  # GET AND PREPARE RESULTS DATA
  # Prepare results dataset (Ordinary and some Pre-Poll)
  results <- prepare_data(file_name, date_range, type, category)

  # Prepare declaration dataset (Absent, some Pre-Poll, Postal, and Provisional)
  dec_votes <- prepare_dec_data(vote, date_range, type, category)

  # Merge results and dec_votes (joining by rows)
  results <- dplyr::bind_rows(results, dec_votes)

  # =====================================#
  # FOR ABS DATA: Join with SA1 weights
  # TODO: Implement SA1/CED/POA level processing
  if (level_source == "ABS") {
    sa1_to_pp <- prepare_sa1_data(date_range, type, level, event, compare_to)
    results <- dplyr::full_join(sa1_to_pp, results,
                                by = c("date", "event", "StateAb", "DivisionNm",
                                       "PollingPlaceID", "PollingPlaceNm"),
                                relationship = "many-to-many")
    results$Votes <- results$Weight * results$Votes
    results <- results[, !(colnames(results) == "Weight")]
  }

  # =====================================#
  # AGGREGATE DATA TO LEVEL
  results <- aggregate_to_level(results, dataset, level, split_by_type)

  # Set VoteType to "Total" if not splitting by type
  if (!split_by_type) {
    results$VoteType <- "Total"
  }

  # Exclude informal votes if requested
  if (exclude_informal && "PartyNm" %in% names(results)) {
    results <- results[results$PartyNm != "Informal", ]
  }

  return(results)
}


#' Helper Function to Validate prepare_results Parameters
#'
#' Validates parameter combinations for \code{prepare_results} and
#' converts the boundary parameter to numeric if needed.
#'
#' @param dataset Character. The type of dataset to retrieve (e.g., "FP", "TCP", "TPP").
#' @param event Character. The election or referendum event.
#' @param level Character. The geographic level for aggregation.
#' @param boundary Character or numeric. Either "latest" or a year between 2011 and 2025.
#'
#' @return The validated boundary parameter (converted to numeric if not "latest").
#'
#' @details
#' This function performs the following validations:
#' \itemize{
#'   \item Boundary must be "latest" or a year between 2011 and 2025
#'   \item Warns if boundary is specified for State/Division levels (ignored)
#'   \item DistPref and TCPFlowPref datasets are only available at Division level
#'   \item Votes dataset is only available for the 2023 Referendum
#' }
#'
#' @noRd
#' @keywords internal
validate_params <- function(dataset, event, level, boundary) {
  # Validate boundary parameter
  if (boundary != "latest") {
    boundary <- as.numeric(boundary)
    if (is.na(boundary) ||
      boundary < 2011 ||
      boundary > 2025) {
      stop("boundary must be 'latest' or a year between 2011 and 2025")
    }
  }

  # Warn if boundary is specified for State/Division levels (not applicable)
  if (level %in% c("State", "Division") && boundary != "latest") {
    warning("boundary parameter is ignored for level = '", level, "' (uses original AEC boundaries)")
  }

  # Validate dataset/level combinations
  # DistPref and TCPFlowPref are only available at Division level
  if (dataset %in% c("DistPref", "TCPFlowPref") && level != "Division") {
    stop("dataset '", dataset, "' is only available at Division level")
  }

  # Votes is only available for Referendum
  if (dataset == "Votes" && event != "2023 Referendum") {
    stop("dataset 'Votes' is only available for the 2023 Referendum")
  }

  # Return validated boundary (converted to numeric if needed)
  boundary
}


#' Helper Function Resolve Dataset and Event Parameters
#'
#' Maps dataset, event, and level parameters to the corresponding AEC file names
#' and metadata required for data retrieval.
#'
#' @param dataset Character. The type of dataset to retrieve. One of "FP", "TCP",
#'   "TPP", "DistPref", "TCPFlowPref", "TPPFlowPref", or "Votes".
#' @param event Character. The election or referendum event (e.g., "2025 Federal Election").
#' @param level Character. The geographic level for aggregation (e.g., "State", "Division", "PP").
#'
#' @return A list containing:
#' \describe{
#'   \item{file_name}{The AEC file name to retrieve}
#'   \item{date_range}{A list with \code{from} and \code{to} date strings}
#'   \item{type}{Either "Federal Election" or "Referendum"}
#'   \item{category}{Either "House" or "Referendum"}
#'   \item{vote}{The vote type file name for declaration votes, or NULL if not applicable}
#'   \item{level_source}{Either "AEC" (State/Division/PP) or "ABS" (SA1/CED/POA)}
#'   \item{needs_processing}{Logical indicating if declaration votes and aggregation are needed}
#' }
#'
#' @noRd
#' @keywords internal
resolve_data_params <- function(dataset, event, level) {
  # Determine file name based on dataset and level
  file_name <- if (level == "State") {
    switch(dataset,
           "FP" = "First preferences by candidate by polling place", # Needs to be aggregated to State-level
           "TCP" = "Two candidate preferred by candidate by polling place", # Needs to be aggregated to State-level
           "TPP" = "Two party preferred by state",
           "DistPref" = "Distribution of preferences by candidate by division", # Needs to be aggregated to State-level
           "TCPFlowPref" = "Two candidate preferred flow of preferences by state by party",
           "TPPFlowPref" = "Two party preferred flow of preferences by state by party",
           "Votes" = "Votes by polling place", # Needs to be aggregated to State-level
           stop("dataset '", dataset, "' is not available at State level")
    )
  } else if (level == "Division") {
    switch(dataset,
           "FP" = "First preferences by candidate by polling place", # Needs to be aggregated to Division-level
           "TCP" = "Two candidate preferred by candidate by polling place", # Needs to be aggregated to Division-level
           "TPP" = "Two party preferred by division",
           "DistPref" = "Distribution of preferences by candidate by division",
           "TCPFlowPref" = "Two candidate preferred flow of preferences by candidate by division",
           "Votes" = "Votes by polling place", # Needs to be aggregated to Division-level
           stop("dataset '", dataset, "' is not available at Division level")
    )
  } else {
    # PP, SA1, CED, POA levels use polling place data
    switch(dataset,
           "FP" = "First preferences by candidate by polling place",
           "TCP" = "Two candidate preferred by candidate by polling place",
           "TPP" = "Two party preferred by polling place",
           "DistPref" = "Distribution of preferences by polling place",
           "TCPFlowPref" = "Two candidate preferred flow of preferences by polling place",
           "Votes" = "Votes by polling place",
           stop("dataset '", dataset, "' is not available at polling place level")
    )
  }

  # Determine date range, type, and category from event
  date_range <- switch(event,
                       "2025 Federal Election" = list(from = "2025-01-01", to = "2026-01-01"),
                       "2023 Referendum" = list(from = "2023-01-01", to = "2024-01-01"),
                       "2022 Federal Election" = list(from = "2022-01-01", to = "2023-01-01"),
                       "2019 Federal Election" = list(from = "2019-01-01", to = "2020-01-01"),
                       "2016 Federal Election" = list(from = "2016-01-01", to = "2017-01-01"),
                       "2013 Federal Election" = list(from = "2013-01-01", to = "2014-01-01")
  )
  type <- ifelse(event == "2023 Referendum", "Referendum", "Federal Election")
  category <- ifelse(event == "2023 Referendum", "Referendum", "House")

  # Determine vote type file name (for declaration votes)
  vote <- switch(dataset,
                 "FP" = "First preferences by candidate by vote type", # Needs to be aggregated to State/Division-level
                 "TCP" = "Two candidate preferred by candidate by vote type", # Needs to be aggregated to State/Division-level
                 "TPP" = "Two party preferred by division by vote type",
                 NULL
  )

  # Determine level source (AEC vs ABS) and whether processing is needed
  level_source <- if (level %in% c("State", "Division", "PP")) "AEC" else "ABS"
  needs_processing <- if (level == "State") {
    dataset %in% c("FP", "TCP", "DistPref", "Votes")
  } else if (level == "Division") {
    dataset %in% c("FP", "TCP", "Votes")
  } else {
    TRUE # PP and ABS levels always process
  }

  list(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category,
    vote = vote,
    level_source = level_source,
    needs_processing = needs_processing
  )
}


#' Helper Function to Resolve Boundary Year and Comparison String
#'
#' Determines the appropriate boundary year based on the event, level, and
#' requested boundary, and constructs the comparison string for
#' \code{prepare_boundaries}.
#'
#' @param event Character. The election or referendum event (e.g., "2025 Federal Election").
#' @param level Character. The geographic level for aggregation (e.g., "CED", "SA1", "POA").
#' @param boundary Character or numeric. Either "latest" or a year between 2011 and 2025.
#'
#' @return A list containing:
#' \describe{
#'   \item{boundary_year}{The resolved boundary year, or NULL for State/Division/PP levels}
#'   \item{compare_to}{The comparison string for \code{prepare_boundaries()}, or NULL if not applicable}
#' }
#'
#' @details
#' The function resolves boundaries as follows:
#' \itemize{
#'   \item For "latest": uses 2025 for CED, 2021 for SA1/POA
#'   \item For specific years: maps to the closest available boundary year
#'   \item Enforces minimum boundary years based on the event (can only map forward)
#'   \item Returns NULL for State, Division, and PP levels (no boundary mapping needed)
#' }
#'
#' @noRd
#' @keywords internal
resolve_boundary_params <- function(event, level, boundary) {
  # Determine minimum boundary year based on event (can only map forward, not backward)
  min_boundary <- switch(event,
                         "2025 Federal Election" = list(CED = 2022, SA1 = 2021, POA = 2021),
                         "2023 Referendum" = list(CED = 2019, SA1 = 2016, POA = 2016),
                         "2022 Federal Election" = list(CED = 2019, SA1 = 2016, POA = 2016),
                         "2019 Federal Election" = list(CED = 2019, SA1 = 2016, POA = 2016),
                         "2016 Federal Election" = list(CED = 2013, SA1 = 2011, POA = 2011),
                         "2013 Federal Election" = list(CED = 2013, SA1 = 2011, POA = 2011)
  )

  # Resolve "latest" to actual year based on level
  if (boundary == "latest") {
    boundary_year <- switch(level,
                            "CED" = 2025,
                            "SA1" = 2021,
                            "POA" = 2021,
                            NULL
    )
  } else {
    # Map to closest available boundary year based on level
    if (level == "CED") {
      ced_years <- c(2013, 2016, 2019, 2022, 2023, 2025)
      ced_years <- ced_years[ced_years >= min_boundary$CED]
      boundary_year <- ced_years[which.min(abs(ced_years - boundary))]
    } else if (level %in% c("SA1", "POA")) {
      census_years <- c(2011, 2016, 2021)
      min_year <- if (level == "SA1") min_boundary$SA1 else min_boundary$POA
      census_years <- census_years[census_years >= min_year]
      boundary_year <- census_years[which.min(abs(census_years - boundary))]
    } else {
      boundary_year <- NULL
    }
  }

  # Ensure boundary_year is not below minimum
  if (!is.null(boundary_year) && level %in% c("CED", "SA1", "POA")) {
    min_year <- min_boundary[[level]]
    if (boundary_year < min_year) {
      boundary_year <- min_year
      message("Adjusted boundary year to ", boundary_year, " (minimum for ", event, ")")
    }
  }

  # Construct compare_to string for prepare_boundaries()
  compare_to <- if (level == "CED") {
    if (boundary_year == 2023) "2023 Referendum" else paste(boundary_year, "Federal Election")
  } else if (level == "SA1") {
    paste(boundary_year, "Census")
  } else if (level == "POA") {
    paste(boundary_year, "Postcodes")
  } else {
    NULL
  }

  list(boundary_year = boundary_year, compare_to = compare_to)
}


#' Prepare main results data
#'
#' Retrieves and prepares the main results dataset (Ordinary and some Pre-Poll votes).
#' Always prepares data at polling place level with VoteType classification.
#' Aggregation to higher levels (State/Division) happens later.
#'
#' @param file_name Character. The AEC file name to retrieve.
#' @param date_range List. Date range with \code{from} and \code{to} elements.
#' @param type Character. Either "Federal Election" or "Referendum".
#' @param category Character. Either "House" or "Referendum".
#'
#' @return A data frame with results data including a VoteType column.
#'
#' @noRd
#' @keywords internal
prepare_data <- function(file_name, date_range, type, category) {
  # Prepare results dataset (Ordinary and some Pre-Poll)
  results <- get_election_data(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category
  )

  # Remove columns that are not needed: Swing
  results <- results[, !(colnames(results) == "Swing")]

  # Rename columns for clarity
  results <- dplyr::rename(results, Votes = OrdinaryVotes)

  # Add VoteType only if PollingPlaceNm exists (polling place level data)
  # Data already at State/Division level (e.g., TPP by state) doesn't get VoteType
  if ("PollingPlaceNm" %in% colnames(results)) {
    results$VoteType <- dplyr::case_when(
      results$PollingPlaceNm == "Pre-Poll" |
        stringr::str_detect(results$PollingPlaceNm, "PPVC") ~ "Pre-Poll",
      stringr::str_detect(results$PollingPlaceNm, "Special Hospital Team") |
        stringr::str_detect(results$PollingPlaceNm, "Mobile Team") ~ "Mobile",
      .default = "Ordinary"
    )
  }

  return(results)
}


#' Helper Function to Prepare Declaration Vote Data
#'
#' Retrieves and reshapes declaration vote data (Absent, Pre-Poll, Postal, Provisional)
#' for merging with main results. Always prepares data at polling place level.
#' Aggregation to higher levels (State/Division) happens later.
#'
#' @param vote Character. The vote type file name for declaration votes.
#' @param date_range List. Date range with \code{from} and \code{to} elements.
#' @param type Character. Either "Federal Election" or "Referendum".
#' @param category Character. Either "House" or "Referendum".
#'
#' @return A data frame with declaration votes in long format with PollingPlaceNm,
#'   PollingPlaceID, and VoteType columns.
#'
#' @noRd
#' @keywords internal
prepare_dec_data <- function(vote, date_range, type, category) {

  # Return NULL if no vote file specified
  if (is.null(vote)) return(NULL)

  # Get declaration votes by division data
  dec_votes <- get_election_data(
    file_name = vote,
    date_range = date_range,
    type = type,
    category = category
  )

  # Remove columns that are not needed: OrdinaryVotes, TotalVotes, and Swing
  dec_votes <- dec_votes[, !(colnames(dec_votes) %in% c("OrdinaryVotes", "TotalVotes", "Swing"))]

  # Rename vote type columns for clarity
  dec_votes <- dplyr::rename(
    dec_votes,
    Absent = AbsentVotes,
    Provisional = ProvisionalVotes,
    `Pre-Poll` = DeclarationPrePollVotes,
    Postal = PostalVotes
  )

  # Pivot to long format with PollingPlaceNm
  dec_votes <- tidyr::pivot_longer(
    dec_votes,
    cols = c(Absent, Provisional, `Pre-Poll`, Postal),
    names_to = "PollingPlaceNm",
    values_to = "Votes"
  )

  # Add PollingPlaceID = 0 (declaration votes don't have a polling place)
  dec_votes$PollingPlaceID <- 0

  # VoteType is the same as PollingPlaceNm for declaration votes
  dec_votes$VoteType <- dec_votes$PollingPlaceNm

  return(dec_votes)
}


#' Prepare SA1 data with boundary correspondence
#'
#' Retrieves SA1 to polling place count data and applies boundary correspondence
#' ratios to map old SA1 codes to new SA1 codes (e.g., 2016 SA1s to 2021 SA1s).
#'
#' @param date_range List. Date range with \code{from} and \code{to} elements.
#' @param type Character. Either "Federal Election" or "Referendum".
#' @param level Character. The geographic level (currently only "SA1" supported).
#' @param event Character. The election event (e.g., "2019 Federal Election").
#' @param compare_to Character. The target boundary year (e.g., "2021 Census").
#'
#' @return A data frame with SA1 to polling place weights, mapped to the target
#'   boundary year's SA1 codes.
#'
#' @importFrom dplyr %>%
#'
#' @noRd
#' @keywords internal
prepare_sa1_data <- function(date_range, type, level, event, compare_to) {

  # Get boundary correspondence data (maps old SA1 -> new SA1 with ratios)
  boundary_df <- prepare_boundaries(
    event = event,
    compare_to = compare_to,
    process = TRUE
  )

  # Get SA1 -> Polling Place count data
  sa1_to_pp <- get_election_data(
    file_name = "Votes by SA1",
    date_range = date_range,
    type = type,
    category = "Statistics"
  )

  # Calculate weight at the polling place level (proportion of PP votes from each SA1)
  sa1_to_pp <- sa1_to_pp %>%
    dplyr::group_by(date, event, StateAb, DivisionNm, PollingPlaceID, PollingPlaceNm) %>%
    dplyr::mutate(Weight = Count / sum(Count, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::select(-Count)

  # Determine column names based on boundary years in the correspondence file
  # Find the old SA1 column (7-digit code from election year)
  old_sa1_col <- names(boundary_df)[grepl("SA1_7DIGITCODE", names(boundary_df)) &
                                      !grepl("2021", names(boundary_df))]
  # Find the new SA1 column (7-digit code for target year)
  new_sa1_col <- names(boundary_df)[grepl("SA1_7DIGITCODE", names(boundary_df)) &
                                      grepl("2021", names(boundary_df))]
  # Find the ratio column
  ratio_col <- names(boundary_df)[grepl("RATIO", names(boundary_df))]

  # If no boundary mapping needed (same year), return as-is
 if (length(old_sa1_col) == 0 || length(ratio_col) == 0) {
    return(sa1_to_pp)
  }

  # Join with boundary correspondence and apply ratios
  sa1_to_pp <- sa1_to_pp %>%
    dplyr::left_join(
      boundary_df %>% dplyr::select(dplyr::all_of(c(old_sa1_col, new_sa1_col, ratio_col))),
      by = stats::setNames(old_sa1_col, "StatisticalAreaID")
    ) %>%
    # Multiply weight by ratio to get proportion in new SA1
    dplyr::mutate(
      Weight = Weight * .data[[ratio_col]],
      # Replace old SA1 with new SA1
      StatisticalAreaID = .data[[new_sa1_col]]
    ) %>%
    # Remove the temporary columns
    dplyr::select(-dplyr::all_of(c(new_sa1_col, ratio_col)))

  return(sa1_to_pp)
}


#' Helper Function to Aggregate Results to a Specified Geographic Level
#'
#' Aggregates polling place level data to the requested geographic level
#' (State, Division, PP, SA1, CED, or POA) by summing numeric vote columns.
#'
#' @param data Data frame. The results data to aggregate.
#' @param dataset Character. The dataset type (e.g., "FP", "TCP", "TPP").
#'   Determines which columns to group by (candidate-level vs party-level).
#' @param level Character. The target geographic level for aggregation.
#'   One of "State", "Division", "PP", "SA1", "CED", or "POA".
#' @param split_by_type Logical. If TRUE and VoteType column exists, includes
#'   VoteType in grouping columns to preserve vote type breakdown. Default FALSE.
#'
#' @return A data frame aggregated to the specified level with summed vote columns.
#'
#' @details
#' Grouping behaviour by level:
#' \itemize{
#'   \item State: Groups by StateAb (and party for FP/TCP/DistPref)
#'   \item Division: Groups by StateAb, DivisionID, DivisionNm (and candidate details)
#'   \item PP: Groups by polling place columns (and candidate details)
#'   \item SA1: Groups by StatisticalAreaID (and candidate details)
#' }
#'
#' Numeric columns are summed, except for ID columns (CandidateID, BallotPosition,
#' PollingPlaceID, DivisionID, StatisticalAreaID, CountNumber) which are excluded.
#'
#' @importFrom dplyr %>%
#'
#' @noRd
#' @keywords internal
aggregate_to_level <- function(data, dataset, level, split_by_type = FALSE) {
  # Define grouping columns based on level
  base_cols <- c("date", "event")

  geo_cols <- if (level == "State") {
    "StateAb"
  } else if (level == "Division") {
    c("StateAb", "DivisionID", "DivisionNm")
  } else if (level == "PP") {
    # PP level: include polling place columns
    c("StateAb", "DivisionID", "DivisionNm", "PollingPlaceID", "PollingPlaceNm")
  } else if (level == "SA1") {
    c("StateAb", "DivisionID", "DivisionNm", "StatisticalAreaID")
  }

  # Define dataset-specific grouping columns
  # For State level: aggregate to party level (not candidate level) for FP/TCP
  # For Division/PP level: keep candidate-level detail
  group_cols <- if (level == "State") {
    switch(dataset,
           "FP" = c(base_cols, geo_cols, "PartyAb", "PartyNm"),
           "TCP" = c(base_cols, geo_cols, "PartyAb", "PartyNm"),
           "DistPref" = c(base_cols, geo_cols, "PartyAb", "PartyNm"),
           "Votes" = c(base_cols, geo_cols),
           # Default for TPP and others
           c(base_cols, geo_cols, "PartyAb", "PartyNm")
    )
  } else {
    # Division/PP level: keep candidate detail
    switch(dataset,
           "FP" = c(base_cols, geo_cols, "CandidateID", "Surname", "GivenNm",
                    "BallotPosition", "Elected", "HistoricElected", "PartyAb", "PartyNm"),
           "TCP" = c(base_cols, geo_cols, "CandidateID", "Surname", "GivenNm",
                     "BallotPosition", "Elected", "HistoricElected", "PartyAb", "PartyNm"),
           "DistPref" = c(base_cols, geo_cols, "CandidateID", "Surname", "GivenNm",
                          "BallotPosition", "Elected", "HistoricElected", "PartyAb", "PartyNm",
                          "CountNumber", "CalculationType"),
           "Votes" = c(base_cols, geo_cols),
           # Default for TPP and others
           c(base_cols, geo_cols, "PartyAb", "PartyNm")
    )
  }

  # Add VoteType to grouping columns if split_by_type is TRUE and column exists
  if (split_by_type && "VoteType" %in% names(data)) {
    group_cols <- c(group_cols, "VoteType")
  }

  # Filter to only columns that exist in the data
  group_cols <- group_cols[group_cols %in% names(data)]

  # Identify numeric columns to aggregate (sum)
  numeric_cols <- names(data)[sapply(data, is.numeric)]
  # Exclude ID columns from summing
  sum_cols <- numeric_cols[!numeric_cols %in% c("CandidateID", "BallotPosition",
                                                "PollingPlaceID", "DivisionID",
                                                "StatisticalAreaID", "CountNumber")]

  # Filter sum_cols to only columns that exist in the data
  sum_cols <- sum_cols[sum_cols %in% names(data)]

  # Aggregate using dplyr
  data <- data %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) %>%
    dplyr::summarise(dplyr::across(dplyr::all_of(sum_cols), ~sum(.x, na.rm = TRUE)),
                     .groups = "drop")

  return(data)
}
