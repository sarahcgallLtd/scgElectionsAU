# Main function
prepare_boundaries <- function(
  event = c("2023 Referendum", "2022 Federal Election", "2019 Federal Election", # 2016 ASGS
            "2016 Federal Election", # 2011 ASGS
            "2013 Federal Election"), # 2006 ASGS
  compare_to = c("2025 Federal Election", "2023 Referendum", "2022 Federal Election", "2021 Postcodes", "2021 Census", # 2021 ASGS
                 "2019 Federal Election", "2016 Federal Election", "2016 Postcodes", "2016 Census", # 2016 ASGS
                 "2013 Federal Election", "2011 Postcodes", "2011 Census"), # 2011 ASGS
  process = TRUE
) {
  # =====================================#
  # CHECK PARAMS
  event <- match.arg(event)
  compare_to <- match.arg(compare_to)

  # Define base geographies for events
  event_base <- list(
    "2013 Federal Election" = list(type = "CD", year = 2006),
    "2016 Federal Election" = list(type = "SA1", year = 2011),
    "2019 Federal Election" = list(type = "SA1", year = 2016),
    "2022 Federal Election" = list(type = "SA1", year = 2016),
    "2023 Referendum" = list(type = "SA1", year = 2016)
  )

  # Define target geographies for comparisons
  comparison_target <- list(
    "2011 Census" = list(sa1_year = 2011, type = "SA1"),
    "2011 Postcodes" = list(sa1_year = 2011, type = "POA"),
    "2013 Federal Election" = list(sa1_year = 2011, type = "CED", ced_year = 2013),
    "2016 Census" = list(sa1_year = 2016, type = "SA1"),
    "2016 Postcodes" = list(sa1_year = 2016, type = "POA"),
    "2016 Federal Election" = list(sa1_year = 2016, type = "CED", ced_year = 2016),
    "2019 Federal Election" = list(sa1_year = 2016, type = "CED", ced_year = 2018),
    "2021 Census" = list(sa1_year = 2021, type = "SA1"),
    "2021 Postcodes" = list(sa1_year = 2021, type = "POA"),
    "2022 Federal Election" = list(sa1_year = 2021, type = "CED", ced_year = 2021, special = "Vic_WA"),
    "2023 Referendum" = list(sa1_year = 2021, type = "CED", ced_year = 2021, special = "Vic_WA"),
    "2025 Federal Election" = list(sa1_year = 2021, type = "CED", ced_year = 2024, special = "NT")
  )

  event_info <- event_base[[event]]
  compare_info <- comparison_target[[compare_to]]

  # Validate combination of event and compare_to
  if (event_info$type == "CD" && event_info$year == 2006) {
    if (!compare_info$sa1_year %in% c(2011, 2016, 2021)) {
      stop("Invalid combination: Cannot correspond from CD 2006 to SA1 year ", compare_info$sa1_year)
    }
  } else if (event_info$type == "SA1") {
    if (event_info$year > compare_info$sa1_year) {
      stop("Invalid combination: Cannot correspond from SA1 ", event_info$year, " to earlier SA1 year ", compare_info$sa1_year)
    }
  }

  # =====================================#
  # GET DATA
  # Get correspondence file
  corresp_df <- get_correspondence(event_info$type, event_info$year, compare_info$sa1_year, process)

  if (compare_info$type == "SA1") {
    return(corresp_df)

  } else if (compare_info$type == "POA") {#
    # Get POA allocation file
    alloc_df <- get_allocation_table(compare_info$sa1_year, "POA")

    # Merge the correspondence and allocation files together by sa1_col
    sa1_col <- if (compare_info$sa1_year == 2011) "SA1_MAINCODE_2011" else if (compare_info$sa1_year == 2016) "SA1_MAINCODE_2016" else "SA1_CODE_2021"
    combined_df <- merge(corresp_df, alloc_df, by = sa1_col, all = TRUE)

    return(combined_df)

  } else if (compare_info$type == "CED") {
    # Get CED allocation file
    alloc_df <- get_allocation_table(compare_info$ced_year, "CED")

    # Merge the correspondence and allocation files together by sa1_col
    sa1_col <- if (compare_info$sa1_year == 2011) c("SA1_MAINCODE_2011", "SA1_7DIGITCODE_2011") else if (compare_info$sa1_year == 2016) c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016") else "SA1_CODE_2021"
    combined_df <- merge(corresp_df, alloc_df, by = sa1_col, all = TRUE)

    if (!is.null(compare_info$special)) {
      sa1_2021 <- if (compare_info$sa1_year == 2021) corresp_df else get_boundary_data(2021, "SA1", "correspondence")
      combined_df <- apply_redistribution_adjustments(combined_df, compare_info$special, sa1_2021)
    }
    return(combined_df)
  }
}

