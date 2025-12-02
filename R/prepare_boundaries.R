#' Prepare Boundary Correspondence for Cross-Election Comparison
#'
#' Creates a correspondence table that maps geographic units from one election event to
#' the boundaries of another event or geographic standard. This enables comparison of
#' election results across different boundary configurations by providing ratios that
#' indicate how source areas map to target areas.
#'
#' @param event Character string specifying the source election event whose results
#'   you want to re-map. The geographic base varies by event:
#'   \describe{
#'     \item{"2025 Federal Election"}{Uses 2021 ASGS SA1 boundaries}
#'     \item{"2023 Referendum", "2022 Federal Election", "2019 Federal Election"}{Use 2016 ASGS SA1 boundaries}
#'     \item{"2016 Federal Election"}{Uses 2011 ASGS SA1 boundaries}
#'     \item{"2013 Federal Election"}{Uses 2006 Census Collector Districts}
#'   }
#' @param compare_to Character string specifying the target boundaries to map to.
#'   Options include federal elections, referendums, Census SA1s, and postcodes:
#'   \describe{
#'     \item{Elections/Referendum}{Map to CED boundaries for that event (e.g., "2025 Federal Election")}
#'     \item{Census}{Map to SA1 boundaries for that Census year (e.g., "2021 Census")}
#'     \item{Postcodes}{Map to Postal Areas for that year (e.g., "2021 Postcodes")}
#'   }
#' @param process Logical. If \code{TRUE} (default), removes geographic units with
#'   correspondence ratios that don't sum to 1 (indicating data quality issues).
#'   If \code{FALSE}, retains all data but issues warnings for problematic units.
#'
#' @return A data frame containing the boundary correspondence with columns for:
#'   \itemize{
#'     \item Source geographic unit identifiers (CD or SA1 codes)
#'     \item Target geographic unit identifiers (SA1, POA, or CED)
#'     \item Ratio column(s) indicating proportion of source mapping to target
#'   }
#'   The exact columns depend on the \code{event} and \code{compare_to} combination.
#'
#' @details
#' This function is central to comparing election results across different boundary
#' configurations. Australian electoral boundaries change due to redistributions, and
#' the ABS updates SA1 boundaries with each Census. This function builds correspondence
#' tables that account for these changes.
#'
#' The function works by:
#' \enumerate{
#'   \item Determining the base geography for the source \code{event}
#'   \item Building a correspondence chain to the target SA1 year via \code{\link{get_correspondence}}
#'   \item If target is POA or CED, merging with allocation tables via \code{\link{get_allocation_table}}
#'   \item For recent elections (2022, 2023, 2025), applying redistribution adjustments
#'         via \code{\link{apply_redistribution_adjustments}} to correct for boundary
#'         changes that occurred after ABS allocation files were published
#' }
#'
#' @section Valid Combinations:
#' Not all event/compare_to combinations are valid. Generally:
#' \itemize{
#'   \item You can map forward in time (older events to newer boundaries)
#'   \item You cannot map to boundaries from an earlier ASGS edition than the event uses
#' }
#'
#' @examples
#' \dontrun{
#'   # Map 2019 election results to 2025 electoral boundaries
#'   corresp <- prepare_boundaries(
#'     event = "2019 Federal Election",
#'     compare_to = "2025 Federal Election"
#'   )
#'
#'   # Map 2022 election results to 2021 postcodes
#'   corresp <- prepare_boundaries(
#'     event = "2022 Federal Election",
#'     compare_to = "2021 Postcodes"
#'   )
#'
#'   # Map 2013 election results (CD-based) to 2021 SA1 boundaries
#'   corresp <- prepare_boundaries(
#'     event = "2013 Federal Election",
#'     compare_to = "2021 Census"
#'   )
#' }
#'
#' @seealso
#' \code{\link{prepare_results}} for applying boundary transformations to election data
#'
#' @keywords internal
prepare_boundaries <- function(
  event = c("2025 Federal Election", # 2021 ASGS
            "2023 Referendum", "2022 Federal Election", "2019 Federal Election", # 2016 ASGS
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
    "2023 Referendum" = list(type = "SA1", year = 2016),
    "2025 Federal Election" = list(type = "SA1", year = 2021)
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

  } else if (compare_info$type == "POA") {
    # Get POA allocation file
    alloc_df <- get_allocation_table(compare_info$sa1_year, "POA")

    # Determine merge column and remove duplicate columns before merge
    if (compare_info$sa1_year == 2016) {
      # Both dataframes have SA1_7DIGITCODE_2016, remove from alloc_df to avoid duplicates
      alloc_df <- alloc_df[, !names(alloc_df) %in% "SA1_7DIGITCODE_2016"]
      sa1_col <- "SA1_MAINCODE_2016"
    } else if (compare_info$sa1_year == 2011) {
      sa1_col <- "SA1_MAINCODE_2011"
    } else {
      sa1_col <- "SA1_CODE_2021"
    }
    combined_df <- merge(corresp_df, alloc_df, by = sa1_col, all = TRUE)

    return(combined_df)

  } else if (compare_info$type == "CED") {
    # Get CED allocation file
    alloc_df <- get_allocation_table(compare_info$ced_year, "CED")

    # Merge the correspondence and allocation files together by sa1_col
    sa1_col <- if (compare_info$sa1_year == 2011) c("SA1_MAINCODE_2011", "SA1_7DIGITCODE_2011") else if (compare_info$sa1_year == 2016) c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016") else "SA1_CODE_2021"
    combined_df <- merge(corresp_df, alloc_df, by = sa1_col, all = TRUE)

    if (!is.null(compare_info$special)) {
      # For Vic_WA redistribution, we need 2016 SA1 -> 2021 SA1 correspondence to map AEC's 2016 SA1 codes
      # Get the correspondence file and add SA1_7DIGITCODE_2016 column to match AEC data format
      sa1_2021 <- get_boundary_data(2021, "SA1", "correspondence")
      sa1_2021 <- amend_maincode(sa1_2021, "SA1_MAINCODE_2016")
      combined_df <- apply_redistribution_adjustments(combined_df, compare_info$special, sa1_2021)
    }
    return(combined_df)
  }
}


