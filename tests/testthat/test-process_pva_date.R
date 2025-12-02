test_that("process_pva_date standardises and transforms PVA data by date correctly", {

  # Test 1: Unrecognised event returns unprocessed data with message
  data_2022 <- data.frame(
    date = "2022-05-21",
    event = "2022 Federal Election",
    StateAb = "Queensland",
    Votes = 90
  )
  expect_message(
    result_2022 <- process_pva_date(data_2022, "2022 Federal Election"),
    "No processing required for `2022 Federal Election`. Data returned unprocessed."
  )
  expect_identical(result_2022, data_2022)

  # Test 2: 2010 data processing
  data_2010 <- data.frame(
    date = "2010-08-21",
    event = "2010 Federal Election",
    StateAb = "Vic",
    Enrolment = "Melbourne",
    `02 Aug 10` = 50,
    `03 Aug 10` = 60,
    check.names = FALSE
  )
  expect_message(
    result_2010 <- process_pva_date(data_2010, "2010 Federal Election"),
    "Processing `2010 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2010), 2)  # 1 row pivoted into 2
  expect_equal(names(result_2010), c("date", "event", "StateAb", "DivisionNm", "DateReceived", "TotalPVAs"))
  expect_equal(result_2010$StateAb, c("VIC", "VIC"))
  expect_equal(result_2010$DivisionNm, c("Melbourne", "Melbourne"))
  expect_equal(result_2010$DateReceived, as.Date(c("2010-08-02", "2010-08-03")))
  expect_equal(result_2010$TotalPVAs, c(50, 60))

  # Test 3: 2013 data processing with NA in State
  data_2013 <- data.frame(
    date = "2013-09-07",
    event = "2013 Federal Election",
    StateAb = NA,
    `Enrolment Division` = "Sydney",
    `20-Aug-13` = 100,
    `21-Aug-13` = 150,
    check.names = FALSE
  )
  expect_message(
    result_2013 <- process_pva_date(data_2013, "2013 Federal Election"),
    "Processing `2013 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2013), 2)
  expect_equal(names(result_2013), c("date", "event", "StateAb", "DivisionNm", "DateReceived", "TotalPVAs"))
  expect_equal(result_2013$StateAb, c("ZZZ", "ZZZ"))  # NA replaced with "ZZZ"
  expect_equal(result_2013$DivisionNm, c("Sydney", "Sydney"))
  expect_equal(result_2013$DateReceived, as.Date(c("2013-08-20", "2013-08-21")))
  expect_equal(result_2013$TotalPVAs, c(100, 150))

  # Test 4: 2016 data processing
  data_2016 <- data.frame(
    date = "2016-07-02",
    event = "2016 Federal Election",
    State_Cd = "NSW",
    PVA_Web_2_Date_Div = "Sydney",
    `20160614` = 200,
    `20160615` = 250,
    check.names = FALSE
  )
  expect_message(
    result_2016 <- process_pva_date(data_2016, "2016 Federal Election"),
    "Processing `2016 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2016), 2)
  expect_equal(names(result_2016), c("date", "event", "StateAb", "DivisionNm", "DateReceived", "TotalPVAs"))
  expect_equal(result_2016$StateAb, c("NSW", "NSW"))
  expect_equal(result_2016$DivisionNm, c("Sydney", "Sydney"))
  expect_equal(result_2016$DateReceived, as.Date(c("2016-06-14", "2016-06-15")))
  expect_equal(result_2016$TotalPVAs, c(200, 250))

  # Test 5: 2019 data processing
  data_2019 <- data.frame(
    date = "2019-05-18",
    event = "2019 Federal Election",
    State_Cd = "QLD",
    PVA_Web_2_Date_V2_Div = "Brisbane",
    `20190411` = 300,
    `20190412` = 350,
    check.names = FALSE
  )
  expect_message(
    result_2019 <- process_pva_date(data_2019, "2019 Federal Election"),
    "Processing `2019 Federal Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2019), 2)
  expect_equal(names(result_2019), c("date", "event", "StateAb", "DivisionNm", "DateReceived", "TotalPVAs"))
  expect_equal(result_2019$StateAb, c("QLD", "QLD"))
  expect_equal(result_2019$DivisionNm, c("Brisbane", "Brisbane"))
  expect_equal(result_2019$DateReceived, as.Date(c("2019-04-11", "2019-04-12")))
  expect_equal(result_2019$TotalPVAs, c(300, 350))


  # Test 6: 2014 Griffith By-Election data processing
  data_2014 <- data.frame(
    date = "2014-05-18",
    event = "2014 Griffith By-Election",
    PVA_Web_2_Date.Div = "Griffith",
    `20190411` = 300,
    `20190412` = 350,
    check.names = FALSE
  )
  expect_message(
    result_2014 <- process_pva_date(data_2014, "2014 Griffith By-Election"),
    "Processing `2014 Griffith By-Election` data to ensure all columns align across all elections."
  )
  expect_equal(nrow(result_2019), 2)
})
