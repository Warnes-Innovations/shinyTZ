# Agent Skill: JavaScript Integration

## Purpose
Guide JavaScript/R integration patterns for timezone detection and other browser-side features in Shiny applications.

## When to Use
- Adding JavaScript timezone detection to Shiny apps
- Implementing browser-side data collection
- Creating custom JavaScript/Shiny message handlers
- Building client-side rendering features

## Core Pattern: Browser Timezone Detection

### Step 1: JavaScript Detection

Create `inst/www/shinytz.js`:

```javascript
// Detect browser timezone on initial connection
$(document).on('shiny:connected', function(event) {
  // Get IANA timezone name
  var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  
  // Send to server as reactive input
  Shiny.setInputValue('shinytz_browser_tz', tz, {priority: 'event'});
  
  // Optional: Also detect locale
  var locale = navigator.language || navigator.userLanguage;
  Shiny.setInputValue('shinytz_browser_locale', locale, {priority: 'event'});
  
  // Optional: Get UTC offset in minutes
  var offset = new Date().getTimezoneOffset();
  Shiny.setInputValue('shinytz_utc_offset', offset, {priority: 'event'});
});
```

**Key points:**
- Use `shiny:connected` event for initialization
- `Intl.DateTimeFormat()` is widely supported (IE 11+)
- `{priority: 'event'}` ensures immediate delivery to server
- Prefix input names to avoid conflicts (`shinytz_`)

### Step 2: Load JavaScript in R

In `.onLoad()` or package initialization:

```r
# R/zzz.R
.onLoad <- function(libname, pkgname) {
  # Add resource path for JavaScript files
  shiny::addResourcePath(
    "shinytz",
    system.file("www", package = "shinytz")
  )
}
```

In UI function or output binding:

```r
datetimeOutput <- function(outputId, ...) {
  shiny::div(
    id = outputId,
    # Include JavaScript dependency
    shiny::tags$script(src = "shinytz/shinytz.js"),
    ...
  )
}
```

### Step 3: Access in R Server Code

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
  
  # Handle NULL (JavaScript not loaded yet or disabled)
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

**Key points:**
- Always provide fallback for NULL values
- Validate browser-provided data (not all timezones in OlsonNames())
- Use `getDefaultReactiveDomain()` to get session automatically
- Return server timezone as sensible default

## Advanced Pattern: Client-Side Rendering

For high-frequency updates (e.g., live clocks), format on client:

### Custom Output Binding

```javascript
// inst/www/shinytz-binding.js
Shiny.outputBindings.register({
  name: "shinytz.datetime",
  
  find: function(scope) {
    return $(scope).find('.shinytz-datetime');
  },
  
  renderValue: function(el, data) {
    // data = {timestamp_ms: <unix epoch>, format_options: {...}}
    
    if (data === null) {
      $(el).text("");
      return;
    }
    
    var date = new Date(data.timestamp_ms);
    
    // Use Intl.DateTimeFormat for locale-aware formatting
    var formatted = new Intl.DateTimeFormat(
      data.locale || undefined,
      data.format_options || {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZoneName: 'short'
      }
    ).format(date);
    
    $(el).text(formatted);
  }
});
```

### R Render Function

```r
renderDatetimeClient <- function(expr, locale = NULL, format_options = NULL) {
  func <- shiny::exprToFunction(expr, parent.frame(), quoted = FALSE)
  
  function() {
    datetime <- func()
    
    if (is.null(datetime) || all(is.na(datetime))) {
      return(NULL)
    }
    
    # Send timestamp as milliseconds since epoch
    list(
      timestamp_ms = as.numeric(datetime) * 1000,
      locale = locale,
      format_options = format_options
    )
  }
}
```

**When to use:**
- Live clocks or frequently updating timestamps (> 1 update/second)
- Want to leverage user's locale settings automatically
- Reduce server load for many concurrent users

**When NOT to use:**
- Infrequent updates (server-side is simpler)
- Need precise control over formatting
- Supporting very old browsers

## Graceful Degradation

### Always Provide Fallbacks

