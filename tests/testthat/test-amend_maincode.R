test_that("amend_maincode correctly converts 11-digit to 7-digit codes", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901", "23456789012"))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_equal(result$SA1_7DIGITCODE_2016, c('1678901', '2789012'))
})

test_that("amend_maincode creates the correct new column name", {
  df <- data.frame(SA1_MAINCODE_2021 = c("12345678901"))
  result <- amend_maincode(df, "SA1_MAINCODE_2021")
  expect_true("SA1_7DIGITCODE_2021" %in% names(result))
})

test_that("amend_maincode creates a numeric column", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901"))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_type(result$SA1_7DIGITCODE_2016, "character")
})

test_that("amend_maincode throws an error if column does not exist", {
  df <- data.frame(other_column = c("123"))
  expect_error(amend_maincode(df, "SA1_MAINCODE_2016"))
})

test_that("amend_maincode handles NA values correctly", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901", NA))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_equal(result$SA1_7DIGITCODE_2016, c('1678901', NA))
})

test_that("amend_maincode works with numeric columns", {
  df <- data.frame(SA1_MAINCODE_2016 = c(12345678901, 23456789012))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_equal(result$SA1_7DIGITCODE_2016, c('1678901', '2789012'))
})

test_that("amend_maincode does not modify original columns", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901"))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_equal(result$SA1_MAINCODE_2016, df$SA1_MAINCODE_2016)
})

test_that("amend_maincode returns a data frame", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901"))
  result <- amend_maincode(df, "SA1_MAINCODE_2016")
  expect_s3_class(result, "data.frame")
})

test_that("amend_maincode returns a error", {
  df <- data.frame(SA1_MAINCODE_2016 = c("12345678901"))
  expect_error(amend_maincode(df, "SA1_7DIGITCODE_2016"),
               "Column `SA1_7DIGITCODE_2016` does not exist in the data frame.")
})
