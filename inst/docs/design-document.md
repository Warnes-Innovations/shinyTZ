# shinyTZ: Timezone-Aware Shiny Components

**Version:** 0.1.0  
**Author:** Dr. Greg Warnes  
**Date:** January 20, 2026  
**Status:** Design Document

## Executive Summary

`shinyTZ` extends R Shiny to provide timezone-aware date and time rendering that automatically adapts to the user's browser timezone. The package eliminates the common problem of server-side timestamps being displayed in the wrong timezone for remote users, while maintaining the simplicity of Shiny's reactive programming model.

## Motivation

### Current Problem

Standard Shiny date/time rendering suffers from timezone ambiguity:

```r
# Server runs in US/Eastern, user browses from US/Pacific
output$timestamp <- renderText({
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Shows Eastern time!
})
```

Users see timestamps in the server's timezone, not their local timezone. Workarounds require:
- Hardcoded timezone conversions (non-portable)
- Manual JavaScript integration (complex, error-prone)
- Environment variable configuration (server-wide, not per-user)

### Solution

`shinyTZ` provides drop-in replacements for Shiny's text/UI outputs that automatically detect the browser timezone and render timestamps accordingly:

```r
# Automatically renders in user's local timezone
output$timestamp <- renderDatetime({
  Sys.time()  # Server timezone doesn't matter!
})
```

## Design Principles

1. **Zero Configuration**: Works out-of-the-box without setup
2. **Transparent**: Minimal changes to existing Shiny code
3. **Reactive**: Integrates seamlessly with Shiny's reactive model
4. **Fallback Safe**: Degrades gracefully if JavaScript unavailable
5. **Flexible**: Supports custom formatting and timezone overrides

## Design Decisions

This section documents the 10 key design decisions that shape shinyTZ's architecture and implementation.

### 1. POSIXct/POSIXlt for Internal Representation

**Decision**: Use R's native POSIXct/POSIXlt classes for all internal datetime handling.

**Rationale**:
- **Native R Integration**: Works seamlessly with existing R code and packages
- **Timezone Preservation**: POSIXct objects carry timezone attributes internally
- **Database Compatibility**: Most R database packages (DBI, RPostgres) return POSIXct for timestamp columns
- **Ecosystem Support**: lubridate, clock, and other time packages work with POSIXct

**Alternative Considered**: Using numeric timestamps (Unix epoch) or ISO8601 strings
- Rejected because it would require conversion at every boundary, losing R's native datetime benefits

### 2. Client-Side Rendering as PRIMARY Approach

**Decision**: Implement client-side rendering using browser's `Intl.DateTimeFormat()` as the **primary** approach, with server-side rendering available for custom formats.

**Rationale**:
- **Browser Capabilities**: Modern browsers have robust timezone and locale support
- **Reduced Server Load**: Formatting happens in the browser, not on server
- **Live Updates**: Client-side rendering enables high-frequency updates (e.g., live clocks) without server round-trips
- **Automatic Locale**: Browser automatically applies user's locale preferences
- **Flexibility**: Server-side rendering still available for custom format strings

**Implementation**:
- Primary: Send ISO8601 timestamp + format options to browser, render with `Intl.DateTimeFormat()`
- Fallback: Server-side rendering when custom format strings required or JavaScript disabled

**Alternative Considered**: Server-side only rendering
- Rejected because it misses benefits of browser's native timezone/locale support and requires reactive updates for live data

### 3. Three Separate Functions (renderDatetime, renderDate, renderTime)

**Decision**: Provide three distinct render functions instead of one multi-purpose function.

**Rationale**:
- **Clear Intent**: Function name indicates what will be displayed
- **Appropriate Defaults**: Each function has sensible defaults for its use case
  - `renderDatetime()`: "%Y-%m-%d %H:%M:%S"
  - `renderDate()`: "%Y-%m-%d"
  - `renderTime()`: "%H:%M:%S"
- **Simpler API**: No need to specify `type` parameter
- **Follows Shiny Conventions**: Similar to `dateInput()` vs `dateRangeInput()`

**Alternative Considered**: Single `renderTZ()` function with `type` parameter
- Rejected because it's less clear and requires extra parameter in every call

### 4. Format Flexibility (Format String + Custom Formatter)

**Decision**: Support both format strings (strftime syntax) AND optional custom formatter functions.

**Rationale**:
- **Familiar Syntax**: R users know strftime format codes (`"%Y-%m-%d %H:%M:%S"`)
- **Advanced Control**: Custom formatter functions for complex logic
- **Gradual Complexity**: Simple cases use strings, complex cases use functions

**API Design**:
```r
# Simple: format string
renderDatetime({Sys.time()}, format = "%B %d, %Y at %I:%M %p")

# Advanced: custom formatter function
renderDatetime({Sys.time()}, 
  formatter = function(dt, tz) {
    # Custom logic here
    if (hour(dt) < 12) paste(format(dt), "(Morning)")
    else paste(format(dt), "(Afternoon)")
  }
)
```

**Alternative Considered**: Format strings only
- Rejected because it limits flexibility for edge cases (conditional formatting, business logic)

### 5. Timezone Override Support

