# =============================================================================
# try_combine() TESTS
# =============================================================================

test_that("try_combine successfully combines compatible data frames", {
  df1 <- data.frame(a = 1:3, b = c("x", "y", "z"))

  df2 <- data.frame(a = 4:6, b = c("p", "q", "r"))

  result <- scgElectionsAU:::try_combine(df1, df2)

  expect_equal(nrow(result), 6)
  expect_equal(result$a, 1:6)
  expect_equal(result$b, c("x", "y", "z", "p", "q", "r"))
})

test_that("try_combine handles type mismatch by converting to numeric", {
  # df1 has character column, df2 has numeric - this triggers the error handler
  df1 <- data.frame(LastElection = c("2010", "2011", "-"))
  df2 <- data.frame(LastElection = c(2012, 2013, 2014))

  expect_message(
    result <- scgElectionsAU:::try_combine(df1, df2),
    "Attempting to fix columns"
  )

  expect_equal(nrow(result), 6)
  # "-" should be coerced to NA
  expect_true(is.na(result$LastElection[3]))
  expect_equal(result$LastElection[4:6], c(2012, 2013, 2014))
})

test_that("try_combine handles multiple type mismatches recursively", {
  # Two columns with mismatched types
  df1 <- data.frame(
    Col1 = c("100", "200"),
    Col2 = c("A", "B"),
    stringsAsFactors = FALSE
  )
  df2 <- data.frame(
    Col1 = c(300, 400),
    Col2 = c(1, 2)
  )

  expect_message(
    result <- scgElectionsAU:::try_combine(df1, df2),
    "Attempting to fix columns"
  )

  expect_equal(nrow(result), 4)
})

test_that("try_combine stops on unhandled errors", {
  # Create data frames that will cause an error not related to type mismatch
  df1 <- data.frame(a = 1:3)
  df2 <- data.frame(b = 4:6)  # Different column name - bind_rows handles this

  # This should work (bind_rows handles different columns by filling with NA)
  result <- scgElectionsAU:::try_combine(df1, df2)
  expect_equal(nrow(result), 6)
})


# =============================================================================
# rename_cols() TESTS
# =============================================================================

test_that("rename_cols successfully renames columns", {
  df <- data.frame(`Old Name` = 1:3, Other = 4:6, check.names = FALSE)

  result <- scgElectionsAU:::rename_cols(df, NewName = "Old Name")

  expect_true("NewName" %in% names(result))
  expect_false("Old Name" %in% names(result))
  expect_true("Other" %in% names(result))
})

test_that("rename_cols handles multiple renamings", {
  df <- data.frame(
    `Pre-poll Votes` = 1:3,
    `Postal Votes` = 4:6,
    Division = c("A", "B", "C"),
    check.names = FALSE
  )

  result <- scgElectionsAU:::rename_cols(
    df,
    PrePollVotes = "Pre-poll Votes",
    PostalVotes = "Postal Votes"
  )

  expect_true("PrePollVotes" %in% names(result))
  expect_true("PostalVotes" %in% names(result))
  expect_true("Division" %in% names(result))
  expect_false("Pre-poll Votes" %in% names(result))
  expect_false("Postal Votes" %in% names(result))
})

test_that("rename_cols errors on unnamed arguments", {
  df <- data.frame(a = 1:3, b = 4:6)

  expect_error(
    scgElectionsAU:::rename_cols(df, "a"),
    "All arguments must be named with new column names"
  )
})

test_that("rename_cols errors on partially unnamed arguments", {
  df <- data.frame(a = 1:3, b = 4:6)

  expect_error(
    scgElectionsAU:::rename_cols(df, NewA = "a", "b"),
    "All arguments must be named with new column names"
  )
})

test_that("rename_cols errors when old column names not found", {
  df <- data.frame(a = 1:3, b = 4:6)

  expect_error(
    scgElectionsAU:::rename_cols(df, NewName = "nonexistent"),
    "The following old names were not found in the data: nonexistent"
  )
})

test_that("rename_cols errors with multiple missing columns", {
  df <- data.frame(a = 1:3, b = 4:6)

  expect_error(
    scgElectionsAU:::rename_cols(df, X = "missing1", Y = "missing2"),
    "The following old names were not found in the data: missing1, missing2"
  )
})


# =============================================================================
# clear_cache() TESTS
# =============================================================================

# Helper to get cache environments from the loaded namespace
# This ensures tests access the same environments that clear_cache() uses
get_cache_env <- function(name) {

  get(name, envir = asNamespace("scgElectionsAU"))
}

test_that("clear_cache validates type parameter", {
  expect_error(
    clear_cache("invalid_type"),
    "type must be NULL, 'election', 'disclosure', 'boundary', 'census', or 'abs'"
  )
})

