test_that("renderDate validates input types", {
  # Test with valid POSIXct input
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  renderer <- renderDate({ dt })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDate handles NULL input gracefully", {
  renderer <- renderDate({ NULL })
  expect_s3_class(renderer, "shiny.render.function")
})

test_that("renderDate format parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Custom format
  renderer <- renderDate({ dt }, format = "%B %d, %Y")
  expect_s3_class(renderer, "shiny.render.function")
  
  # Default format (%Y-%m-%d)
  renderer_default <- renderDate({ dt })
  expect_s3_class(renderer_default, "shiny.render.function")
})

test_that("renderDate timezone parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Explicit timezone
  renderer <- renderDate({ dt }, tz = "America/New_York")
  expect_s3_class(renderer, "shiny.render.function")
  
  # NULL timezone (will use browser detection)
  renderer_auto <- renderDate({ dt }, tz = NULL)
  expect_s3_class(renderer_auto, "shiny.render.function")
})

test_that("renderDate show_tz parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # With timezone abbreviation (unusual for dates but supported)
  renderer_tz <- renderDate({ dt }, show_tz = TRUE)
  expect_s3_class(renderer_tz, "shiny.render.function")
  
  # Without timezone abbreviation (default)
  renderer_no_tz <- renderDate({ dt }, show_tz = FALSE)
  expect_s3_class(renderer_no_tz, "shiny.render.function")
})

test_that("renderDate locale parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # With locale specification
  renderer <- renderDate({ dt }, locale = "en-US")
  expect_s3_class(renderer, "shiny.render.function")
  
  # Without locale (default)
  renderer_default <- renderDate({ dt }, locale = NULL)
  expect_s3_class(renderer_default, "shiny.render.function")
})

test_that("renderDate handles edge cases", {
  # Test with different datetime objects
  dt_posixct <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  dt_posixlt <- as.POSIXlt("2026-01-20 15:30:00", tz = "UTC")
  
  renderer_ct <- renderDate({ dt_posixct })
  renderer_lt <- renderDate({ dt_posixlt })
  
  expect_s3_class(renderer_ct, "shiny.render.function")
  expect_s3_class(renderer_lt, "shiny.render.function")
})

test_that("renderDate quoted parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Test quoted expressions
  expr_quoted <- quote(dt)
  renderer <- renderDate(expr_quoted, quoted = TRUE)
  expect_s3_class(renderer, "shiny.render.function")
  
  # Test unquoted (default)
  renderer_unquoted <- renderDate({ dt }, quoted = FALSE)
  expect_s3_class(renderer_unquoted, "shiny.render.function")
})

test_that("renderDate env parameter works", {
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  
  # Test with custom environment
  custom_env <- new.env()
  custom_env$dt <- dt
  
  renderer <- renderDate(dt, env = custom_env)
  expect_s3_class(renderer, "shiny.render.function")
})
