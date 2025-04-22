test_that("process_ccd standardises election data correctly", {

  # Test 1: Unrecognised event returns unprocessed data with message
  data_2025 <- data.frame(
    event = "2025 Federal Election",
    state_ab = "QLD",
    div_nm = "Brisbane",
    votes = 100
  )
  expect_message(
    result_2025 <- process_ccd(data_2025, "2025 Federal Election"),
    "No processing required for `2025 Federal Election`. Data returned unprocessed."
  )
  expect_identical(result_2025, data_2025)  # Data returned unchanged

  # Test 2: 2013 data processing
  data_2013 <- data.frame(
    event = "2013",
    state_ab = "NSW",
    div_nm = "Sydney",
    pp_id = 101,
    pp_nm = "Sydney Town Hall",
    ccd_id = "12345",
    count = 500,
    year = 2013
  )
  expect_message(
    result_2013 <- process_ccd(data_2013, "2013 Federal Election"),
    "Processing `2013 Federal Election` data to ensure all columns align across all elections."
  )
  expected_cols_2013 <- c("event", "StateAb", "DivisionNm", "PollingPlaceID",
                          "PollingPlaceNm", "StatisticalAreaID", "Count")
  expect_equal(names(result_2013), expected_cols_2013)
  expect_equal(result_2013$StateAb, "NSW")
  expect_equal(result_2013$StatisticalAreaID, "12345")
  expect_equal(result_2013$Count, 500)
  expect_false("year" %in% names(result_2013))

  # Test 3: 2016 data processing
  data_2016 <- data.frame(
    event = "2016 Federal Election",
    state_ab = "VIC",
    div_nm = "Melbourne",
    pp_id = 102,
    pp_nm = "Melbourne Central",
    SA1_id = "67890",
    votes = 600,
    year = 2016
  )
  expect_message(
    result_2016 <- process_ccd(data_2016, "2016 Federal Election"),
    "Processing `2016 Federal Election` data to ensure all columns align across all elections."
  )
  expected_cols_2016 <- c("event", "StateAb", "DivisionNm", "PollingPlaceID",
                          "PollingPlaceNm", "StatisticalAreaID", "Count")
  expect_equal(names(result_2016), expected_cols_2016)
  expect_equal(result_2016$StateAb, "VIC")
  expect_equal(result_2016$StatisticalAreaID, "67890")
  expect_equal(result_2016$Count, 600)
  expect_false("year" %in% names(result_2016))

  # Test 4: 2019 data processing (same as 2016)
  data_2019 <- data.frame(
    event = "2019 Federal Election",
    state_ab = "QLD",
    div_nm = "Brisbane",
    pp_id = 103,
    pp_nm = "Brisbane City",
    SA1_id = "54321",
    votes = 700,
    year = 2019
  )
  expect_message(
    result_2019 <- process_ccd(data_2019, "2019 Federal Election"),
    "Processing `2019 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2019), expected_cols_2016)  # Same expected columns as 2016
  expect_equal(result_2019$StateAb, "QLD")
  expect_equal(result_2019$StatisticalAreaID, "54321")
  expect_equal(result_2019$Count, 700)
  expect_false("year" %in% names(result_2019))

  # Test 5: 2022 data processing
  data_2022 <- data.frame(
    event = "2022 Federal Election",
    state_ab = "SA",
    div_nm = "Adelaide",
    pp_id = 104,
    pp_nm = "Adelaide Central",
    ccd_id = "98765",
    votes = 800,
    year = 2022
  )
  expect_message(
    result_2022 <- process_ccd(data_2022, "2022 Federal Election"),
    "Processing `2022 Federal Election` data to ensure all columns align across all elections."
  )
  expected_cols_2022 <- c("event", "StateAb", "DivisionNm", "PollingPlaceID",
                          "PollingPlaceNm", "StatisticalAreaID", "Count")
  expect_equal(names(result_2022), expected_cols_2022)
  expect_equal(result_2022$StateAb, "SA")
  expect_equal(result_2022$StatisticalAreaID, "98765")
  expect_equal(result_2022$Count, 800)
  expect_false("year" %in% names(result_2022))
})
