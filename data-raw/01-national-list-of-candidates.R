# 01. Candidates & seats: National list of candidates

# import utils
source("data-raw/utils.R")
# filter required elections for data
info <- filter(info, type == "Federal Election")

# Get data
national_list_of_candidates <- get_aec_data("HouseCandidatesDownload")

# Amend 2004 data (Make `SittingMemberFl` = `HistoricElected`)
national_list_of_candidates <- dplyr::mutate(national_list_of_candidates,
                                             HistoricElected = ifelse(election == "2004" &
                                                                        is.na(SittingMemberFl) == FALSE,
                                                                      "Y", "N"))
# Remove `SittingMemberFl` column
national_list_of_candidates <- dplyr::select(national_list_of_candidates, -SittingMemberFl)

# save to .rds
usethis::use_data(national_list_of_candidates, overwrite = TRUE)


