test_that("test that get_election_data returns processes data", {
  df <- get_election_data(file_name = "National list of candidates",
                     date_range = list(from = "2004-01-01", to = "2005-01-01"),
                     process = TRUE)
  expect_length(df, 11)
})

test_that("test that get_election_data returns processes data", {
  df <- get_election_data(file_name = "National list of candidates",
                     date_range = list(from = "2004-01-01", to = "2005-01-01"),
                     category = "Senate",
                     process = TRUE)
  expect_length(df, 9)
})