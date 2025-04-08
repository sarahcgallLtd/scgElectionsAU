df <- get_aec_data("First preferences by candidate by polling place")


df <- get_aec_data("Distribution of preferences by polling place")


df <- get_aec_data("Two candidate preferred flow of preferences by polling place")


df <- get_aec_data("Party representation",
                   #  date_range = list(from = "2004-01-01", to = "2023-01-01"),
                   process = TRUE)

df <- get_aec_data("Votes by polling place",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Declaration votes issued by state",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Declaration votes issued by division",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Declaration votes received by state",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Declaration votes received by division",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Enrolment by state",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Enrolment by division",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Informal votes by state",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Turnout by state",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Turnout by division",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Informal votes by division",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Votes by state",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Votes by division",
                   type = "Referendum",
                   category = "Referendum"
)

df <- get_aec_data("Polling places",
                   type = "Referendum",
                   category = "General"
)

df <- get_aec_data("Pre-poll votes",
                   type = "Referendum",
                   category = "Statistics"
)

df <- get_aec_data("Votes by SA1",
                   type = "Referendum",
                   category = "Statistics"
)

df <- get_aec_data("Overseas",
                   type = "Referendum",
                   category = "Statistics"
)


df <- get_aec_data(
  file_name = "First preferences by state by vote type",
  #date_range = list(from = "2004-01-01", to = "2025-01-01"),
  category = "Senate"
)

