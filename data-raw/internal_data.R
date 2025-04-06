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

# ===
# for any future internal additions, use the following to save to systdata.rda
name_conversions <- readr::read_csv("data-raw/name_conversions.csv")

sysdata_filenames <- load("R/sysdata.rda")
save(list = c(sysdata_filenames, "name_conversions"), file = "R/sysdata.rda")

# ===
# Get all unprocessed polling place datasets
data <- get_aec_data(file_name = "Polling places",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

# Make any coordinates listed as 0,0, NAs
data$Latitude1 <- ifelse(data$Latitude == 0, NA, data$Latitude)
data$Longitude1 <- ifelse(data$Longitude == 0, NA, data$Longitude)

# Create reference dataframe with non-NA coordinates
ref <- data[!is.na(data$Latitude1) & !is.na(data$Longitude1), c("PollingPlaceID", "Latitude", "Longitude")]
ref <- unique(ref)

# Fill in missing Latitude and Longitude values
data$Latitude1[is.na(data$Latitude1)] <- ref$Latitude[match(data$PollingPlaceID[is.na(data$Latitude1)], ref$PollingPlaceID)]
data$Longitude1[is.na(data$Longitude1)] <- ref$Longitude[match(data$PollingPlaceID[is.na(data$Longitude1)], ref$PollingPlaceID)]

# Extract required columns
coords <- data[, names(data) %in% c("PollingPlaceID", "Latitude", "Longitude")]

# Save to internal data
sysdata_filenames <- load("R/sysdata.rda")
save(list = c(sysdata_filenames, "coords"), file = "R/sysdata.rda")

# For more information go to: https://r-pkgs.org/data.html#sec-data-state