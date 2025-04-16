test_that("test that check_params returns errors", {
  expect_error(
    get_election_data(file_name = as.list("National list of candidates","National")),
    "`file_name` must be a string."
  )

  expect_error(
    get_election_data(file_name = "National list of candidates", date_range = "2022-01-01"),
    "`date_range` must be a list with 'from' and 'to' keys."
  )

  expect_error(
    get_election_data(file_name = "National list of candidates", date_range = list(from = "2022-28-01", to = "2023-01-01")),
    "`date_range` values must be valid dates formatted as 'YYYY-MM-DD'."
  )

  expect_error(
    get_election_data(file_name = "National list of candidates", process = "TRUE"),
    "`process` must be a binary TRUE or FALSE."
  )
})