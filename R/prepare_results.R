prepare_results <- function(
  dataset = c("Votes", "FP", "TCP", "TPP", "DistPref", "TCPFlowPref"),
  event = c("2025 Federal Election", "2023 Referendum", "2022 Federal Election", "2019 Federal Election",
            "2016 Federal Election", "2013 Federal Election"),
  boundary = c("original", "latest CED", "2024 CED", "2021 CED", "latest POA", "latest SA1")
) {
  # =====================================#
  # CHECK PARAMS
  dataset <- match.arg(dataset)
  event <- match.arg(event)
  boundary <- match.arg(boundary)

  # =====================================#
  # PREPARE PARAMETERS
  file_name <- switch(
    dataset,
    "Votes" = "Votes by polling place",
    "FP" = "First preferences by candidate by polling place",
    "TCP" = "Two candidate preferred by candidate by polling place",
    "TPP" = "Two party preferred by polling place",
    "DistPref" = "Distribution of preferences by polling place",
    "TCPFlowPref" = "Two candidate preferred flow of preferences by polling place"
  )
  date_range <- switch(
    event,
    "2025 Federal Election" = list(from = "2025-01-01", to = "2026-01-01"),
    "2023 Referendum" = list(from = "2023-01-01", to = "2024-01-01"),
    "2022 Federal Election" = list(from = "2022-01-01", to = "2023-01-01"),
    "2019 Federal Election" = list(from = "2019-01-01", to = "2020-01-01"),
    "2016 Federal Election" = list(from = "2016-01-01", to = "2017-01-01"),
    "2013 Federal Election" = list(from = "2013-01-01", to = "2014-01-01")
  )
  type <- ifelse(event == "2023 Referendum", "Referendum", "Federal Election")
  category <- ifelse(event == "2023 Referendum", "Referendum", "House")

  # =====================================#
  # GET ELECTION DATA
  # Get SA1 -> Polling Place count data
  sa1_to_pp <- get_election_data(
    file_name = "Votes by SA1",
    date_range = date_range,
    type = type,
    category = "Statistics"
  )

  # Get dataset
  results <- get_election_data(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category
  )

  # Merge SA1 and dataset by polling place:
  # date, event, StateAb, DivisionNm, PollingPlaceID, PollingPlaceNm
  results <- merge(sa1_to_pp,
                   results[, !(names(results) %in% c("StateAb", "DivisionNm", "PollingPlaceNm"))],
                   by = c("date", "event", "PollingPlaceID"), all = TRUE)

  # Rename `StatisticalAreaID` to match ABS dataset
  if (event == "2013 Federal Election") {
    results <- rename_cols(results, CD_CODE_2006 = "StatisticalAreaID")
  } else if (event == "2016 Federal Election") {
    results <- rename_cols(results, SA1_7DIGITCODE_2011 = "StatisticalAreaID")
  } else if (event %in% c("2023 Referendum", "2022 Federal Election", "2019 Federal Election")) {
    results <- rename_cols(results, SA1_7DIGITCODE_2016 = "StatisticalAreaID")
  } else if (event == "2025 Federal Election") {
    results <- rename_cols(results, SA1_7DIGITCODE_2021 = "StatisticalAreaID")
  }

  # =====================================#
  # APPLY BOUNDARY TRANSFORMATION
  # Return as-is if original boundaries requested
  if (boundary == "original") {
    return(results)
  }

  # Map boundary choice to compare_to parameter for prepare_boundaries()
  compare_to <- switch(
    boundary,
    "latest CED" = "2025 Federal Election",
    "2024 CED" = "2025 Federal Election",
    "2021 CED" = "2022 Federal Election",
    "latest POA" = "2021 Postcodes",
    "latest SA1" = "2021 Census"
  )

  # Map event to the event parameter for prepare_boundaries()
  boundary_event <- switch(
    event,
    "2025 Federal Election" = "2025 Federal Election",
    "2023 Referendum" = "2023 Referendum",
    "2022 Federal Election" = "2022 Federal Election",
    "2019 Federal Election" = "2019 Federal Election",
    "2016 Federal Election" = "2016 Federal Election",
    "2013 Federal Election" = "2013 Federal Election"
  )

  # Get boundary correspondence data
  boundary_df <- prepare_boundaries(
    event = boundary_event,
    compare_to = compare_to,
    process = TRUE
  )

  # Determine the join column based on event
  join_col <- switch(
    event,
    "2013 Federal Election" = "CD_CODE_2006",
    "2016 Federal Election" = "SA1_7DIGITCODE_2011",
    "2019 Federal Election" = "SA1_7DIGITCODE_2016",
    "2022 Federal Election" = "SA1_7DIGITCODE_2016",
    "2023 Referendum" = "SA1_7DIGITCODE_2016",
    "2025 Federal Election" = "SA1_7DIGITCODE_2021"
  )

  # Merge results with boundary correspondence data
  results <- merge(results, boundary_df, by = join_col, all.x = TRUE)

  return(results)
}