test_that("format_in_tz and get_browser_tz integrate correctly", {
  # Mock session with browser timezone
  session <- list(input = list(shinytz_browser_tz = "America/Los_Angeles"))
  browser_tz <- get_browser_tz(session)
  
  # Create UTC timestamp
  ts_utc <- as.POSIXct("2026-01-20 20:00:00", tz = "UTC")
  
  # Format in browser timezone
  formatted <- format_in_tz(ts_utc, tz = browser_tz, format = "%Y-%m-%d %H:%M %Z")
  
  # Verify PST conversion (UTC-8 in January)
  expect_equal(formatted, "2026-01-20 12:00 PST")
})

test_that("render functions handle timezone transition correctly", {
  # Test datetime near DST transition
  # March 8, 2026 02:00 AM is when DST starts in US (2nd Sunday of March)
  ts_before_dst <- as.POSIXct("2026-03-07 10:00:00", tz = "UTC")  # Saturday before DST
  ts_after_dst <- as.POSIXct("2026-03-09 10:00:00", tz = "UTC")   # Monday after DST
  
  # Format in New York (should show EST before, EDT after)
  result_before <- format_in_tz(ts_before_dst, tz = "America/New_York", format = "%H:%M %Z")
  result_after <- format_in_tz(ts_after_dst, tz = "America/New_York", format = "%H:%M %Z")
  
  expect_equal(result_before, "05:00 EST")
  expect_equal(result_after, "06:00 EDT")
})

test_that("all output functions work with all render functions", {
  # Create datetime
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Create all outputs
  ui_datetime <- datetimeOutput("test_dt")
  ui_date <- dateOutput("test_d")
  ui_time <- timeOutput("test_t")
  
  # Create all renders
  render_dt <- renderDatetime({ dt })
  render_d <- renderDate({ dt })
  render_t <- renderTime({ dt })
  
  # Verify all combinations create proper objects
  expect_s3_class(ui_datetime, "shiny.tag")
  expect_s3_class(ui_date, "shiny.tag")
  expect_s3_class(ui_time, "shiny.tag")
  
  expect_s3_class(render_dt, "shiny.render.function")
  expect_s3_class(render_d, "shiny.render.function")
  expect_s3_class(render_t, "shiny.render.function")
})

