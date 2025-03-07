test_that("test that check_file_exists returns error when incorrect file_name", {
  expect_error(
    get_aec_data(file_name = "National list of candidate"),
    "`National list of candidate` does not exist. Check the `file_name` and try again."
  )
})

test_that("test that check_file_exists returns error when category does not match file_name", {
  expect_error(
    get_aec_data(file_name = "National list of candidates", category = "General"),
    "`National list of candidates` for the `General` category does not exist. Check that the `category` is one of only 'General', 'House', or 'Senate' and try again."
  )
})

test_that("test that check_file_exists returns error when date range does not include file", {
  expect_error(
    get_aec_data(file_name = "Non-classic divisions", date_range = list(from = "2004-01-01", to = "2005-01-01")),
    "`Non-classic divisions` for the year `2004` is not available. Check availability and try again."
  )
})