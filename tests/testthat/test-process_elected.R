test_that("process_elected standardises elected candidate data correctly", {

  # Test 1: 2004 data processing with SittingMemberFl present
  data_2004 <- data.frame(
    date = "2004-10-09",
    event = "2004",
    CandidateID = 123,
    SittingMemberFl = "Y"
  )
  expect_message(
    result_2004 <- process_elected(data_2004, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004), c("date", "event", "CandidateID", "Elected"))
  expect_equal(result_2004$Elected, "Y")

  # Test 2: 2004 data processing with NA in SittingMemberFl
  data_2004_na <- data.frame(
    date = "2004-10-09",
    event = "2004",
    CandidateID = 456,
    SittingMemberFl = NA
  )
  expect_message(
    result_2004_na <- process_elected(data_2004_na, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004_na), c("date", "event", "CandidateID", "Elected"))
  expect_equal(result_2004_na$Elected, "N")  # NA converted to "N"

  # Test 3: Unrecognised event (2010) returns unprocessed data with message
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010",
    CandidateID = 789,
    Elected = "Y"
  )
  expect_message(
    result_2010 <- process_elected(data_2010, "2010"),
    "No processing required for `2010`. Data returned unprocessed."
  )
  expect_identical(result_2010, data_2010)  # Data unchanged
})