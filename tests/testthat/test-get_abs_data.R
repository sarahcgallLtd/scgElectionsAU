# =============================================================================
# PARAMETER VALIDATION TESTS
# =============================================================================

test_that("get_abs_data validates dataflow parameter - missing", {
  expect_error(
    get_abs_data(),
    "dataflow must be provided as a single character string"
  )
})

test_that("get_abs_data validates dataflow parameter - non-character", {
  expect_error(
    get_abs_data(dataflow = 123),
    "dataflow must be provided as a single character string"
  )
})

test_that("get_abs_data validates dataflow parameter - multiple values", {
  expect_error(
    get_abs_data(dataflow = c("flow1", "flow2")),
    "dataflow must be provided as a single character string"
  )
})


# =============================================================================
# CACHING HELPER FUNCTION TESTS
# =============================================================================

test_that("get_abs_cache returns NULL for non-existent key", {
  result <- scgElectionsAU:::get_abs_cache("nonexistent_key_12345")
  expect_null(result)
})

test_that("set_abs_cache stores data and get_abs_cache retrieves it", {
  test_data <- data.frame(x = 1:3, y = c("a", "b", "c"))
  test_key <- "test_cache_key_for_testing"

  scgElectionsAU:::set_abs_cache(test_key, test_data)

  result <- scgElectionsAU:::get_abs_cache(test_key)
  expect_equal(result, test_data)

  # Clean up
  rm(list = test_key, envir = scgElectionsAU:::.abs_cache)
})

test_that("set_abs_cache returns invisible NULL", {
  result <- scgElectionsAU:::set_abs_cache("temp_key", data.frame(x = 1))
  expect_null(result)

  # Clean up
  rm(list = "temp_key", envir = scgElectionsAU:::.abs_cache)
})


# =============================================================================
# CACHING BEHAVIOR TESTS (using mocked data)
# =============================================================================

test_that("get_abs_data uses cached data when available", {
  # Pre-populate cache
  test_data <- data.frame(test_col = 1:5)
  cache_key <- "abs|TEST_CACHED_FLOW|all||"
  assign(cache_key, test_data, envir = scgElectionsAU:::.abs_cache)

  expect_message(
    result <- get_abs_data("TEST_CACHED_FLOW", cache = TRUE),
    "Using cached ABS API data for `TEST_CACHED_FLOW`"
  )

  expect_equal(result, test_data)

  # Clean up
  rm(list = cache_key, envir = scgElectionsAU:::.abs_cache)
})

test_that("get_abs_data cache key includes filter", {
  # Pre-populate cache with specific filter
  test_data <- data.frame(filtered = TRUE)
  cache_key <- "abs|TEST_FLOW|custom_filter||"
  assign(cache_key, test_data, envir = scgElectionsAU:::.abs_cache)

  expect_message(
    result <- get_abs_data("TEST_FLOW", filter = "custom_filter", cache = TRUE),
    "Using cached ABS API data"
  )

  expect_equal(result, test_data)

  # Clean up
  rm(list = cache_key, envir = scgElectionsAU:::.abs_cache)
})

test_that("get_abs_data cache key includes time periods", {
  # Pre-populate cache with time periods
  test_data <- data.frame(with_periods = TRUE)
  cache_key <- "abs|TEST_FLOW|all|2020|2021"
  assign(cache_key, test_data, envir = scgElectionsAU:::.abs_cache)

  expect_message(
    result <- get_abs_data("TEST_FLOW", start_period = "2020", end_period = "2021", cache = TRUE),
    "Using cached ABS API data"
  )

  expect_equal(result, test_data)

  # Clean up
  rm(list = cache_key, envir = scgElectionsAU:::.abs_cache)
})

test_that("get_abs_data treats NULL filter same as 'all'", {
  # Pre-populate cache with "all" filter
  test_data <- data.frame(all_filter = TRUE)
  cache_key <- "abs|TEST_FLOW_NULL|all||"
  assign(cache_key, test_data, envir = scgElectionsAU:::.abs_cache)

  # Call with NULL filter (should use same cache key as "all")
  expect_message(
    result <- get_abs_data("TEST_FLOW_NULL", filter = NULL, cache = TRUE),
    "Using cached ABS API data"
  )

  expect_equal(result, test_data)

  # Clean up
  rm(list = cache_key, envir = scgElectionsAU:::.abs_cache)
})


# =============================================================================
# INTEGRATION TESTS (require network - may be skipped if offline)
# =============================================================================