# Helper function to get correspondence from base to target SA1 year
get_correspondence <- function(
  base_type,
  base_year,
  target_sa1_year,
  process
) {
  if (base_type == "CD" && base_year == 2006) {
    # Get 2006 CDs to 2011 SA1s correspondence table
    sa1_2011 <- get_boundary_data(2011, "SA1", "correspondence")

    # Clarify RATIO_FROM_TO to make it unique
    sa1_2011 <- rename_cols(sa1_2011, RATIO_06CD_11SA1 = "RATIO_FROM_TO", SA1_CODE_2011 = "SA1_MAINCODE_2011")

    # Remove unnecessary columns
    sa1_2011 <- sa1_2011[, !names(sa1_2011) == "SA1_7DIGITCODE_2011"]

    # Verify ratios = 1
    sa1_2011 <- verify_ratios(sa1_2011, "RATIO_06CD_11SA1", "CD_CODE_2006", process)

    # Make CD_CODE_2006 and SA1_CODE_2011 a string to match AEC data
    sa1_2011$CD_CODE_2006 <- as.character(sa1_2011$CD_CODE_2006)
    sa1_2011$SA1_CODE_2011 <- as.character(sa1_2011$SA1_CODE_2011)

    # Return CD_2006 -> SA1 2011
    if (target_sa1_year == 2011) return(sa1_2011)

    # Get 2011 SA1s to 2016 SA1s correspondence table
    sa1_2016 <- get_boundary_data(2016, "SA1", "correspondence")

    # Clarify RATIO_FROM_TO to make it unique
    sa1_2016 <- rename_cols(sa1_2016, RATIO_11SA1_16SA1 = "RATIO_FROM_TO", SA1_CODE_2011 = "SA1_MAINCODE_2011",
                            SA1_CODE_2016 = "SA1_MAINCODE_2016")

    # Make SA1_CODE_2016 a string to match AEC data
    sa1_2016$SA1_CODE_2016 <- as.character(sa1_2016$SA1_CODE_2016)

    # Combine sa1_2011 and sa1_2016
    sa1_1116 <- merge(sa1_2011, sa1_2016, by = "SA1_CODE_2011", all = TRUE)

    # Combine ratios and simplify file
    sa1_1116 <- combine_ratios(sa1_1116, "RATIO_06CD_16SA1", "RATIO_06CD_11SA1", "RATIO_11SA1_16SA1",
                               c("CD_CODE_2006", "SA1_CODE_2016"), process)

    # Return CD_2006 -> SA1 2016
    if (target_sa1_year == 2016) return(sa1_1116)

    # Get 2016 SA1s to 2021 SA1s correspondence table
    sa1_2021 <- get_boundary_data(2021, "SA1", "correspondence")

    # Select necessary columns
    sa1_2021 <- sa1_2021[, c("SA1_MAINCODE_2016", "SA1_CODE_2021", "RATIO_FROM_TO")]

    # Clarify RATIO_FROM_TO to make it unique
    sa1_2021 <- rename_cols(sa1_2021, RATIO_16SA1_21SA1 = "RATIO_FROM_TO", SA1_CODE_2016 = "SA1_MAINCODE_2016")

    # Add SA1_7DIGITCODE_2016 to be in line with AEC data
    #sa1_2021 <- amend_maincode(sa1_2021, "SA1_MAINCODE_2016")

    # Combine sa1_1116 and sa1_2021
    #sa1_1121 <- merge(sa1_1116, sa1_2021, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)
    sa1_1121 <- merge(sa1_1116, sa1_2021, by = "SA1_CODE_2016", all = TRUE)

    # Combine ratios and simplify file
    sa1_1121 <- combine_ratios(sa1_1121, "RATIO_06CD_21SA1", "RATIO_06CD_16SA1", "RATIO_16SA1_21SA1",
                               c("CD_CODE_2006", "SA1_CODE_2021"), process)

    # Return CD_2006 -> SA1 2021
    return(sa1_1121)

  } else if (base_type == "SA1") {
    if (base_year == target_sa1_year) {
      # Get 2011 SA1s
      sa1_data <- get_boundary_data(base_year, "SA1")

      # Extract relevant columns
      sa1_data <- sa1_data[, c(paste0("SA1_MAINCODE_", base_year), paste0("SA1_7DIGITCODE_", base_year))]

      # Return SA1 2011 or SA1 2016
      return(sa1_data)

    } else if (base_year == 2011) {
      # Get 2011 SA1s to 2016 SA1s correspondence table
      sa1_2016 <- get_boundary_data(2016, "SA1", "correspondence")

      # Clarify RATIO_FROM_TO to make it unique
      sa1_2016 <- rename_cols(sa1_2016, RATIO_11SA1_16SA1 = "RATIO_FROM_TO")

      # Return SA1 2011 -> SA1 2016
      if (target_sa1_year == 2016) return(sa1_2016)

      # Get 2016 SA1s to 2021 SA1s correspondence table
      sa1_2021 <- get_boundary_data(2021, "SA1", "correspondence")

      # Select necessary columns
      sa1_2021 <- sa1_2021[, c("SA1_MAINCODE_2016", "SA1_CODE_2021", "RATIO_FROM_TO")]

      # Clarify RATIO_FROM_TO to make it unique
      sa1_2021 <- rename_cols(sa1_2021, RATIO_16SA1_21SA1 = "RATIO_FROM_TO")

      # Add SA1_7DIGITCODE_2016 to be in line with AEC data
      sa1_2021 <- amend_maincode(sa1_2021, "SA1_MAINCODE_2016")

      # Combine sa1_2016 and sa1_2021
      sa1_1621 <- merge(sa1_2016, sa1_2021, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Combine ratios and simplify file
      sa1_1621 <- combine_ratios(sa1_1621, "RATIO_11SA1_21SA1", "RATIO_11SA1_16SA1", "RATIO_16SA1_21SA1",
                                 c("SA1_7DIGITCODE_2011", "SA1_CODE_2021"), process)

      # Return SA1 2011 -> SA1 2021
      return(sa1_1621)

    } else if (base_year == 2016 && target_sa1_year == 2021) {

      # Get 2016 SA1s to 2021 SA1s correspondence table
      sa1_2021 <- get_boundary_data(2021, "SA1", "correspondence")

      # Select necessary columns
      sa1_2021 <- sa1_2021[, c("SA1_MAINCODE_2016", "SA1_CODE_2021", "RATIO_FROM_TO")]

      # Clarify RATIO_FROM_TO to make it unique
      sa1_2021 <- rename_cols(sa1_2021, RATIO_16SA1_21SA1 = "RATIO_FROM_TO")

      # Add SA1_7DIGITCODE_2016 to be in line with AEC data
      sa1_2021 <- amend_maincode(sa1_2021, "SA1_MAINCODE_2016")

      # Return SA1 2016 -> SA1 2021
      return(sa1_2021)
    }
  }
  stop("Unsupported base_type or year combination")
}


# Helper function to get allocation tables for POA or CED
get_allocation_table <- function(
  year,
  type
) {
  if (type == "POA") {
    # Get POA allocation table
    alloc_df <- get_boundary_data(year, "POA")

    if (year %in% c(2016, 2021)) {
      # Extract relevant columns
      alloc_df <- alloc_df[, c(paste("MB_CODE_", year), paste0("POA_NAME_", year))]

      # Get MB to SA1 allocation table and select relevant columns
      mb_df <- get_boundary_data(year, "MB")
      mb_cols <- if (year == 2016) c("MB_CODE_2016", "SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016") else c("MB_CODE_2021", "SA1_CODE_2021")
      mb_df <- mb_df[, mb_cols]

      # Merge MB -> SA1 file to MB -> POA file
      alloc_df <- merge(mb_df, alloc_df, by = paste0("MB_CODE_", year), all = TRUE)

      # Drop MB column and make unique to make a SA1 -> POA allocation file
      alloc_df <- unique(alloc_df[, !grepl("MB_CODE", names(alloc_df))])

    } else {
      # Extract relevant columns
      alloc_df <- alloc_df[, c("SA1_MAINCODE_2011", "POA_NAME_2011")]
    }

  } else if (type == "CED") {
    # Get CED allocation table
    alloc_df <- get_boundary_data(year, "CED")

    if (year %in% c(2021, 2024)) {
      # Keep relevant columns
      alloc_df <- alloc_df[, c("MB_CODE_2021", paste0("CED_NAME_", year))]

      # Get 2021 MB to 2021 SA1 allocation table and select relevant columns
      mb_df <- get_boundary_data(2021, "MB")
      mb_df <- mb_df[, c("MB_CODE_2021", "SA1_CODE_2021")]

      # Merge MB -> SA1 file to MB -> CED file
      alloc_df <- merge(mb_df, alloc_df, by = "MB_CODE_2021", all = TRUE)

      # Drop MB column and make unique to make a SA1 -> CED allocation file
      alloc_df <- unique(alloc_df[, !grepl("MB_CODE", names(alloc_df))])

    } else {
      # Keep relevant columns
      sa1_col <- if (year %in% c(2016, 2018)) "SA1_MAINCODE_2016" else "SA1_MAINCODE_2011"
      alloc_df <- alloc_df[, c(sa1_col, paste0("CED_NAME_", year))]
    }
    # Add SA1_7DIGITCODE_2011 to be in line with AEC data
    sa1_col <- if (year == 2013) "SA1_MAINCODE_2011" else if (year %in% c(2016, 2018)) "SA1_MAINCODE_2016" else "SA1_CODE_2021"
    alloc_df <- amend_maincode(alloc_df, sa1_col)
  }
  return(alloc_df)
}


# Helper function for redistribution adjustments
apply_redistribution_adjustments <- function(
  data,
  special,
  sa1_2021 = NULL
) {
  if (special == "Vic_WA") {
    # Get supplementatry AEC data
    Vic <- scgUtils::get_file("https://www.aec.gov.au/redistributions/2021/vic/final-report/files/vic-by-SA2-and-SA1.xlsx", source = "web")
    WA <- scgUtils::get_file("https://www.aec.gov.au/redistributions/2021/wa/final-report/files/wa-by-SA2-and-SA1.xlsx", source = "web")

    # Amend to match ABS for NT redistribution
    Vic <- Vic[, c("SA1 code\r\n(2016 SA1s)", "New electoral division from \r\n26 July 2021")]
    WA <- WA[, c("SA1 code\r\n(2016 SA1s)", "New electoral division from \r\n2 August 2021")]
    Vic <- rename_cols(Vic, SA1_7DIGITCODE_2016 = "SA1 code\r\n(2016 SA1s)", CED_NAME_2021 = "New electoral division from \r\n26 July 2021")
    WA <- rename_cols(WA, SA1_7DIGITCODE_2016 = "SA1 code\r\n(2016 SA1s)", CED_NAME_2021 = "New electoral division from \r\n2 August 2021")

    # combine the two
    redist_states <- rbind(Vic, WA)
    redist_states <- redist_states[!is.na(redist_states$SA1_7DIGITCODE_2016),]

    # Add sa1_2021
    redist_states <- merge(redist_states, sa1_2021, by = "SA1_7DIGITCODE_2016", all.x = TRUE)
    redist_states <- unique(redist_states[, c("CED_NAME_2021", "SA1_CODE_2021")])

    # Lookup redist_states$SA1_CODE_2021 against data$SA1_CODE_2021
    indices <- match(redist_states$SA1_CODE_2021, data$SA1_CODE_2021)

    # Check if all SA1s in NT are present in combined_df
    if (any(is.na(indices))) {
      warning("Some SA1s in AEC data not found in ABS data")
      # Proceed with valid matches only
      valid <- !is.na(indices)
      indices <- indices[valid]
      redist_states <- redist_states[valid,]
    }

    # Identify where CED_NAME_2021 differs or is NA in combined_df
    is_different <- data$CED_NAME_2021[indices] != redist_states$CED_NAME_2021 & !is.na(data$CED_NAME_2021[indices])
    is_na <- is.na(data$CED_NAME_2021[indices])
    changes <- sum(is_different | is_na)

    # Update data with WA & Vic's CED_NAME_2021
    data$CED_NAME_2021[indices] <- redist_states$CED_NAME_2021

    # Print message with number of changes
    message(paste(changes, "ABS CEDs changed based on AEC redistribution data in Vic & WA"))

  } else if (special == "NT") {
    # Get supplementatry AEC data
    NT <- scgUtils::get_file("https://www.aec.gov.au/redistributions/2024/nt/final-report/files/Northern-Territory-electoral-divisions-SA1-and-SA2.xlsx", source = "web")

    # Amend to match ABS for NT redistribution
    NT <- NT[, c("Statistical Area Level 1 (SA1) Code (7-digit)\r\n(2021 SA1s)\r\n", "New Electoral Division from 4 March 2025")]
    NT <- rename_cols(NT, SA1_7DIGITCODE_2021 = "Statistical Area Level 1 (SA1) Code (7-digit)\r\n(2021 SA1s)\r\n", CED_NAME_2024 = "New Electoral Division from 4 March 2025")
    NT$CED_NAME_2024 <- tools::toTitleCase(tolower(NT$CED_NAME_2024))
    NT <- NT[NT$CED_NAME_2024 != "Total",]

    # Lookup NT$SA1_7DIGITCODE_2021 against dataf$SA1_7DIGITCODE_2021
    indices <- match(NT$SA1_7DIGITCODE_2021, data$SA1_7DIGITCODE_2021)

    # Check if all SA1s in NT are present in data
    if (any(is.na(indices))) {
      warning("Some SA1s in AEC data not found in ABS data")
      # Proceed with valid matches only
      valid <- !is.na(indices)
      indices <- indices[valid]
      NT <- NT[valid,]
    }

    # Identify where CED_NAME_2024 differs or is NA in data
    is_different <- data$CED_NAME_2024[indices] != NT$CED_NAME_2024 & !is.na(data$CED_NAME_2024[indices])
    is_na <- is.na(data$CED_NAME_2024[indices])
    changes <- sum(is_different | is_na)

    # Update combined_df with NT's CED_NAME_2024
    data$CED_NAME_2024[indices] <- NT$CED_NAME_2024

    # Print message with number of changes
    message(paste(changes, "ABS CEDs changed based on AEC redistribution data in NT"))
  }
  return(data)
}


# Helper function to combine correspondence files
combine_ratios <- function(
  data,
  col_name,
  ratio_col1,
  ratio_col2,
  group_cols,
  process
) {
  # Calculate the product of the ratios of each row
  data[[col_name]] <- data[[ratio_col1]] * data[[ratio_col2]]

  # Aggregate by the specified group columns, summing the combined ratio
  agg_formula <- as.formula(paste(col_name, "~", paste(group_cols, collapse = " + ")))
  combined_df <- aggregate(agg_formula, data = data, sum, na.rm = TRUE)

  # Verify ratios = 1
  combined_df <- verify_ratios(combined_df, col_name, group_cols[1], process)

  # Return
  return(combined_df)
}


# Helper function to ensure ratios of correspondence files = 1
verify_ratios <- function(
  data,
  ratio_col,
  group_cols,
  process,
  threshold = 0.01,
  reverify = TRUE
) {
  # Create formula for aggregation
  formula_str <- paste(ratio_col, "~", paste(group_cols, collapse = " + "))
  ver_formula <- as.formula(formula_str)
  group_type <- strsplit(group_cols[1], "_")[[1]][1]

  # Aggregate to sum ratios by group_cols
  verification <- aggregate(ver_formula, data = data, sum, na.rm = TRUE)

  # Identify problematic groups
  problematic_idx <- which(abs(verification[[ratio_col]] - 1) > threshold)

  if (length(problematic_idx) > 0) {
    if (!process) {
      warning("Some total ratios of the ", group_type, "s deviate from 1 by more than ", threshold, " after removal.")
    } else {
      # Get the problematic group combinations
      problematic_groups <- verification[problematic_idx, group_cols, drop = FALSE]

      # Create a key for data and problematic_groups
      data$temp_key <- do.call(paste, c(data[group_cols], sep = "_"))
      problematic_groups$temp_key <- do.call(paste, c(problematic_groups, sep = "_"))

      # Filter data to exclude problematic keys
      data <- data[!data$temp_key %in% problematic_groups$temp_key,]

      # Remove the temporary key column
      data$temp_key <- NULL

      # Message
      message("Removed ", nrow(problematic_groups), " ", group_type,
              "(s) with total ratios deviating from 1 by more than ", threshold, ".")

      if (reverify) {
        # Re-aggregate
        verification_after <- aggregate(ver_formula, data = data, sum, na.rm = TRUE)
        if (any(abs(verification_after[[ratio_col]] - 1) > threshold)) {
          warning("Some total ratios still deviate from 1 by more than ", threshold, " after removal.")
        } else {
          message("All total ratios are now within the acceptable range of 1 ± ", threshold, ".")
        }
      }
    }
  } else {
    message("No groups found with total ratios deviating from 1 by more than ", threshold, ".")
  }

  return(data)
}