test_that("process_prepoll standardises pre-poll voting data correctly", {

  # Test 1: 2004 data processing
  data_2004 <- data.frame(
    date = "2004-10-09",
    event = "2004",
    State = "VIC",
    Party = "ALP",
    PrePollVotes = 500,
    PrePollPercentage = 25.0
  )
  expect_message(
    result_2004 <- process_prepoll(data_2004, "2004"),
    "Processing `2004` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2004), c("date", "event", "State", "Party", "DeclarationPrePollVotes", "DeclarationPrePollPercentage"))
  expect_equal(result_2004$DeclarationPrePollVotes, 500)
  expect_equal(result_2004$DeclarationPrePollPercentage, 25.0)

  # Test 2: 2007 data processing
  data_2007 <- data.frame(
    date = "2007-11-24",
    event = "2007",
    State = "NSW",
    Party = "LIB",
    PrePollVotes = 600,
    PrePollPercentage = 30.0
  )
  expect_message(
    result_2007 <- process_prepoll(data_2007, "2007"),
    "Processing `2007` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2007), c("date", "event", "State", "Party", "DeclarationPrePollVotes", "DeclarationPrePollPercentage"))
  expect_equal(result_2007$DeclarationPrePollVotes, 600)
  expect_equal(result_2007$DeclarationPrePollPercentage, 30.0)

  # Test 3: 2010 data processing
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010",
    State = "QLD",
    Party = "ALP",
    PrePollVotes = 450,
    PrePollPercentage = 22.5
  )
  expect_message(
    result_2010 <- process_prepoll(data_2010, "2010"),
    "Processing `2010` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2010), c("date", "event", "State", "Party", "DeclarationPrePollVotes", "DeclarationPrePollPercentage"))
  expect_equal(result_2010$DeclarationPrePollVotes, 450)
  expect_equal(result_2010$DeclarationPrePollPercentage, 22.5)

  # Test 4: 2013 data processing
  data_2013 <- data.frame(
    date = "2013-09-07",
    event = "2013",
    State = "SA",
    Party = "LIB",
    PrePollVotes = 700,
    PrePollPercentage = 35.0
  )
  expect_message(
    result_2013 <- process_prepoll(data_2013, "2013"),
    "Processing `2013` data to ensure all columns align across all elections."
  )
  expect_equal(names(result_2013), c("date", "event", "State", "Party", "DeclarationPrePollVotes", "DeclarationPrePollPercentage"))
  expect_equal(result_2013$DeclarationPrePollVotes, 700)
  expect_equal(result_2013$DeclarationPrePollPercentage, 35.0)

  # Test 5: Unrecognised event (2016) returns unprocessed data with message
  data_2016 <- data.frame(
    date = "2016-07-02",
    event = "2016",
    State = "TAS",
    Party = "GRN",
    DeclarationPrePollVotes = 300,
    DeclarationPrePollPercentage = 15.0
  )
  expect_message(
    result_2016 <- process_prepoll(data_2016, "2016"),
    "No processing required for `2016`. Data returned unprocessed."
  )
  expect_identical(result_2016, data_2016)  # Data unchanged
})
