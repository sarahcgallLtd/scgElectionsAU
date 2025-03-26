
# Get data
# NEEDS PROCESSING: Declaration votes prior to 2016 and PrePoll Voters after 2016
df <- get_aec_data(file_name = "First preferences by state by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

# NEEDS PROCESSING: Remove SittingMember flag column
df <- get_aec_data(file_name = "First preferences by candidate by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

# NEEDS PROCESSING
df <- get_aec_data(file_name = "Distribution of preferences by candidate by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)


# PARSING PROBLEMS
df <- get_aec_data(file_name = "Polling places",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

# PROCESS: Group and Ticket merge
df <- get_aec_data(file_name = "First preferences by state by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate"
)

# PROCESS: Group and Ticket merge + SittingMemberFl
df <- get_aec_data(file_name = "First preferences by division by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate"
)

# PROCESS: PrePoll and Declaration Votes
df <- get_aec_data(file_name = "First preferences by group by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate"
)

# PROCESS: PrePoll and Declaration Votes
df <- get_aec_data(file_name = "First preferences by state by group by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate"
)

# save to .rds
# usethis::use_data(national_list_of_candidates, overwrite = TRUE)


