test_that("test that check_params returns errors", {
  expect_error(
    get_aec_data(file_name = as.list("National list of candidates","National")),
    "`file_name` must be a string."
  )

  expect_error(
    get_aec_data(file_name = "National list of candidates", date_range = "2022-01-01"),
    "`date_range` must be a list with 'from' and 'to' keys."
  )

  expect_error(
    get_aec_data(file_name = "National list of candidates", date_range = list(from = "2022-28-01", to = "2023-01-01")),
    "`date_range` values must be valid dates formatted as 'YYYY-MM-DD'."
  )

  expect_error(
    get_aec_data(file_name = "National list of candidates", process = "TRUE"),
    "`process` must be a binary TRUE or FALSE."
  )
})

test_that("test that check_file_exists returns errors", {
  expect_error(
    get_aec_data(file_name = "National list of candidate"),
    "`National list of candidate` does not exist. Check the `file_name` and try again."
  )

  expect_error(
    get_aec_data(file_name = "National list of candidates", category = "General"),
    "`National list of candidates` for the `General` category does not exist. Check that the `category` is one of only 'General', 'House', or 'Senate' and try again."
  )

  expect_error(
    get_aec_data(file_name = "Non-classic divisions", date_range = list(from = "2004-01-01", to = "2005-01-01")),
    "`Non-classic divisions` for the year `2004` is not available. Check availability and try again."
  )
})

test_that("test that get_aec_data returns errors", {
  expect_error(
    get_aec_data(file_name = "Non-classic divisions", date_range = list(from = "2024-01-01", to = "2025-01-01")),
    "Check that the `date_range` captures election periods between 2004 and 2022, inclusively."
  )
})

test_that("test that get_aec_data returns 2022 election data", {
  df <- get_aec_data(file_name = "National list of candidates")
  expect_length(df, 12)
})

test_that("test that get_aec_data returns both 2022 and 2019 election data", {
  df <- get_aec_data(file_name = "National list of candidates",
                     date_range = list(from = "2019-01-01", to = "2023-01-01"))
  expect_length(df, 12)
})


