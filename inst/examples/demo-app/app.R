library(shiny)
library(shinyTZ)
library(lubridate)  # For custom formatter examples

# Demo Shiny app showcasing shinyTZ timezone-aware rendering
# Organized from simple to complex across tabs

ui <- fluidPage(
    # Add custom CSS for styling
    tags$head(
        # Include shinyTZ JavaScript
        tags$script(src = "shinytz/shinytz.js"),
        
        tags$style(HTML("
            .info-box {
                background-color: #f8f9fa;
                border: 1px solid #dee2e6;
                border-radius: 5px;
                padding: 15px;
                margin-bottom: 20px;
            }
            .timestamp-display {
                font-size: 18px;
                font-weight: bold;
                color: #0066cc;
                margin: 10px 0;
            }
            .section-title {
                color: #495057;
                border-bottom: 2px solid #dee2e6;
                padding-bottom: 5px;
                margin-top: 20px;
            }
            .code-example {
                background-color: #f4f4f4;
                border-left: 3px solid #0066cc;
                padding: 10px;
                margin: 10px 0;
                font-family: monospace;
                font-size: 13px;
            }
            .level-badge {
                display: inline-block;
                padding: 3px 8px;
                border-radius: 3px;
                font-size: 12px;
                font-weight: bold;
                margin-left: 10px;
            }
            .level-basic { background-color: #d4edda; color: #155724; }
            .level-intermediate { background-color: #fff3cd; color: #856404; }
            .level-advanced { background-color: #f8d7da; color: #721c24; }
        "))
    ),

    titlePanel("shinyTZ Demo: Simple → Complex"),

    sidebarLayout(
        sidebarPanel(
            width = 3,

            div(
                class = "info-box",
                h5("Your Timezone:"),
                textOutput("user_timezone"),
                br(),
                h5("Server Timezone:"),
                textOutput("server_timezone"),
                br(),
                h5("🐛 Debug Info:"),
                p("JS Input:", textOutput("debug_js_input", inline = TRUE)),
                p("UTC Offset:", textOutput("debug_utc_offset", inline = TRUE)),
                p("Locale:", textOutput("debug_locale", inline = TRUE))
            ),
            
            div(
                class = "info-box",
                h5("Manual Timezone Override:"),
                selectInput("manual_tz", "Choose timezone:",
                    choices = c("Auto-detect" = "",
                              "America/New_York" = "America/New_York",
                              "America/Chicago" = "America/Chicago",
                              "America/Denver" = "America/Denver",
                              "America/Los_Angeles" = "America/Los_Angeles",
                              "Europe/London" = "Europe/London",
                              "Europe/Paris" = "Europe/Paris",
                              "Asia/Tokyo" = "Asia/Tokyo",
                              "Asia/Shanghai" = "Asia/Shanghai",
                              "Australia/Sydney" = "Australia/Sydney"),
                    selected = ""),
                helpText("Select a timezone to override browser detection")
            ),

            hr(),

            h5("Live Update Control"),
            sliderInput(
                "refresh_rate",
                "Update interval (seconds):",
                min = 1, max = 10, value = 2, step = 1
            ),

            hr(),

            h5("Navigation Guide"),
            p(strong("Level 1:"), "Basic drop-in replacements"),
            p(strong("Level 2:"), "Custom formatting options"),
            p(strong("Level 3:"), "Advanced customization"),
            p(strong("Level 4:"), "Before/After comparison")
        ),

        mainPanel(
            width = 9,

            tabsetPanel(
                id = "demo_tabs",

                # TAB 1: Basic Usage (Simple)
                tabPanel(
                    title = HTML("Level 1: Basic<span class='level-badge level-basic'>SIMPLE</span>"),
                    value = "basic",

                    br(),
                    h3("🎯 Basic Usage: Drop-In Replacements"),
                    p("The simplest use case - just replace standard Shiny outputs with shinyTZ equivalents."),
                    p(strong("Zero configuration required!"), "The package automatically detects each user's timezone."),

                    fluidRow(
                        hr(),
                        h4("📋 Example Code:"),
                        div(
                            class = "code-example",
                            "# UI", br(),
                            "datetimeOutput('timestamp')", br(),
                            br(),
                            "# Server", br(),
                            "output$timestamp <- renderDatetime({", br(),
                            "  Sys.time()", br(),
                            "})"
                        ),

                        hr(),
                        h4("🕐 Live Demo:"),

                        fluidRow(
                            column(
                                4,
                                div(
                                    class = "info-box",
                                    h5("Full Datetime:"),
                                    p("renderDatetime()"),
                                    datetimeOutput("basic_datetime")
                                )
                            ),
                            column(
                                4,
                                div(
                                    class = "info-box",
                                    h5("Date Only:"),
                                    p("renderDate()"),
                                    dateOutput("basic_date")
                                )
                            ),
                            column(
                                4,
                                div(
                                    class = "info-box",
                                    h5("Time Only:"),
                                    p("renderTime()"),
                                    timeOutput("basic_time")
                                )
                            )
                        ),

                        hr(),
                        div(
                            class = "info-box",
                            h5("✨ What's Happening:"),
                            tags$ul(
                                tags$li("Your browser's timezone is automatically detected"),
                                tags$li("All timestamps are converted to YOUR local time"),
                                tags$li("No manual configuration needed!"),
                                tags$li("Falls back to server timezone if JavaScript unavailable")
                            )
                        )
                    )
                ),

                # TAB 2: Custom Formatting (Intermediate)
                tabPanel(
                    title = HTML("Level 2: Formatting<span class='level-badge level-intermediate'>INTERMEDIATE</span>"),
                    value = "formatting",

                    br(),
                    h3("🎨 Custom Formatting Options"),
                    p("Control how timestamps are displayed using standard strftime format strings."),

                    hr(),
                    h4("📋 Example Code:"),
                    div(
                        class = "code-example",
                        "renderDatetime({", br(),
                        "  Sys.time()", br(),
                        "}, format = '%B %d, %Y at %I:%M %p')"
                    ),

                    hr(),
                    h4("🎯 Common Format Examples:"),

                    fluidRow(
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("Long Format:"),
                                code("%A, %B %d, %Y at %I:%M:%S %p"),
                                br(), br(),
                                datetimeOutput("fmt_long")
                            )
                        ),
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("ISO 8601:"),
                                code("%Y-%m-%dT%H:%M:%S"),
                                br(), br(),
                                datetimeOutput("fmt_iso")
                            )
                        )
                    ),

                    fluidRow(
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("12-Hour Time:"),
                                code("%I:%M:%S %p"),
                                br(), br(),
                                datetimeOutput("fmt_12hour")
                            )
                        ),
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("Short Date:"),
                                code("%m/%d/%Y"),
                                br(), br(),
                                datetimeOutput("fmt_short")
                            )
                        )
                    ),

                    hr(),
                    h4("🏷️ Show Timezone Abbreviation:"),
                    p("Use the", code("show_tz"), "parameter to append timezone abbreviation."),

                    div(
                        class = "code-example",
                        "renderDatetime({", br(),
                        "  Sys.time()", br(),
                        "}, show_tz = TRUE)  # Adds 'EST', 'PST', etc."
                    ),

                    fluidRow(
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("Without Timezone:"),
                                datetimeOutput("fmt_no_tz")
                            )
                        ),
                        column(
                            6,
                            div(
                                class = "info-box",
                                h5("With Timezone:"),
                                datetimeOutput("fmt_with_tz")
                            )
                        )
                    ),

                    hr(),
                    div(
                        class = "info-box",
                        h5("💡 Common Format Codes:"),
                        tags$ul(
                            tags$li(code("%Y"), "= 4-digit year (2026)"),
                            tags$li(code("%m"), "= Month number (01-12)"),
                            tags$li(code("%d"), "= Day of month (01-31)"),
                            tags$li(code("%H"), "= Hour 24-hour (00-23)"),
                            tags$li(code("%I"), "= Hour 12-hour (01-12)"),
                            tags$li(code("%M"), "= Minute (00-59)"),
                            tags$li(code("%S"), "= Second (00-59)"),
                            tags$li(code("%p"), "= AM/PM"),
                            tags$li(code("%A"), "= Full weekday name"),
                            tags$li(code("%B"), "= Full month name")
                        )
                    )
                ),

                # TAB 3: Advanced Features (Advanced)
                tabPanel(
                    title = HTML("Level 3: Advanced<span class='level-badge level-advanced'>ADVANCED</span>"),
                    value = "advanced",

                    br(),
                    h3("🚀 Advanced Customization"),

                    h4("1️⃣ Custom Formatter Functions"),
                    p("For complex formatting logic, use a custom formatter function."),

                    div(
                        class = "code-example",
                        "renderDatetime({", br(),
                        "  Sys.time()", br(),
                        "}, formatter = function(dt, tz) {", br(),
                        "  dt_tz <- lubridate::with_tz(dt, tz)", br(),
                        "  hour <- lubridate::hour(dt_tz)", br(),
                        "  ", br(),
                        "  base <- format(dt_tz, '%Y-%m-%d %I:%M %p')", br(),
                        "  ", br(),
                        "  if (hour >= 9 && hour < 17) {", br(),
                        "    paste(base, '(Business Hours)')", br(),
                        "  } else {", br(),
                        "    paste(base, '(After Hours)')", br(),
                        "  }", br(),
                        "})"
                    ),

                    div(
                        class = "info-box",
                        h5("Business Hours Indicator:"),
                        datetimeOutput("adv_business_hours")
                    ),

                    hr(),
                    h4("2️⃣ Timezone Override"),
                    p("Force a specific timezone instead of using the browser's detected timezone."),

                    div(
                        class = "code-example",
                        "renderDatetime({", br(),
                        "  Sys.time()", br(),
                        "}, tz = 'America/New_York')  # Always show in ET"
                    ),

                    fluidRow(
                        column(
                            4,
                            div(
                                class = "info-box",
                                h5("New York (ET):"),
                                datetimeOutput("adv_ny")
                            )
                        ),
                        column(
                            4,
                            div(
                                class = "info-box",
                                h5("London (GMT):"),
                                datetimeOutput("adv_london")
                            )
                        ),
                        column(
                            4,
                            div(
                                class = "info-box",
                                h5("Tokyo (JST):"),
                                datetimeOutput("adv_tokyo")
                            )
                        )
                    ),

                    hr(),
                    h4("3️⃣ Database Timestamp Example"),
                    p("Format timestamps from database queries in user's timezone."),

                    div(
                        class = "code-example",
                        "# Simulated database query", br(),
                        "db_timestamp <- as.POSIXct('2026-01-20 14:30:00', tz = 'UTC')", br(),
                        "", br(),
                        "output$db_time <- renderDatetime({", br(),
                        "  db_timestamp", br(),
                        "})"
                    ),

                    div(
                        class = "info-box",
                        h5("Database Timestamps (stored in UTC, displayed in your timezone):"),
                        tableOutput("adv_db_table")
                    ),

                    hr(),
                    h4("4️⃣ Helper Function: get_browser_tz()"),
                    p("Access the detected timezone directly for custom logic."),

                    div(
                        class = "code-example",
                        "user_tz <- get_browser_tz(session)", br(),
                        "# Use in your custom logic"
                    ),

                    div(
                        class = "info-box",
                        h5("Detected Timezone Info:"),
                        verbatimTextOutput("adv_tz_info")
                    )
                ),

                # TAB 4: Before/After Comparison
                tabPanel(
                    title = HTML("Level 4: Comparison"),
                    value = "comparison",

                    br(),
                    h3("⚖️ Before & After: Why shinyTZ Matters"),

                    p(
                        strong("The Problem:"), "Standard Shiny displays timestamps in the server's timezone,",
                        "which can be confusing for users in different time zones."
                    ),
                    p(strong("The Solution:"), "shinyTZ automatically detects and converts to each user's local timezone."),

                    hr(),

                    fluidRow(
                        column(
                            6,
                            div(
                                class = "info-box",
                                style = "border-left: 4px solid #dc3545;",
                                h4("❌ WITHOUT shinyTZ"),
                                p(em("Using standard Shiny renderText()")),
                                hr(),
                                div(
                                    class = "code-example",
                                    "output$time <- renderText({", br(),
                                    "  format(Sys.time(), '%Y-%m-%d %H:%M:%S %Z')", br(),
                                    "})"
                                ),
                                hr(),
                                h5("Current Time:"),
                                div(
                                    style = "font-size: 16px; padding: 10px; background-color: #f8d7da;",
                                    textOutput("compare_before")
                                ),
                                br(),
                                p(
                                    strong("Problem:"), "Shows server timezone (", textOutput("server_tz_inline", inline = TRUE),
                                    ") to all users regardless of their location! 😞"
                                )
                            )
                        ),
                        column(
                            6,
                            div(
                                class = "info-box",
                                style = "border-left: 4px solid #28a745;",
                                h4("✅ WITH shinyTZ"),
                                p(em("Using shinyTZ renderDatetime()")),
                                hr(),
                                div(
                                    class = "code-example",
                                    "output$time <- renderDatetime({", br(),
                                    "  Sys.time()", br(),
                                    "}, show_tz = TRUE)"
                                ),
                                hr(),
                                h5("Current Time:"),
                                div(
                                    style = "font-size: 16px; padding: 10px; background-color: #d4edda;",
                                    datetimeOutput("compare_after")
                                ),
                                br(),
                                p(
                                    strong("Solution:"), "Automatically shows YOUR timezone (", textOutput("user_tz_inline", inline = TRUE),
                                    ")! 🎉"
                                )
                            )
                        )
                    ),

                    hr(),
                    h4("🌍 Real-World Impact:"),
                    div(
                        class = "info-box",
                        tags$ul(
                            tags$li(strong("For Users:"), "See timestamps in their local time without mental conversion"),
                            tags$li(strong("For Developers:"), "No need to manually handle timezone conversions"),
                            tags$li(strong("For Teams:"), "Reduced confusion when coordinating across time zones"),
                            tags$li(strong("For Support:"), "Fewer questions about 'why is the time wrong?'")
                        )
                    ),

                    hr(),
                    h4("📊 Side-by-Side Table Comparison:"),
                    p("Same timestamps from a hypothetical database, displayed both ways:"),
                    tableOutput("compare_table")
                )
            )
        )
    )
)

