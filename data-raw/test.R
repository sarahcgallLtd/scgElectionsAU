df <- get_aec_data(
  file_name = "First preferences by state by vote type",
  #date_range = list(from = "2004-01-01", to = "2025-01-01"),
  category = "Senate"
)

sa1 <- get_election_data(file_name = "Votes by SA1",
                         date_range = list(from = "2013-01-01", to = "2014-01-01"),
                         category = "Statistics")


# rmarkdown::render("C:/Users/SarahGall/Programming/PyCharm/Projects/Packages/scgElectionsAU/vignettes/articles/aec-raw-data.rmd")
