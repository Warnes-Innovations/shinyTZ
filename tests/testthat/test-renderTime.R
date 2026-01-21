test_that("renderTime validates input types", {
  # Test with valid POSIXct input
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  renderer <- renderTime({ dt })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderTime handles NULL input gracefully", {
  renderer <- renderTime({ NULL })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderTime format parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # 12-hour format with AM/PM
  renderer_12h <- renderTime({ dt }, format = "%I:%M:%S %p")
  expect_s3_class(renderer_12h, "shiny.render.function")
  
  # Default 24-hour format
  renderer_default <- renderTime({ dt })
  expect_s3_class(renderer_default, "shiny.render.function")
  
  # Simple hour:minute format
  renderer_simple <- renderTime({ dt }, format = "%H:%M")
  expect_s3_class(renderer_simple, "shiny.render.function")
})

test_that("renderTime timezone parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Explicit timezone
  renderer <- renderTime({ dt }, tz = "America/New_York")
  expect_s3_class(renderer, "shiny.render.function")
  
  # NULL timezone (will use browser detection)
  renderer_auto <- renderTime({ dt }, tz = NULL)
  expect_s3_class(renderer_auto, "shiny.render.function")
})

test_that("renderTime show_tz parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # With timezone abbreviation
  renderer_tz <- renderTime({ dt }, show_tz = TRUE)
  expect_s3_class(renderer_tz, "shiny.render.function")
  
  # Without timezone abbreviation (default)
  renderer_no_tz <- renderTime({ dt }, show_tz = FALSE)
  expect_s3_class(renderer_no_tz, "shiny.render.function")
})

test_that("renderTime handles edge cases", {
  # Test with different datetime objects
  dt_posixct <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  dt_posixlt <- as.POSIXlt("2026-01-20 15:30:00", tz = "UTC")
  
  renderer_ct <- renderTime({ dt_posixct })
  renderer_lt <- renderTime({ dt_posixlt })
  
  expect_s3_class(renderer_ct, "shiny.render.function")
  expect_s3_class(renderer_lt, "shiny.render.function")
})

test_that("renderTime quoted parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Test quoted expressions
  expr_quoted <- quote(dt)
  renderer <- renderTime(expr_quoted, quoted = TRUE)
  expect_s3_class(renderer, "shiny.render.function")
  
  # Test unquoted (default)
  renderer_unquoted <- renderTime({ dt }, quoted = FALSE)
  expect_s3_class(renderer_unquoted, "shiny.render.function")
})

test_that("renderTime env parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Test with custom environment
  custom_env <- new.env()
  custom_env$dt <- dt
  
  renderer <- renderTime(dt, env = custom_env)
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderTime different time formats work", {
  dt <- as.POSIXct("2026-01-20 15:30:45", tz = "UTC")
  
  # Test various time formats
  formats <- list(
    "%H:%M:%S",           # 24-hour with seconds
    "%H:%M",              # 24-hour without seconds  
    "%I:%M:%S %p",        # 12-hour with seconds and AM/PM
    "%I:%M %p",           # 12-hour without seconds
    "%H:%M:%S %Z"         # 24-hour with timezone
  )
  
  for (fmt in formats) {
    renderer <- renderTime({ dt }, format = fmt)
    expect_s3_class(renderer, "shiny.render.function")
  }
})