**Decision**: Allow explicit timezone override via `tz` parameter, defaulting to browser timezone.

**Rationale**:
- **Flexibility**: Support use cases where specific timezone needed (e.g., "Show all times in Eastern")
- **Testing**: Developers can test with known timezones
- **Multi-Timezone Apps**: Apps showing times in multiple zones (e.g., global operations dashboard)
- **Smart Default**: Browser timezone is automatic fallback

**Priority Order**:
1. Explicit `tz` parameter
2. Browser timezone (from JavaScript detection)
3. Server timezone (if JavaScript unavailable)

### 6. Utility Functions (get_browser_tz, format_in_tz)

**Decision**: Expose low-level utility functions for advanced users.

**Rationale**:
- **Composability**: Users can build custom solutions
- **Non-Shiny Use Cases**: `format_in_tz()` useful outside reactive context
- **Debugging**: `get_browser_tz()` helps diagnose timezone issues
- **Table Formatting**: Apply timezone conversion to entire dataframes

**Example Use Case**:
```r
# Format entire column in user's timezone
tasks <- reactive({
  df <- dbGetQuery(con, "SELECT * FROM tasks")
  user_tz <- get_browser_tz(session)
  df$start_time <- sapply(df$start_time, format_in_tz, tz = user_tz)
  df
})
```

### 7. Timezone Selection Widget

**Decision**: Provide `timezoneSelectInput()` for user timezone selection.

**Rationale**:
- **User Control**: Some users want to override automatic detection
- **Multi-Timezone Viewing**: Users may want to see times in different zones
- **Common Pattern**: Many apps need timezone selector

**Design**:
- Default: "auto" (browser detection)
- "common" mode: Subset of frequently-used timezones
- "all" mode: All IANA timezones
- Searchable dropdown for usability

### 8. Matched UI/Render Function Pairs

**Decision**: Every render function has a corresponding output function.

**Rationale**:
- **Follows Shiny Convention**: `renderPlot()` → `plotOutput()`, etc.
- **Semantic HTML**: Output functions add appropriate classes and structure
- **JavaScript Hooks**: Output functions can attach client-side behavior
- **Clear Pairing**: Easy to see which functions work together

**Pairing**:
- `renderDatetime()` ↔ `datetimeOutput()`
- `renderDate()` ↔ `dateOutput()`
- `renderTime()` ↔ `timeOutput()`

### 9. Validation Strategy with Multi-Layer Approach

**Decision**: Use Shiny's `validate()` and `need()` for inline error display, with multi-layer validation.

**Rationale**:
- **Shiny Standard**: Matches how Shiny's built-in render functions handle errors
- **Inline Display**: Errors shown in output element, not crash app
- **Silent on Success**: No console clutter when validation passes
- **Multi-Layer**: JavaScript validates timezone, R validates POSIXct, console logs warnings only

**Implementation Pattern** (from Shiny source code examination):
```r
renderDatetime <- function(expr, ...) {
  func <- installExprFunction(expr, ...)
  
  createRenderFunction(func, function(value, session, name, ...) {
    # Validation using Shiny's standard pattern
    validate(
      need(!is.null(value), ""),  # Silent validation (empty message)
      need(inherits(value, c("POSIXct", "POSIXlt")), 
           "renderDatetime requires POSIXct or POSIXlt datetime object")
    )
    
    # Multi-layer validation
    target_tz <- tz %||% get_browser_tz(session)
    
    # Validate timezone (log warning, don't stop)
    if (!target_tz %in% OlsonNames()) {
      message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
      target_tz <- Sys.timezone()
    }
    
    # Format and return
    format_in_tz(value, tz = target_tz, ...)
  }, ...)
}
```

**Layers**:
1. **JavaScript**: Validates browser timezone is in IANA database (logs to console if invalid)
2. **R Input Validation**: `validate(need())` for NULL/type checking (displays inline)
3. **Runtime Warnings**: `message()` for timezone validation issues (logs but continues)

**Confirmed by Shiny source code**: Examined `renderText()`, `renderPlot()`, and test files showing `validate()/need()` is the standard pattern for inline error display without crashing the app.

### 10. Comprehensive Testing

**Decision**: Require unit tests for all functions and integration tests for Shiny behavior.

**Rationale**:
- **Timezone Complexity**: Many edge cases (DST transitions, invalid zones, NULL handling)
- **Cross-Platform**: Different OS handle timezones differently
- **Regression Prevention**: Tests catch breaking changes early
- **Documentation**: Tests serve as executable examples

**Test Coverage Requirements**:
- Unit tests: All exported functions
- Edge cases: NULL, NA, invalid input handling
- Timezone conversion: Multiple timezones with known conversions
- Shiny integration: Browser timezone detection, reactive updates

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────┐
│                   Shiny App                         │
├─────────────────────────────────────────────────────┤
│  Server                    │  UI                    │
│  ─────────                 │  ──                    │
│  renderDatetime() ────────>│  datetimeOutput()      │
│  renderDate()     ────────>│  dateOutput()          │
│  renderTime()     ────────>│  timeOutput()          │
│                            │                        │
│  get_browser_tz() <────────│  [JavaScript]          │
│  format_in_tz()            │  Intl.DateTimeFormat() │
└────────────────────────────┴────────────────────────┘
                     │
                     ▼
              [Browser Timezone]
           Detected automatically
