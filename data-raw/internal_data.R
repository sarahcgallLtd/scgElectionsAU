# Internal data
info <- readr::read_csv("data-raw/info.csv")
info$aec_reference <- as.character(info$aec_reference)
info$event <- as.character(info$event)

# ===
aec_elections_index <- readr::read_csv("data-raw/aec-elections-index.csv")

# ===
abs_boundary_index <- readr::read_csv("data-raw/abs-boundary-index.csv")

# ===
aec_disclosure_index <- readr::read_csv("data-raw/aec-disclosure-index.csv")

# ===
name_conversions <- readr::read_csv("data-raw/name_conversions.csv")

# ===
# Get all unprocessed polling place datasets
data <- get_election_data(file_name = "Polling places",
                          date_range = list(from = "2004-01-01", to = "2026-01-01"),
                          type = c("Federal Election",
                                   "Referendum",
                                   "By-Election"),
                          category = "General",
                          process = FALSE
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

# Make unique
coords <- unique(coords)

# Filter out NAs
coords <- na.omit(coords)

# Save to internal data
# sysdata_filenames <- load("R/sysdata.rda")
save(info, aec_elections_index, aec_disclosure_index, abs_boundary_index, name_conversions, coords,
     file = "R/sysdata.rda", compress = "xz")

# Save to external data
abs_census_tables <- read.csv("data-raw/abs-census-tables.csv", stringsAsFactors = FALSE)

usethis::use_data(abs_census_tables, overwrite = TRUE)

devtools::load_all()