#' Helper Function to Build Geographic Correspondence from Source to Target SA1 Year
#'
#' Constructs a correspondence table that maps geographic units from the source election's
#' base geography (CD 2006 or SA1 2011/2016/2021) to a target SA1 year. Handles chaining
#' of multiple ABS correspondence files when the source and target span multiple ASGS editions.
#'
#' @param base_type Character string specifying the source geographic unit type.
#'   Must be one of:
#'   \describe{
#'     \item{"CD"}{Census Collector District (used for 2013 Federal Election)}
#'     \item{"SA1"}{Statistical Area Level 1 (used for 2016+ elections)}
#'   }
#' @param base_year Numeric. The ASGS edition year of the source geography:
#'   \describe{
#'     \item{2006}{For CD base type (2013 election)}
#'     \item{2011}{For SA1 base type (2016 election)}
#'     \item{2016}{For SA1 base type (2019, 2022, 2023 elections)}
#'     \item{2021}{For SA1 base type (2025 election)}
#'   }
#' @param target_sa1_year Numeric. The target SA1 year to correspond to (2011, 2016, or 2021).
#'   Must be greater than or equal to \code{base_year} for SA1 base types.
#' @param process Logical. Passed to \code{\link{verify_ratios}} and \code{\link{combine_ratios}}
#'   to control whether problematic ratio groups are removed.
#'
#' @return A data frame containing the correspondence mapping with columns for source unit
#'   identifiers, target SA1 codes, and ratio columns indicating the proportion of each
#'   source unit mapping to each target SA1. Column names follow the pattern
#'   \code{RATIO_[source]_[target]} (e.g., \code{RATIO_06CD_21SA1}).
#'
#' @details
#' The function handles several correspondence pathways:
#'
#' \strong{From CD 2006:}
#' \itemize{
#'   \item To SA1 2011: Direct correspondence from ABS
#'   \item To SA1 2016: Chains CD→SA1 2011→SA1 2016
#'   \item To SA1 2021: Chains CD→SA1 2011→SA1 2016→SA1 2021
#' }
#'
#' \strong{From SA1 2011:}
#' \itemize{
#'   \item To SA1 2011: Returns allocation table (no correspondence needed)
#'   \item To SA1 2016: Direct correspondence from ABS
#'   \item To SA1 2021: Chains SA1 2011→SA1 2016→SA1 2021
#' }
#'
#' \strong{From SA1 2016:}
#' \itemize{
#'   \item To SA1 2016: Returns allocation table (no correspondence needed)
#'   \item To SA1 2021: Direct correspondence from ABS
#' }
#'
#' \strong{From SA1 2021:}
#' \itemize{
#'   \item To SA1 2021: Returns allocation table (no correspondence needed)
#' }
#'
#' When chaining correspondences, ratios are multiplied and aggregated using
#' \code{\link{combine_ratios}}, then validated using \code{\link{verify_ratios}}.
#'
#' @examples
#' \dontrun{
#'   # Get correspondence from 2013 election (CD 2006) to 2021 SA1s
#'   corresp <- get_correspondence("CD", 2006, 2021, process = TRUE)
#'
#'   # Get correspondence from 2019 election (SA1 2016) to 2021 SA1s
#'   corresp <- get_correspondence("SA1", 2016, 2021, process = TRUE)
#' }
#'
#' @seealso \code{\link{combine_ratios}}, \code{\link{verify_ratios}},
#'   \code{\link{get_boundary_data}}
#'
#' @noRd
#' @keywords internal
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
    sa1_2011 <- rename_cols(sa1_2011, RATIO_06CD_11SA1 = "RATIO_FROM_TO")

    # Verify ratios = 1
    sa1_2011 <- verify_ratios(sa1_2011, "RATIO_06CD_11SA1", "CD_CODE_2006", process)

    # Make CD_CODE_2006 a string to match AEC data
    sa1_2011$CD_CODE_2006 <- as.character(sa1_2011$CD_CODE_2006)

    # Return CD_2006 -> SA1 2011
    if (target_sa1_year == 2011) return(sa1_2011)

    # Get 2011 SA1s to 2016 SA1s correspondence table
    sa1_2016 <- get_boundary_data(2016, "SA1", "correspondence")

    # Clarify RATIO_FROM_TO to make it unique
    sa1_2016 <- rename_cols(sa1_2016, RATIO_11SA1_16SA1 = "RATIO_FROM_TO")

    # Combine sa1_2011 and sa1_2016
    sa1_1116 <- merge(sa1_2011, sa1_2016, by = "SA1_MAINCODE_2011", all = TRUE)

    # Combine ratios and simplify file
    sa1_1116 <- combine_ratios(sa1_1116, "RATIO_06CD_16SA1", "RATIO_06CD_11SA1", "RATIO_11SA1_16SA1",
                               c("CD_CODE_2006", "SA1_MAINCODE_2016"), process)

    # Return CD_2006 -> SA1 2016
    if (target_sa1_year == 2016) {
      # Add SA1_7DIGITCODE_2016 to match allocation table column names
      sa1_1116 <- amend_maincode(sa1_1116, "SA1_MAINCODE_2016")
      return(sa1_1116)
    }

    # Get 2016 SA1s to 2021 SA1s correspondence table
    sa1_2021 <- get_boundary_data(2021, "SA1", "correspondence")

    # Select necessary columns
    sa1_2021 <- sa1_2021[, c("SA1_MAINCODE_2016", "SA1_CODE_2021", "RATIO_FROM_TO")]

    # Clarify RATIO_FROM_TO to make it unique
    sa1_2021 <- rename_cols(sa1_2021, RATIO_16SA1_21SA1 = "RATIO_FROM_TO")

    # Combine sa1_1116 and sa1_2021
    sa1_1121 <- merge(sa1_1116, sa1_2021, by = "SA1_MAINCODE_2016", all = TRUE)

    # Combine ratios and simplify file
    sa1_1121 <- combine_ratios(sa1_1121, "RATIO_06CD_21SA1", "RATIO_06CD_16SA1", "RATIO_16SA1_21SA1",
                               c("CD_CODE_2006", "SA1_CODE_2021"), process)

    # Return CD_2006 -> SA1 2021
    return(sa1_1121)

  } else if (base_type == "SA1") {
    if (base_year == target_sa1_year) {
      # Get SA1 allocation table for the base year
      sa1_data <- get_boundary_data(base_year, "SA1")

      # Extract relevant columns - 2021 uses SA1_CODE_2021, earlier years use SA1_MAINCODE_XXXX
      if (base_year == 2021) {
        sa1_data <- sa1_data[, "SA1_CODE_2021", drop = FALSE]
      } else {
        sa1_data <- sa1_data[, c(paste0("SA1_MAINCODE_", base_year), paste0("SA1_7DIGITCODE_", base_year))]
      }

      # Return SA1 data (no transformation needed when base equals target)
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

    } else if (base_year == 2021 && target_sa1_year == 2021) {
      # 2025 Federal Election uses 2021 SA1s - no correspondence needed
      # Get 2021 SA1 allocation table
      sa1_2021 <- get_boundary_data(2021, "SA1")

      # Select relevant columns and add 7-digit code
      sa1_2021 <- sa1_2021[, "SA1_CODE_2021", drop = FALSE]
      sa1_2021 <- amend_maincode(sa1_2021, "SA1_CODE_2021")

      # Return SA1 2021 (no transformation needed)
      return(sa1_2021)
    }
  }
  stop("Unsupported base_type or year combination")
}


