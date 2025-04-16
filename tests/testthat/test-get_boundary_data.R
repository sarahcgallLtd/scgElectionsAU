test_that("get_boundary_data validates input parameters correctly", {
  # Test invalid ref_date
  expect_error(
    get_boundary_data(ref_date = 2010, level = "CED", type = "allocation"),
    "ref_date must be a number between 2011 and 2024"
  )
  expect_error(
    get_boundary_data(ref_date = 2025, level = "CED", type = "allocation"),
    "ref_date must be a number between 2011 and 2024"
  )
  expect_error(
    get_boundary_data(ref_date = "2021", level = "CED", type = "allocation"),
    "ref_date must be a number between 2011 and 2024"
  )

  # Test invalid level
  expect_error(
    get_boundary_data(ref_date = 2021, level = "INVALID", type = "allocation"),
    "arg.*should be one of.*CED.*SA1.*MB.*POA"
  )

  # Test invalid type
  expect_error(
    get_boundary_data(ref_date = 2021, level = "CED", type = "INVALID"),
    "arg.*should be one of.*allocation.*correspondence"
  )
})


test_that("get_boundary_data downloads and returns data correctly", {
  # Test with a known valid combination (e.g., 2021 CED allocation)
  expect_s3_class(
    get_boundary_data(ref_date = 2021, level = "CED", type = "allocation"),
    "data.frame"
  )
})