```r
# ✅ CORRECT - Multiple fallback layers
get_browser_tz <- function(session, fallback = Sys.timezone()) {
  browser_tz <- session$input$shinytz_browser_tz
  
  # Layer 1: JavaScript not loaded/disabled
  if (is.null(browser_tz) || browser_tz == "") {
    return(fallback)
  }
  
  # Layer 2: Invalid timezone name
  if (!browser_tz %in% OlsonNames()) {
    warning(sprintf("Invalid timezone '%s', using fallback", browser_tz))
    return(fallback)
  }
  
  # Layer 3: Validate makes sense
  # (some corporate proxies might inject weird values)
  if (nchar(browser_tz) > 50) {
    warning("Suspiciously long timezone name, using fallback")
    return(fallback)
  }
  
  browser_tz
}

# ❌ INCORRECT - No fallback for JavaScript disabled
get_browser_tz <- function(session) {
  session$input$shinytz_browser_tz  # NULL breaks everything!
}
```

### Check for Reactive Context

```r
# ✅ CORRECT - Safe outside reactive context
browser_tz <- reactive({
  if (is.null(session$input$shinytz_browser_tz)) {
    Sys.timezone()
  } else {
    session$input$shinytz_browser_tz
  }
})

# Use in renders
output$time <- renderText({
  format(
    lubridate::with_tz(Sys.time(), browser_tz()),
    "%H:%M:%S %Z"
  )
})
```

## Data Validation

### Validate All Browser Data

Browser-provided data is untrusted:

```r
validate_browser_locale <- function(locale, fallback = "en-US") {
  if (is.null(locale) || locale == "") {
    return(fallback)
  }
  
  # BCP 47 locale format: language[-script][-region]
  if (!grepl("^[a-z]{2,3}(-[A-Z][a-z]{3})?(-[A-Z]{2})?$", locale)) {
    warning(sprintf("Invalid locale '%s', using fallback", locale))
    return(fallback)
  }
  
  locale
}

validate_browser_tz <- function(tz, fallback = Sys.timezone()) {
  if (is.null(tz) || tz == "") return(fallback)
  if (!tz %in% OlsonNames()) return(fallback)
  if (nchar(tz) > 50) return(fallback)  # Sanity check
  
  tz
}
```

## Sending Data from R to JavaScript

### Use jsonlite for Safe Encoding

```r
# ✅ CORRECT - Safe JSON encoding
send_config <- function(session, config) {
  session$sendCustomMessage(
    type = "shinytz-config",
    message = jsonlite::toJSON(config, auto_unbox = TRUE)
  )
}

# JavaScript receives:
Shiny.addCustomMessageHandler("shinytz-config", function(message) {
  var config = JSON.parse(message);
  // Use config...
});
```

### Escape User-Provided Strings

```r
# ✅ CORRECT - Escape HTML
output$user_message <- renderUI({
  HTML(htmltools::htmlEscape(user_input))
})

# ❌ INCORRECT - XSS vulnerability
output$user_message <- renderUI({
  HTML(user_input)  # Dangerous!
})
```

## Checklist

Before finalizing JavaScript integration:

- [ ] JavaScript loaded via addResourcePath()
- [ ] Timezone detection on 'shiny:connected' event
- [ ] Reactive input created with {priority: 'event'}
- [ ] R function has NULL fallback
- [ ] Browser data validated before use
- [ ] Works without JavaScript (graceful degradation)
- [ ] User-provided data escaped if rendered as HTML
- [ ] Using jsonlite::toJSON() for complex data structures

## Common Mistakes

1. **No fallback for NULL** → Always check `is.null()` and provide default
2. **Trusting browser data** → Validate timezone in OlsonNames()
3. **Missing resource path** → JavaScript won't load without addResourcePath()
4. **Wrong event** → Use 'shiny:connected', not $(document).ready()
5. **XSS vulnerabilities** → Use htmlEscape() for user content
6. **Race conditions** → Check for NULL in reactive context
7. **Invalid JSON** → Use jsonlite, not paste() or sprintf()