```

### Timezone Detection Flow

1. **Initial Page Load**: JavaScript detects browser timezone via `Intl.DateTimeFormat().resolvedOptions().timeZone`
2. **Reactive Input**: Timezone sent to server as `input$shinytz_browser_tz`
3. **Render Functions**: Use detected timezone for formatting
4. **Fallback**: If JavaScript disabled, falls back to server timezone

### Data Flow

**Primary Path (Client-Side Rendering):**
```
Server (UTC/Any TZ)           Network              Browser (User TZ)
─────────────────────────────────────────────────────────────────
POSIXct object
    │
    ▼
Convert to ISO8601 string ─────────────────────> Receive ISO string
+ format options                                 + format options
                                                        │
                                                        ▼
                                                Intl.DateTimeFormat()
                                                Parse + Format in user TZ
                                                        │
                                                        ▼
                                                Render in DOM
```

**Fallback Path (Server-Side Rendering):**
```
Server                        Network              Browser
─────────────────────────────────────────────────────────────────
POSIXct object
    │
    ▼
Get browser timezone
    │
    ▼
Convert to user timezone
    │
    ▼
Format with strftime ──────────────────────────> Receive formatted string
                                                        │
                                                        ▼
                                                Render in DOM
```

**Use client-side when**: Standard format options, high-frequency updates, locale-aware formatting  
**Use server-side when**: Custom format strings, complex formatting logic, JavaScript disabled

## API Design

### Core Output/Render Functions

#### `datetimeOutput()` / `renderDatetime()`

Full date and time rendering with timezone awareness.

**UI Function:**
```r
datetimeOutput(outputId, placeholder = "Loading...", tz_display = TRUE)
```

**Arguments:**
- `outputId`: Output variable name (character)
- `placeholder`: Text shown before reactive value available
- `tz_display`: Whether to show timezone abbreviation (e.g., "EST", "PST")

**Server Function:**
```r
renderDatetime(expr, format = "%Y-%m-%d %H:%M:%S", formatter = NULL, tz = NULL, locale = NULL, show_tz = FALSE)
```

**Arguments:**
- `expr`: Expression returning POSIXct or POSIXlt object
- `format`: Format string (strftime syntax or locale-specific preset)
- `formatter`: Optional custom formatter function `function(datetime, tz)` for advanced formatting logic
- `tz`: Override timezone (defaults to browser timezone)
- `locale`: BCP 47 locale code for formatting (e.g., "en-US", "de-DE")
- `show_tz`: Whether to append timezone abbreviation (e.g., "EST", "PST") to output (default: FALSE)

**Note**: If `formatter` is provided, it takes precedence over `format`.

**Example:**
```r
# UI
datetimeOutput("last_update")

# Server
output$last_update <- renderDatetime({
  Sys.time()  # Auto-formats to user's timezone
})

# Custom format string
output$timestamp <- renderDatetime({
  task_data$start_time
}, format = "%B %d, %Y at %I:%M %p")  # "January 20, 2026 at 03:45 PM"

# Show timezone abbreviation
output$timestamp_with_tz <- renderDatetime({
  task_data$start_time
}, format = "%Y-%m-%d %H:%M:%S", show_tz = TRUE)  # "2026-01-20 15:45:23 EST"

# Custom formatter function for complex logic
output$business_hours <- renderDatetime({
  task_data$start_time
}, formatter = function(dt, tz) {
  dt_tz <- lubridate::with_tz(dt, tz)
  hour <- lubridate::hour(dt_tz)
  
  base_format <- format(dt_tz, "%Y-%m-%d %I:%M %p")
  
  if (hour >= 9 && hour < 17) {
    paste(base_format, "(Business Hours)")
  } else {
    paste(base_format, "(After Hours)")
  }
})
```

#### `dateOutput()` / `renderDate()`

Date-only rendering (no time component).

**UI Function:**
```r
dateOutput(outputId, placeholder = "Loading...")
```

**Server Function:**
```r
renderDate(expr, format = "%Y-%m-%d", tz = NULL, locale = NULL, show_tz = FALSE)
```

**Arguments:**
- `expr`: Expression returning POSIXct or POSIXlt object
- `format`: Format string (default: "%Y-%m-%d")
- `tz`: Override timezone (defaults to browser timezone)
- `locale`: BCP 47 locale code
- `show_tz`: Whether to append timezone abbreviation (default: FALSE, rarely used for date-only)

**Example:**
```r
# UI
dateOutput("processing_date")

# Server
output$processing_date <- renderDate({
  task_data$completion_date
}, format = "%B %d, %Y")  # "January 20, 2026"
```

#### `timeOutput()` / `renderTime()`

Time-only rendering with optional timezone display.

**UI Function:**
```r
timeOutput(outputId, placeholder = "--:--:--", tz_display = TRUE)
```

**Server Function:**
```r
renderTime(expr, format = "%H:%M:%S", tz = NULL, show_tz = FALSE)
```

**Arguments:**
- `expr`: Expression returning POSIXct or POSIXlt object
- `format`: Format string (default: "%H:%M:%S")
- `tz`: Override timezone (defaults to browser timezone)
- `show_tz`: Whether to append timezone abbreviation (e.g., "EST", "PST") (default: FALSE)

**Example:**
```r
# UI
timeOutput("current_time", tz_display = TRUE)

