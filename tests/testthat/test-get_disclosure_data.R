test_that("get_disclosure_data works with default parameters", {
  df <- get_disclosure_data()
  expect_s3_class(df, "data.frame")
})

test_that("get_disclosure_data works with specific valid parameters", {
  df <- get_disclosure_data(file_name = "Donations Made", group = "Donor", type = "Annual")
  expect_s3_class(df, "data.frame")

  df <- get_disclosure_data(file_name = "Returns", group = "Party", type = "Annual")
  expect_s3_class(df, "data.frame")

  df <- get_disclosure_data(file_name = "Expenses", group = "Candidate", type = "Election")
  expect_s3_class(df, "data.frame")
})

test_that("get_disclosure_data errors with invalid file_name", {
  expect_error(
    get_disclosure_data(file_name = "Invalid File"),
    regexp = "Invalid file_name provided: Invalid File"
  )
})

test_that("get_disclosure_data errors with invalid group", {
  expect_error(
    get_disclosure_data(group = "Invalid Group"),
    regexp = "Invalid group provided: Invalid Group"
  )
})

test_that("get_disclosure_data errors when data does not exist", {
  expect_error(
    get_disclosure_data(file_name = "Donations Made", group = "Candidate", type = "Annual"),
    regexp = "File does not exist"
  )
})