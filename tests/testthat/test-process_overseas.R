test_that("process_overseas handles event values and data processing correctly", {

  # Test 1: Unrecognised event returns unprocessed data with message
  invalid_data <- data.frame(
    event = "2025",
    State = "Queensland",
    Division = "Brisbane",
    Votes = 100
  )
  expect_message(
    result_invalid <- process_overseas(invalid_data, "2025"),
    "No processing required for `2025`. Data returned unprocessed."
  )
  expect_identical(result_invalid, invalid_data)  # Data returned unchanged

  # Test 2: 2013 data processing
  data_2013 <- data.frame(
    event = "2013",
    State = c("New South Wales", "Victoria", NA),
    Division = c("Sydney", "Melbourne", "Total"),
    pp_nm = c("London", "Paris", "All"),
    `Pre-poll Votes` = c(100, 150, 250),
    `Postal Votes` = c(50, 75, 125),
    pp_sort_nm = c("LON", "PAR", "ALL"),
    Total = c(150, 225, 375),
    check.names = FALSE
  )
  expect_message(
    result_2013 <- process_overseas(data_2013, "2013"),
    "Processing `2013` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2013), 2)  # NA row removed
  expect_true(all(c("StateAb", "DivisionNm", "OverseasPost", "PrePollVotes",
                    "PostalVotes", "TotalVotes") %in% names(result_2013)))
  expect_equal(result_2013$StateAb, c("NSW", "VIC"))
  expect_equal(result_2013$TotalVotes, c(150, 225))
  expect_false("pp_sort_nm" %in% names(result_2013))
  expect_false("Total" %in% names(result_2013))

  # Test 3: 2019 data processing
  data_2019 <- data.frame(
    event = "2019",
    State = c("Queensland", "Tasmania"),
    Division = c("Brisbane", "Hobart"),
    `Diplomatic Post\r\n(Nb. Colombo did not operate due to security issues)` = c("Tokyo", "Berlin"),
    `Pre-Poll Votes Issued` = c(200, 300),
    `Postal Votes Received` = c(100, 150),
    check.names = FALSE
  )
  expect_message(
    result_2019 <- process_overseas(data_2019, "2019"),
    "Processing `2019` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2019), 2)
  expect_true(all(c("StateAb", "DivisionNm", "OverseasPost", "PrePollVotes",
                    "PostalVotes", "TotalVotes") %in% names(result_2019)))
  expect_equal(result_2019$StateAb, c("QLD", "TAS"))
  expect_equal(result_2019$TotalVotes, c(300, 450))

  # Test 4: 2022 data processing
  data_2022 <- data.frame(
    event = "2022",
    State = c("South Australia", "Western Australia"),
    Division = c("Adelaide", "Perth"),
    `Overseas Post` = c("New York", "London"),
    `Pre-Poll (in-person) Votes` = c(120, 180),
    `Postal Vote Envelopes Received at Post` = c(80, 120),
    check.names = FALSE
  )
  expect_message(
    result_2022 <- process_overseas(data_2022, "2022"),
    "Processing `2022` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2022), 2)
  expect_true(all(c("StateAb", "DivisionNm", "OverseasPost", "PrePollVotes",
                    "PostalVotes", "TotalVotes") %in% names(result_2022)))
  expect_equal(result_2022$StateAb, c("South Australia", "Western Australia"))  # No amendment for 2022
  expect_equal(result_2022$TotalVotes, c(200, 300))
})