# Server
output$current_time <- renderTime({
  Sys.time()
}, format = "%I:%M:%S %p", show_tz = TRUE)  # "03:45:23 PM EST"
```

### Utility Functions

#### `get_browser_tz()`

Retrieve the detected browser timezone in server code.

```r
get_browser_tz(session = getDefaultReactiveDomain(), fallback = Sys.timezone())
```

**Arguments:**
- `session`: Shiny session object
- `fallback`: Timezone to use if detection unavailable

**Returns:** Character string (IANA timezone name, e.g., "America/New_York")

**Example:**
```r
server <- function(input, output, session) {
  user_tz <- reactive({
    get_browser_tz(session)
  })
  
  output$debug_info <- renderText({
    paste("Your timezone:", user_tz())
  })
}
```

#### `format_in_tz()`

Format POSIXct/POSIXlt in a specific timezone (helper function).

```r
format_in_tz(datetime, format = "%Y-%m-%d %H:%M:%S", tz = NULL, locale = NULL)
```

**Arguments:**
- `datetime`: POSIXct or POSIXlt object
- `format`: Format string
- `tz`: Target timezone (IANA name)
- `locale`: BCP 47 locale code

**Returns:** Formatted character string

**Example:**
```r
# Format server timestamp in user's timezone
formatted <- format_in_tz(
  Sys.time(),
  format = "%Y-%m-%d %H:%M:%S %Z",
  tz = get_browser_tz(session)
)
```

### UI Widgets

#### `timezoneSelectInput()`

Dropdown selector for timezone with search and common timezone suggestions.

```r
timezoneSelectInput(
  inputId,
  label = "Timezone",
  selected = "auto",
  choices = c("auto", "common", "all"),
  common_zones = c("America/New_York", "America/Chicago", 
                   "America/Denver", "America/Los_Angeles",
                   "Europe/London", "Europe/Paris", "Asia/Tokyo"),
  multiple = FALSE
)
```

**Arguments:**
- `inputId`: Input variable name
- `label`: Display label
- `selected`: Initially selected timezone ("auto" for browser detection)
- `choices`: Scope of timezones ("auto" only, "common" subset, "all" zones)
- `common_zones`: Vector of IANA timezone names for "common" mode
- `multiple`: Allow multiple selection (default FALSE)

**Example:**
```r
# UI
timezoneSelectInput("user_tz", "Display Timezone", selected = "auto")

# Server
output$timestamp <- renderDatetime({
  Sys.time()
}, tz = input$user_tz)  # Respects user's manual selection
```

#### `timezoneInfo()`

Display current timezone information (read-only widget).

```r
timezoneInfo(outputId, show_offset = TRUE, show_abbrev = TRUE)
```

**Arguments:**
- `outputId`: Output variable name
- `show_offset`: Display UTC offset (e.g., "UTC-05:00")
- `show_abbrev`: Display timezone abbreviation (e.g., "EST")

**Example:**
```r
# UI
timezoneInfo("tz_info")

