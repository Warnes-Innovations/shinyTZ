# shinyTZ 0.2.0

CRAN preparation release — API completion, bug fixes, CI/CD, and documentation.

## Breaking Changes

- `renderTime()` signature expanded: added `formatter` and `locale` parameters for
  consistency with `renderDatetime()` and `renderDate()`. Existing code using
  positional arguments for `tz` or `show_tz` must be updated to use named arguments.

## New Features

- `renderDate()` now accepts a `formatter` parameter (custom formatter function),
  consistent with `renderDatetime()`.
- `renderTime()` now accepts `formatter` and `locale` parameters, consistent with
  `renderDatetime()` and `renderDate()`.
- `.onLoad()` now automatically registers the `inst/www` resource path so users do
  not need to call `shiny::addResourcePath()` manually before `useShinyTZ()`.

## Bug Fixes

- Fixed undefined `%||%` operator (now defined internally for R < 4.4.0 compatibility).
- Removed duplicate exported function definitions that could cause issues on
  certain R versions.
- Fixed `NAMESPACE` to include all required `importFrom` declarations.
- Fixed `URL` and `BugReports` fields in DESCRIPTION (now point to correct repository).

## Infrastructure

- Added GitHub Actions workflows: R-CMD-check, test-coverage, pkgdown.
- Added `Config/testthat/edition: 3` to DESCRIPTION.
- Removed `LazyData: true` (no data files in package).
- Removed unused `DBI` and `dplyr` from Suggests.
- Added `shinytest2` to Suggests for UI integration tests.
- Added vignettes: "Getting Started" and "Advanced Usage".
- Added `cran-comments.md` for CRAN submission tracking.

---

# shinyTZ 0.1.2

- Added `inline` parameter to all output functions (`datetimeOutput()`,
  `dateOutput()`, `timeOutput()`) enabling use in `inline = TRUE` or
  `inline = FALSE` modes.
- Added `container` parameter to all output functions allowing custom HTML
  container elements.

---

# shinyTZ 0.1.1

- Added `tz_display` parameter to `datetimeOutput()` and `timeOutput()`.
- Added `placeholder` parameter to all output functions.
- Improved JavaScript timezone detection: added UTC offset and locale detection.

---

# shinyTZ 0.1.0

Initial development release of timezone-aware Shiny components.

## Features

- Automatic browser timezone detection via JavaScript
- Drop-in replacements for Shiny's text outputs:
  - `renderDatetime()` / `datetimeOutput()` - Full datetime rendering
  - `renderDate()` / `dateOutput()` - Date-only rendering
  - `renderTime()` / `timeOutput()` - Time-only rendering
- Utility functions:
  - `get_browser_tz()` - Retrieve detected browser timezone
  - `format_in_tz()` - Format datetime in specific timezone
- Graceful fallback to server timezone when JavaScript unavailable
- Support for custom format strings (strftime syntax)
- Support for custom formatter functions for advanced logic
- Optional timezone abbreviation display via `show_tz` parameter
- Multi-layer validation with inline error display
- Comprehensive unit tests for timezone conversion
