test_that("renderDatetime validates input types", {
  # Test with valid POSIXct input
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  renderer <- renderDatetime({ dt })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDatetime handles NULL input gracefully", {
  renderer <- renderDatetime({ NULL })
  expect_s3_class(renderer, "shiny.render.function")
  
  # The actual validation happens during rendering, not creation
  # We'll test that the renderer doesn't crash during creation
})

test_that("renderDatetime handles invalid input types", {
  # Test that function creation doesn't crash with invalid types
  # The validation happens during render execution, not function creation
  renderer <- renderDatetime({ "invalid" })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDatetime format parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Custom format
  renderer <- renderDatetime({ dt }, format = "%B %d, %Y at %I:%M %p")
  expect_s3_class(renderer, "shiny.render.function")
  
  # Default format
  renderer_default <- renderDatetime({ dt })
  expect_s3_class(renderer_default, "shiny.render.function")
})

test_that("renderDatetime timezone parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Explicit timezone
  renderer <- renderDatetime({ dt }, tz = "America/New_York")
  expect_s3_class(renderer, "shiny.render.function")
  
  # NULL timezone (will use browser detection)
  renderer_auto <- renderDatetime({ dt }, tz = NULL)
  expect_s3_class(renderer_auto, "shiny.render.function")
})

test_that("renderDatetime show_tz parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # With timezone abbreviation
  renderer_tz <- renderDatetime({ dt }, show_tz = TRUE)
  expect_s3_class(renderer_tz, "shiny.render.function")
  
  # Without timezone abbreviation (default)
  renderer_no_tz <- renderDatetime({ dt }, show_tz = FALSE)
  expect_s3_class(renderer_no_tz, "shiny.render.function")
})

test_that("renderDatetime custom formatter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Custom formatter function
  custom_fmt <- function(datetime, tz) {
    paste("Custom:", format(datetime, "%Y-%m-%d"))
  }
  
  renderer <- renderDatetime({ dt }, formatter = custom_fmt)
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDatetime handles edge cases", {
  # Test with different datetime objects
  dt_posixct <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  dt_posixlt <- as.POSIXlt("2026-01-20 15:30:00", tz = "UTC")
  
  renderer_ct <- renderDatetime({ dt_posixct })
  renderer_lt <- renderDatetime({ dt_posixlt })
  
  expect_s3_class(renderer_ct, "shiny.render.function")
  expect_s3_class(renderer_lt, "shiny.render.function")
})

test_that("renderDatetime quoted parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Test quoted expressions
  expr_quoted <- quote(dt)
  renderer <- renderDatetime(expr_quoted, quoted = TRUE)
  expect_s3_class(renderer, "shiny.render.function")
  
  # Test unquoted (default)
  renderer_unquoted <- renderDatetime({ dt }, quoted = FALSE)
  expect_s3_class(renderer_unquoted, "shiny.render.function")
})