# Displays: "America/New_York (EST, UTC-05:00)"
```

## Implementation Details

### JavaScript Integration

#### Timezone Detection with Validation

Inject JavaScript on app initialization:

```javascript
// inst/www/shinytz.js
$(document).on('shiny:connected', function(event) {
  // Detect browser timezone
  var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  
  // Validate timezone against IANA database (log warnings only)
  // R will handle final validation with fallback
  if (!tz || tz === '') {
    console.warn('shinyTZ: Could not detect browser timezone, server will use fallback');
  }
  
  // Send to server as reactive input
  Shiny.setInputValue('shinytz_browser_tz', tz, {priority: 'event'});
  
  // Also detect locale
  var locale = navigator.language || navigator.userLanguage;
  Shiny.setInputValue('shinytz_browser_locale', locale, {priority: 'event'});
  
  // Detect UTC offset (for display purposes)
  var offset = new Date().getTimezoneOffset();
  Shiny.setInputValue('shinytz_utc_offset', offset, {priority: 'event'});
});
```

#### Client-Side Formatting (Primary Approach)

Client-side formatting using `Intl.DateTimeFormat()` is the **primary** approach for standard formatting. Server-side rendering (using format strings or custom formatters) is available when needed:

```javascript
// Custom output binding for client-side rendering
Shiny.outputBindings.register({
  name: "shinytz.datetime",
  find: function(scope) {
    return $(scope).find('.shinytz-datetime');
  },
  renderValue: function(el, data) {
    // data: {timestamp_ms: <unix epoch ms>, format: "...", locale: "..."}
    var date = new Date(data.timestamp_ms);
    var formatted = new Intl.DateTimeFormat(
      data.locale || undefined,
      JSON.parse(data.format_options)
    ).format(date);
    
    $(el).text(formatted);
  }
});
```

### R Implementation

#### Core Render Functions

```r
#' Render datetime with timezone awareness
#'
#' @param expr Expression returning POSIXct/POSIXlt
#' @param format Format string or preset (default: "%Y-%m-%d %H:%M:%S")
#' @param formatter Optional custom formatter function(datetime, tz) for advanced logic
#' @param tz Override timezone (defaults to browser timezone)
#' @param locale BCP 47 locale code
#' @param show_tz Whether to append timezone abbreviation to output (default: FALSE)
#' @param env Evaluation environment
#' @param quoted Is expr quoted?
#' @export
renderDatetime <- function(expr, format = "%Y-%m-%d %H:%M:%S", 
                           formatter = NULL, tz = NULL, locale = NULL,
                           show_tz = FALSE, env = parent.frame(), quoted = FALSE) {
  
  # Convert expr to function
  func <- shiny::installExprFunction(expr, "func", env, quoted, label = "renderDatetime")
  
  # Return render function using Shiny's standard pattern
  shiny::createRenderFunction(
    func,
    function(value, session, name, ...) {
      # Validation using Shiny's validate()/need() pattern
      shiny::validate(
        shiny::need(!is.null(value), ""),  # Silent validation
        shiny::need(inherits(value, c("POSIXct", "POSIXlt")), 
                    "renderDatetime requires POSIXct or POSIXlt datetime object")
      )
      
      # Determine target timezone
      target_tz <- tz %||% get_browser_tz(session, fallback = Sys.timezone())
      
      # Validate timezone (warn but continue)
      if (!target_tz %in% OlsonNames()) {
        message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
        target_tz <- Sys.timezone()
      }
      
      # Use custom formatter if provided, otherwise use format string
      if (!is.null(formatter)) {
        formatter(value, target_tz)
      } else {
        format_in_tz(value, format = format, tz = target_tz, locale = locale)
      }
    },
    shiny::textOutput,
    list()
  )
}
```

#### Timezone Detection

```r
#' Get browser timezone from session
#'
#' @param session Shiny session object
#' @param fallback Fallback timezone if detection unavailable
#' @export
get_browser_tz <- function(session = shiny::getDefaultReactiveDomain(), 
                           fallback = Sys.timezone()) {
  
  if (is.null(session)) {
    warning("No active Shiny session, using fallback timezone")
    return(fallback)
  }
  
  # Get reactive input from JavaScript
  browser_tz <- session$input$shinytz_browser_tz
  
  if (is.null(browser_tz) || browser_tz == "") {
    return(fallback)
  }
  
  # Validate timezone
  if (!browser_tz %in% OlsonNames()) {
    warning(sprintf("Invalid timezone '%s', using fallback", browser_tz))
    return(fallback)
  }
  
  browser_tz
}
```

#### Formatting Helper

```r
#' Format datetime in specific timezone
#'
#' @param datetime POSIXct or POSIXlt object
#' @param format Format string
#' @param tz Target timezone
#' @param locale BCP 47 locale code (future enhancement)
#' @export
format_in_tz <- function(datetime, format = "%Y-%m-%d %H:%M:%S", 
                         tz = NULL, locale = NULL) {
  
  if (is.null(tz)) tz <- Sys.timezone()
  
  # Convert to target timezone
  datetime_tz <- lubridate::with_tz(datetime, tz)
  
  # Format
  formatted <- format(datetime_tz, format = format)
  
  formatted
}
```

### Output Bindings

```r
#' Datetime output UI element
#'
#' @param outputId Output variable name
#' @param placeholder Placeholder text
#' @param tz_display Show timezone abbreviation
#' @export
datetimeOutput <- function(outputId, placeholder = "Loading...", 
                           tz_display = TRUE) {
  
  # Add JavaScript dependency
  shiny::addResourcePath("shinytz", system.file("www", package = "shinytz"))
  
  shiny::div(
    id = outputId,
    class = "shiny-text-output shinytz-datetime",
    `data-tz-display` = tolower(as.character(tz_display)),
    shiny::tags$script(src = "shinytz/shinytz.js"),
    placeholder
  )
}
```

## Implementation Patterns

### Pattern 1: Preserve Timezone Information

**Always keep datetime objects as POSIXct/POSIXlt throughout reactive logic. Only convert to strings in the final render step.**

```r
# ✅ CORRECT - Timezone preserved
server <- function(input, output, session) {
  timestamp <- reactive({
    # Store with full timezone info
    Sys.time()  # POSIXct with tz attribute
  })
  
  output$display <- renderDatetime({
    timestamp()  # Function handles conversion to user timezone
  })
}

# ❌ INCORRECT - Timezone lost early
server <- function(input, output, session) {
  timestamp <- reactive({
    format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Lost timezone!
  })
  
  output$display <- renderText({
    timestamp()  # Can't convert timezone anymore
  })
}
```

### Pattern 2: Static UI + Reactive Content

**Use static UI structure with reactive content updates. Never use renderUI() for dynamic content that changes frequently.**

```r
# ✅ CORRECT - Static structure, reactive content
ui <- fluidPage(
  div(class = "timezone-display", textOutput("time_content"))
)

