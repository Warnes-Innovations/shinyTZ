test_that("get_browser_tz returns fallback when no session", {
  expect_warning(
    result <- get_browser_tz(session = NULL, fallback = "America/New_York"),
    "No active Shiny session"
  )
  expect_equal(result, "America/New_York")
})

test_that("get_browser_tz validates timezone", {
  # Mock session with invalid timezone
  session <- list(input = list(shinytz_browser_tz = "Invalid/Timezone"))
  
  expect_warning(
    result <- get_browser_tz(session, fallback = "UTC"),
    "Invalid timezone"
  )
  expect_equal(result, "UTC")
})

test_that("get_browser_tz handles empty timezone", {
  session <- list(input = list(shinytz_browser_tz = ""))
  result <- get_browser_tz(session, fallback = "UTC")
  expect_equal(result, "UTC")
})

test_that("get_browser_tz returns valid timezone", {
  session <- list(input = list(shinytz_browser_tz = "America/New_York"))
  result <- get_browser_tz(session, fallback = "UTC")
  expect_equal(result, "America/New_York")
})
