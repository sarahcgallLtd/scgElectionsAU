df <- get_aec_data(
  file_name = "First preferences by state by vote type",
  #date_range = list(from = "2004-01-01", to = "2025-01-01"),
  category = "Senate"
)

national_list_of_candidates <- suppressMessages(
  get_aec_data(file_name = "National list of candidates",
  date_range = list(from = "2024-04-13", to = "2024-06-13"),
  type = c("By-Election")
)



rmarkdown::render("C:/Users/SarahGall/Programming/PyCharm/Projects/Packages/scgElectionsAU/vignettes/articles/aec-raw-data.rmd")
