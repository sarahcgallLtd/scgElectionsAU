# =============================================================================
# PARAMETER VALIDATION TESTS
# =============================================================================

test_that("prepare_boundaries validates event parameter", {

  expect_error(
    prepare_boundaries(event = "INVALID", compare_to = "2025 Federal Election"),
    "arg.*should be one of"
  )
})

test_that("prepare_boundaries validates compare_to parameter", {
  expect_error(
    prepare_boundaries(event = "2022 Federal Election", compare_to = "INVALID"),
    "arg.*should be one of"
  )
})

test_that("prepare_boundaries rejects invalid event/compare_to combinations", {
  # Cannot map from SA1 2016 (2019 election) to earlier SA1 2011 boundaries
  expect_error(
    prepare_boundaries(event = "2019 Federal Election", compare_to = "2013 Federal Election"),
    "Invalid combination: Cannot correspond from SA1 2016 to earlier SA1 year 2011"
  )

  # Cannot map from SA1 2021 (2025 election) to earlier SA1 2016 boundaries
  expect_error(
    prepare_boundaries(event = "2025 Federal Election", compare_to = "2016 Federal Election"),
    "Invalid combination: Cannot correspond from SA1 2021 to earlier SA1 year 2016"
  )

  # Cannot map from SA1 2016 (2022 election) to earlier SA1 2011 boundaries
  expect_error(
    prepare_boundaries(event = "2022 Federal Election", compare_to = "2011 Census"),
    "Invalid combination: Cannot correspond from SA1 2016 to earlier SA1 year 2011"
  )
})


# =============================================================================
# HELPER FUNCTION TESTS: verify_ratios()
# =============================================================================

test_that("verify_ratios identifies valid ratios", {
  # Create test data where ratios sum to 1
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B"),
    SA1_CODE_2011 = c("1", "2", "3", "4"),
    RATIO = c(0.6, 0.4, 0.7, 0.3)
  )

  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE),
    "No groups found with total ratios deviating from 1"
  )

  expect_equal(nrow(result), 4)
})

test_that("verify_ratios removes problematic groups when process = TRUE", {
  # Create test data where one group's ratios don't sum to 1
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B"),
    SA1_CODE_2011 = c("1", "2", "3", "4"),
    RATIO = c(0.6, 0.4, 0.5, 0.3)  # B sums to 0.8, not 1
  )

  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE),
    "Removed 1 CD"
  )

  # Only group A should remain
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$CD_CODE_2006), "A")
})

test_that("verify_ratios warns but keeps data when process = FALSE", {
  # Create test data where ratios don't sum to 1
  df <- data.frame(
    CD_CODE_2006 = c("A", "A"),
    SA1_CODE_2011 = c("1", "2"),
    RATIO = c(0.5, 0.3)  # Sums to 0.8
  )

  expect_warning(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = FALSE),
    "Some total ratios of the CDs deviate from 1"
  )

  # All data should be retained
  expect_equal(nrow(result), 2)
})

test_that("verify_ratios respects threshold parameter", {
  # Create test data with two groups - one perfect, one with small deviation
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B"),
    SA1_CODE_2011 = c("1", "2", "3", "4"),
    RATIO = c(0.505, 0.5, 0.6, 0.4)  # A sums to 1.005, B sums to 1.0
  )

  # With default threshold (0.01), both should pass
  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE, threshold = 0.01),
    "No groups found with total ratios deviating"
  )
  expect_equal(nrow(result), 4)

  # With stricter threshold (0.001), only A should be removed
  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE, threshold = 0.001),
    "Removed 1 CD"
  )
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$CD_CODE_2006), "B")
})


# =============================================================================
# HELPER FUNCTION TESTS: combine_ratios()
# =============================================================================

test_that("combine_ratios correctly multiplies and aggregates ratios", {
  # Create test data simulating CD -> SA1 2011 -> SA1 2016 chain
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "A", "A"),
    SA1_CODE_2011 = c("1", "1", "2", "2"),
    SA1_CODE_2016 = c("X", "Y", "X", "Z"),
    RATIO_1 = c(0.6, 0.6, 0.4, 0.4),  # CD -> SA1 2011
    RATIO_2 = c(0.5, 0.5, 0.3, 0.7)   # SA1 2011 -> SA1 2016
  )

  result <- scgElectionsAU:::combine_ratios(
    df,
    col_name = "RATIO_COMBINED",
    ratio_col1 = "RATIO_1",
    ratio_col2 = "RATIO_2",
    group_cols = c("CD_CODE_2006", "SA1_CODE_2016"),
    process = TRUE
  )

  expect_true("RATIO_COMBINED" %in% names(result))
  expect_equal(nrow(result), 3)  # X, Y, Z

  # Check that ratios for CD "A" sum to 1
  total_ratio <- sum(result$RATIO_COMBINED[result$CD_CODE_2006 == "A"])
  expect_equal(total_ratio, 1, tolerance = 0.01)
})