server <- function(input, output, session) {
  output$time_content <- renderDatetime({
    Sys.time()
  })
}

# ❌ INCORRECT - Recreates entire structure on every update
ui <- fluidPage(
  uiOutput("time_display")
)

server <- function(input, output, session) {
  output$time_display <- renderUI({
    div(class = "timezone-display", renderDatetime({
      Sys.time()
    }))
  })
}
```

### Pattern 3: Graceful Degradation

**Always provide fallbacks for JavaScript functionality.**

```r
# ✅ CORRECT - Validates and provides fallback
get_browser_tz <- function(session = shiny::getDefaultReactiveDomain(), 
                           fallback = Sys.timezone()) {
  
  if (is.null(session)) {
    warning("No active Shiny session, using fallback timezone")
    return(fallback)
  }
  
  # Get reactive input from JavaScript
  browser_tz <- session$input$shinytz_browser_tz
  
  if (is.null(browser_tz) || browser_tz == "") {
    return(fallback)
  }
  
  # Validate timezone
  if (!browser_tz %in% OlsonNames()) {
    warning(sprintf("Invalid timezone '%s', using fallback", browser_tz))
    return(fallback)
  }
  
  browser_tz
}

# ❌ INCORRECT - No validation or fallback
get_browser_tz <- function(session) {
  session$input$shinytz_browser_tz  # NULL breaks everything!
}
```

### Pattern 4: Multi-Layer Validation

**Use Shiny's validate()/need() pattern for inline error display, with multi-layer validation.**

```r
renderDatetime <- function(expr, ...) {
  func <- installExprFunction(expr, ...)
  
  createRenderFunction(func, function(value, session, name, ...) {
    # Layer 1: Shiny validation for inline display
    validate(
      need(!is.null(value), ""),  # Silent validation
      need(inherits(value, c("POSIXct", "POSIXlt")), 
           "renderDatetime requires POSIXct or POSIXlt datetime object")
    )
    
    # Layer 2: Timezone validation (warns but continues)
    target_tz <- tz %||% get_browser_tz(session)
    
    if (!target_tz %in% OlsonNames()) {
      message(sprintf("Warning: Invalid timezone '%s', using server timezone", target_tz))
      target_tz <- Sys.timezone()
    }
    
    # Format and return
    format_in_tz(value, tz = target_tz, ...)
  }, ...)
}
```

**Validation layers:**
1. **JavaScript**: Log warnings for invalid timezones (don't block)
2. **R Input Validation**: `validate(need())` for NULL/type checking (inline display)
3. **Runtime Warnings**: `message()` for recoverable issues (logs but continues)

### Pattern 5: Database Timestamp Handling

**When fetching datetime columns from database, preserve POSIXct objects and format in render functions.**

```r
# ✅ CORRECT - Format during rendering
server <- function(input, output, session) {
  tasks <- reactive({
    # Returns POSIXct columns
    dbGetQuery(con, "SELECT task_name, start_time, end_time FROM tasks")
  })
  
  # Option 1: Render individual timestamp
  output$task_start <- renderDatetime({
    req(input$selected_task)
    task_row <- tasks()[tasks()$task_name == input$selected_task, ]
    task_row$start_time
  }, format = "%B %d, %Y at %I:%M %p")
  
  # Option 2: Format entire table column
  output$task_table <- renderTable({
    df <- tasks()
    user_tz <- get_browser_tz(session)
    
    df$start_time <- sapply(df$start_time, format_in_tz, 
                            tz = user_tz, format = "%Y-%m-%d %H:%M")
    df
  })
}

