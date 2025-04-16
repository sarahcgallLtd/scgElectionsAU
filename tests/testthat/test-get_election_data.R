test_that("test that get_election_data returns errors", {
  expect_error(
    get_election_data(file_name = "Non-classic divisions", date_range = list(from = "2024-01-01", to = "2025-01-01")),
    "Check that the `date_range` captures election periods between 2004 and 2022, inclusively."
  )
})

test_that("test that get_election_data returns 2022 election data", {
  df <- get_election_data(file_name = "National list of candidates")
  expect_length(df, 12)

  df <- get_election_data(file_name = "Postal vote applications by party",
                     date_range = list(from = "2016-01-01", to = "2019-01-01"),
                     category = "Statistics",
                     process = FALSE)
  expect_length(df, 14)

  df <- get_election_data(file_name = "Postal vote applications by date",
                     date_range = list(from = "2016-01-01", to = "2019-01-01"),
                     category = "Statistics",
                     process = FALSE)
  expect_length(df, 58)
})

test_that("test that get_election_data returns both 2022 and 2019 election data", {
  df <- get_election_data(file_name = "National list of candidates",
                     date_range = list(from = "2019-01-01", to = "2023-01-01"))
  expect_length(df, 12)
})

test_that("test that check_file_exists returns message when date range does not include file", {
  expect_error(
    get_election_data(file_name = "Non-classic divisions", date_range = list(from = "2004-01-01", to = "2005-01-01")),
    "No data was available for `Non-classic divisions` with the parameters used. Check the date range and try again."
  )
})


