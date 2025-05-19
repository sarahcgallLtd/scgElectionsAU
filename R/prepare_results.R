prepare_results <- function(
  dataset = c("Votes", "FP", "TCP", "TPP", "DistPref", "TCPFlowPref"),
  event = c("2023 Referendum", "2022 Federal Election", "2019 Federal Election", "2016 Federal Election", "2013 Federal Election"),
  boundary = c("original", "latest CED", "2021 CED", "latest POA", "latest SA1") # most recent
) {

  # Prepare parameters
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
    "2023 Referendum" = list(from = "2023-01-01", to = "2024-01-01"),
    "2022 Federal Election" = list(from = "2022-01-01", to = "2014-01-01"),
    "2019 Federal Election" = list(from = "2019-01-01", to = "2020-01-01"),
    "2016 Federal Election" = list(from = "2016-01-01", to = "2017-01-01"),
    "2013 Federal Election" = list(from = "2013-01-01", to = "2014-01-01")
  )
  type <- ifelse(event == "2023 Referendum", "Referendum", "Federal Election")
  category <- ifelse(event == "2023 Referendum", "Referendum", "House")

  # Get SA1 -> Polling Place count data
  sa1_to_pp <- get_election_data(
    file_name = "Votes by SA1",
    date_range = date_range,
    type = type,
    category = "Statistics"
  )

  # Get dataset
  dataset <- get_election_data(
    file_name = file_name,
    date_range = date_range,
    type = type,
    category = category
  )

  # Merge SA1 and dataset by polling place:
  # date, event, StateAb, DivisionNm, PollingPlaceID, PollingPlaceNm
  dataset <- merge(sa1_to_pp,
                   dataset[, !(names(dataset) %in% c("StateAb", "DivisionNm", "PollingPlaceNm"))],
                   by = c("date", "event", "PollingPlaceID"), all = TRUE)

  # Rename `StatisticalAreaID` to match ABS dataset
  if (event == "2013 Federal Election") {
    dataset <- rename_cols(dataset, CD_CODE_20061 = "StatisticalAreaID")
  } else if (event == "2016 Federal Election") {
    dataset <- rename_cols(dataset, SA1_7DIGITCODE_2011 = "StatisticalAreaID")
  } else if (event %in% c("2023 Referendum", "2022 Federal Election", "2019 Federal Election")) {
    dataset <- rename_cols(dataset, SA1_7DIGITCODE_2016 = "StatisticalAreaID")
  }

  return(dataset)
}