# shinyTZ Demo App

This demo application showcases the timezone-aware rendering capabilities of the shinyTZ package.

## Running the Demo

From R:

```r
# Install shinyTZ first if not already installed
# remotes::install_github("gwarnes-mdsol/shinyTZ")

# Run the demo
shiny::runApp(system.file("examples/demo-app", package = "shinyTZ"))
```

From the command line:

```bash
cd /path/to/shinyTZ/inst/examples/demo-app
Rscript app.R
```

## Features Demonstrated

1. **Live Clock** - Real-time updates showing current date/time in user's timezone
2. **Custom Formatting** - Various strftime format examples
3. **Timezone Display** - Optional timezone abbreviation (`show_tz` parameter)
4. **Database Timestamps** - Example of formatting timestamps from database queries
5. **Before/After Comparison** - Side-by-side comparison of standard Shiny vs shinyTZ rendering

## What to Notice

- The app automatically detects your browser's timezone via JavaScript
- All timestamps are displayed in YOUR local timezone, not the server's
- The "Before shinyTZ" example shows what standard Shiny does (server timezone)
- The "After shinyTZ" example shows automatic timezone adaptation
- No manual timezone configuration required!

## Key Functions Used

- `renderDatetime()` - Full date and time rendering
- `renderDate()` - Date-only rendering
- `renderTime()` - Time-only rendering
- `datetimeOutput()`, `dateOutput()`, `timeOutput()` - UI elements
- `get_browser_tz()` - Retrieve detected browser timezone
- `format_in_tz()` - Format timestamps in specific timezone

## Browser Compatibility

Requires a modern browser with `Intl.DateTimeFormat()` support:
- Chrome/Edge 24+
- Firefox 29+
- Safari 10+
- Internet Explorer 11+
