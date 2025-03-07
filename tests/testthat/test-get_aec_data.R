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