server <- function(input, output, session) {
    # Reactive timer for live updates
    autoInvalidate <- reactive({
        invalidateLater(input$refresh_rate * 1000)
        Sys.time()
    })

    # Sidebar timezone displays  
    output$user_timezone <- renderText({
        # Use manual override if selected, otherwise browser detection
        if (!is.null(input$manual_tz) && input$manual_tz != "") {
            paste0(input$manual_tz, " (manual)")
        } else {
            get_browser_tz(session, fallback = "Not detected yet...")
        }
    })
    
    output$server_timezone <- renderText({
        Sys.timezone()
    })
    
    # Debug outputs
    output$debug_js_input <- renderText({
        input$shinytz_browser_tz %||% "NULL"
    })
    
    output$debug_utc_offset <- renderText({
        input$shinytz_utc_offset %||% "NULL"
    })
    
    output$debug_locale <- renderText({
        input$shinytz_browser_locale %||% "NULL"
    })
    
    # Helper to get effective timezone (manual override or browser)
    effective_timezone <- reactive({
        if (!is.null(input$manual_tz) && input$manual_tz != "") {
            input$manual_tz
        } else {
            get_browser_tz(session, fallback = Sys.timezone())
        }
    })

    # === TAB 1: BASIC USAGE ===
    output$basic_datetime <- renderDatetime({
        autoInvalidate()
    })

    output$basic_date <- renderDate({
        autoInvalidate()
    })

    output$basic_time <- renderTime({
        autoInvalidate()
    })

    # === TAB 2: CUSTOM FORMATTING ===
    output$fmt_long <- renderDatetime({
        autoInvalidate()
    }, format = "%A, %B %d, %Y at %I:%M:%S %p")

    output$fmt_iso <- renderDatetime({
        autoInvalidate()
    }, format = "%Y-%m-%dT%H:%M:%S")

    output$fmt_12hour <- renderDatetime({
        autoInvalidate()
    }, format = "%I:%M:%S %p")

    output$fmt_short <- renderDatetime({
        autoInvalidate()
    }, format = "%m/%d/%Y")

    output$fmt_no_tz <- renderDatetime({
        autoInvalidate()
    }, show_tz = FALSE)

    output$fmt_with_tz <- renderDatetime({
        autoInvalidate()
    }, show_tz = TRUE)

    # === TAB 3: ADVANCED FEATURES ===
    output$adv_business_hours <- renderDatetime({
        autoInvalidate()
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

    output$adv_ny <- renderDatetime({
        autoInvalidate()
    }, tz = "America/New_York", show_tz = TRUE)

    output$adv_london <- renderDatetime({
        autoInvalidate()
    }, tz = "Europe/London", show_tz = TRUE)

    output$adv_tokyo <- renderDatetime({
        autoInvalidate()
    }, tz = "Asia/Tokyo", show_tz = TRUE)

    output$adv_db_table <- renderTable({
        data.frame(
            Event = c("Pipeline Started", "Data Processing", "Analysis Complete", "Report Generated"),
            "UTC Timestamp" = c(
                "2026-01-20 08:30:00", "2026-01-20 10:15:00",
                "2026-01-20 14:45:00", "2026-01-20 16:20:00"
            ),
            "Your Local Time" = sapply(c(
                as.POSIXct("2026-01-20 08:30:00", tz = "UTC"),
                as.POSIXct("2026-01-20 10:15:00", tz = "UTC"),
                as.POSIXct("2026-01-20 14:45:00", tz = "UTC"),
                as.POSIXct("2026-01-20 16:20:00", tz = "UTC")
            ), function(ts) {
                format_in_tz(ts, format = "%Y-%m-%d %I:%M %p", tz = effective_timezone())
            }),
            check.names = FALSE,
            stringsAsFactors = FALSE
        )
    })

    output$adv_tz_info <- renderPrint({
        cat("Detected Browser Timezone:", input$shinytz_browser_tz %||% "NULL", "\n")
        cat("Effective Timezone:", effective_timezone(), "\n")
        cat("Server Timezone:", Sys.timezone(), "\n")
        cat("Current Server Time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")
    })

    # === TAB 4: COMPARISON ===
    output$compare_before <- renderText({
        format(autoInvalidate(), "%Y-%m-%d %H:%M:%S %Z")
    })

    output$compare_after <- renderDatetime({
        autoInvalidate()
    }, show_tz = TRUE)

    output$server_tz_inline <- renderText({
        Sys.timezone()
    })

    output$user_tz_inline <- renderText({
        effective_timezone()
    })

    output$compare_table <- renderTable({
        sample_times <- c(
            as.POSIXct("2026-01-20 09:00:00", tz = "UTC"),
            as.POSIXct("2026-01-20 14:30:00", tz = "UTC"),
            as.POSIXct("2026-01-20 21:45:00", tz = "UTC")
        )

        data.frame(
            Event = c("Morning Meeting", "Afternoon Report", "Evening Update"),
            "Standard Shiny" = sapply(sample_times, function(t) {
                format(lubridate::with_tz(t, Sys.timezone()), "%Y-%m-%d %I:%M %p %Z")
            }),
            "With shinyTZ" = sapply(sample_times, function(t) {
                format_in_tz(t, format = "%Y-%m-%d %I:%M %p", tz = effective_timezone())
            }),
            check.names = FALSE,
            stringsAsFactors = FALSE
        )
    })
}

shinyApp(ui, server)
