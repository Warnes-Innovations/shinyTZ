#' Datetime output UI element
#'
#' Creates a UI element for displaying timezone-aware datetime values.
#' Use with \code{\link{renderDatetime}} in server code.
#'
#' @param outputId Output variable name
#' @param container A function to generate an HTML element to contain the text
#' @param placeholder Placeholder text shown before reactive value available
#' @param tz_display Show timezone abbreviation (default: TRUE)
#' @param inline Use an inline (\code{span()}) or block container (\code{div()})
#'
#' @return Shiny UI output element
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # UI
#' datetimeOutput("last_update")
#' datetimeOutput("inline_time", inline = TRUE)
#'
#' # Server
#' output$last_update <- renderDatetime({
#'   Sys.time()
#' })
#' }
datetimeOutput <- function(outputId, container = if (inline) shiny::span else shiny::div, 
                           placeholder = "Loading...", tz_display = TRUE, inline = FALSE) {
  
  container(
    id = outputId,
    class = "shiny-text-output shinytz-datetime",
    `data-tz-display` = tolower(as.character(tz_display)),
    placeholder
  )
}
