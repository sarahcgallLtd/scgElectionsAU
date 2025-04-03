test_that("test that get_aec_data returns errors", {
  expect_error(
    get_aec_data(file_name = "Non-classic divisions", date_range = list(from = "2024-01-01", to = "2025-01-01")),
    "Check that the `date_range` captures election periods between 2004 and 2022, inclusively."
  )
})

test_that("test that get_aec_data returns 2022 election data", {
  df <- get_aec_data(file_name = "National list of candidates")
  expect_length(df, 12)

  df <- get_aec_data(file_name = "Party representation",
                     date_range = list(from = "2007-01-01", to = "2010-01-01"),
                     process = TRUE)
  expect_length(df, 13)

  # df <- get_aec_data(file_name = "First preferences by state by party",
  #                    process = TRUE)

  df <- get_aec_data(file_name = "Polling places",
                     category = "General",
                     process = TRUE)
  expect_length(df, 17)

  # df <- get_aec_data(file_name = "First preferences by state by vote type",
  #                    category = "Senate",
  #                    process = TRUE)
  #
  # df <- get_aec_data(file_name = "First preferences by group by vote type",
  #                    category = "Senate",
  #                    process = TRUE)

  df <- get_aec_data(file_name = "Postal vote applications by date",
                     date_range = list(from = "2019-01-01", to = "2022-01-01"),
                     category = "Statistics",
                     process = TRUE)
  expect_length(df, 6)

  df <- get_aec_data(file_name = "Pre-poll votes",
                     category = "Statistics",
                     process = TRUE)
  expect_length(df, 7)

  df <- get_aec_data(file_name = "Votes by SA1",
                     category = "Statistics",
                     process = TRUE)
  expect_length(df, 9)

  df <- get_aec_data(file_name = "Overseas",
                     category = "Statistics",
                     process = TRUE)
  expect_length(df, 8)
})

test_that("test that get_aec_data returns both 2022 and 2019 election data", {
  df <- get_aec_data(file_name = "National list of candidates",
                     date_range = list(from = "2019-01-01", to = "2023-01-01"))
  expect_length(df, 12)
})

test_that("test that check_file_exists returns message when date range does not include file", {
  expect_error(
    get_aec_data(file_name = "Non-classic divisions", date_range = list(from = "2004-01-01", to = "2005-01-01")),
    "No data was available for `Non-classic divisions` with the parameters used. Check the date range and try again."
  )
})


