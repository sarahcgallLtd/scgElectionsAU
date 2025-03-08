# 01. Candidates & seats: National list of candidates

# Get data
df <- get_aec_data(file_name = "Nominations by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # and House
)

df <- get_aec_data(file_name = "Nominations by division", # by House only and from 2011 only
                   date_range = list(from = "2011-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Nominations by gender",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # and House
)

# ISSUE! Senate is fine House has an issue
df <- get_aec_data(file_name = "Party representation",
                   date_range = list(from = "2004-01-01", to = "2005-01-01"),
                  # category = "Senate" # and House
)

df <- get_aec_data(file_name = "Seats that changed hands",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"), # House only
)

df <- get_aec_data(file_name = "Seats decided on preferences",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"), # House only
)

df <- get_aec_data(file_name = "Seats decided on first preferences",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"), # House only
)

df <- get_aec_data(file_name = "Non-classic divisions",
                   date_range = list(from = "2010-01-01", to = "2025-01-01"), # House only
)

df <- get_aec_data(file_name = "Political parties",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                  category = "General"
)

df <- get_aec_data(file_name = "First preferences by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

# NEEDS PROCESSING: Declaration votes prior to 2016 and PrePoll Voters after 2016
df <- get_aec_data(file_name = "First preferences by state by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

# NEEDS PROCESSING: Remove SittingMember flag column
df <- get_aec_data(file_name = "First preferences by candidate by vote type",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)


df <- get_aec_data(file_name = "Two party preferred by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two party preferred by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two party preferred by division by vote type",
                   date_range = list(from = "2016-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two party preferred by polling place",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

# NEEDS PROCESSING
df <- get_aec_data(file_name = "Distribution of preferences by candidate by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two candidate preferred flow of preferences by candidate by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two party preferred flow of preferences by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two party preferred flow of preferences by state by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two candidate preferred flow of preferences by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Two candidate preferred flow of preferences by state by party",
                   date_range = list(from = "2004-01-01", to = "2025-01-01")
)

df <- get_aec_data(file_name = "Enrolment by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

df <- get_aec_data(file_name = "Enrolment by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

df <- get_aec_data(file_name = "Informal votes by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # House
)

df <- get_aec_data(file_name = "Informal votes by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   #category = "Senate" # House
)

df <- get_aec_data(file_name = "Turnout by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # House
)

df <- get_aec_data(file_name = "Turnout by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # House
)

df <- get_aec_data(file_name = "Votes by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # House
)

df <- get_aec_data(file_name = "Votes by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "Senate" # House
)

df <- get_aec_data(file_name = "Declaration votes issued by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

df <- get_aec_data(file_name = "Declaration votes issued by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

df <- get_aec_data(file_name = "Declaration votes received by state",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
)

df <- get_aec_data(file_name = "Declaration votes received by division",
                   date_range = list(from = "2004-01-01", to = "2025-01-01"),
                   category = "General"
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


