# 01. Candidates & seats: National list of candidates

# Get data
df <- get_aec_data(file_name = "Senators elected",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate")


# save to .rds
usethis::use_data(national_list_of_candidates, overwrite = TRUE)


