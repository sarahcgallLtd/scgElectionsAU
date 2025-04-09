test_that("process_reps standardises party representation data correctly", {

  # Test 1: 2004 data processing
  data_2004 <- data.frame(
    date = "2004-10-09",
    event = "2004",
    PartyNm = "ALP",
    Total = 60,
    LastElectionTotal = 65
  )
  expect_message(
    result_2004 <- process_reps(data_2004, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004), c("date", "event", "PartyNm", "National", "LastElection"))
  expect_equal(result_2004$National, 60)
  expect_equal(result_2004$LastElection, 65)

  # Test 2: 2007 data processing
  data_2007 <- data.frame(
    date = "2007-11-24",
    event = "2007",
    PartyNm = "LIB",
    Total = 55,
    LastElectionTotal = 60
  )
  expect_message(
    result_2007 <- process_reps(data_2007, "2007"),
    "Processing `2007` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2007), c("date", "event", "PartyNm", "National", "LastElection"))
  expect_equal(result_2007$National, 55)
  expect_equal(result_2007$LastElection, 60)

  # Test 3: 2010 data processing
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010",
    PartyNm = "ALP",
    Total = 72,
    LastElectionTotal = 60
  )
  expect_message(
    result_2010 <- process_reps(data_2010, "2010"),
    "Processing `2010` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2010), c("date", "event", "PartyNm", "National", "LastElection"))
  expect_equal(result_2010$National, 72)
  expect_equal(result_2010$LastElection, 60)

  # Test 4: Unrecognised event (2013) returns unprocessed data with message
  data_2013 <- data.frame(
    date = "2013-09-07",
    event = "2013",
    PartyNm = "LIB",
    National = 90,
    LastElection = 72
  )
  expect_message(
    result_2013 <- process_reps(data_2013, "2013"),
    "No processing required for `2013`. Data returned unprocessed."
  )
  expect_identical(result_2013, data_2013)  # Data unchanged
})