# ❌ INCORRECT - Format in SQL query (loses flexibility)
server <- function(input, output, session) {
  tasks <- reactive({
    # Formats as string in SQL - can't change timezone
    dbGetQuery(con, "
      SELECT task_name, 
             TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI:SS') as start_time 
      FROM tasks
    ")
  })
}
```

## Usage Examples

### Example 1: Basic Timestamp Display

```r
library(shiny)
library(shinyTZ)

ui <- fluidPage(
  titlePanel("Task Monitor"),
  
  h4("Last Update:"),
  datetimeOutput("last_update")
)

server <- function(input, output, session) {
  
  # Update every second
  autoInvalidate <- reactiveTimer(1000)
  
  output$last_update <- renderDatetime({
    autoInvalidate()
    Sys.time()  # Automatically shows in user's timezone!
  })
}

shinyApp(ui, server)
```

### Example 2: Task Timeline with Custom Formatting

```r
ui <- fluidPage(
  titlePanel("Pipeline Tasks"),
  
  tableOutput("task_table")
)

server <- function(input, output, session) {
  
  tasks <- reactive({
    # Fetch from database (POSIXct columns)
    dbGetQuery(con, "SELECT task_name, start_time, end_time FROM tasks")
  })
  
  output$task_table <- renderTable({
    df <- tasks()
    
    # Format timestamps in user's timezone
    user_tz <- get_browser_tz(session)
    
    df$start_time <- sapply(df$start_time, function(ts) {
      format_in_tz(ts, format = "%Y-%m-%d %H:%M", tz = user_tz)
    })
    
    df$end_time <- sapply(df$end_time, function(ts) {
      format_in_tz(ts, format = "%Y-%m-%d %H:%M", tz = user_tz)
    })
    
    df
  })
}
```

### Example 3: User-Selectable Timezone

```r
ui <- fluidPage(
  titlePanel("Global Task Monitor"),
  
  sidebarLayout(
    sidebarPanel(
      timezoneSelectInput("display_tz", "Display Timezone", 
                          selected = "auto", choices = "common"),
      timezoneInfo("tz_info")
    ),
    
    mainPanel(
      h4("Current Time:"),
      timeOutput("current_time"),
      
      h4("Next Scheduled Run:"),
      datetimeOutput("next_run")
    )
  )
)

server <- function(input, output, session) {
  
  # Current time updates every second
  autoInvalidate <- reactiveTimer(1000)
  
  output$current_time <- renderTime({
    autoInvalidate()
    Sys.time()
  }, tz = input$display_tz)
  
  # Next scheduled run
  output$next_run <- renderDatetime({
    # Calculate next midnight Eastern time
    as.POSIXct("2026-01-21 00:00:00", tz = "America/New_York")
  }, tz = input$display_tz, format = "%A, %B %d at %I:%M %p")
  
  # Show selected timezone info
  output$tz_info <- renderText({
    tz <- if (input$display_tz == "auto") {
      get_browser_tz(session)
    } else {
      input$display_tz
    }
    
    paste("Displaying times in:", tz)
  })
}
```

### Example 4: Mixed Server/Client Rendering

```r
# For high-frequency updates, send raw timestamp and format client-side
ui <- fluidPage(
  titlePanel("Live Clock"),
  
  # Client-side formatting (no server round-trip)
  uiOutput("live_clock")
)

server <- function(input, output, session) {
  
  output$live_clock <- renderUI({
    # Send JavaScript timestamp, format in browser
    tags$script(HTML(sprintf(
      "setInterval(function() {
         var now = new Date();
         var formatted = now.toLocaleString('%s', {
           timeZone: '%s',
           dateStyle: 'full',
           timeStyle: 'long'
         });
         document.getElementById('clock').innerText = formatted;
       }, 1000);",
      session$input$shinytz_browser_locale,
      get_browser_tz(session)
    )))
    
    div(id = "clock", style = "font-size: 24px; font-weight: bold;")
  })
}
```

## Package Structure

```
shinyTZ/
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── LICENSE
├── NEWS.md
│
├── R/
│   ├── datetime-outputs.R      # datetimeOutput(), dateOutput(), timeOutput()
│   ├── datetime-renders.R      # renderDatetime(), renderDate(), renderTime()
│   ├── timezone-utils.R        # get_browser_tz(), format_in_tz()
│   ├── timezone-widgets.R      # timezoneSelectInput(), timezoneInfo()
│   └── zzz.R                   # .onLoad() for resource paths
│
├── inst/
│   ├── www/
│   │   └── shinytz.js          # Timezone detection JavaScript
│   │
│   └── docs/
│       ├── design-document.md  # This document
│       └── examples/           # Extended examples
│
├── man/                        # roxygen2 documentation
│
└── tests/
    └── testthat/
        ├── test-timezone-detection.R
        ├── test-formatting.R
        └── test-widgets.R
```

## Dependencies

### Required
- `shiny` (>= 1.7.0) - Core Shiny framework
- `lubridate` (>= 1.9.0) - Timezone conversion
- `htmltools` - HTML generation

### Suggested
- `testthat` - Unit testing
- `DBI` - Database examples
- `dplyr` - Data manipulation in examples

## Testing Strategy

### Unit Tests

```r
# tests/testthat/test-formatting.R
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

