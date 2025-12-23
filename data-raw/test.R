# 2013 Federal Election
### To Census
df <- prepare_boundaries("2013 Federal Election", "2011 Census")
df1 <- prepare_boundaries("2013 Federal Election", "2016 Census")
df2 <- prepare_boundaries("2013 Federal Election", "2021 Census")

### To Postcodes


### To Federal Elections & Referendums

df <- prepare_boundaries("2013 Federal Election", "2011 Postcodes")
df <- prepare_boundaries("2013 Federal Election", "2013 Federal Election")




df <- get_election_data("Overseas", category = "Statistics")


# Prepare results function test
df <- prepare_results(dataset = "FP", level = "SA1", split_by_type = FALSE)
df1 <- prepare_results(dataset = "TCP", level = "SA1", split_by_type = FALSE)
df <- prepare_results(dataset = "Votes", event="2023 Referendum",
                      level = "Division", split_by_type = TRUE)
# level = c("SA1", "PP", "Division", "CED", "POA", "State"),
# dataset = c("FP", "TCP", "TPP", "DistPref", "TCPFlowPref", "TPPFlowPref", "Votes")