#' Helper Function to Retrieve SA1 to Geographic Unit Allocation Table
#'
#' Fetches and processes ABS allocation data to create a mapping from SA1 codes to either
#' Postal Areas (POA) or Commonwealth Electoral Divisions (CED). For years where direct
#' SA1 allocation files are unavailable, constructs the mapping via Mesh Block (MB)
#' intermediate tables.
#'
#' @param year Numeric. The reference year for the allocation data. Valid values depend
#'   on \code{type}:
#'   \describe{
#'     \item{POA}{2011, 2016, or 2021}
#'     \item{CED}{2013, 2016, 2018, 2021, or 2024}
#'   }
#' @param type Character string specifying the target geographic unit. Must be one of:
#'   \describe{
#'     \item{"POA"}{Postal Area - returns SA1 to postcode mapping}
#'     \item{"CED"}{Commonwealth Electoral Division - returns SA1 to electorate mapping}
#'   }
#'
#' @return A data frame with SA1 identifiers and the corresponding POA or CED name.
#'   The SA1 column name varies by year (e.g., \code{SA1_MAINCODE_2016}, \code{SA1_CODE_2021}).
#'   For CED allocations, a 7-digit SA1 code column is also added via \code{\link{amend_maincode}}.
#'
#' @details
#' The ABS provides allocation files at different geographic levels depending on the year:
#' \itemize{
#'   \item \strong{2011}: Direct SA1 to POA/CED allocation files available
#'   \item \strong{2016, 2018}: Direct SA1 to CED files; POA requires MB intermediate
#'   \item \strong{2021, 2024}: MB-level files only; SA1 mapping constructed via MB to SA1 join
#' }
#'
#' For years requiring MB intermediates, the function:
#' \enumerate{
#'   \item Downloads the MB to POA/CED allocation file
#'   \item Downloads the MB to SA1 allocation file
#'   \item Merges on MB code and removes duplicates to create SA1-level allocation
#' }
#'
#' @examples
#' \dontrun{
#'   # Get SA1 to CED allocation for 2024 boundaries
#'   ced_alloc <- get_allocation_table(2024, "CED")
#'
#'   # Get SA1 to POA allocation for 2021 postcodes
#'   poa_alloc <- get_allocation_table(2021, "POA")
#' }
#'
#' @seealso \code{\link{get_boundary_data}} for downloading raw ABS boundary files
#'
#' @noRd
#' @keywords internal
get_allocation_table <- function(
  year,
  type
) {
  if (type == "POA") {
    # Get POA allocation table
    alloc_df <- get_boundary_data(year, "POA")

    if (year %in% c(2016, 2021)) {
      # Extract relevant columns
      alloc_df <- alloc_df[, c(paste0("MB_CODE_", year), paste0("POA_NAME_", year))]

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


#' Helper Function to Apply Electoral Redistribution Adjustments to Boundary Data
#'
#' Updates Commonwealth Electoral Division (CED) assignments in boundary correspondence data
#' to reflect redistributions that occurred after the ABS released their allocation files.
#' Downloads supplementary SA1-to-CED mappings from AEC redistribution reports and overwrites
#' the ABS CED assignments for affected SA1s.
#'
#' @param data A data frame containing boundary correspondence data with CED assignments
#'   (e.g., \code{CED_NAME_2021} or \code{CED_NAME_2024}) and SA1 identifiers.
#' @param special Character string specifying which redistribution to apply. Must be one of:
#'   \describe{
#'     \item{"Vic_WA"}{Victoria and Western Australia 2021 redistributions, effective for
#'       the 2022 Federal Election. Updates \code{CED_NAME_2021} using 2016 SA1 codes.}
#'     \item{"NT"}{Northern Territory 2024 redistribution, effective from 4 March 2025.
#'       Updates \code{CED_NAME_2024} using 2021 SA1 codes.}
#'   }
#' @param sa1_2021 A data frame containing SA1 2016 to SA1 2021 correspondence data.
#'   Required when \code{special = "Vic_WA"} to map 2016 SA1 codes (used by AEC) to
#'   2021 SA1 codes (used in the output data). Ignored for \code{special = "NT"}.
#'
#' @return The input data frame with updated CED assignments for SA1s affected by the
#'   specified redistribution. A message reports the number of CED assignments changed.
#'
#' @details
#' ABS allocation files are released based on gazetted CED boundaries at the time of each
#' Census. However, electoral redistributions can occur between Censuses, meaning the ABS
#' CED assignments may not reflect the boundaries used for a particular election.
#'
#' This function corrects for this by:
#' \enumerate{
#'   \item Downloading the official AEC redistribution SA1-to-CED mapping
#'   \item Matching SA1s in the input data to the redistribution data
#'   \item Overwriting the CED assignment with the post-redistribution division name
#' }
#'
#' For \code{special = "Vic_WA"}, the AEC files use 2016 SA1 codes, so the \code{sa1_2021}
#' correspondence is needed to link to 2021 SA1 codes in the output data.
#'
#' @examples
#' \dontrun{
#'   # Apply Victoria/WA redistribution for 2022 election boundaries
#'   sa1_corresp <- get_boundary_data(2021, "SA1", "correspondence")
#'   adjusted_df <- apply_redistribution_adjustments(
#'     data = combined_df,
#'     special = "Vic_WA",
#'     sa1_2021 = sa1_corresp
#'   )
#'
#'   # Apply NT redistribution for 2025 election boundaries
#'   adjusted_df <- apply_redistribution_adjustments(
#'     data = combined_df,
#'     special = "NT"
#'   )
#' }
#'
#' @noRd
#' @keywords internal
apply_redistribution_adjustments <- function(
  data,
  special,
  sa1_2021 = NULL
) {
  if (special == "Vic_WA") {
    # Get supplementatry AEC data
    Vic <- scgUtils::get_file("https://www.aec.gov.au/redistributions/2021/vic/final-report/files/vic-by-SA2-and-SA1.xlsx", source = "web")
    WA <- scgUtils::get_file("https://www.aec.gov.au/redistributions/2021/wa/final-report/files/wa-by-SA2-and-SA1.xlsx", source = "web")

    # Clean column names to remove \r\n
    colnames(Vic) <- gsub("[\r\n]", "", colnames(Vic))
    colnames(WA) <- gsub("[\r\n]", "", colnames(WA))

    # Amend to match ABS for VIC & WA redistribution
    # Subset columns using grep
    Vic <- Vic[, grep("SA1 code.*2016|New electoral division.*26 July 2021", colnames(Vic))]
    WA <- WA[, grep("SA1 code.*2016|New electoral division.*2 August 2021", colnames(WA))]
    # Rename columns
    colnames(Vic)[grep("SA1 code.*2016", colnames(Vic))] <- "SA1_7DIGITCODE_2016"
    colnames(Vic)[grep("electoral division", colnames(Vic), ignore.case = TRUE)] <- "CED_NAME_2021"

    colnames(WA)[grep("SA1 code.*2016", colnames(WA))] <- "SA1_7DIGITCODE_2016"
    colnames(WA)[grep("electoral division", colnames(WA), ignore.case = TRUE)] <- "CED_NAME_2021"

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

    # Clean column names to remove \r\n
    colnames(NT) <- gsub("[\r\n]", "", colnames(NT))

    # Amend to match ABS for NT redistribution
    cols <- grep("Statistical Area Level 1|New Electoral Division", colnames(NT), value = TRUE)
    NT <- NT[, cols]
    colnames(NT)[grep("SA1.*Code.*7-digit", colnames(NT))] <- "SA1_7DIGITCODE_2021"
    colnames(NT)[grep("Electoral Division", colnames(NT))] <- "CED_NAME_2024"
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


#' Helper Function to Combine Correspondence Ratios Across ASGS Editions
#'
#' Chains two correspondence ratios together to create a combined ratio spanning multiple
#' ASGS editions. For example, combines CD 2006 → SA1 2011 ratios with SA1 2011 → SA1 2016
#' ratios to produce CD 2006 → SA1 2016 ratios.
#'
#' @param data A data frame containing merged correspondence data with two ratio columns
#'   from consecutive ASGS correspondence files.
#' @param col_name Character string specifying the name for the new combined ratio column
#'   (e.g., "RATIO_06CD_16SA1").
#' @param ratio_col1 Character string specifying the first ratio column name
#'   (e.g., "RATIO_06CD_11SA1").
#' @param ratio_col2 Character string specifying the second ratio column name
#'   (e.g., "RATIO_11SA1_16SA1").
#' @param group_cols Character vector of length 2 specifying the source and target
#'   geographic unit columns to aggregate by (e.g., \code{c("CD_CODE_2006", "SA1_CODE_2016")}).
#' @param process Logical. Passed to \code{\link{verify_ratios}} to control whether
#'   groups with invalid combined ratios are removed.
#'
#' @return A data frame with columns for the source unit, target unit, and combined ratio.
#'   The combined ratio represents the proportion of the source unit that maps to each
#'   target unit across the chained correspondences.
#'
#' @details
#' The function works by:
#' \enumerate{
#'   \item Multiplying the two input ratios row-wise to get the combined ratio
#'   \item Aggregating by source and target units, summing the combined ratios
#'   \item Verifying the aggregated ratios sum to 1 for each source unit
#' }
#'
#' This approach handles cases where an intermediate geographic unit (e.g., SA1 2011)
#' splits across multiple target units, correctly apportioning the source unit's
#' contribution to each final target.
#'
#' @examples
#' \dontrun{
#'   # Combine CD 2006 -> SA1 2011 with SA1 2011 -> SA1 2016
#'   combined_df <- combine_ratios(
#'     data = merged_corresp,
#'     col_name = "RATIO_06CD_16SA1",
#'     ratio_col1 = "RATIO_06CD_11SA1",
#'     ratio_col2 = "RATIO_11SA1_16SA1",
#'     group_cols = c("CD_CODE_2006", "SA1_CODE_2016"),
#'     process = TRUE
#'   )
#' }
#'
#' @seealso \code{\link{verify_ratios}} for ratio validation
#'
#' @noRd
#' @keywords internal
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
  agg_formula <- stats::as.formula(paste(col_name, "~", paste(group_cols, collapse = " + ")))
  combined_df <- stats::aggregate(agg_formula, data = data, sum, na.rm = TRUE)

  # Verify ratios = 1
  combined_df <- verify_ratios(combined_df, col_name, group_cols[1], process)

  # Return
  return(combined_df)
}


#' Helper Function to Verify and Clean Correspondence Ratios
#'
#' Validates that correspondence ratios sum to 1 for each source geographic unit and optionally
#' removes units with invalid ratios. In ABS correspondence files, ratios represent the proportion
#' of a source unit (e.g., CD or SA1) that maps to each target unit. Valid correspondences should
#' have ratios summing to 1 for each source unit.
#'
#' @param data A data frame containing correspondence data with ratio values.
#' @param ratio_col Character string specifying the name of the column containing ratio values.
#' @param group_cols Character vector specifying the column name(s) to group by when summing ratios.
#'   Typically the source geographic unit identifier (e.g., "CD_CODE_2006", "SA1_CODE_2016").
#' @param process Logical. If \code{TRUE}, removes rows belonging to groups with invalid ratios.
#'   If \code{FALSE}, issues a warning but retains all data.
#' @param threshold Numeric. The acceptable deviation from 1 for summed ratios. Groups with
#'   total ratios outside \code{1 ± threshold} are considered problematic. Defaults to 0.01.
#' @param reverify Logical. If \code{TRUE} and \code{process = TRUE}, re-checks ratios after
#'   removing problematic groups to confirm all remaining groups are valid. Defaults to \code{TRUE}.
#'
#' @return A data frame. If \code{process = TRUE}, problematic groups are removed. If
#'   \code{process = FALSE}, the original data is returned unchanged (with a warning if issues exist).
#'
#' @details
#' The function aggregates ratios by the specified grouping column(s) and checks whether each
#' group's total deviates from 1 by more than the threshold. Deviations can occur due to:
#' \itemize{
#'   \item Rounding in ABS correspondence files
#'   \item Geographic units that span multiple ASGS editions
#'   \item Data quality issues in source files
#' }
#'
#' When \code{process = TRUE}, entire groups (all rows for a source unit) are removed if their
#' ratios don't sum correctly. This ensures downstream calculations using ratios remain valid.
#'
#' @examples
#' \dontrun{
#'   # Verify CD to SA1 correspondence ratios
#'   cleaned_df <- verify_ratios(
#'     data = corresp_df,
#'     ratio_col = "RATIO_06CD_11SA1",
#'     group_cols = "CD_CODE_2006",
#'     process = TRUE
#'   )
#' }
#'
#' @noRd
#' @keywords internal
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
  ver_formula <- stats::as.formula(formula_str)
  group_type <- strsplit(group_cols[1], "_")[[1]][1]

  # Aggregate to sum ratios by group_cols
  verification <- stats::aggregate(ver_formula, data = data, sum, na.rm = TRUE)

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
        verification_after <- stats::aggregate(ver_formula, data = data, sum, na.rm = TRUE)
        if (any(abs(verification_after[[ratio_col]] - 1) > threshold)) {
          warning("Some total ratios still deviate from 1 by more than ", threshold, " after removal.")
        } else {
          message("All total ratios are now within the acceptable range of 1 \u00B1 ", threshold, ".")
        }
      }
    }
  } else {
    message("No groups found with total ratios deviating from 1 by more than ", threshold, ".")
  }

  return(data)
}
