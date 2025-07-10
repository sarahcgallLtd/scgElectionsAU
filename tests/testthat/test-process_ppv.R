test_that("process_ppv standardises and transforms PPVC data correctly", {

  # Test 1: Unrecognised event returns unprocessed data with message
  data_2024 <- data.frame(event = "2024 Federal Election", State = "Queensland", Votes = 100)
  expect_message(
    result_2024 <- process_ppv(data_2024, "2024 Federal Election"),
    "No processing required for `2024 Federal Election`. Data returned unprocessed."
  )
  expect_identical(result_2024, data_2024)

  # Test 2: 2010 data processing (no PollingPlaceNm, with NA filtering)
  data_2010 <- data.frame(
    date="2010-08-21",
    event = "2010 Federal Election",
    StateAb = c("NSW", "Notes"),
    DivisionNm = c("Sydney", NA),
    `02 Aug 10` = c(100, NA),
    `03 Aug 10` = c(150, NA),
    check.names = FALSE
  )
  expect_message(
    result_2010 <- process_ppv(data_2010, "2010 Federal Election"),
    "Processing `2010 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2010), 2)  # 1 row pivoted into 2
  expect_equal(names(result_2010), c("date", "event", "StateAb", "DivisionNm", "IssueDate", "TotalPPVs"))
  expect_equal(result_2010$StateAb, c("NSW", "NSW"))
  expect_equal(result_2010$IssueDate, as.Date(c("2010-08-02", "2010-08-03")))
  expect_equal(result_2010$TotalPPVs, c(100, 150))
  expect_false("PollingPlaceNm" %in% names(result_2010))

  # Test 3: 2013 data processing
  data_2013 <- data.frame(
    date = "2013-09-07",
    event = "2013 Federal Election",
    StateAb = "New South Wales",
    DivisionNm = "Sydney",
    m_pp_nm = "Sydney PPVC",
    `20/08/2013` = 100,
    `21/08/2013` = 150,
    check.names = FALSE
  )
  expect_message(
    result_2013 <- process_ppv(data_2013, "2013 Federal Election"),
    "Processing `2013 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2013), 2)
  expect_equal(names(result_2013), c("date", "event", "StateAb", "DivisionNm", "PollingPlaceNm", "IssueDate", "TotalPPVs"))
  expect_equal(result_2013$StateAb, c("New South Wales", "New South Wales"))
  expect_equal(result_2013$PollingPlaceNm, c("Sydney PPVC", "Sydney PPVC"))
  #expect_equal(result_2013$IssueDate, as.Date(c("2013-08-20", "2013-08-21")))
  expect_equal(result_2013$TotalPPVs, c(100, 150))

  # Test 4: 2016 data processing
  data_2016 <- data.frame(
    date = "2016-07-02",
    event = "2016 Federal Election",
    m_state_ab = "Victoria",
    m_div_nm = "Melbourne",
    m_pp_nm = "Melbourne PPVC",
    `2016-06-14` = 200,
    `2016-06-15` = 250,
    check.names = FALSE
  )
  expect_message(
    result_2016 <- process_ppv(data_2016, "2016 Federal Election"),
    "Processing `2016 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2016), 2)
  expect_equal(names(result_2016), c("date", "event", "StateAb", "DivisionNm", "PollingPlaceNm", "IssueDate", "TotalPPVs"))
  expect_equal(result_2016$StateAb, c("Victoria", "Victoria"))
  #expect_equal(result_2016$IssueDate, as.Date(c("2016-06-14", "2016-06-15")))
  expect_equal(result_2016$TotalPPVs, c(200, 250))

  # Test 5: 2019 data processing (same as 2016)
  data_2019 <- data.frame(
    date = "2019-05-18",
    event = "2019 Federal Election",
    m_state_ab = "Queensland",
    m_div_nm = "Brisbane",
    m_pp_nm = "Brisbane PPVC",
    `29/04/2019` = 300,
    `30/04/2019` = 350,
    check.names = FALSE
  )
  expect_message(
    result_2019 <- process_ppv(data_2019, "2019 Federal Election"),
    "Processing `2019 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2019), 2)
  expect_equal(names(result_2019), c("date", "event", "StateAb", "DivisionNm", "PollingPlaceNm", "IssueDate", "TotalPPVs"))
  expect_equal(result_2019$StateAb, c("Queensland", "Queensland"))
  expect_equal(result_2019$IssueDate, as.Date(c("2019-04-29", "2019-04-30")))
  expect_equal(result_2019$TotalPPVs, c(300, 350))

  # Test 6: 2022 data processing (no pivoting)
  data_2022 <- data.frame(
    date = "2022-05-21",
    event = "2022 Federal Election",
    StateAb = "South Australia",
    DivisionNm = "Adelaide",
    PPVC = "Adelaide PPVC",
    `Issue Date` = "09/05/22",
    `Total Votes` = 200,
    check.names = FALSE
  )
  expect_message(
    result_2022 <- process_ppv(data_2022, "2022 Federal Election"),
    "Processing `2022 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2022), 1)
  expect_equal(names(result_2022), c("date", "event", "StateAb", "DivisionNm", "PollingPlaceNm", "IssueDate", "TotalPPVs"))
  expect_equal(result_2022$StateAb, "South Australia")
  expect_equal(result_2022$PollingPlaceNm, "Adelaide PPVC")
  expect_equal(result_2022$IssueDate, as.Date("2022-05-09"))
  expect_equal(result_2022$TotalPPVs, 200)
})