test_that("get_abs_data fetches real data from ABS API", {
  skip_on_cran()
  skip_if_offline()

  # Clear any cached data first
  clear_cache("abs")

  # Use a small CED-level dataset for faster testing
  expect_message(
    result <- get_abs_data("C21_G02_CED", cache = FALSE),
    "Fetching data from ABS API"
  )

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("get_abs_data with cache=FALSE skips cache", {
  skip_on_cran()
  skip_if_offline()

  # Pre-populate cache with fake data
  fake_data <- data.frame(fake = TRUE)
  cache_key <- "abs|C21_G02_CED|all||"
  assign(cache_key, fake_data, envir = scgElectionsAU:::.abs_cache)

  # With cache=FALSE, should fetch fresh data (not the fake cached data)
  expect_message(
    result <- get_abs_data("C21_G02_CED", cache = FALSE),
    "Fetching data from ABS API"
  )

  # Result should NOT be our fake data
  expect_false(identical(result, fake_data))

  # Clean up
  rm(list = cache_key, envir = scgElectionsAU:::.abs_cache)
})

test_that("get_abs_data stores result in cache when cache=TRUE", {
  skip_on_cran()
  skip_if_offline()

  # Clear cache first
  clear_cache("abs")

  cache_key <- "abs|C21_G02_CED|all||"

  # Verify cache is empty
  expect_null(scgElectionsAU:::get_abs_cache(cache_key))

  # Fetch data
  result <- get_abs_data("C21_G02_CED", cache = TRUE)

  # Verify data was cached
  cached <- scgElectionsAU:::get_abs_cache(cache_key)
  expect_false(is.null(cached))
  expect_equal(cached, result)

  # Clean up
  clear_cache("abs")
})

test_that("get_abs_data constructs URL with start_period only", {
  skip_on_cran()
  skip_if_offline()

  # This tests that start_period is added to URL correctly
  expect_message(
    result <- get_abs_data("C21_G02_CED", start_period = "2021", cache = FALSE),
    "Fetching data from ABS API"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_abs_data constructs URL with end_period only", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_abs_data("C21_G02_CED", end_period = "2021", cache = FALSE),
    "Fetching data from ABS API"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_abs_data constructs URL with both time periods", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_abs_data("C21_G02_CED",
                           start_period = "2021",
                           end_period = "2021",
                           cache = FALSE),
    "Fetching data from ABS API"
  )

  expect_s3_class(result, "data.frame")
})


# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

test_that("get_abs_data handles warning for invalid dataflow", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
      get_abs_data("COMPLETELY_INVALID_DATAFLOW_NAME_12345", cache = FALSE),
    "not found|Invalid request|Failed to fetch|Error"
  )
})


# =============================================================================
# list_abs_dataflows() TESTS
# =============================================================================

test_that("list_abs_dataflows returns data frame with id and name columns", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- list_abs_dataflows(),
    "Fetching available dataflows"
  )

  expect_s3_class(result, "data.frame")
  expect_true("id" %in% names(result))
  expect_true("name" %in% names(result))
  expect_gt(nrow(result), 0)
})

test_that("list_abs_dataflows filters by SA1", {
  skip_on_cran()
  skip_if_offline()

  result <- list_abs_dataflows(filter = "SA1")

  expect_s3_class(result, "data.frame")
  # All results should contain SA1 in id or name
  has_sa1 <- grepl("SA1", result$id, ignore.case = TRUE) |
    grepl("SA1", result$name, ignore.case = TRUE)
  expect_true(all(has_sa1))
})

test_that("list_abs_dataflows filters by CED", {
  skip_on_cran()
  skip_if_offline()

  result <- list_abs_dataflows(filter = "CED")

  expect_s3_class(result, "data.frame")
  # All results should contain CED or Electoral in id or name
  has_ced <- grepl("CED", result$id, ignore.case = TRUE) |
    grepl("CED|Electoral", result$name, ignore.case = TRUE)
  expect_true(all(has_ced))
})

test_that("list_abs_dataflows filters by census", {
  skip_on_cran()
  skip_if_offline()

  result <- list_abs_dataflows(filter = "census")

  expect_s3_class(result, "data.frame")
  # All results should be Census-related
  has_census <- grepl("CENSUS|^C[0-9]{2}_", result$id, ignore.case = TRUE) |
    grepl("Census", result$name, ignore.case = TRUE)
  expect_true(all(has_census))
})

test_that("list_abs_dataflows applies pattern filter", {
  skip_on_cran()
  skip_if_offline()

  result <- list_abs_dataflows(pattern = "SEIFA")

  expect_s3_class(result, "data.frame")
  # All results should match SEIFA pattern
  has_seifa <- grepl("SEIFA", result$id, ignore.case = TRUE) |
    grepl("SEIFA", result$name, ignore.case = TRUE)
  expect_true(all(has_seifa))
})

test_that("list_abs_dataflows combines filter and pattern", {
  skip_on_cran()
  skip_if_offline()

  result <- list_abs_dataflows(filter = "SA1", pattern = "SEIFA")

  expect_s3_class(result, "data.frame")
  # Results should have both SA1 AND SEIFA
  if (nrow(result) > 0) {
    has_sa1 <- grepl("SA1", result$id, ignore.case = TRUE) |
      grepl("SA1", result$name, ignore.case = TRUE)
    has_seifa <- grepl("SEIFA", result$id, ignore.case = TRUE) |
      grepl("SEIFA", result$name, ignore.case = TRUE)
    expect_true(all(has_sa1 & has_seifa))
  }
})

test_that("list_abs_dataflows is case insensitive for filter", {
  skip_on_cran()
  skip_if_offline()

  result_upper <- list_abs_dataflows(filter = "SA1")
  result_lower <- list_abs_dataflows(filter = "sa1")

  expect_equal(nrow(result_upper), nrow(result_lower))
})
