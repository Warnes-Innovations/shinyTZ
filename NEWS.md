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

## Design Decisions

See [inst/docs/design-document.md](inst/docs/design-document.md) for complete architectural design including:

- POSIXct/POSIXlt for internal representation
- Client-side rendering as PRIMARY approach
- Three separate functions (renderDatetime, renderDate, renderTime)
- Format flexibility (format strings + custom formatters)
- Timezone override support
- Multi-layer validation strategy
- Complete testing requirements

## Package Structure

- `R/datetime-renders.R` - Render functions
- `R/datetime-outputs.R` - UI output functions
- `R/timezone-utils.R` - Utility functions
- `R/zzz.R` - Package initialization (.onLoad)
- `inst/www/shinytz.js` - Browser timezone detection
- `tests/testthat/` - Unit tests

## Known Limitations

- Requires modern browser with `Intl.DateTimeFormat()` support (IE 11+)
- Server-side rendering used for custom format strings (minor performance impact)
- Locale integration not yet implemented (reserved for future enhancement)

## Future Enhancements

See design document for planned Phase 2 and Phase 3 features:

- Locale-aware formatting
- Relative time rendering ("3 minutes ago")
- Duration formatting
- Timezone-aware calendar widgets
- Multi-timezone comparison widget
