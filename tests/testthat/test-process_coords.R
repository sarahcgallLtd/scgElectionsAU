test_that("process_coords updates polling place coordinates correctly", {

  # Test 1: 2010 data with all missing coordinates (NA and 0)
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010 Federal Election",
    PollingPlaceID = c(93925.0, 11877.0),
    Latitude = c(NA, 0),
    Longitude = c(0, NA)
  )
  expect_message(
    result_2010 <- process_coords(data_2010, "2010 Federal Election"),
    "Filling in missing coordinates for `2010 Federal Election` data, where possible."
  )
  expect_equal(result_2010$Latitude, c(-35.238950, -35.431464))  # Replaced NA and 0
  expect_equal(result_2010$Longitude, c(149.069140, 149.082409))  # Replaced 0 and NA

  # Test 2: 2019 data with all valid coordinates
  data_2019 <- data.frame(
    date = "2019-05-18",
    event = "2019 Federal Election",
    PollingPlaceID = c(93925.0, 11877.0),
    Latitude = c(-37.81, -33.87),
    Longitude = c(144.96, 151.21)
  )
  expect_message(
    result_2019 <- process_coords(data_2019, "2019 Federal Election"),
    "Filling in missing coordinates for `2019 Federal Election` data, where possible."
  )
  expect_equal(result_2019$Latitude, c(-37.81, -33.87))  # Valid, unchanged
  expect_equal(result_2019$Longitude, c(144.96, 151.21))  # Valid, unchanged
})