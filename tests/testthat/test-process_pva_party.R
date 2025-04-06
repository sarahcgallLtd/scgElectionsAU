test_that("process_pva_party standardises PVA data correctly", {

  # Test 1: Unrecognised event returns unprocessed data with message
  data_2022 <- data.frame(
    date = "2022-05-21",
    event = "2022",
    State = "Queensland",
    Votes = 90
  )
  expect_message(
    result_2022 <- process_pva_party(data_2022, "2022"),
    "No processing required for `2022`. Data returned unprocessed."
  )
  expect_identical(result_2022, data_2022)

  # Test 2: 2010 data processing
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010",
    State = "Victoria",
    Enrolment = "Melbourne",
    `Country Liberal` = 0,
    Greens = 2,
    Labor = 120,
    Liberal = 180,
    National = 1,
    `Other Party` = 2,
    AEC = 60,
    `Sum of AEC and Parties` = 360,
    check.names = FALSE
  )
  expect_message(
    result_2010 <- process_pva_party(data_2010, "2010"),
    "Processing `2010` data to ensure all columns align across all elections."
  )
  expected_cols_2010 <- c("date", "event", "StateAb", "DivisionNm", "AEC (Total)","Total (AEC + Parties)",
                          "ALP","CLP","GRN","LIB","NAT", "OTH")
  expect_equal(names(result_2010), expected_cols_2010)
  expect_equal(result_2010$StateAb, "VICTORIA")  # State renamed and uppercased
  expect_equal(result_2010$`AEC (Total)`, 60)
  expect_equal(result_2010$ALP, 120)
  expect_equal(result_2010$LIB, 180)
  expect_equal(result_2010$`Total (AEC + Parties)`, 360)

  # Test 3: 2013 data processing with NA in State
  data_2013 <- data.frame(
    date = "2013-09-07",
    event = "2013",
    State = NA,
    `Enrolment Division` = "Sydney",
    `Country Liberal` = 0,
    Greens = 2,
    National = 1,
    `Other Party` = 2,
    `Liberal-National` = 150,
    `AEC (Online)` = 25,
    `AEC (Paper)` = 15,
    Labor = 100,
    Liberal = 120,
    check.names = FALSE
  )
  expect_message(
    result_2013 <- process_pva_party(data_2013, "2013"),
    "Processing `2013` data to ensure all columns align across all elections."
  )
  expected_cols_2013 <- c("date", "event", "StateAb", "DivisionNm", "AEC (Online)", "AEC (Paper)",
                          "AEC (Total)", "Total (AEC + Parties)", "ALP", "CLP", "GRN", "LIB", "LNP", "NAT", "OTH")
  expect_equal(names(result_2013), expected_cols_2013)
  expect_equal(result_2013$StateAb, "ZZZ")  # NA replaced with "ZZZ"
  expect_equal(result_2013$`AEC (Total)`, 40)  # 25 + 15
  expect_equal(result_2013$`Total (AEC + Parties)`, 415)
  expect_equal(result_2013$ALP, 100)
  expect_equal(result_2013$LNP, 150)

  # Test 4: 2016 data processing
  data_2016 <- data.frame(
    date = "2016-07-02",
    event = "2016",
    State_Cd = "NSW",
    PVA_Web_1_Party_Div = "Sydney",
    `AEC - OPVA` = 30,
    `AEC - Paper` = 20,
    ALP = 110,
    CLP = 12,
    LIB = 130,
    GRN = 40,
    GPV = 12,
    LNP = 6,
    NAT = 12,
    OTH = 9,
    check.names = FALSE
  )
  expect_message(
    result_2016 <- process_pva_party(data_2016, "2016"),
    "Processing `2016` data to ensure all columns align across all elections."
  )
  expected_cols_2016 <- c("date", "event", "StateAb", "DivisionNm","GPV", "AEC (Online)", "AEC (Paper)",
                          "AEC (Total)", "Total (AEC + Parties)", "ALP", "CLP", "GRN", "LIB","LNP", "NAT", "OTH")
  expect_equal(names(result_2016), expected_cols_2016)
  expect_equal(result_2016$StateAb, "NSW")
  expect_equal(result_2016$`AEC (Total)`, 50)
  expect_equal(result_2016$`Total (AEC + Parties)`, 381)
  expect_equal(result_2016$ALP, 110)
  expect_equal(result_2016$GRN, 40)
})
