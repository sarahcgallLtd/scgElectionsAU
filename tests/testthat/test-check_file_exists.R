test_that("test that check_file_exists returns error when incorrect file_name", {
  expect_error(
    get_aec_data(file_name = "National list of candidate"),
    "`National list of candidate` does not exist. Check the `file_name` and try again."
  )
})

test_that("test that check_file_exists returns error when category does not match file_name", {
  expect_error(
    get_aec_data(file_name = "National list of candidates", category = "General"),
    "`National list of candidates` for the `General` category does not exist. Check that the `category` is one of only 'General', 'House', 'Referendum', or 'Senate' and try again."
  )
})