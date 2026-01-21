library(shiny)
library(shinyTZ)

# Demo Shiny app showcasing shinyTZ timezone-aware rendering

ui <- fluidPage(
  
  # Add custom CSS for styling
  tags$head(
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
    "))
  ),
  
  titlePanel("shinyTZ Demo: Timezone-Aware Rendering"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      h4("About This Demo"),
      p("This app demonstrates automatic timezone-aware rendering using the shinyTZ package."),
      
      div(class = "info-box",
          h5("Your Timezone:"),
          textOutput("user_timezone"),
          br(),
          h5("Server Timezone:"),
          textOutput("server_timezone")
      ),
      
      hr(),
      
      h5("Refresh Rate"),
      sliderInput("refresh_rate", 
                  "Update interval (seconds):",
                  min = 1, max = 10, value = 2, step = 1),
      
      hr(),
      
      h5("Documentation"),
      p("Functions used:"),
      tags$ul(
        tags$li(tags$code("renderDatetime()")),
        tags$li(tags$code("renderDate()")),
        tags$li(tags$code("renderTime()")),
        tags$li(tags$code("get_browser_tz()"))
      )
    ),
    
    mainPanel(
      width = 9,
      
      # Live Clock Section
      h3(class = "section-title", "Live Clock"),
      p("Current time updated in real-time (automatic timezone detection):"),
      div(class = "timestamp-display",
          datetimeOutput("live_datetime")
      ),
      
      fluidRow(
        column(6,
               div(class = "info-box",
                   h5("Date Only:"),
                   dateOutput("live_date")
               )
        ),
        column(6,
               div(class = "info-box",
                   h5("Time Only:"),
                   timeOutput("live_time")
               )
        )
      ),
      
      # Custom Formatting Section
      h3(class = "section-title", "Custom Formatting"),
      
      fluidRow(
        column(6,
               div(class = "info-box",
                   h5("Long Format with Timezone:"),
                   datetimeOutput("formatted_long")
               )
        ),
        column(6,
               div(class = "info-box",
                   h5("12-Hour Format:"),
                   datetimeOutput("formatted_12hour")
               )
        )
      ),
      
      fluidRow(
        column(6,
               div(class = "info-box",
                   h5("Show Timezone Abbreviation:"),
                   datetimeOutput("with_tz_display")
               )
        ),
        column(6,
               div(class = "info-box",
                   h5("ISO 8601 Format:"),
                   datetimeOutput("iso_format")
               )
        )
      ),
      
      # Simulated Database Timestamps
      h3(class = "section-title", "Simulated Database Timestamps"),
      p("Examples of timestamps that might come from a database:"),
      
      tableOutput("timestamp_table"),
      
      # Comparison Section
      h3(class = "section-title", "Before & After Comparison"),
      
      fluidRow(
        column(6,
               div(class = "info-box",
                   h5("❌ Before shinyTZ (Server Timezone):"),
                   p("Shows time in server's timezone (confusing for remote users):"),
                   textOutput("before_shinytz")
               )
        ),
        column(6,
               div(class = "info-box",
                   h5("✅ After shinyTZ (User's Timezone):"),
                   p("Automatically shows time in user's local timezone:"),
                   datetimeOutput("after_shinytz")
               )
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
  
  # Display user's detected timezone
  output$user_timezone <- renderText({
    user_tz <- get_browser_tz(session, fallback = "Not detected")
    paste0(user_tz)
  })
  
  # Display server timezone
  output$server_timezone <- renderText({
    Sys.timezone()
  })
  
  # Live clock - full datetime
  output$live_datetime <- renderDatetime({
    autoInvalidate()
  }, format = "%Y-%m-%d %H:%M:%S", show_tz = TRUE)
  
  # Live clock - date only
  output$live_date <- renderDate({
    autoInvalidate()
  }, format = "%A, %B %d, %Y")
  
  # Live clock - time only
  output$live_time <- renderTime({
    autoInvalidate()
  }, format = "%I:%M:%S %p", show_tz = TRUE)
  
  # Custom formatted timestamps
  output$formatted_long <- renderDatetime({
    autoInvalidate()
  }, format = "%A, %B %d, %Y at %I:%M:%S %p")
  
  output$formatted_12hour <- renderDatetime({
    autoInvalidate()
  }, format = "%I:%M:%S %p")
  
  output$with_tz_display <- renderDatetime({
    autoInvalidate()
  }, show_tz = TRUE)
  
  output$iso_format <- renderDatetime({
    autoInvalidate()
  }, format = "%Y-%m-%dT%H:%M:%S")
  
  # Simulated database timestamps
  output$timestamp_table <- renderTable({
    # Simulate database query results with timestamps
    data.frame(
      Event = c(
        "Pipeline Started",
        "Data Processing",
        "Analysis Complete",
        "Report Generated"
      ),
      Timestamp = sapply(c(
        as.POSIXct("2026-01-20 08:30:00", tz = "UTC"),
        as.POSIXct("2026-01-20 10:15:00", tz = "UTC"),
        as.POSIXct("2026-01-20 14:45:00", tz = "UTC"),
        as.POSIXct("2026-01-20 16:20:00", tz = "UTC")
      ), function(ts) {
        format_in_tz(ts, 
                     format = "%Y-%m-%d %I:%M %p", 
                     tz = get_browser_tz(session))
      }),
      stringsAsFactors = FALSE
    )
  })
  
  # Before shinyTZ (shows server timezone)
  output$before_shinytz <- renderText({
    format(autoInvalidate(), "%Y-%m-%d %H:%M:%S %Z")
  })
  
  # After shinyTZ (shows user's timezone)
  output$after_shinytz <- renderDatetime({
    autoInvalidate()
  }, show_tz = TRUE)
}

shinyApp(ui, server)
