#' Retrieve Australian Bureau of Statistics (ABS) boundary data
#'
#' Downloads and processes ABS boundary data (allocation or correspondence files)
#' for a specified reference year and geographic level from the scgElectionsAU package.
#' For the special case of 2011 SA1 correspondence data, it handles multiple sheets
#' from an Excel file and performs additional data cleaning.
#'
#' @param ref_date Numeric. The reference year for the boundary data. Must be between 2011 and 2024, inclusive.
#' @param level Character. The geographic level of the boundary data. One of "CED" (Commonwealth Electoral Division),
#'   "SED" (State Electoral Division), "POA" (Postal Area), "SA1" (Statistical Area Level 1), or "MB" (Mesh Block).
#'   Defaults to "CED".
#' @param type Character. The type of boundary data. One of "allocation" or "correspondence". Defaults to "allocation".
#' @param cache Logical. If TRUE (default), caches the downloaded and processed data for the session,
#'   making subsequent identical requests instant. Set to FALSE to always download fresh data.
#'
#' @return A data frame containing the boundary data for the specified parameters. If multiple files are downloaded,
#'   they are combined into a single data frame, provided they have identical column structures. For the 2011 SA1
#'   correspondence data, additional cleaning is performed to ensure data consistency.
#'
#' @details
#' This function retrieves boundary data by accessing the `abs_boundary_index` dataset in the `scgElectionsAU` package,
#' filtering it based on the provided `ref_date`, `level`, and `type`. It then downloads the corresponding files from
#' the URLs listed in the index using `scgUtils::get_file()`. If multiple files are retrieved, they are combined into
#' a single data frame using `rbind`. For the special case where `ref_date = 2011`, `level = "SA1"`, and
#' `type = "correspondence"`, the function downloads multiple sheets from an Excel file (sheets 4 to 7), corrects a
#' known column name typo ("SA1_7DIGICODE_2011" to "SA1_7DIGITCODE_2011"), and performs additional data cleaning steps,
#' such as renaming columns (e.g., "CD_CODE_2006...2" to "CD_CODE_2006"), removing redundant columns (e.g.,
#' "CD_CODE_2006...1"), and removing rows with all NA values. The function includes validation checks to ensure the
#' parameters are valid and that the downloaded data can be combined.
#'
#' Use \code{clear_cache} to remove cached data when needed.
#'
#' @examples
#' \dontrun{
#' # Retrieve 2024 CED allocation data
#' ced_data <- get_boundary_data(ref_date = 2024, level = "CED", type = "allocation")
#'
#' # Retrieve 2021 SA1 correspondence data (from 2016 to 2021)
#' sa1_data <- get_boundary_data(ref_date = 2021, level = "SA1", type = "correspondence")
#'
#' # Retrieve 2011 SA1 correspondence data (special case)
#' sa1_2011_data <- get_boundary_data(ref_date = 2011, level = "SA1", type = "correspondence")
#'
#' # Second call uses cache - instant!
#' sa1_2011_data2 <- get_boundary_data(ref_date = 2011, level = "SA1", type = "correspondence")
#' }
#'
#' @seealso \code{clear_cache} to remove cached data
#'
#' @export
get_boundary_data <- function(
  ref_date,
  level = c("CED", "SED", "POA", "SA1", "MB"),
  type = c("allocation", "correspondence"),
  cache = TRUE
) {
  # =====================================#
  # CHECK PARAMS
  level <- match.arg(level)
  type <- match.arg(type)

  # Validate ref_date
  if (!is.numeric(ref_date) ||
    ref_date < 2011 ||
    ref_date > 2024) {
    stop("ref_date must be a number between 2011 and 2024")
  }

  # =====================================#
  # CHECK CACHE
  if (cache) {
    cache_key <- paste("boundary", ref_date, level, type, sep = "|")
    cached_data <- get_boundary_cache(cache_key)
    if (!is.null(cached_data)) {
      message("Using cached boundary data for ", ref_date, " ", level, " ", type, "...")
      return(cached_data)
    }
  }

  # =====================================#
  # GET AND PROCESS INTERNAL DATA
  # Get index from the 'abs_boundary_index' data available in scgElectionsAU package
  index <- get0(x = "abs_boundary_index", envir = asNamespace("scgElectionsAU"))

  # Check if 'names' data is available
  if (is.null(index)) {
    stop(paste0("Data 'abs_boundary_index' not found in 'scgElectionsAU' package. Contact the package maintainer."))
  }

  # Filter index by level, type, and ref_date
  index <- index[index$level == level &
                   index$type == type &
                   index$ref_date == ref_date,]

  # Get list of urls
  urls <- as.character(index$url)

  # Check if index has 1 or more urls
  if (length(urls) == 0) {
    stop("No data found for the specified parameters. Check that the `ref_date` captures years between 2011 and 2024, inclusively.")
  }

  # =====================================#
  # GET DATA FILES FROM URLs
  is_special_case <- ref_date <= 2016 &&
    level %in% c("SA1", "MB") &&
    type == "correspondence"

  # Initliase an empty df to store all data
  df_list <- list()

  for (i in seq_along(urls)) {
    message(paste0("Downloading `", type, "` file from: ", urls[i]))

    # Download the file
    if (is_special_case) {
      df_list <- process_special_case(urls, level, ref_date)
    } else {
      tmp_df <- suppressMessages(
        scgUtils::get_file(urls[i], source = "web")
      )
      # Append to the combined DataFrame
      df_list[[i]] <- tmp_df
    }
  }

  message(paste0("Successfully downloaded ", ref_date, " ", level, " boundary file(s). Structure: ", index$Notes[1]))

  # Prepare result data frame
  if (length(df_list) == 1) {
    result_df <- df_list[[1]]
  } else {
    # Check if all data frames have the same columns
    first_cols <- names(df_list[[1]])
    if (is_special_case) {
      if (!all(sapply(df_list, function(df) all(first_cols %in% names(df))))) {
        stop("Some sheets are missing required columns.")
      }
      df_list <- lapply(df_list, function(df) df[, first_cols, drop = FALSE])
    } else {
      if (!all(sapply(df_list[-1], function(df) identical(names(df), first_cols)))) {
        stop("Data frames have different columns and cannot be combined.")
      }
    }
    # Combine the data frames using base R
    message("Combining files into one single file.")
    result_df <- do.call(rbind, df_list)

    # Fix formatting issues in special case
    if (is_special_case) {
      if (ref_date == 2011) {
        # Rename the second column with labels/unique IDs
        result_df <- rename_cols(result_df, CD_CODE_2006 = "CD_CODE_2006...2")
        # Remove the first column containing what is in the second column as well as Copyright information
        result_df <- result_df[, !names(result_df) == "CD_CODE_2006...1"]
      } else if (ref_date == 2016) {
        if (level == "MB") {
          # Rename the second column with labels/unique IDs
          result_df <- rename_cols(result_df, MB_CODE_2011 = "MB_CODE_2011...2", MB_CODE_2016 = "MB_CODE_2016...3")
          # Remove the first column containing what is in the second column as well as Copyright information
          result_df <- result_df[, !names(result_df) %in% c("MB_CODE_2011...1", "MB_CODE_2016...4")]
        } else if (level == "SA1") {
          # Remove "C Commonwealth of Australia 2012"
          result_df <- result_df[result_df$SA1_MAINCODE_2011 != "C Commonwealth of Australia 2012",]
        }
      }
      # Remove rows with all NA
      result_df <- result_df[rowSums(!is.na(result_df)) > 0,]
    }

    # Remove "PERCENTAGE" column and standardise RATIO colnames
    result_df <- result_df[, !names(result_df) == "PERCENTAGE"]
    result_df <- amend_colnames(result_df)
  }

  # =====================================#
  # CACHE AND RETURN DATA
  if (cache) {
    set_boundary_cache(cache_key, result_df)
  }

  return(result_df)
}