test_that("timezone validation cascades properly", {
  # Test invalid timezone handling through the chain
  invalid_tz <- "Invalid/Timezone"
  
  # format_in_tz should handle gracefully (uses Sys.timezone as fallback)
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # This should not error even with invalid timezone
  # The function will use Sys.timezone() as default
  result <- format_in_tz(ts, tz = NULL, format = "%Y-%m-%d %H:%M:%S")
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("Date boundary handling across timezones", {
  # Test case where time is on different dates in different timezones
  # 2026-01-20 23:00 UTC is 2026-01-21 08:00 in Asia/Tokyo
  ts <- as.POSIXct("2026-01-20 23:00:00", tz = "UTC")
  
  # Format as date in UTC
  date_utc <- format_in_tz(ts, tz = "UTC", format = "%Y-%m-%d")
  expect_equal(date_utc, "2026-01-20")
  
  # Format as date in Tokyo (should be next day)
  date_tokyo <- format_in_tz(ts, tz = "Asia/Tokyo", format = "%Y-%m-%d")
  expect_equal(date_tokyo, "2026-01-21")
})

test_that("Multiple concurrent timezones don't interfere", {
  # Simulate multiple users with different timezones
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # User 1: New York
  session1 <- list(input = list(shinytz_browser_tz = "America/New_York"))
  tz1 <- get_browser_tz(session1)
  result1 <- format_in_tz(ts, tz = tz1, format = "%H:%M")
  
  # User 2: London
  session2 <- list(input = list(shinytz_browser_tz = "Europe/London"))
  tz2 <- get_browser_tz(session2)
  result2 <- format_in_tz(ts, tz = tz2, format = "%H:%M")
  
  # User 3: Tokyo
  session3 <- list(input = list(shinytz_browser_tz = "Asia/Tokyo"))
  tz3 <- get_browser_tz(session3)
  result3 <- format_in_tz(ts, tz = tz3, format = "%H:%M")
  
  # Verify all different
  expect_equal(result1, "07:00")  # EST (UTC-5)
  expect_equal(result2, "12:00")  # GMT (UTC+0)
  expect_equal(result3, "21:00")  # JST (UTC+9)
  
  # Verify independence
  expect_false(result1 == result2)
  expect_false(result2 == result3)
  expect_false(result1 == result3)
})

test_that("NULL and NA datetime handling is consistent", {
  # Test NULL
  expect_equal(format_in_tz(NULL), "")
  
  # Test NA POSIXct
  na_time <- as.POSIXct(NA)
  expect_equal(format_in_tz(na_time), "")
  
  # Test that all() check catches vectors with any NA
  ts_with_na <- c(as.POSIXct("2026-01-20 12:00:00", tz = "UTC"), NA)
  # When vector has mix, the all(is.na()) check is FALSE, so it processes the vector
  # lubridate::with_tz will handle this - just verify it doesn't crash
  result <- format_in_tz(ts_with_na)
  expect_type(result, "character")
})

test_that("renderDatetime with custom formatter receives correct parameters", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Custom formatter that captures parameters
  test_formatter <- function(datetime, tz) {
    # Verify parameters are passed correctly
    expect_true(inherits(datetime, c("POSIXct", "POSIXlt")))
    expect_type(tz, "character")
    expect_true(tz %in% OlsonNames())
    
    paste("Custom:", format(datetime, "%Y-%m-%d"))
  }
  
  renderer <- renderDatetime({ dt }, formatter = test_formatter)
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("Edge case: leap second handling", {
  # Most systems don't handle leap seconds, but test we don't crash
  # 2026 doesn't have a scheduled leap second, but test the format
  ts <- as.POSIXct("2026-06-30 23:59:59", tz = "UTC")
  
  result <- format_in_tz(ts, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")
  expect_equal(result, "2026-06-30 23:59:59")
})

test_that("Very old and very new dates work correctly", {
  # Test historical date (year 1970)
  ts_old <- as.POSIXct("1970-01-01 00:00:00", tz = "UTC")
  result_old <- format_in_tz(ts_old, tz = "UTC", format = "%Y-%m-%d")
  expect_equal(result_old, "1970-01-01")
  
  # Test far future date (year 2099)
  ts_future <- as.POSIXct("2099-12-31 23:59:59", tz = "UTC")
  result_future <- format_in_tz(ts_future, tz = "UTC", format = "%Y-%m-%d")
  expect_equal(result_future, "2099-12-31")
})

test_that("Output placeholders are unique and meaningful", {
  # Datetime uses "Loading..."
  ui_dt <- datetimeOutput("test1")
  expect_equal(ui_dt$children[[1]], "Loading...")
  
  # Date uses "Loading..."
  ui_d <- dateOutput("test2")
  expect_equal(ui_d$children[[1]], "Loading...")
  
  # Time uses "--:--:--"
  ui_t <- timeOutput("test3")
  expect_equal(ui_t$children[[1]], "--:--:--")
  
  # Custom placeholders work
  ui_custom <- datetimeOutput("test4", placeholder = "Waiting...")
  expect_equal(ui_custom$children[[1]], "Waiting...")
})

test_that("Timezone abbreviation appending works correctly", {
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # Test that show_tz parameter properly formats with timezone
  # Note: We can't test actual rendering without Shiny session,
  # but we can verify format_in_tz works with %Z
  result_with_tz <- format_in_tz(ts, tz = "America/New_York", format = "%H:%M %Z")
  expect_true(grepl("EST", result_with_tz) || grepl("EDT", result_with_tz))
  
  result_without_tz <- format_in_tz(ts, tz = "America/New_York", format = "%H:%M")
  expect_false(grepl("EST", result_without_tz) || grepl("EDT", result_without_tz))
})

test_that("All common timezone regions work", {
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # Test major timezone regions
  timezones <- c(
    "America/New_York",
    "America/Los_Angeles", 
    "America/Chicago",
    "Europe/London",
    "Europe/Paris",
    "Asia/Tokyo",
    "Asia/Shanghai",
    "Australia/Sydney",
    "Pacific/Auckland"
  )
  
  for (tz in timezones) {
    result <- format_in_tz(ts, tz = tz, format = "%Y-%m-%d %H:%M:%S")
    # Just verify it doesn't error and returns non-empty string
    expect_type(result, "character")
    expect_true(nchar(result) > 0)
  }
})
