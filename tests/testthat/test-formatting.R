test_that("format_in_tz handles timezone conversion correctly", {
  # Create known timestamp (2026-01-20 12:00:00 UTC)
  ts_utc <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # Format in New York (EST, UTC-5)
  formatted_ny <- format_in_tz(ts_utc, tz = "America/New_York", 
                               format = "%Y-%m-%d %H:%M %Z")
  expect_equal(formatted_ny, "2026-01-20 07:00 EST")
  
  # Format in Tokyo (JST, UTC+9)
  formatted_jp <- format_in_tz(ts_utc, tz = "Asia/Tokyo",
                               format = "%Y-%m-%d %H:%M %Z")
  expect_equal(formatted_jp, "2026-01-20 21:00 JST")
})

test_that("format_in_tz handles NULL gracefully", {
  expect_equal(format_in_tz(NULL), "")
  expect_equal(format_in_tz(as.POSIXct(NA)), "")
})

test_that("format_in_tz handles multiple timezones", {
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  tz_tests <- list(
    list(tz = "America/New_York", expected = "07:00 EST"),
    list(tz = "Europe/London",    expected = "12:00 GMT"),
    list(tz = "Asia/Tokyo",       expected = "21:00 JST")
  )
  
  for (test in tz_tests) {
    result <- format_in_tz(ts, tz = test$tz, format = "%H:%M %Z")
    expect_equal(result, test$expected)
  }
})