#' Retrieve and process boundary correspondence data for special cases
#'
#' This internal helper function retrieves boundary correspondence data for
#' reference years 2011 or 2016 at SA1 or MB geographic levels. It extracts
#' specific sheets from Excel files within zip archives and corrects column
#' names as needed.
#'
#' @param urls Character vector of URLs to data sources (zip files with Excel files).
#' @param level String specifying the geographic level: "SA1" or "MB".
#' @param ref_date Numeric reference year: 2011 or 2016.
#'
#' @return A list of data frames, each from a specific Excel sheet. For
#'   ref_date == 2011, renames "SA1_7DIGICODE_2011" to "SA1_7DIGITCODE_2011"
#'   if present.
#'
#' @noRd
#' @keywords internal
process_special_case <- function(urls, level, ref_date) {
  # Initliase an empty df to store all data
  df_list <- list()

  for (i in seq_along(urls)) {
    # Download the file
    if (level == "MB") {
      # Define the list of file names (without extensions, if the function expects base names)
      files <- c(
        "CG_ACT_MB_2011_ACT_MB_2016.xls",
        "CG_NSW_MB_2011_NSW_MB_2016.xls",
        "CG_NT_MB_2011_NT_MB_2016.xls",
        "CG_OT_MB_2011_OT_MB_2016.xls",
        "CG_QLD_MB_2011_QLD_MB_2016.xls",
        "CG_SA_MB_2011_SA_MB_2016.xls",
        "CG_TAS_MB_2011_TAS_MB_2016.xls",
        "CG_VIC_MB_2011_VIC_MB_2016.xls",
        "CG_WA_MB_2011_WA_MB_2016.xls"
      )

      # Function to determine sheets per file
      get_sheets <- function(file) {
        switch(sub("\\.xls$", "", basename(file)),
               "CG_ACT_MB_2011_ACT_MB_2016" = 4:5,
               "CG_NSW_MB_2011_NSW_MB_2016" = 5:8,
               "CG_NT_MB_2011_NT_MB_2016" = 4:6,
               "CG_OT_MB_2011_OT_MB_2016" = 4,
               "CG_QLD_MB_2011_QLD_MB_2016" = 5:8,
               "CG_SA_MB_2011_SA_MB_2016" = 4:6,
               "CG_TAS_MB_2011_TAS_MB_2016" = 4:6,
               "CG_VIC_MB_2011_VIC_MB_2016" = 5:8,
               "CG_WA_MB_2011_WA_MB_2016" = 4:6,
               stop("Unknown file name")
        )
      }

      # Process each file and its sheets
      for (file in files) {
        sheets <- get_sheets(file)
        for (sheet in sheets) {
          tmp_df <- suppressMessages(
            scgUtils::get_file(urls[i], source = "web", row_no = 5, sheet_no = sheet, file_name = file)
          )
          message(paste0("Extracting data from sheet ", sheet, " in `", file, "`..."))
          df_list <- c(df_list, list(tmp_df))
        }
      }
    } else {
      sheets <- switch(
        paste0(level, ref_date),
        "SA12011" = 4:7,
        "SA12016" = 4:6
      )
      for (sheet in sheets) {
        tmp_df <- suppressMessages(
          scgUtils::get_file(urls[i], source = "web", row_no = 5, sheet_no = sheet)
        )
        message(paste0("Extracting data from sheet ", sheet, "..."))
        df_list <- c(df_list, list(tmp_df))
      }
    }
  }

  # Fix column name typo in special case
  if (ref_date == 2011) {
    for (i in seq_along(df_list)) {
      if ("SA1_7DIGICODE_2011" %in% names(df_list[[i]])) {
        names(df_list[[i]])[names(df_list[[i]]) == "SA1_7DIGICODE_2011"] <- "SA1_7DIGITCODE_2011"
        message(paste("Fixed column name typo in sheet", i + 3))
      }
    }
  }
  return(df_list)
}


# ======================================================================================================================
# CACHING FUNCTIONS

# Package-level environment to store cached boundary data
.boundary_cache <- new.env(parent = emptyenv())


#' Get cached boundary data
#'
#' Retrieves data from the boundary cache if it exists.
#'
#' @param cache_key The cache key to look up.
#'
#' @return The cached data frame, or NULL if not found.
#'
#' @noRd
#' @keywords internal
get_boundary_cache <- function(cache_key) {
  if (exists(cache_key, envir = .boundary_cache)) {
    return(get(cache_key, envir = .boundary_cache))
  }
  return(NULL)
}


#' Store boundary data in cache
#'
#' Saves data to the boundary cache.
#'
#' @param cache_key The cache key to store under.
#' @param data The data frame to cache.
#'
#' @return Invisible NULL.
#'
#' @noRd
#' @keywords internal
set_boundary_cache <- function(cache_key, data) {
  assign(cache_key, data, envir = .boundary_cache)
  invisible(NULL)
}