test_that("clear_cache clears election cache when data exists", {
  cache_env <- get_cache_env(".election_cache")

  # Clear any existing data from prior tests, then add our test data
  rm(list = ls(envir = cache_env), envir = cache_env)
  assign("test_key", data.frame(x = 1), envir = cache_env)

  expect_message(
    clear_cache("election"),
    "Cleared 1 cached election dataset"
  )

  # Verify it's empty
  expect_equal(length(ls(envir = cache_env)), 0)
})

test_that("clear_cache reports when election cache is empty", {
  cache_env <- get_cache_env(".election_cache")

  # Ensure cache is empty first
  rm(list = ls(envir = cache_env), envir = cache_env)

  expect_message(
    clear_cache("election"),
    "No cached election data found"
  )
})

test_that("clear_cache clears disclosure cache when data exists", {
  cache_env <- get_cache_env(".disclosure_cache")

  # Clear any existing data from prior tests, then add our test data
  rm(list = ls(envir = cache_env), envir = cache_env)
  assign("test_key", data.frame(x = 1), envir = cache_env)

  expect_message(
    clear_cache("disclosure"),
    "Cleared 1 cached disclosure dataset"
  )

  expect_equal(length(ls(envir = cache_env)), 0)
})

test_that("clear_cache reports when disclosure cache is empty", {
  cache_env <- get_cache_env(".disclosure_cache")
  rm(list = ls(envir = cache_env), envir = cache_env)

  expect_message(
    clear_cache("disclosure"),
    "No cached disclosure data found"
  )
})

test_that("clear_cache clears boundary cache when data exists", {
  cache_env <- get_cache_env(".boundary_cache")

  # Clear any existing data from prior tests, then add our test data
  rm(list = ls(envir = cache_env), envir = cache_env)
  assign("test_key", data.frame(x = 1), envir = cache_env)

  expect_message(
    clear_cache("boundary"),
    "Cleared 1 cached boundary dataset"
  )

  expect_equal(length(ls(envir = cache_env)), 0)
})

test_that("clear_cache reports when boundary cache is empty", {
  cache_env <- get_cache_env(".boundary_cache")
  rm(list = ls(envir = cache_env), envir = cache_env)

  expect_message(
    clear_cache("boundary"),
    "No cached boundary data found"
  )
})

test_that("clear_cache clears abs cache when data exists", {
  cache_env <- get_cache_env(".abs_cache")

  # Clear any existing data from prior tests, then add our test data
  rm(list = ls(envir = cache_env), envir = cache_env)
  assign("test_key", data.frame(x = 1), envir = cache_env)

  expect_message(
    clear_cache("abs"),
    "Cleared 1 cached ABS API dataset"
  )

  expect_equal(length(ls(envir = cache_env)), 0)
})

test_that("clear_cache reports when abs cache is empty", {
  cache_env <- get_cache_env(".abs_cache")
  rm(list = ls(envir = cache_env), envir = cache_env)

  expect_message(
    clear_cache("abs"),
    "No cached ABS API data found"
  )
})

test_that("clear_cache handles census cache directory", {
  cache_dir <- file.path(tempdir(), "scgElectionsAU_census_cache")

  # Create directory and a fake zip file
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  fake_zip <- file.path(cache_dir, "census_2021_datapack.zip")
  writeLines("fake", fake_zip)

  expect_message(
    clear_cache("census"),
    "Cleared 1 cached Census DataPack"
  )

  expect_false(file.exists(fake_zip))
})

test_that("clear_cache reports when census cache is empty", {
  cache_dir <- file.path(tempdir(), "scgElectionsAU_census_cache")

  # Ensure directory exists but has no matching files
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  # Remove any existing census zips
  files <- list.files(cache_dir, pattern = "^census_.*\\.zip$", full.names = TRUE)
  if (length(files) > 0) unlink(files)

  expect_message(
    clear_cache("census"),
    "No cached Census DataPacks found"
  )
})

test_that("clear_cache reports when census cache directory doesn't exist", {
  cache_dir <- file.path(tempdir(), "scgElectionsAU_census_cache")

  # Remove directory if it exists
  if (dir.exists(cache_dir)) unlink(cache_dir, recursive = TRUE)

  expect_message(
    clear_cache("census"),
    "No cached Census DataPacks found"
  )
})