test_that("renderDatetime validation uses Shiny's validate/need pattern", {
  # Test NULL - should display silently (empty message)
  render_func <- renderDatetime({NULL})
  expect_error(isolate(render_func()), class = "shiny.silent.error")
  
  # Test invalid type - should display helpful error message
  expect_error(
    renderDatetime({"not a datetime"}),
    "renderDatetime requires POSIXct or POSIXlt"
  )
  
  # Test valid POSIXct - should succeed
  ts <- as.POSIXct("2026-01-20 12:00:00", tz = "UTC")
  render_func <- renderDatetime({ts})
  result <- isolate(render_func())
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("renderDatetime handles invalid timezone gracefully", {
  # Mock session with invalid timezone
  session <- list(input = list(shinytz_browser_tz = "Invalid/Timezone"))
  
  # Should fall back to server timezone with warning
  expect_warning(
    get_browser_tz(session),
    "Invalid timezone"
  )
})

test_that("renderDatetime respects custom formatter", {
  custom_formatter <- function(dt, tz) {
    dt_tz <- lubridate::with_tz(dt, tz)
    hour <- lubridate::hour(dt_tz)
    
    base_format <- format(dt_tz, "%Y-%m-%d %I:%M %p")
    
    if (hour >= 9 && hour < 17) {
      paste(base_format, "(Business Hours)")
    } else {
      paste(base_format, "(After Hours)")
    }
  }
  
  # Test business hours
  ts_business <- as.POSIXct("2026-01-20 14:00:00", tz = "America/New_York")
  result <- custom_formatter(ts_business, "America/New_York")
  expect_match(result, "Business Hours")
  
  # Test after hours
  ts_after <- as.POSIXct("2026-01-20 19:00:00", tz = "America/New_York")
  result <- custom_formatter(ts_after, "America/New_York")
  expect_match(result, "After Hours")
})
```

### Integration Tests

```r
# tests/testthat/test-shiny-integration.R
test_that("timezone detection works in Shiny app", {
  library(shinytest2)
  
  app <- AppDriver$new(test_app_path)
  
  # Check that browser timezone was detected
  tz <- app$get_value(input = "shinytz_browser_tz")
  expect_true(tz %in% OlsonNames())
  
  # Check that datetime renders correctly
  output_text <- app$get_value(output = "timestamp")
  expect_match(output_text, "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}")
})

test_that("timezone override works correctly", {
  library(shinytest2)
  
  app <- AppDriver$new(test_app_path)
  
  # Set timezone selector to specific timezone
  app$set_inputs(user_tz = "Asia/Tokyo")
  
  # Verify output reflects selected timezone
  output_text <- app$get_value(output = "timestamp")
  expect_true(!is.null(output_text))
})
```

### Test Coverage Goals

- **Exported functions**: 100% coverage
- **Internal functions**: >80% coverage
- **Edge cases**: NULL, NA, invalid inputs, boundary conditions
- **Timezone conversions**: Multiple timezones with known conversions
- **Graceful degradation**: Fallback behaviors when JavaScript disabled

## Migration Guide

### From Manual Timezone Handling

**Before:**
```r
output$timestamp <- renderText({
  eastern_time <- lubridate::with_tz(Sys.time(), "America/New_York")
  format(eastern_time, "%Y-%m-%d %H:%M:%S %Z")
})
```

**After:**
```r
output$timestamp <- renderDatetime({
  Sys.time()  # Automatically uses browser timezone
})
```

### From Environment Variable Configuration

**Before:**
```r
# app.R
DISPLAY_TZ <- Sys.getenv("DISPLAY_TIMEZONE", unset = Sys.timezone())

# server.R
output$timestamp <- renderText({
  tz_time <- lubridate::with_tz(Sys.time(), DISPLAY_TZ)
  format(tz_time, "%Y-%m-%d %H:%M:%S %Z")
})
```

**After:**
```r
# No configuration needed!
output$timestamp <- renderDatetime({
  Sys.time()
})
```

## Future Enhancements

### Phase 2 Features

1. **Locale-Aware Formatting**: Use `Intl.DateTimeFormat` options for locale-specific date/time formats
   ```r
   renderDatetime({Sys.time()}, locale = "de-DE")
   # Outputs: "20.01.2026, 15:45:23"
   ```

2. **Relative Time Rendering**: "3 minutes ago", "in 2 hours"
   ```r
   renderRelativeTime({task$start_time})
   # Outputs: "Started 45 minutes ago"
   ```

3. **Duration Formatting**: Human-readable durations
   ```r
   renderDuration({task$end_time - task$start_time})
   # Outputs: "2 hours 34 minutes"
   ```

4. **Calendar Widgets**: Timezone-aware date/datetime pickers
   ```r
   datetimeInput("schedule_time", "Scheduled For", timezone = "auto")
   ```

5. **Timezone Conversion Widget**: Display time across multiple timezones
   ```r
   timezoneCompare(c("America/New_York", "Europe/London", "Asia/Tokyo"))
   # Shows current time in all three zones
   ```

### Phase 3 Features

1. **Server-Sent Events (SSE)**: Real-time clock updates without polling
2. **Caching**: Memoize timezone conversions for performance
3. **Accessibility**: ARIA labels for screen readers
4. **Themes**: Bootstrap-compatible styling options

## Open Questions

1. **Server-side vs Client-side Formatting**: Which approach for live updates?
   - Server-side: Simpler, more R-native, but requires reactive updates
   - Client-side: More efficient for high-frequency updates, but requires JavaScript

2. **Locale Integration**: How deeply to integrate with browser locale settings?
   - Auto-detect locale for formatting?
   - Provide locale override options?

3. **Backward Compatibility**: Should we provide migration helpers for existing apps?
   - Auto-detect `renderText()` with POSIXct and suggest `renderDatetime()`?

4. **Database Integration**: Should we provide database-specific helpers?
   - `dbReadDatetime()` that automatically sets timezone attributes?
   - PostgreSQL `TIMESTAMP WITH TIME ZONE` handling?

## References

- MDN: [Intl.DateTimeFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat)
- IANA: [Time Zone Database](https://www.iana.org/time-zones)
- Shiny: [Creating Custom Outputs](https://shiny.rstudio.com/articles/building-outputs.html)
- lubridate: [Working with Timezones](https://lubridate.tidyverse.org/reference/with_tz.html)

## Conclusion

`shinyTZ` solves a common pain point in Shiny development by providing timezone-aware rendering that "just works." The design prioritizes simplicity and zero-configuration while remaining flexible for advanced use cases. By leveraging browser timezone detection and Shiny's reactive model, we can provide a seamless experience for developers and end-users alike.
