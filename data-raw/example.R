# This file is as an example only for creating package data

# For more information go to: https://r-pkgs.org/data.html#sec-documenting-data
# ======================================================================================================================
# EXAMPLE 1: Data that is exported by the package to use as a practice

# read SPSS file and save it in a data frame called "df"
survey <- haven::read_sav("data-raw/other/BES2019_W25_v25.0.sav")

# Limit size to n=5000 and number of variables
survey <- survey[1:5000, c(1, 4:14, 23:35, 59:60, 73:79, 522:525, 527, 531:553, 563, 568:568, 570)]

# save to .rds
usethis::use_data(survey, overwrite = TRUE)

# ======================================================================================================================
# EXAMPLE 2: Data that is used internally by functions

# Read csv
colours <- utils::read.csv("data-raw/colours.csv", encoding = "UTF-8")
colours <- dplyr::rename(colours, palette = X.U.FEFF.palette)

# save to .rds
usethis::use_data(colours, internal = TRUE, overwrite = TRUE)

# for any future internal additions, use the following to save to systdata.rda
# sysdata_filenames <- load("R/sysdata.rda")
# save(list = c(sysdata_filenames, "df"), file = "R/sysdata.rda")

# For more information go to: https://r-pkgs.org/data.html#sec-data-state