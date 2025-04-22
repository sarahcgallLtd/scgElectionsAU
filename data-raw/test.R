df <- get_results(dataset = "Votes", event = "2023 Referendum")
df1 <- get_election_data(
  file_name = "Votes by polling place",
  date_range = list(from = "2023-01-01", to = "2024-01-01"),
  type = "Referendum",
  category = "Referendum"
)
sa1 <- get_election_data(file_name = "Votes by SA1",
                         date_range = list(from = "2023-01-01", to = "2024-01-01"),
                         type = "Referendum",
                         category = "Statistics")
df2 <- get_election_data(file_name = "Informal votes by division",
                         date_range = list(from = "2023-01-01", to = "2024-01-01"),
                         type = "Referendum",
                         category = "Referendum")

df <- get_boundary_data(2016, "MB", "correspondence")

cd06to11sa1 <- get_boundary_data(2011, "SA1", "correspondence")
sa111to16 <- get_boundary_data(2016, "SA1", "correspondence")

# Prepare boundary data
if (boundary %in% c("latest CED","2021 CED") & event %in% c("2023 Referendum", "2022 Federal Election", "2019 Federal Election")) {
  year <- ifelse("latest CED", 2024, 2021)

  # Step 1: Create a 2021 SA1 to 2021/24 CED file
  # Explanation:  As the 2021 boundaries use MBs to CED, we need to convert MBs to SA1s to CEDs.
  #               We therefore start by getting the 2021 MB allocation file, which contains the MB to SA1 information
  #               and the 2021/24 CED allocation file, while contains the MB to CED information.
  mb21 <- get_boundary_data(2021, "MB")
  goalCED <- get_boundary_data(year, "CED")
  #               We then combine the two files by `MB_CODE_2021`, remove the MB information and extract unique rows
  #               leaving the SA1 to CED information.
  sa1GoalCED <- merge(mb21[, c("MB_CODE_2021", "SA1_CODE_2021")],
                    goalCED[, c("MB_CODE_2021", paste0("CED_CODE_", year), paste0("CED_NAME_", year))], by = "MB_CODE_2021")
  sa1GoalCED <- unique(sa1GoalCED[, c("SA1_CODE_2021", paste0("CED_CODE_", year), paste0("CED_NAME_", year))])

  # Step 2: Create a 2016 SA1 to 2021/24 CED file
  # Explanation:  We first retrieve the 2016 SA1 to 2021 SA1 correspondence tables.
  sa116to21 <- get_boundary_data(2021, "SA1", "correspondence")
  #               Next we need to match the correspondence from 2016 to 2021
  sa116to24ced <- merge(sa116to21[, c("SA1_MAINCODE_2016", "SA1_CODE_2021", "RATIO_FROM_TO")], sa1GoalCED, by = "SA1_CODE_2021")
}

refCED <- get_boundary_data(2016, "SA1")
# Now, we can merge the sa1 AEC data to the sa1 abs data


# rmarkdown::render("C:/Users/SarahGall/Programming/PyCharm/Projects/Packages/scgElectionsAU/vignettes/articles/aec-raw-data.rmd")
