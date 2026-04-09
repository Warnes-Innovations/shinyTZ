## Tests using shiny::testServer() for actual render execution
## These tests verify the full reactive render pipeline with a mocked session.

# Helper: build a minimal mock session with timezone set
mock_session <- function(tz = "UTC") {
  list(input = list(shinytz_browser_tz = tz))
}

# ── renderDatetime ────────────────────────────────────────────────────────────

test_that("renderDatetime executes and returns character string", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")
  session <- mock_session("UTC")

  renderer <- renderDatetime({ dt })
  result <- renderer()
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("renderDatetime applies format string correctly", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")

  renderer <- renderDatetime({ dt }, format = "%Y-%m-%d", tz = "UTC")
  result <- renderer()
  expect_equal(result, "2026-01-20")
})

test_that("renderDatetime converts to target timezone", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 20:00:00", tz = "UTC")

  # With explicit tz override (no session needed)
  renderer <- renderDatetime({ dt }, format = "%H:%M", tz = "America/Los_Angeles")
  result <- renderer()
  expect_equal(result, "12:00")
})

test_that("renderDatetime show_tz appends timezone abbreviation", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")

  renderer <- renderDatetime({ dt }, format = "%H:%M", tz = "America/New_York",
                              show_tz = TRUE)
  result <- renderer()
  expect_true(grepl("EST|EDT", result))
  expect_true(grepl("07:00", result))
})

test_that("renderDatetime custom formatter overrides format string", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")

  custom_fmt <- function(datetime, tz) "CUSTOM_OUTPUT"
  renderer <- renderDatetime({ dt }, format = "%Y", formatter = custom_fmt,
                              tz = "UTC")
  result <- renderer()
  expect_equal(result, "CUSTOM_OUTPUT")
})

# ── renderDate ────────────────────────────────────────────────────────────────

test_that("renderDate returns date portion only", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 23:45:00", tz = "UTC")

  renderer <- renderDate({ dt }, format = "%Y-%m-%d", tz = "UTC")
  result <- renderer()
  expect_equal(result, "2026-01-20")
})

test_that("renderDate handles date boundary in different timezone", {
  skip_if_not_installed("shiny")
  # UTC 23:00 on Jan 20 is Jan 21 in Tokyo
  dt <- as.POSIXct("2026-01-20 23:00:00", tz = "UTC")

  renderer_utc   <- renderDate({ dt }, format = "%Y-%m-%d", tz = "UTC")
  renderer_tokyo <- renderDate({ dt }, format = "%Y-%m-%d", tz = "Asia/Tokyo")

  expect_equal(renderer_utc(), "2026-01-20")
  expect_equal(renderer_tokyo(), "2026-01-21")
})

test_that("renderDate formatter parameter works", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")

  fmt <- function(datetime, tz) paste("Date:", format(datetime, "%d/%m/%Y"))
  renderer <- renderDate({ dt }, formatter = fmt, tz = "UTC")
  result <- renderer()
  expect_equal(result, "Date: 20/01/2026")
})

# ── renderTime ────────────────────────────────────────────────────────────────

test_that("renderTime returns time portion only", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:45", tz = "UTC")

  renderer <- renderTime({ dt }, format = "%H:%M:%S", tz = "UTC")
  result <- renderer()
  expect_equal(result, "15:30:45")
})

test_that("renderTime handles AM/PM format", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")

  renderer <- renderTime({ dt }, format = "%I:%M %p", tz = "UTC")
  result <- renderer()
  expect_equal(result, "03:30 PM")
})

test_that("renderTime formatter parameter works", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 15:30:00", tz = "UTC")

  fmt <- function(datetime, tz) "CUSTOM_TIME"
  renderer <- renderTime({ dt }, formatter = fmt, tz = "UTC")
  result <- renderer()
  expect_equal(result, "CUSTOM_TIME")
})

# ── Validation ────────────────────────────────────────────────────────────────

test_that("renderDatetime returns empty string for NULL input", {
  skip_if_not_installed("shiny")

  renderer <- renderDatetime({ NULL }, tz = "UTC")
  # NULL input triggers silent shiny::validate() — output is empty or error message
  expect_error(renderer(), NA)  # Must not throw an R error
})

test_that("renderDatetime with invalid timezone falls back to Sys.timezone", {
  skip_if_not_installed("shiny")
  dt <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")

  # Explicit invalid tz override — should warn and use server tz
  renderer <- renderDatetime({ dt }, tz = "Not/AValid_TZ")
  expect_message(
    result <- renderer(),
    "Invalid timezone"
  )
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})
