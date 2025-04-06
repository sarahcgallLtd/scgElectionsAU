test_that("process_group standardises Senate group voting data correctly", {

  # Test 1: 2004 data processing without SittingMemberFl
  data_2004 <- data.frame(
    date = "2004-10-09",
    event = "2004",
    State = "VIC",
    Ticket = "A"
  )
  expect_message(
    result_2004 <- process_group(data_2004, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004), c("date", "event", "State", "Group"))
  expect_equal(result_2004$Group, "A")

  # Test 2: 2004 data processing with SittingMemberFl
  data_2004_smf <- data.frame(
    date = "2004-10-09",
    event = "2004",
    State = "NSW",
    Ticket = "B",
    SittingMemberFl = "Y"
  )
  expect_message(
    result_2004_smf <- process_group(data_2004_smf, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004_smf), c("date", "event", "State", "Group", "Elected"))
  expect_equal(result_2004_smf$Group, "B")
  expect_equal(result_2004_smf$Elected, "Y")  # Processed by process_elected

  # Test 3: 2010 data processing without SittingMemberFl
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010",
    State = "QLD",
    Ticket = "C"
  )
  expect_message(
    result_2010 <- process_group(data_2010, "2010"),
    "Processing `2010` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2010), c("date", "event", "State", "Group"))
  expect_equal(result_2010$Group, "C")

  # Test 4: 2016 data processing with SittingMemberFl (process_elected does nothing for non-2004)
  data_2016_smf <- data.frame(
    date = "2016-07-02",
    event = "2016",
    State = "SA",
    Ticket = "D",
    SittingMemberFl = "N"
  )
  expect_message(
    result_2016_smf <- process_group(data_2016_smf, "2016"),
    "Processing `2016` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2016_smf), c("date", "event", "State", "Group", "SittingMemberFl"))
  expect_equal(result_2016_smf$Group, "D")
  expect_equal(result_2016_smf$SittingMemberFl, "N")  # Unchanged, as process_elected only affects 2004

  # Test 5: Unrecognised event (2022) returns unprocessed data with message
  data_2022 <- data.frame(
    date = "2022-05-21",
    event = "2022",
    State = "TAS",
    Group = "E"
  )
  expect_message(
    result_2022 <- process_group(data_2022, "2022"),
    "No processing required for `2022`. Data returned unprocessed."
  )
  expect_identical(result_2022, data_2022)  # Data unchanged
})
