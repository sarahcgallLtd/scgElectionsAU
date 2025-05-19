# 2013 Federal Election
### To Census
df <- prepare_boundaries("2013 Federal Election", "2011 Census")
df1 <- prepare_boundaries("2013 Federal Election", "2016 Census")
df2 <- prepare_boundaries("2013 Federal Election", "2021 Census")

### To Postcodes


### To Federal Elections & Referendums

df <- prepare_boundaries("2013 Federal Election", "2011 Postcodes")
df <- prepare_boundaries("2013 Federal Election", "2013 Federal Election")














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

  # =====================================#
  # GET DATA
  if (event == "2013 Federal Election") {
    # 2013 FEDERAL ELECTION
    sa1_2011 <- get_correspondence("CD", 2006, 2011, process=TRUE)

    if (compare_to == "2011 Census") {
      # Return CD_2006 -> SA1 2011
      return(sa1_2011)

    } else if (compare_to == "2011 Postcodes") {
      # Add 2011 SA1s to 2011 POAs allocation table
      poa_2011 <- get_allocation_table(2011, "POA")

      # Combine 2011 SA1 -> 2011 POA allocation table to 2006 CD -> 2011 SA1 correspondence table by 2011 SA1
      combined_df <- merge(sa1_2011, poa_2011, by = "SA1_MAINCODE_2011", all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2011 POA
      return(combined_df)

    } else if (compare_to == "2013 Federal Election") {
      # Get 2011 SA1s to 2013 CEDs allocation table
      ced_2013 <- get_allocation_table(2013, "CED")

      # Add 2011 SA1 -> 2013 CED allocation table to 2006 CD -> 2011 SA1 correspondence table
      combined_df <- merge(sa1_2011, ced_2013, by = c("SA1_MAINCODE_2011", "SA1_7DIGITCODE_2011"), all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2013 CED
      return(combined_df)
    }

    sa1_1116 <- get_correspondence("CD", 2006, 2016, process=TRUE)

    if (compare_to == "2016 Census") {
      # Return CD_2006 -> SA1 2011 -> SA1 2016
      return(sa1_1116)

    } else if (compare_to == "2016 Postcodes") {
      # Get 2016 MBs to 2016 POAs allocation table
      poa_2016 <- get_allocation_table(2016, "POA")

      # Combine 2016 SA1 -> 2016 POA allocation table to 2006 CD -> 2016 SA1 correspondence table by 2016 SA1
      combined_df <- merge(sa1_1116, poa_2016, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2016 POA
      return(combined_df)

    } else if (compare_to == "2016 Federal Election") {
      # Get 2016 SA1s to 2016 CEDs allocation table
      ced_2016 <- get_allocation_table(2016, "CED")

      # Add 2016 SA1 -> 2016 CED allocation table to 2006 CD -> 2016 SA1 -> 2016 SA1 correspondence table
      combined_df <- merge(sa1_1116, ced_2016, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2016 CED
      return(combined_df)

    } else if (compare_to == "2019 Federal Election") {
      # Get 2016 SA1s to 2018 CEDs allocation table
      ced_2018 <- get_allocation_table(2018, "CED")

      # Add 2016 SA1 -> 2018 CED allocation table to 2006 CD -> 2016 SA1 -> 2016 SA1 correspondence table
      combined_df <- merge(sa1_1116, ced_2018, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2018 CED
      return(combined_df)

    }

    sa1_1121 <- get_correspondence("CD", 2006, 2021, process=TRUE)

    if (compare_to == "2021 Census") {
      # Return CD_2006 -> SA1 2011 -> SA1 2016 -> SA1 2021
      return(sa1_1121)

    } else if (compare_to == "2021 Postcodes") {
      # Get 2021 MBs to 2021 POAs allocation table
      poa_2021 <- get_allocation_table(2021, "POA")

      # Combine 2021 SA1 -> 2021 POA allocation table to 2006 CD -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1121, poa_2021, by = "SA1_CODE_2021", all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2016 POA
      return(combined_df)

    } else if (compare_to %in% c("2022 Federal Election", "2023 Referendum")) {
      # Get 2021 MBs to 2021 CEDs allocation table
      ced_2021 <- get_allocation_table(2021, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2006 CD -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1121, ced_2021, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "Vic_WA", sa1_2021)


    } else if (compare_to == "2025 Federal Election") {
      # Get 2021 MBs to 2024 CEDs allocation table
      ced_2024 <- get_allocation_table(2024, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2006 CD -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1121, ced_2024, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "NT")
    }

  } else if (event == "2016 Federal Election") {
    # 2016 FEDERAL ELECTION ===========================================================================================#
    if (compare_to == "2011 Census") {
      # Get 2011 SA1s
      sa1_2011 <- get_correspondence("SA1", 2011, 2011, process=TRUE)

      # Return SA1 2011
      return(sa1_2011)

    } else if (compare_to == "2011 Postcodes") {
      # Add 2011 SA1s to 2011 POAs allocation table
      poa_2011 <- get_allocation_table(2011, "POA")

      # Return SA1 2011 -> 2011 POA
      return(poa_2011)

    } else if (compare_to == "2013 Federal Election") {
      # Get 2011 SA1s to 2013 CEDs allocation table
      ced_2013 <- get_allocation_table(2013, "CED")

      # Return SA1 2011 -> 2013 CED
      return(ced_2013)
    }

    # Get 2011 SA1s to 2016 SA1s correspondence table
    sa1_2016 <- get_correspondence("SA1", 2011, 2016, process=TRUE)

    if (compare_to == "2016 Census") {
      # Return SA1 2011 -> SA1 2016
      return(sa1_2016)

    } else if (compare_to == "2016 Postcodes") {
      # Get 2016 MBs to 2016 POAs allocation table
      poa_2016 <- get_allocation_table(2016, "POA")

      # Combine 2016 SA1 -> 2016 POA allocation table to 2011 SA1 -> 2016 SA1 correspondence table by 2016 SA1
      combined_df <- merge(sa1_2016, poa_2016, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return SA1 2011 -> 2016 SA1 -> 2016 POA
      return(combined_df)

    } else if (compare_to == "2016 Federal Election") {
      # Get 2016 SA1s to 2016 CEDs allocation table
      ced_2016 <- get_allocation_table(2016, "CED")

      # Add 2016 SA1 -> 2016 CED allocation table to 2011 SA1 -> 2016 SA1 correspondence table
      combined_df <- merge(sa1_2016, ced_2016, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return SA1 2011 -> 2016 SA1 -> 2016 CED
      return(combined_df)

    } else if (compare_to == "2019 Federal Election") {
      # Get 2016 SA1s to 2018 CEDs allocation table
      ced_2018 <- get_allocation_table(2018, "CED")

      # Add 2016 SA1 -> 2018 CED allocation table to 2006 CD -> 2011 SA1 -> 2016 SA1 correspondence table
      combined_df <- merge(sa1_2016, ced_2018, by = c("SA1_MAINCODE_2016", "SA1_7DIGITCODE_2016"), all = TRUE)

      # Return SA1 2011 -> 2016 SA1 -> 2018 CED
      return(combined_df)

    }

    sa1_1621 <- get_correspondence("SA1", 2011, 2021, process=TRUE)

    if (compare_to == "2021 Census") {
      # Return SA1 2011 -> SA1 2021
      return(sa1_1621)

    } else if (compare_to == "2021 Postcodes") {
      # Get 2021 MBs to 2021 POAs allocation table
      poa_2021 <- get_allocation_table(2021, "POA")

      # Combine 2021 SA1 -> 2021 POA allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1621, poa_2021, by = "SA1_CODE_2021", all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2016 POA
      return(combined_df)

    } else if (compare_to %in% c("2022 Federal Election", "2023 Referendum")) {
      # Get 2021 MBs to 2021 CEDs allocation table
      ced_2021 <- get_allocation_table(2021, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1621, ced_2021, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "Vic_SA", sa1_2021)


    } else if (compare_to == "2025 Federal Election") {
      # Get 2021 MBs to 2024 CEDs allocation table
      ced_2024 <- get_allocation_table(2024, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_1621, ced_2024, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "NT")
    }

  } else if (event %in% c("2022 Federal Election","2023 Referendum","2019 Federal Election")) {
    # 2019 FEDERAL ELECTION ===========================================================================================#
    if (compare_to == "2016 Census") {
      sa1_2016 <- get_correspondence("SA1", 2016, 2016, process=TRUE)

      # Return SA1 2016
      return(sa1_2016)

    } else if (compare_to == "2016 Postcodes") {
      # Get 2016 MBs to 2016 POAs allocation table
      poa_2016 <- get_allocation_table(2016, "POA")

      # Return 2016 SA1 -> 2016 POA
      return(poa_2016)

    } else if (compare_to == "2016 Federal Election") {
      # Get 2016 SA1s to 2016 CEDs allocation table
      ced_2016 <- get_allocation_table(2016, "CED")

      # Return 2016 SA1 -> 2016 CED
      return(ced_2016)

    } else if (compare_to == "2019 Federal Election") {
      # Get 2016 SA1s to 2018 CEDs allocation table
      ced_2018 <- get_allocation_table(2018, "CED")

      # Return 2016 SA1 -> 2018 CED
      return(ced_2018)
    }

    sa1_2021 <- get_correspondence("SA1", 2016, 2021, process=TRUE)

    if (compare_to == "2021 Census") {
      # Return SA1 2016 -> SA1 2021
      return(sa1_2021)

    } else if (compare_to == "2021 Postcodes") {
      # Get 2021 MBs to 2021 POAs allocation table
      poa_2021 <- get_allocation_table(2021, "POA")

      # Combine 2021 SA1 -> 2021 POA allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_2021, poa_2021, by = "SA1_CODE_2021", all = TRUE)

      # Return CD_2006 -> SA1 2011 -> 2016 SA1 -> 2016 POA
      return(combined_df)

    } else if (compare_to %in% c("2022 Federal Election", "2023 Referendum")) {
      # Get 2021 MBs to 2021 CEDs allocation table
      ced_2021 <- get_allocation_table(2021, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_2021, ced_2021, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "Vic_WA", sa1_2021)


    } else if (compare_to == "2025 Federal Election") {
      # Get 2021 MBs to 2024 CEDs allocation table
      ced_2024 <- get_allocation_table(2024, "CED")

      # Combine 2021 SA1 -> 2021 CED allocation table to 2011 SA1 -> 2021 SA1 correspondence table by 2021 SA1
      combined_df <- merge(sa1_2021, ced_2024, by = "SA1_CODE_2021", all = TRUE)

      # Get supplementatry AEC data
      combined_df <- apply_redistribution_adjustments(combined_df, "NT")
    }

  }
}