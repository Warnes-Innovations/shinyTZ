# Agent Skill: Shiny UI Patterns

## Purpose
Guide implementation of Shiny UI components that update efficiently without flickering, lost scroll position, or performance degradation.

## When to Use
- Creating or modifying Shiny UI components with dynamic content
- Converting renderUI()-based code to more efficient patterns
- Implementing reactive displays with frequent updates
- Troubleshooting UI flickering or performance issues

## Core Principle

**Static Structure + Reactive Content**

UI structure should be created once. Only content should update reactively.

## Anti-Pattern: renderUI() for Content Updates

### ❌ INCORRECT - Recreates entire UI on every update

```r
# UI
uiOutput("dynamic_section")

# Server - BAD: Recreates entire structure
output$dynamic_section <- renderUI({
  div(
    class = "log-terminal",
    style = "height: 400px; overflow-y: auto;",
    h4("Log Output"),
    div(id = "log_content", read_log_file())
  )
})
```

**Problems:**
- Entire div recreated on every reactive change
- Scroll position lost
- CSS classes/styles reapplied
- Event handlers re-bound
- Memory overhead from DOM churn

### ✅ CORRECT - Static structure, reactive content

```r
# UI - Created once
div(
  class = "log-terminal",
  style = "height: 400px; overflow-y: auto;",
  h4("Log Output"),
  htmlOutput("log_content")  # Only this updates
)

# Server - GOOD: Only content updates
output$log_content <- renderUI({
  HTML(read_log_file())
})
```

## Update Patterns

### Pattern 1: Use Specific Render Functions

**For text content:**
```r
# UI
textOutput("timestamp")

# Server
output$timestamp <- renderText({
  format(Sys.time(), "%H:%M:%S")
})
```

**For formatted HTML:**
```r
# UI
htmlOutput("formatted_content")

# Server
output$formatted_content <- renderUI({
  HTML(sprintf("<strong>Status:</strong> %s", status))
})
```

**For plots:**
```r
# UI
plotOutput("my_plot")

# Server
output$my_plot <- renderPlot({
  ggplot(data(), aes(x, y)) + geom_point()
})
```

### Pattern 2: Use updateXXX() Functions

For input widgets that need dynamic updates:

```r
# Update select input choices
observeEvent(input$state, {
  counties <- get_counties_for_state(input$state)
  updateSelectInput(session, "county", choices = counties)
})

# Update slider range
observeEvent(data(), {
  range <- range(data()$value, na.rm = TRUE)
  updateSliderInput(session, "filter", min = range[1], max = range[2])
})

# Update checkbox group
observeEvent(input$category, {
  options <- get_options_for_category(input$category)
  updateCheckboxGroupInput(session, "options", choices = options)
})
```

### Pattern 3: Use shinyjs for DOM Manipulation

For show/hide, enable/disable, or CSS updates:

```r
library(shinyjs)

# Show/hide elements
observeEvent(input$advanced, {
  if (input$advanced) {
    shinyjs::show("advanced_options")
  } else {
    shinyjs::hide("advanced_options")
  }
})

# Enable/disable inputs
observeEvent(input$enable_submit, {
  if (valid_input()) {
    shinyjs::enable("submit_button")
  } else {
    shinyjs::disable("submit_button")
  }
})

# Update CSS classes
observeEvent(status(), {
  shinyjs::removeClass("status_indicator", "status-error status-success")
  if (status() == "error") {
    shinyjs::addClass("status_indicator", "status-error")
  } else {
    shinyjs::addClass("status_indicator", "status-success")
  }
})
```

### Pattern 4: Reactive Triggers for Content-Only Updates

When you need to control update timing:

```r
# Create reactive trigger
rv <- reactiveValues(trigger = 0)

# Force update
observeEvent(input$refresh, {
  rv$trigger <- rv$trigger + 1
})

# Use trigger as dependency
output$content <- renderText({
  rv$trigger  # Depend on trigger
  fetch_latest_data()
})
```

## Special Case: Timezone-Aware Rendering

### Keep POSIXct Objects, Convert Late

```r
# ✅ CORRECT - Preserve timezone info
server <- function(input, output, session) {
  timestamp <- reactive({
    Sys.time()  # POSIXct with timezone
  })
  
  output$display <- renderDatetime({
    timestamp()  # Conversion happens in render
  })
}

# ❌ INCORRECT - Early string conversion
server <- function(input, output, session) {
  timestamp <- reactive({
    format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Lost timezone!
  })
  
  output$display <- renderText({
    timestamp()  # Can't convert timezone anymore
  })
}
```

### Use Reactive Inputs for JavaScript-Detected Values

```r
# JavaScript sends timezone
# $(document).on('shiny:connected', function(event) {
#   var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
#   Shiny.setInputValue('browser_tz', tz);
# });

server <- function(input, output, session) {
  browser_tz <- reactive({
    input$browser_tz %||% Sys.timezone()  # Fallback
  })
  
  output$time <- renderText({
    format(
      lubridate::with_tz(Sys.time(), browser_tz()),
      "%Y-%m-%d %H:%M:%S %Z"
    )
  })
}
```

## Checklist

Before finalizing Shiny UI code:

- [ ] UI structure created once (not in renderUI)
- [ ] Only content updates reactively
- [ ] Using specific render functions (renderText, renderPlot, etc.)
- [ ] updateXXX() functions for input widget updates
- [ ] shinyjs for DOM manipulation where appropriate
- [ ] Reactive triggers control update timing
- [ ] POSIXct objects preserved until final rendering
- [ ] Fallbacks for JavaScript-dependent values

## Common Mistakes

1. **renderUI() for frequently updating content** → Use renderText/renderUI with static wrapper
2. **Recreating entire tables** → Use DT::replaceData() or updateXXX()
3. **Early datetime formatting** → Keep POSIXct, format in render function
4. **Missing NULL checks for JavaScript inputs** → Always provide fallbacks
5. **No reactive isolation** → Use isolate() to prevent unnecessary updates
