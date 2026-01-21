#' Include shinyTZ JavaScript in Shiny UI
#'
#' This function must be called from within the UI of a Shiny app to enable
#' automatic timezone detection. It loads the JavaScript code that detects
#' the browser's timezone and sends it to the server.
#'
#' @return An HTML tag object that should be included in the Shiny UI
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(shiny)
#' library(shinyTZ)
#'
#' ui <- fluidPage(
#'   useShinyTZ(),  # Enable timezone detection
#'   
#'   h3("Current Time:"),
#'   datetimeOutput("current_time")
#' )
#'
#' server <- function(input, output, session) {
#'   output$current_time <- renderDatetime({
#'     Sys.time()
#'   })
#' }
#'
#' shinyApp(ui, server)
#' }
useShinyTZ <- function() {
  # Ensure resource path is registered (redundant with .onLoad but safer)
  shiny::addResourcePath(
    "shinytz",
    system.file("www", package = "shinyTZ")
  )
  
  # Use singleton to ensure script is only included once
  shiny::singleton(
    shiny::tags$head(
      shiny::tags$script(src = "shinytz/shinytz.js")
    )
  )
}