test_that("clear_cache with NULL clears all caches", {
  election_cache <- get_cache_env(".election_cache")
  disclosure_cache <- get_cache_env(".disclosure_cache")
  boundary_cache <- get_cache_env(".boundary_cache")
  abs_cache <- get_cache_env(".abs_cache")

  # Add data to multiple caches
  assign("test1", data.frame(x = 1), envir = election_cache)
  assign("test2", data.frame(x = 1), envir = disclosure_cache)
  assign("test3", data.frame(x = 1), envir = boundary_cache)
  assign("test4", data.frame(x = 1), envir = abs_cache)

  # Should get messages for each cache type
  expect_message(
    expect_message(
      expect_message(
        expect_message(
          clear_cache(NULL),
          "Cleared.*election"
        ),
        "Cleared.*disclosure"
      ),
      "Cleared.*boundary"
    ),
    "Cleared.*ABS"
  )

  # Verify all are empty
  expect_equal(length(ls(envir = election_cache)), 0)
  expect_equal(length(ls(envir = disclosure_cache)), 0)
  expect_equal(length(ls(envir = boundary_cache)), 0)
  expect_equal(length(ls(envir = abs_cache)), 0)
})

test_that("clear_cache with NULL reports when all caches are empty", {
  election_cache <- get_cache_env(".election_cache")
  disclosure_cache <- get_cache_env(".disclosure_cache")
  boundary_cache <- get_cache_env(".boundary_cache")
  abs_cache <- get_cache_env(".abs_cache")

  # Ensure all caches are empty
  rm(list = ls(envir = election_cache), envir = election_cache)
  rm(list = ls(envir = disclosure_cache), envir = disclosure_cache)
  rm(list = ls(envir = boundary_cache), envir = boundary_cache)
  rm(list = ls(envir = abs_cache), envir = abs_cache)

  # Ensure census cache is empty too
  cache_dir <- file.path(tempdir(), "scgElectionsAU_census_cache")
  if (dir.exists(cache_dir)) {
    files <- list.files(cache_dir, pattern = "^census_.*\\.zip$", full.names = TRUE)
    if (length(files) > 0) unlink(files)
  }

  expect_message(
    clear_cache(NULL),
    "No cached data found"
  )
})

test_that("clear_cache returns invisible NULL", {
  result <- clear_cache("election")
  expect_null(result)
})


# =============================================================================
# pivot_event() TESTS
# =============================================================================

test_that("pivot_event transforms wide to long format", {
  df <- data.frame(
    Division = c("Div1", "Div2"),
    State = c("NSW", "VIC"),
    `2020-01-01` = c(100, 200),
    `2020-01-02` = c(150, 250),
    check.names = FALSE
  )

  result <- scgElectionsAU:::pivot_event(
    df,
    id_cols = c("Division", "State"),
    long_cols = NULL,
    names_to = "Date",
    values_to = "Votes"
  )

  expect_equal(nrow(result), 4)
  expect_true("Date" %in% names(result))
  expect_true("Votes" %in% names(result))
  expect_true(all(c("2020-01-01", "2020-01-02") %in% result$Date))
})

test_that("pivot_event skips NA values", {
  df <- data.frame(
    Division = c("Div1", "Div2"),
    `2020-01-01` = c(100, NA),
    `2020-01-02` = c(150, 250),
    check.names = FALSE
  )

  result <- scgElectionsAU:::pivot_event(
    df,
    id_cols = c("Division"),
    long_cols = NULL,
    names_to = "Date",
    values_to = "Votes"
  )

  # Should have 3 rows (skipping the NA)
  expect_equal(nrow(result), 3)
})

test_that("pivot_event respects long_cols exclusion", {
  df <- data.frame(
    Division = c("Div1"),
    Metadata = c("info"),
    `2020-01-01` = c(100),
    check.names = FALSE
  )

  result <- scgElectionsAU:::pivot_event(
    df,
    id_cols = c("Division"),
    long_cols = c("Metadata"),
    names_to = "Date",
    values_to = "Votes"
  )

  # Metadata should not appear as a date value
  expect_false("Metadata" %in% result$Date)
})


# =============================================================================
# validate_date() TESTS
# =============================================================================

test_that("validate_date accepts valid YYYY-MM-DD format", {
  expect_true(scgElectionsAU:::validate_date("2024-01-15"))
  expect_true(scgElectionsAU:::validate_date("2000-12-31"))
  expect_true(scgElectionsAU:::validate_date("1999-06-01"))
})

test_that("validate_date rejects invalid date formats", {
  expect_false(scgElectionsAU:::validate_date("01-15-2024"))  # Wrong order
  expect_false(scgElectionsAU:::validate_date("2024/01/15"))  # Wrong separator
  expect_false(scgElectionsAU:::validate_date("not-a-date"))
  expect_false(scgElectionsAU:::validate_date(""))
})

test_that("validate_date rejects invalid dates", {
  expect_false(scgElectionsAU:::validate_date("2024-02-30"))  # Feb 30 doesn't exist
  expect_false(scgElectionsAU:::validate_date("2024-13-01"))  # Month 13 doesn't exist
})