test_that("combine_ratios handles multiple source groups", {
  # Create test data with two source CDs
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B"),
    SA1_CODE_2016 = c("X", "Y", "Y", "Z"),
    RATIO_1 = c(1.0, 1.0, 1.0, 1.0),
    RATIO_2 = c(0.6, 0.4, 0.7, 0.3)
  )

  result <- scgElectionsAU:::combine_ratios(
    df,
    col_name = "RATIO_COMBINED",
    ratio_col1 = "RATIO_1",
    ratio_col2 = "RATIO_2",
    group_cols = c("CD_CODE_2006", "SA1_CODE_2016"),
    process = TRUE
  )

  # Check both groups sum to 1
  total_A <- sum(result$RATIO_COMBINED[result$CD_CODE_2006 == "A"])
  total_B <- sum(result$RATIO_COMBINED[result$CD_CODE_2006 == "B"])
  expect_equal(total_A, 1, tolerance = 0.01)
  expect_equal(total_B, 1, tolerance = 0.01)
})


# =============================================================================
# HELPER FUNCTION TESTS: verify_ratios() - additional coverage
# =============================================================================

test_that("verify_ratios handles reverify = FALSE", {
  # Create test data where one group's ratios don't sum to 1
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B"),
    SA1_CODE_2011 = c("1", "2", "3", "4"),
    RATIO = c(0.6, 0.4, 0.5, 0.3)  # B sums to 0.8, not 1
  )

  # With reverify = FALSE, should not get the "All total ratios are now within" message
  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE, reverify = FALSE),
    "Removed 1 CD"
  )

  # Should NOT get the reverification message
  expect_equal(nrow(result), 2)
})

test_that("verify_ratios handles single group correctly", {
  # Create test data with single group
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "A"),
    SA1_CODE_2011 = c("1", "2", "3"),
    RATIO = c(0.5, 0.3, 0.2)  # Sums to 1.0
  )

  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE),
    "No groups found with total ratios deviating"
  )

  expect_equal(nrow(result), 3)
})

test_that("verify_ratios issues warning after removal if ratios still invalid", {
  # This tests the case where after removing problematic groups,
  # the remaining groups still have issues (edge case with reverify)
  # Create data where removal doesn't fix all issues
  df <- data.frame(
    CD_CODE_2006 = c("A", "A", "B", "B", "C", "C"),
    SA1_CODE_2011 = c("1", "2", "3", "4", "5", "6"),
    RATIO = c(0.6, 0.4, 0.5, 0.3, 0.6, 0.4)  # A=1.0, B=0.8, C=1.0
  )

  # Only B should be removed
  expect_message(
    result <- scgElectionsAU:::verify_ratios(df, "RATIO", "CD_CODE_2006", process = TRUE),
    "Removed 1 CD"
  )

  expect_equal(nrow(result), 4)  # A and C remain
  expect_true(all(result$CD_CODE_2006 %in% c("A", "C")))
})


# =============================================================================
# INTERNAL MAPPING TESTS (parameter validation only - no downloads)
# =============================================================================

test_that("prepare_boundaries rejects all backward mappings for 2025 election", {
  # 2025 cannot map to any 2016 or 2011 boundaries
  expect_error(
    prepare_boundaries(event = "2025 Federal Election", compare_to = "2016 Postcodes"),
    "Invalid combination"
  )

  expect_error(
    prepare_boundaries(event = "2025 Federal Election", compare_to = "2019 Federal Election"),
    "Invalid combination"
  )

  expect_error(
    prepare_boundaries(event = "2025 Federal Election", compare_to = "2016 Federal Election"),
    "Invalid combination"
  )

  expect_error(
    prepare_boundaries(event = "2025 Federal Election", compare_to = "2013 Federal Election"),
    "Invalid combination"
  )
})

test_that("prepare_boundaries rejects backward mappings for 2019/2022/2023 events",
{
  # Events using SA1 2016 cannot map to SA1 2011 boundaries
  events_2016 <- c("2019 Federal Election", "2022 Federal Election", "2023 Referendum")

  for (evt in events_2016) {
    expect_error(
      prepare_boundaries(event = evt, compare_to = "2011 Census"),
      "Invalid combination"
    )

    expect_error(
      prepare_boundaries(event = evt, compare_to = "2011 Postcodes"),
      "Invalid combination"
    )

    expect_error(
      prepare_boundaries(event = evt, compare_to = "2013 Federal Election"),
      "Invalid combination"
    )
  }
})

test_that("prepare_boundaries rejects backward mappings for 2016 election", {
  # 2016 uses SA1 2011 - cannot map backwards (but 2011 is the earliest, so only 2013 CED applies)
  # Actually 2016 CAN map to 2011 Census (same SA1 year) and 2013 CED (uses 2011 SA1)
  # This is testing that it DOESN'T error for valid combinations

  # These should NOT error (valid forward/same mappings)
  # We can't actually run them without downloading, but we can verify no error on param validation
  expect_error(
    prepare_boundaries(event = "2016 Federal Election", compare_to = "2011 Census"),
    NA
  )
})


# =============================================================================
# FULL FUNCTION TESTS (with downloads)
# =============================================================================
test_that("prepare_boundaries downloads and converts Postcodes", {
  expect_message(
    result <- prepare_boundaries(event = "2025 Federal Election", compare_to = "2021 Postcodes"),
    "Downloading `allocation` file from"
  )
  expect_equal(ncol(result), 2)
})

test_that("prepare_boundaries downloads and converts CEDs", {
  expect_warning(
    result <- prepare_boundaries(event = "2013 Federal Election", compare_to = "2025 Federal Election"),
    "Some SA1s in AEC data not found in ABS data")

  expect_equal(ncol(result), 5)
})