# shinyTZ

Timezone-aware date and time rendering for R Shiny applications.

## Overview

**shinyTZ** extends R Shiny to provide timezone-aware date and time rendering that automatically adapts to each user's browser timezone. It eliminates the common problem of server timestamps being displayed in the wrong timezone for remote users.

### The Problem

Standard Shiny date/time rendering shows timestamps in the server's timezone, which can be confusing for users in different locations:

```r
# Server runs in US/Eastern, user browses from US/Pacific
output$timestamp <- renderText({
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Shows Eastern time!
})
```

### The Solution

shinyTZ provides drop-in replacements that automatically detect and use the browser's timezone:

```r
# Automatically renders in user's local timezone
output$timestamp <- renderDatetime({
  Sys.time()  # Just works!
})
```

## Installation

```r
# Install from GitHub
# install.packages("remotes")
remotes::install_github("gwarnes-mdsol/shinyTZ")
```

## Quick Start

```r
library(shiny)
library(shinyTZ)

ui <- fluidPage(
  titlePanel("Timezone-Aware Timestamps"),
  
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

## Key Features

- **Zero Configuration**: Works out-of-the-box without setup
- **Automatic Detection**: Browser timezone detected via JavaScript
- **Graceful Fallback**: Falls back to server timezone if JavaScript unavailable
- **Flexible Formatting**: Supports strftime format strings and custom formatters
- **Shiny-Native**: Follows Shiny's reactive programming patterns

## Core Functions

### Render Functions

- `renderDatetime()` - Full date and time with timezone awareness
- `renderDate()` - Date-only rendering
- `renderTime()` - Time-only rendering

### Output Functions

- `datetimeOutput()` - UI element for datetime display
- `dateOutput()` - UI element for date display
- `timeOutput()` - UI element for time display

### Utility Functions

- `get_browser_tz()` - Retrieve detected browser timezone
- `format_in_tz()` - Format datetime in specific timezone

## Usage Examples

### Basic Timestamp Display

```r
output$timestamp <- renderDatetime({
  Sys.time()
})
```

### Custom Formatting

```r
output$timestamp <- renderDatetime({
  Sys.time()
}, format = "%B %d, %Y at %I:%M %p")  # "January 20, 2026 at 03:45 PM"
```

### Show Timezone Abbreviation

```r
output$timestamp <- renderDatetime({
  Sys.time()
}, show_tz = TRUE)  # "2026-01-20 15:45:23 EST"
```

### Custom Formatter Function

```r
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

### Database Timestamps

```r
server <- function(input, output, session) {
  
  tasks <- reactive({
    # Returns POSIXct columns
    dbGetQuery(con, "SELECT task_name, start_time, end_time FROM tasks")
  })
  
  output$task_table <- renderTable({
    df <- tasks()
    user_tz <- get_browser_tz(session)
    
    df$start_time <- sapply(df$start_time, format_in_tz, 
                            tz = user_tz, format = "%Y-%m-%d %H:%M")
    df
  })
}
```

## Design Principles

1. **Zero Configuration**: Works out-of-the-box without setup
2. **Transparent**: Minimal changes to existing Shiny code
3. **Reactive**: Integrates seamlessly with Shiny's reactive model
4. **Fallback Safe**: Degrades gracefully if JavaScript unavailable
5. **Flexible**: Supports custom formatting and timezone overrides

## Documentation

- [Design Document](inst/docs/design-document.md) - Complete architectural design and technical specifications
- [Development Guidelines](.github/copilot-instructions.md) - For contributors

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Gregory Warnes <warnes@binghamton.edu>

## Contributing

Contributions welcome! Please see the design document for architectural decisions and guidelines.
