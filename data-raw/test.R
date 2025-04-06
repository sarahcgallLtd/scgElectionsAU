df <- get_aec_data(file_name = "First preferences by division by vote type",
                   date_range = list(from = "2004-01-01", to = "2007-01-01"),
                   category = "Senate",
                   process = TRUE
)

df <- get_aec_data(file_name = "Pre-poll votes",
                   #date_range = list(from = "2010-01-01", to = "2022-01-01"),
                     category = "Statistics",
                   process = TRUE
)