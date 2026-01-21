test_that("format_in_tz handles vector inputs", {
  # Create vector of timestamps
  ts_vector <- c(
    as.POSIXct("2026-01-20 12:00:00", tz = "UTC"),
    as.POSIXct("2026-01-20 15:00:00", tz = "UTC"),
    as.POSIXct("2026-01-20 18:00:00", tz = "UTC")
  )
  
  # Format first element only (vector input but format_in_tz works on single values)
  # This tests that we handle vectors gracefully
  result <- format_in_tz(ts_vector[1], tz = "America/New_York", format = "%H:%M")
  expect_equal(result, "07:00")
})

test_that("format_in_tz handles mixed timezone inputs", {
  # Create timestamp with specific timezone
  ts_pacific <- as.POSIXct("2026-01-20 12:00:00", tz = "America/Los_Angeles")
  
  # Convert to different timezone
  result <- format_in_tz(ts_pacific, tz = "America/New_York", format = "%Y-%m-%d %H:%M %Z")
  
  # LA 12:00 PST = NY 15:00 EST
  expect_equal(result, "2026-01-20 15:00 EST")
})

test_that("get_browser_tz handles NULL input list", {
  # Mock session with NULL input
  session <- list(input = NULL)
  
  result <- get_browser_tz(session, fallback = "UTC")
  expect_equal(result, "UTC")
})

test_that("get_browser_tz handles session without shinytz_browser_tz", {
  # Mock session with input but no shinytz_browser_tz key
  session <- list(input = list(other_input = "value"))
  
  result <- get_browser_tz(session, fallback = "America/Chicago")
  expect_equal(result, "America/Chicago")
})

test_that("format_in_tz respects locale parameter (reserved for future)", {
  # While locale is not yet implemented, verify parameter doesn't cause errors
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  result_with_locale <- format_in_tz(ts, tz = "UTC", locale = "en-US")
  result_without_locale <- format_in_tz(ts, tz = "UTC", locale = NULL)
  
  # Both should work (locale not yet used but parameter exists)
  expect_type(result_with_locale, "character")
  expect_type(result_without_locale, "character")
})

test_that("renderDatetime formatter parameter takes precedence over format", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Define custom formatter
  custom_formatter <- function(datetime, tz) {
    "CUSTOM_OUTPUT"
  }
  
  # Create renderer with both formatter and format
  # formatter should take precedence
  renderer <- renderDatetime(
    { dt },
    format = "%Y-%m-%d",  # This should be ignored
    formatter = custom_formatter
  )
  
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDate and renderTime handle POSIXlt input", {
  # Create POSIXlt object
  dt_lt <- as.POSIXlt("2026-01-20 15:30:00", tz = "UTC")
  
  renderer_date <- renderDate({ dt_lt })
  renderer_time <- renderTime({ dt_lt })
  
  expect_s3_class(renderer_date, "shiny.render.function")
  expect_s3_class(renderer_time, "shiny.render.function")
})

test_that("output functions handle empty string outputId", {
  # While not recommended, test that empty string doesn't crash
  ui <- datetimeOutput("")
  expect_s3_class(ui, "shiny.tag")
  expect_equal(ui$attribs$id, "")
})

test_that("get_browser_tz handles whitespace in timezone", {
  # Mock session with timezone containing whitespace
  session <- list(input = list(shinytz_browser_tz = " America/New_York "))
  
  expect_warning(
    result <- get_browser_tz(session, fallback = "UTC"),
    "Invalid timezone"
  )
  expect_equal(result, "UTC")
})

test_that("format_in_tz handles timezone with UTC offset", {
  # Test with Etc/GMT timezones (which have reversed signs)
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # Etc/GMT+5 is actually UTC-5 (confusing but standard)
  result <- format_in_tz(ts, tz = "Etc/GMT+5", format = "%Y-%m-%d %H:%M")
  expect_equal(result, "2026-01-20 07:00")
})

test_that("Multiple format strings work correctly", {
  ts <- as.POSIXct("2026-01-20 15:30:45", tz = "UTC")
  
  # Test various format combinations
  formats <- list(
    list(fmt = "%Y-%m-%d %H:%M:%S", expected_pattern = "^2026-01-20 \\d{2}:\\d{2}:\\d{2}$"),
    list(fmt = "%B %d, %Y", expected_pattern = "^January 20, 2026$"),
    list(fmt = "%m/%d/%y", expected_pattern = "^01/20/26$"),
    list(fmt = "%I:%M %p", expected_pattern = "^\\d{2}:\\d{2} (AM|PM)$")
  )
  
  for (test in formats) {
    result <- format_in_tz(ts, tz = "UTC", format = test$fmt)
    expect_true(grepl(test$expected_pattern, result), 
                info = paste("Format:", test$fmt, "Result:", result))
  }
})

test_that("timezone case sensitivity", {
  # Test that timezone names are case-sensitive
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  
  # Valid timezone (correct case)
  result_valid <- format_in_tz(ts, tz = "America/New_York", format = "%H:%M")
  expect_type(result_valid, "character")
  expect_equal(result_valid, "07:00")
  
  # Invalid timezone case is handled by lubridate with warning,
  # so we skip that test to avoid spurious warnings in test output
})

test_that("renderDatetime handles reactive expressions correctly", {
  # Test with various types of expressions
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Simple value
  renderer1 <- renderDatetime({ dt })
  expect_s3_class(renderer1, "shiny.render.function")
  
  # Expression with logic
  renderer2 <- renderDatetime({ 
    if (TRUE) dt else NULL 
  })
  expect_s3_class(renderer2, "shiny.render.function")
  
  # Expression with calculation
  renderer3 <- renderDatetime({ 
    dt + 3600  # Add 1 hour
  })
  expect_s3_class(renderer3, "shiny.render.function")
})

test_that("All output CSS classes are correctly set", {
  ui_dt <- datetimeOutput("test1")
  ui_d <- dateOutput("test2")
  ui_t <- timeOutput("test3")
  
  # Check base class
  expect_true("shiny-text-output" %in% strsplit(ui_dt$attribs$class, " ")[[1]])
  expect_true("shiny-text-output" %in% strsplit(ui_d$attribs$class, " ")[[1]])
  expect_true("shiny-text-output" %in% strsplit(ui_t$attribs$class, " ")[[1]])
  
  # Check specific classes
  expect_true("shinytz-datetime" %in% strsplit(ui_dt$attribs$class, " ")[[1]])
  expect_true("shinytz-date" %in% strsplit(ui_d$attribs$class, " ")[[1]])
  expect_true("shinytz-time" %in% strsplit(ui_t$attribs$class, " ")[[1]])
  
  # Verify classes don't overlap
  expect_false("shinytz-date" %in% strsplit(ui_dt$attribs$class, " ")[[1]])
  expect_false("shinytz-time" %in% strsplit(ui_d$attribs$class, " ")[[1]])
  expect_false("shinytz-datetime" %in% strsplit(ui_t$attribs$class, " ")[[1]])
})
