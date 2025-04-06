# Internal data
info <- readr::read_csv("data-raw/info.csv")
info$aec_reference <- as.character(info$aec_reference)
info$event <- as.character(info$event)

# save to .rds
usethis::use_data(info, internal = TRUE, overwrite = TRUE)

# for any future internal additions, use the following to save to systdata.rda
aec_names_fed <- readr::read_csv("data-raw/aec-fed-elections.csv")

sysdata_filenames <- load("R/sysdata.rda")
save(list = c(sysdata_filenames, "aec_names_fed"), file = "R/sysdata.rda")

# for any future internal additions, use the following to save to systdata.rda
name_conversions <- readr::read_csv("data-raw/name_conversions.csv")

sysdata_filenames <- load("R/sysdata.rda")
save(list = c(sysdata_filenames, "name_conversions"), file = "R/sysdata.rda")

# For more information go to: https://r-pkgs.org/data.html#sec-data-state