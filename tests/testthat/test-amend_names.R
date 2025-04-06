test_that("test mixed cases", {
  df <- data.frame(
    State = c("NEW south WALES", "VicTORIA", "tasMania", "Unknown"),
    value = 1:4
  )
  result <- amend_names(df, "State", "state_to_abbr")
  expect_equal(result$State[1], "NSW")

  df_abbr <- data.frame(
    State = c("nsw", "Vic", "Tas", "xyz"),
    value = 1:4
  )
  result <- amend_names(df_abbr, "State", "abbr_to_state")
  expect_equal(result$State[1], "New South Wales")
})
